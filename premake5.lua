workspace "sleepydiscord-squirrel"
    if os.target() == "windows" then
        configurations { "Debug", "Release" }
        platforms { "Win32", "x64" }
    else
        configurations { "Debug", "Release", "debug32", "release32" }
    end

project "sleepydiscord-squirrel"
    kind "SharedLib"
    language "C++"
    cppdialect "C++20"

    targetname "discord04rel"
    targetprefix "" 

    files {
        "src/**.cpp",
        "src/**.h"
    }

    includedirs {
        ".",
        "src",
        "include",
        "readerwriterqueue"
    }

    defines {
        "NOMINMAX"
    }

    forceincludes {
        "algorithm"
    }


-- ==========================
-- Build Shortcut Mapping for Linux
-- ==========================

filter { "system:linux", "configurations:Release" }
    architecture "x86_64"
    targetsuffix "64"
    externalincludedirs { "/usr/include/x86_64-linux-gnu" }

filter { "system:linux", "configurations:Debug" }
    architecture "x86_64"
    targetsuffix "64"
    externalincludedirs { "/usr/include/x86_64-linux-gnu" }

filter { "system:linux", "configurations:release32" }
    architecture "x86"
    targetsuffix "32"
    runtime "Release"
    optimize "Full"
    linktimeoptimization "On"
    targetdir "bin/Release"
    objdir "obj/Release"
    externalincludedirs { "/usr/include/i386-linux-gnu" }

filter { "system:linux", "configurations:debug32" }
    architecture "x86"
    targetsuffix "32"
    runtime "Debug"
    symbols "On"
    targetdir "bin/Debug"
    objdir "obj/Debug"
    externalincludedirs { "/usr/include/i386-linux-gnu" }


-- ==========================
-- Windows
-- ==========================

filter "system:windows"

    systemversion "latest"

    defines {
        "_CRT_SECURE_NO_WARNINGS"
    }

    buildoptions {
        "/utf-8"
    }

    characterset "MBCS"

    links {
        "ws2_32",
        "crypt32",
        "wldap32",
        "bcrypt",
        "Normaliz",
        "Secur32",
        "iphlpapi",

        "cpr",
        "zs",
        "opus",
        "libsodium",
        "sleepy-discord",
        "libssl",
        "libcrypto",
        "libcurl"
    }


    filter { "system:windows", "platforms:Win32" }

        architecture "x86"
        targetsuffix "32"

        externalincludedirs {
            "$(VCPKG_ROOT)/installed/x86-windows-static/include",
            "$(VCPKG_ROOT)/installed/x86-windows-static/include/asio",
            "$(VCPKG_ROOT)/installed/x86-windows-static/include/boost",
            "$(VCPKG_ROOT)/installed/x86-windows-static/include/cpr",
            "$(VCPKG_ROOT)/installed/x86-windows-static/include/curl",
            "$(VCPKG_ROOT)/installed/x86-windows-static/include/openssl",
            "$(VCPKG_ROOT)/installed/x86-windows-static/include/opus",
            "$(VCPKG_ROOT)/installed/x86-windows-static/include/sleepy_discord",
            "$(VCPKG_ROOT)/installed/x86-windows-static/include/sodium"
        }

        libdirs {
            "$(VCPKG_ROOT)/installed/x86-windows-static/lib"
        }


    filter { "system:windows", "platforms:x64" }

        architecture "x86_64"
        targetsuffix "64"

        externalincludedirs {
            "$(VCPKG_ROOT)/installed/x64-windows-static/include",
            "$(VCPKG_ROOT)/installed/x64-windows-static/include/asio",
            "$(VCPKG_ROOT)/installed/x64-windows-static/include/boost",
            "$(VCPKG_ROOT)/installed/x64-windows-static/include/cpr",
            "$(VCPKG_ROOT)/installed/x64-windows-static/include/curl",
            "$(VCPKG_ROOT)/installed/x64-windows-static/include/openssl",
            "$(VCPKG_ROOT)/installed/x64-windows-static/include/opus",
            "$(VCPKG_ROOT)/installed/x64-windows-static/include/sleepy_discord",
            "$(VCPKG_ROOT)/installed/x64-windows-static/include/sodium"
        }

        libdirs {
            "$(VCPKG_ROOT)/installed/x64-windows-static/lib"
        }


-- ==========================
-- Linux
-- ==========================

filter "system:linux"

    targetextension ".so"

    local homeDir = os.getenv("HOME") or os.getenv("USERPROFILE") or ""

    externalincludedirs {
        homeDir .. "/sleepy-discord/include",
        homeDir .. "/sleepy-discord/deps/asio/include",
        homeDir .. "/sleepy-discord/deps/cpr/include",
        "/usr/include/opus"
    }

    libdirs {
        homeDir .. "/sleepy-discord/build",
        homeDir .. "/sleepy-discord/build/sleepy_discord",
        homeDir .. "/sleepy-discord/build/deps/cpr/cpr"
    }

    links {
        "pthread",
        "curl",
        "ssl",
        "crypto",
        "opus",
        "sodium",
        "z",
        "cpr",
        "sleepy-discord"
    }


-- ==========================
-- Configurations (Debug vs Release)
-- ==========================

filter "configurations:Debug*"
    runtime "Debug"
    symbols "On"
    targetdir "bin/Debug"
    objdir "obj/Debug"

filter "configurations:Release*"
    runtime "Release"
    optimize "Full"
    symbols "Off"
    linktimeoptimization "On"
    targetdir "bin/Release"
    objdir "obj/Release"


-- ==========================
-- Windows static runtime
-- ==========================

filter { "system:windows", "configurations:Debug*" }
    staticruntime "on"

filter { "system:windows", "configurations:Release*" }
    staticruntime "on"

filter {}