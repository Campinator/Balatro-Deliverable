calculate_score = function(highlightedCards, unhighlightedCards)
    if #highlightedCards == 0 then
        return 0
    end
    
    local text,disp_text,poker_hands,scoring_hand,non_loc_disp_text = G.FUNCS.get_poker_hand_info(highlightedCards)

    --Add all the pure bonus cards to the scoring hand
    local pures = {}
    for i=1, #highlightedCards do
        if next(find_joker('Splash')) then  --Count all cards when using Splash joker
            scoring_hand[i] = highlightedCards[i]
        else
            if highlightedCards[i].ability.effect == 'Stone Card' then
                local inside = false
                for j=1, #scoring_hand do
                    if scoring_hand[j] == highlightedCards[i] then
                        inside = true
                    end
                end
                if not inside then table.insert(pures, highlightedCards[i]) end --Add stones cards to scoring hand is not already added
            end
        end
    end
    for i=1, #pures do
        table.insert(scoring_hand, pures[i])
    end
    table.sort(scoring_hand, function (a, b) return a.T.x < b.T.x end ) --Sort scoring hand

    if not G.GAME.blind:debuff_hand(highlightedCards, poker_hands, text) then --Debuff hand blinds work differently below
        mult = mod_mult(G.GAME.hands[text].mult) --Calculate mult and chips for base hand type
        hand_chips = mod_chips(G.GAME.hands[text].chips)

        local modded = false --Handles blinds that modify hand
        mult, hand_chips, modded = G.GAME.blind:modify_hand(G.play.cards, poker_hands, text, mult, hand_chips)
        mult, hand_chips = mod_mult(mult), mod_chips(hand_chips)

        for i=1, #scoring_hand do
            --add cards played to list
            if scoring_hand[i].ability.effect ~= 'Stone Card' then
                G.GAME.cards_played[scoring_hand[i].base.value].total = G.GAME.cards_played[scoring_hand[i].base.value].total + 1
                G.GAME.cards_played[scoring_hand[i].base.value].suits[scoring_hand[i].base.suit] = true 
            end
            --if card is debuffed
            if scoring_hand[i].debuff then
                --Debuff animations would go here, but since we're just calculating score they are removed
            else
                --Check for play doubling
                local reps = {1}
                
                --From Red seal
                local eval = eval_card(scoring_hand[i], {repetition_only = true,cardarea = G.play, full_hand = highlightedCards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, repetition = true})
                if next(eval) then 
                    for h = 1, eval.seals.repetitions do
                        reps[#reps+1] = eval
                    end
                end
                --From jokers
                for j=1, #G.jokers.cards do
                    --calculate the joker effects
                    local eval = eval_card(G.jokers.cards[j], {cardarea = G.play, full_hand = highlightedCards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_card = scoring_hand[i], repetition = true})
                    if next(eval) and eval.jokers then 
                        for h = 1, eval.jokers.repetitions do
                            reps[#reps+1] = eval
                        end
                    end
                end
                for j=1,#reps do 
                    --calculate the hand effects
                    local effects = {eval_card(scoring_hand[i], {cardarea = G.play, full_hand = highlightedCards, scoring_hand = scoring_hand, poker_hand = text})}
                    for k=1, #G.jokers.cards do
                        --calculate the joker individual card effects
                        local eval = G.jokers.cards[k]:calculate_joker({cardarea = G.play, full_hand = highlightedCards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_card = scoring_hand[i], individual = true})
                        if eval then 
                            table.insert(effects, eval)
                        end
                    end
                    scoring_hand[i].lucky_trigger = nil

                    for ii = 1, #effects do
                        --If chips added, do chip add event and add the chips to the total
                        if effects[ii].chips then 
                            hand_chips = mod_chips(hand_chips + effects[ii].chips)
                            --Many visual effects were cut out here and in the following sections
                        end

                        --If mult added, do mult add event and add the mult to the total
                        if effects[ii].mult then 
                            mult = mod_mult(mult + effects[ii].mult)
                        end

                        --Dollar additions are skipped for score calculation

                        --Any extra effects
                        if effects[ii].extra then 
                            local extras = {mult = false, hand_chips = false}
                            if effects[ii].extra.mult_mod then mult =mod_mult( mult + effects[ii].extra.mult_mod);extras.mult = true end
                            if effects[ii].extra.chip_mod then hand_chips = mod_chips(hand_chips + effects[ii].extra.chip_mod);extras.hand_chips = true end
                            if effects[ii].extra.swap then 
                                local old_mult = mult
                                mult = mod_mult(hand_chips)
                                hand_chips = mod_chips(old_mult)
                                extras.hand_chips = true; extras.mult = true
                            end
                            if effects[ii].extra.func then effects[ii].extra.func() end --Not sure what this does, may need to remove if there are side effects
                        end

                        --If x_mult added, do mult add event and mult the mult to the total
                        if effects[ii].x_mult then
                            mult = mod_mult(mult*effects[ii].x_mult)
                        end

                        --calculate the card edition effects
                        if effects[ii].edition then
                            hand_chips = mod_chips(hand_chips + (effects[ii].edition.chip_mod or 0))
                            mult = mult + (effects[ii].edition.mult_mod or 0)
                            mult = mod_mult(mult*(effects[ii].edition.x_mult_mod or 1))
                        end
                    end
                end
            end
        end
            for i=1, #unhighlightedCards do --Handle effects on/from unplayed cards
                --Check for hand doubling
                local reps = {1}
                local j = 1
                while j <= #reps do
                    --calculate the hand effects
                    local effects = {eval_card(unhighlightedCards[i], {cardarea = G.hand, full_hand = highlightedCards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands})}

                    for k=1, #G.jokers.cards do
                        --calculate the joker individual card effects
                        local eval = G.jokers.cards[k]:calculate_joker({cardarea = G.hand, full_hand = highlightedCards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_card = unhighlightedCards[i], individual = true})
                        if eval then
                            table.insert(effects, eval)
                        end
                    end

                    if reps[j] == 1 then 
                        --Check for hand doubling

                        --From Red seal
                        local eval = eval_card(unhighlightedCards[i], {repetition_only = true,cardarea = G.hand, full_hand = highlightedCards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, repetition = true, card_effects = effects})
                        if next(eval) and (next(effects[1]) or #effects > 1) then 
                            for h  = 1, eval.seals.repetitions do
                                reps[#reps+1] = eval
                            end
                        end

                        --From Joker
                        for j=1, #G.jokers.cards do
                            --calculate the joker effects
                            local eval = eval_card(G.jokers.cards[j], {cardarea = G.hand, full_hand = highlightedCards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_card = unhighlightedCards[i], repetition = true, card_effects = effects})
                            if next(eval) then 
                                for h  = 1, eval.jokers.repetitions do
                                    reps[#reps+1] = eval
                                end
                            end
                        end
                    end
    
                    for ii = 1, #effects do
                        --If hold mult added, do hold mult add event and add the mult to the total
                        if effects[ii].h_mult then
                            mult = mod_mult(mult + effects[ii].h_mult)
                        end

                        if effects[ii].x_mult then
                            mult = mod_mult(mult*effects[ii].x_mult)
                        end
                    end
                    j = j +1
                end
            end
        --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        --Joker Effects
        --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
        for i=1, #G.jokers.cards + #G.consumeables.cards do
            local _card = G.jokers.cards[i] or G.consumeables.cards[i - #G.jokers.cards]
            --calculate the joker edition effects
            local edition_effects = eval_card(_card, {cardarea = G.jokers, full_hand = highlightedCards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, edition = true})
            if edition_effects.jokers then
                edition_effects.jokers.edition = true
                if edition_effects.jokers.chip_mod then
                    hand_chips = mod_chips(hand_chips + edition_effects.jokers.chip_mod)
                end
                if edition_effects.jokers.mult_mod then
                    mult = mod_mult(mult + edition_effects.jokers.mult_mod)
                end
            end

            --calculate the joker effects
            local effects = eval_card(_card, {cardarea = G.jokers, full_hand = highlightedCards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, joker_main = true})

            --Any Joker effects
            if effects.jokers then 
                local extras = {mult = false, hand_chips = false}
                if effects.jokers.mult_mod then mult = mod_mult(mult + effects.jokers.mult_mod);extras.mult = true end
                if effects.jokers.chip_mod then hand_chips = mod_chips(hand_chips + effects.jokers.chip_mod);extras.hand_chips = true end
                if effects.jokers.Xmult_mod then mult = mod_mult(mult*effects.jokers.Xmult_mod);extras.mult = true  end
            end

            --Joker on Joker effects
            for _, v in ipairs(G.jokers.cards) do
                local effect = v:calculate_joker{full_hand = highlightedCards, scoring_hand = scoring_hand, scoring_name = text, poker_hands = poker_hands, other_joker = _card}
                if effect then
                    local extras = {mult = false, hand_chips = false}
                    if effect.mult_mod then mult = mod_mult(mult + effect.mult_mod);extras.mult = true end
                    if effect.chip_mod then hand_chips = mod_chips(hand_chips + effect.chip_mod);extras.hand_chips = true end
                    if effect.Xmult_mod then mult = mod_mult(mult*effect.Xmult_mod);extras.mult = true  end
                end
            end

            if edition_effects.jokers then
                if edition_effects.jokers.x_mult_mod then
                    mult = mod_mult(mult*edition_effects.jokers.x_mult_mod)
                end
            end
        end

        local nu_chip, nu_mult = G.GAME.selected_back:trigger_effect{context = 'final_scoring_step', chips = hand_chips, mult = mult}
        mult = mod_mult(nu_mult or mult)
        hand_chips = mod_chips(nu_chip or hand_chips)

        --Destroyed card stuff went here before, was removed since that is unnecessary for the calculator

    else
        mult = mod_mult(0)
        hand_chips = mod_chips(0)
    end

    local calculated_score = mult * hand_chips
    return calculated_score
end

function tableContains(table, value)
    for i = 1,#table do
        if (table[i] == value) then
            return true
        end
    end
    return false
end

function doCardTablesMatch(table1, table2)
    if #table1 ~= #table2 then
        return false
    end

    for i = 1, #table1 do
        if table1[i].base.value ~= table2[i].base.value or table1[i].base.suit ~= table2[i].base.suit then
            return false
        end
    end

    return true
end

function copyTable(source)
    local copy = {}
    for i = 1, #source do
        table.insert(copy, source[i])
    end
    return copy
end

function get_cards_by_index(highlightedIndexes)
    local highlightedCards = {}
    local unhighlightedCards = {}
    for i = 1, #G.hand.cards do
        if tableContains(highlightedIndexes, i) then
            table.insert(highlightedCards, G.hand.cards[i])
        else
            table.insert(unhighlightedCards, G.hand.cards[i])
        end
    end
    return highlightedCards, unhighlightedCards
end

function card_table_to_string(cards)
    if cards == nil or #cards == 0 then
        return "None"
    end
    
    local cardString = ""
    for i = 1, #cards - 1 do
        cardString = cardString .. cards[i].base.value .. " of " .. cards[i].base.suit .. ", "
    end
    cardString = cardString .. cards[#cards].base.value .. " of " .. cards[#cards].base.suit
    return cardString
end

function is_optimal_by_indexes(indexes, optimal_hand, optimal_score)
    local highlighted, unhighlighted = get_cards_by_index(indexes)
    local score = calculate_score(highlighted, unhighlighted)
    if (score > optimal_score) then
        return highlighted, score
    else
        if score == optimal_score and #highlighted < #optimal_hand then
            return highlighted, score
        else
            return optimal_hand, optimal_score
        end
    end
end

function get_optimal_hand()
    local optimal_hand = {}
    local optimal_hand_string = "None"
    local optimal_hand_type = "None"
    local optimal_score = 0

    --Try all possible combinations of cards
    for c1 = 1, #G.hand.cards do
        optimal_hand, optimal_score = is_optimal_by_indexes({c1}, optimal_hand, optimal_score)
        for c2 = c1 + 1, #G.hand.cards do
            optimal_hand, optimal_score = is_optimal_by_indexes({c1, c2}, optimal_hand, optimal_score)
            for c3 = c2 + 1, #G.hand.cards do
                optimal_hand, optimal_score = is_optimal_by_indexes({c1, c2, c3}, optimal_hand, optimal_score)
                for c4 = c3 + 1, #G.hand.cards do
                    optimal_hand, optimal_score = is_optimal_by_indexes({c1, c2, c3, c4}, optimal_hand, optimal_score)
                    for c5 = c4 + 1, #G.hand.cards do
                        optimal_hand, optimal_score = is_optimal_by_indexes({c1, c2, c3, c4, c5}, optimal_hand, optimal_score)
                    end
                end
            end
        end
    end

    --Get hand string and hand type of optimal hand
    optimal_hand_string = card_table_to_string(optimal_hand)
    local text,disp_text,poker_hands,scoring_hand,non_loc_disp_text = G.FUNCS.get_poker_hand_info(optimal_hand)
    optimal_hand_type = disp_text

    return optimal_hand, optimal_hand_string, optimal_hand_type, optimal_score
end

function force_hand_to(cards, silent)
    G.hand:unhighlight_all()
    for i = 1, #cards do
        G.hand:add_to_highlighted(cards[i], silent)
    end
end

function all_king_of_spades(cards)
    for i = 1, #cards do
        cards[i].base.value = 'King'
        cards[i].base.nominal = 10
        cards[i].base.face_nominal = 0.3
        cards[i].base.id = 13
        cards[i].base.suit = 'Spades'
        cards[i].base.suit_nominal = 0.04
        cards[i].base.suit_nominal_original = 0.004
        cards[i]:set_sprites(G.P_CENTERS.j_card_sharp, nil)
    end
end