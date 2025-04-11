#include <windows.h>
#include <stdio.h>
#include <iostream>

/*
Balatro.exe Imports
.idata:00000001400031F8                 extrn __imp_luaopen_love:qword
.idata:00000001400031F8                                         ; DATA XREF: luaopen_love↑r
.idata:00000001400031F8                                         ; .rdata:0000000140003CA0↓o
.idata:0000000140003200                 extrn __imp_love_codename:qword
.idata:0000000140003200                                         ; DATA XREF: love_codename↑r
.idata:0000000140003208 ; __declspec(dllimport) int love::luax_resume(struct lua_State *, int, int *)
.idata:0000000140003208                 extrn __imp_?luax_resume@love@@YAHPEAUlua_State@@HPEAH@Z:qword
.idata:0000000140003208                                         ; DATA XREF: love::luax_resume(lua_State *,int,int *)↑r
.idata:0000000140003210                 extrn __imp_love_version:qword
.idata:0000000140003210                                         ; DATA XREF: love_version↑r
.idata:0000000140003218                 extrn __imp_luaopen_love_jitsetup:qword
.idata:0000000140003218                                         ; DATA XREF: luaopen_love_jitsetup↑r
.idata:0000000140003220                 extrn __imp_love_openConsole:qword
.idata:0000000140003220                                         ; DATA XREF: love_openConsole↑r
*/

/*
love.dll exports
Could be wrong because IDA

dd rva luaopen_love
__int64 __fastcall luaopen_love(__int64 a1)

dd rva love_codename
char *love_codename()

dd rva ?luax_resume@love@@YAHPEAUlua_State@@HPEAH@Z
int __fastcall love::luax_resume(love *this, struct lua_State *a2, int a3, int *a4)

rva love_version
const char *love_version()

dd rva luaopen_love_jitsetup
__int64 __fastcall luaopen_love_jitsetup(__int64 a1)


dd rva love_openConsole
char __fastcall love_openConsole(const char **a1)
*/


typedef unsigned __int64 _QWORD;
typedef unsigned char _BYTE, *_PBYTE, *_LPBYTE;

const char* a115 = "11.5";
const char* aRestart = "restart";


typedef __int64 (*LuaOpenLoveFunction)(__int64);
typedef char* (*LoveCodenameFunction)();
typedef int (*LoveLuaxResumeFunction)(void*, void*, int, int*);
typedef const char* (*LoveVersionFunction)();
typedef __int64 (*LuaOpenLoveJitSetupFunction)(__int64);
typedef char (*LoveOpenConsoleFunction)(const char**);

int main(int argc, char** argv) {

    #pragma region Load DLL
    HMODULE lovedll = LoadLibraryA("C:/Users/camps/Projects/Balatro/old_love.dll");

    if (lovedll == NULL)
    {
        std::cerr << "Failed to load DLL" << std::endl;
        return 1;
    }

    LuaOpenLoveFunction luaopen_love = (LuaOpenLoveFunction)GetProcAddress(lovedll, "luaopen_love");
    if(luaopen_love == NULL)
    {
        std::cerr << "Failed to locate luaopen_love function" << std::endl;
        FreeLibrary(lovedll);
        return 1;
    }

    LoveCodenameFunction love_codename = (LoveCodenameFunction)GetProcAddress(lovedll, "love_codename");
    if(love_codename == NULL)
    {
        std::cerr << "Failed to locate love_codename function" << std::endl;
        FreeLibrary(lovedll);
        return 1;
    }

    LoveLuaxResumeFunction love_luax_resume = (LoveLuaxResumeFunction)GetProcAddress(lovedll, "?luax_resume@love@@YAHPEAUlua_State@@HPEAH@Z");
    if(love_luax_resume == NULL)
    {
        std::cerr << "Failed to locate love_luax_resume function" << std::endl;
        FreeLibrary(lovedll);
        return 1;
    }

    LoveVersionFunction love_version = (LoveVersionFunction)GetProcAddress(lovedll, "love_version");
    if(love_version == NULL)
    {
        std::cerr << "Failed to locate love_version function" << std::endl;
        FreeLibrary(lovedll);
        return 1;
    }

    LuaOpenLoveJitSetupFunction luaopen_love_jitsetup = (LuaOpenLoveJitSetupFunction)GetProcAddress(lovedll, "luaopen_love_jitsetup");
    if(luaopen_love_jitsetup == NULL)
    {
        std::cerr << "Failed to locate luaopen_love_jitsetup function" << std::endl;
        FreeLibrary(lovedll);
        return 1;
    }

    LoveOpenConsoleFunction love_openConsole = (LoveOpenConsoleFunction)GetProcAddress(lovedll, "love_openConsole");
    if(love_openConsole == NULL)
    {
        std::cerr << "Failed to locate love_openConsole function" << std::endl;
        FreeLibrary(lovedll);
        return 1;
    }

    #pragma endregion
    std::cout << "Hey Mom, I'm a DLL function being called!" << std::endl;
    std::cout << "Love Version: " << love_version() << std::endl;
    std::cout << "Love Codename: " << love_codename() << std::endl;

    const char* errorMessage;
    char result = love_openConsole(&errorMessage);
    if (result == 0) {
        std::cerr << "Failed to open console: " << errorMessage << std::endl;
    } else {
        std::cout << "Console opened successfully" << std::endl;
    }

    FreeLibrary(lovedll);
    std::cout << "Ended execution" << std::endl;
    return 0;

// // IDA Start
//   const char* v4; // rax
//   __int64 v5; // r9
//   char v6; // r8
//   struct lua_State *lua_State; // rbx
//   int v8; // edi
//   _QWORD *v9; // rsi
//   int v10; // edi
//   int v11; // eax
//   unsigned int v12; // esi
//   int v13; // edi
//   __int64 v14; // rax
//   __int64 v15; // rcx
//   char v16; // dl
//   bool v17; // zf
//   const char *v18; // rbx
//   const char *v19; // rax
//   const char *v21; // rax
//   int v22; // [rsp+60h] [rbp+18h] BYREF
//   __int64 v23; // [rsp+68h] [rbp+20h] BYREF

//   v4 = love_version();
//   v5 = 0i64;
//   do
//   {
//     v6 = a115[v5++];
//     if ( v6 != *(_BYTE *)(v4 + v5 - 1) )
//     {
//       v21 = (const char *)love_version();
//       printf("Version mismatch detected!\nLOVE binary is version %s\nLOVE library is version %s\n", "11.5", v21);
//       return 1i64;
//     }
//   }
//   while ( v5 != 5 );
//   while ( argc <= 1 || strcmp((const char *)argv[1], "--version") )
//   {
//     lua_State = (struct lua_State *)luaL_newstate();
//     luaL_openlibs(lua_State);
//     lua_getfield(lua_State, 0xFFFFD8EEi64, "package");
//     lua_getfield(lua_State, 0xFFFFFFFFi64, "preload");
//     lua_pushcclosure(lua_State, &luaopen_love_jitsetup, 0i64);
//     lua_setfield(lua_State, 0xFFFFFFFEi64, "love.jitsetup");
//     lua_settop(lua_State, 0xFFFFFFFDi64);
//     lua_getfield(lua_State, 0xFFFFD8EEi64, "require");
//     lua_pushstring(lua_State, "love.jitsetup");
//     lua_call(lua_State, 1i64, 0i64);
//     lua_getfield(lua_State, 0xFFFFD8EEi64, "package");
//     lua_getfield(lua_State, 0xFFFFFFFFi64, "preload");
//     lua_pushcclosure(lua_State, &luaopen_love, 0i64);
//     lua_setfield(lua_State, 0xFFFFFFFEi64, "love");
//     lua_settop(lua_State, 0xFFFFFFFDi64);
//     lua_createtable(lua_State, 0i64, 0i64);
//     if ( argc > 0 )
//     {
//       lua_pushstring(lua_State, *argv);
//       lua_rawseti(lua_State, 0xFFFFFFFEi64, 0xFFFFFFFEi64);
//     }
//     lua_pushstring(lua_State, "embedded boot.lua");
//     lua_rawseti(lua_State, 0xFFFFFFFEi64, 0xFFFFFFFFi64);
//     v8 = 1;
//     if ( argc > 1 )
//     {
//       v9 = argv + 1;
//       do
//       {
//         lua_pushstring(lua_State, *v9);
//         lua_rawseti(lua_State, 0xFFFFFFFEi64, (unsigned int)v8++);
//         ++v9;
//       }
//       while ( v8 < argc );
//     }
//     lua_setfield(lua_State, 0xFFFFD8EEi64, "arg");
//     lua_getfield(lua_State, 0xFFFFD8EEi64, "require");
//     lua_pushstring(lua_State, "love");
//     lua_call(lua_State, 1i64, 1i64);
//     lua_pushboolean(lua_State, 1i64);
//     lua_setfield(lua_State, 0xFFFFFFFEi64, "_exe");
//     lua_settop(lua_State, 0xFFFFFFFEi64);
//     lua_getfield(lua_State, 0xFFFFD8EEi64, "require");
//     lua_pushstring(lua_State, "love.boot");
//     lua_call(lua_State, 1i64, 1i64);
//     lua_newthread(lua_State);
//     lua_pushvalue(lua_State, 0xFFFFFFFEi64);
//     v10 = lua_gettop(lua_State);
//     while ( love::luax_resume(lua_State, 0, &v22) == 1 )
//     {
//       v11 = lua_gettop(lua_State);
//       lua_settop(lua_State, (unsigned int)(v10 - v11 - 1));
//     }
//     v12 = 0;
//     v13 = 0;
//     if ( (unsigned int)lua_type(lua_State, 0xFFFFFFFFi64) == 4 )
//     {
//       v14 = lua_tolstring(lua_State, 0xFFFFFFFFi64, 0i64);
//       v15 = 0i64;
//       while ( 1 )
//       {
//         v16 = *(_BYTE *)(v14 + v15++);
//         v17 = v16 == aRestart[v15 - 1];
//         if ( v16 != aRestart[v15 - 1] )
//           break;
//         if ( v15 == 8 )
//         {
//           v17 = v16 == aRestart[7];
//           break;
//         }
//       }
//       if ( v17 )
//         v13 = 1;
//     }
//     if ( (unsigned int)lua_isnumber(lua_State, 0xFFFFFFFFi64) )
//       v12 = (int)lua_tonumber(lua_State, 0xFFFFFFFFi64);
//     lua_close(lua_State);
//     if ( !v13 )
//       return v12;
//   }
//   v23 = 0i64;
//   love_openConsole(&v23);
//   v18 = (const char *)love_codename();
//   v19 = (const char *)love_version();
//   printf("LOVE %s (%s)\n", v19, v18);
//   return 0;
}