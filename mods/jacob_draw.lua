	--Find highlighted cards
	local highlighted_cards = "Undefined"
	if G.hand then
		if G.hand.highlighted ~= nil then
			highlighted_cards = card_table_to_string(G.hand.highlighted)
		end
	end

	--Get current hand type
	local hand_type = "Undefined"
	if G.hand then
		if G.hand.highlighted ~= nil then
			local text,disp_text,poker_hands,scoring_hand,non_loc_disp_text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
			if disp_text ~= "ERROR" then
				hand_type = disp_text
			else
				hand_type = "None"
			end
		end
	end

	--Calculate current hand score
	local calculated_score = 0
	if G.hand then
		if G.hand.highlighted ~= nil then
			local highlightedCards = G.hand.highlighted
			local unhighlightedCards = {}
			for i=1, #G.hand.cards do
				if not G.hand.cards[i].highlighted then 
					table.insert(unhighlightedCards, G.hand.cards[i])
				end
			end
			calculated_score = calculate_score(highlightedCards, unhighlightedCards)
		end
	end

	--Refresh optimal score if hand has changed
	if G.hand then
		if G.hand.cards ~= nil and #G.hand.cards > 0 then 
			local match = doCardTablesMatch(G.prev_hand, G.hand.cards)	
			if (match == false) then
				G.prev_hand = copyTable(G.hand.cards)
				G.optimal_hand, G.optimal_hand_string, G.optimal_hand_type, G.optimal_score = get_optimal_hand()
			end
		end
	end

	--Print info
	love.graphics.print(string.format("Current Hand: %s", highlighted_cards), 10, 10)
	love.graphics.print(string.format("Current Hand Type: %s", hand_type), 10, 30)
	love.graphics.print(string.format("Predicted Score: %s", calculated_score), 10, 50)

	love.graphics.print(string.format("Optimal Hand: %s", G.optimal_hand_string), 10, 80)
	love.graphics.print(string.format("Optimal Hand Type: %s", G.optimal_hand_type), 10, 100)
	love.graphics.print(string.format("Optimal Score: %s", G.optimal_score), 10, 120)
	
	--Force highlight the optimal hand when J is pressed
	if love.keyboard.isDown("j") then
		if G.hand then
			if G.hand.highlighted ~= nil then
				if #G.optimal_hand > 0 then
					if highlighted_cards ~= G.optimal_hand_string then
						G.played_hand = false
						force_hand_to(G.optimal_hand, false)
					end
				end
			end
		end
	end

	--Force play highlighted cards when K is pressed
	if love.keyboard.isDown("k") then
		if G.hand then
			if G.hand.highlighted ~= nil then
				if #G.hand.highlighted > 0 then
					if G.played_hand == false then
						G.FUNCS.play_cards_from_highlighted()
						G.played_hand = true
					end
				end
			end
		end
	end

	--Force play highlighted cards when K is pressed
	if love.keyboard.isDown("l") then
		if G.hand then
			if G.hand.cards ~= nil then
				all_king_of_spades(G.hand.cards)
				G.prev_hand = {}
			end
		end
	end
