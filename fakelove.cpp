#define UNICODE
#include <windows.h>
#include <stdio.h>



// #include <windows.h>

// // Function prototype for the replacement function
// extern "C" __declspec(dllexport) const char* love_version();

// // Function pointer type for the original function
// typedef const char* (*OriginalFunction)();

// // Pointer to the original function
// OriginalFunction original_love_version = nullptr;

// // Replacement function
// const char* love_version() {
//     // Implement your replacement logic here
//     return "My Version"; // Example replacement
// }

// // Entry point
// BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
//     OutputDebugStringW(L"Hello, World from DllMain!");
//     switch (ul_reason_for_call) {
//     case DLL_PROCESS_ATTACH:
//         // Load the original DLL
//         HMODULE hOriginalDLL = LoadLibraryA("original_love.dll");
//         if (hOriginalDLL != NULL) {
//             // Get the address of the original function
//             original_love_version = (OriginalFunction)GetProcAddress(hOriginalDLL, "love_version");
//         }
//         break;
//     case DLL_PROCESS_DETACH:
//         // Free resources
//         if (hOriginalDLL != NULL) {
//             FreeLibrary(hOriginalDLL);
//         }
//         break;
//     }
//     return TRUE;
// }

// // Forward function calls to the original DLL
// extern "C" __declspec(dllexport) const char* love_version_proxy() {
//     OutputDebugStringW(L"Hello, World from love_version_proxy!");
//     if (original_love_version != nullptr) {
//         return original_love_version();
//     }
//     return nullptr;
// }






__declspec(dllexport) BOOL DllMain(HINSTANCE, DWORD, LPVOID);

namespace love {
    __declspec(dllexport) int luax_resume(void*, void*, int, int*);
}

// imports in Balatro.exe from love.dll
__declspec(dllexport) __int64 luaopen_love();
__declspec(dllexport) char* love_codename(void);
__declspec(dllexport) const char* love_version(void);
__declspec(dllexport) __int64 luaopen_love_jitsetup(__int64);
__declspec(dllexport) char love_openConsole(const char **);




__declspec(dllexport) BOOL DllMain(HINSTANCE hinstDLL, DWORD fdwReason, LPVOID lpvReserved) {
    OutputDebugStringW(L"Hello, World from DllMain!");
    if ( fdwReason == 1 )
        DisableThreadLibraryCalls(hinstDLL);
    return 1;
}

__declspec(dllexport) int love::luax_resume(void*, void*, int, int*) {
    return 0;
}

__declspec(dllexport) __int64 luaopen_love() {
    // MessageBoxW(NULL, L"Hello, World in luaopen_love!", L"Fake DLL", MB_OK);
    return 1;
    OutputDebugStringA("Hello, World in luaopen_love!");
}

__declspec(dllexport) char* love_codename(void) {
    return "Fake Love";
}

__declspec(dllexport) const char* love_version(void) {
    // Display a message box with "Hello, World!"
    MessageBoxW(NULL, L"Hello, World!", L"Fake DLL", MB_OK);

    return "12.5"; 
}

__declspec(dllexport) __int64 luaopen_love_jitsetup(__int64) {
    return 0;
}

__declspec(dllexport) char love_openConsole(const char **) {
    return 0;
}