workspace "sleepydiscord-squirrel"
    configurations { "Debug", "Release" }
    platforms { "Win32", "x64" }

project "sleepydiscord-squirrel"
    kind "SharedLib"
    language "C++"
    cppdialect "C++20"

    targetname "discord04rel"

    files {
        "src/**.cpp",
        "src/**.h"
    }

    includedirs {
        ".",
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


    filter "platforms:Win32"

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


    filter "platforms:x64"

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

    architecture "x86_64"

    targetextension ".so"

    includedirs {
        "/usr/local/include",
        "/usr/local/include/sleepy_discord"
    }

    libdirs {
        "/usr/local/lib"
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
-- Configurations
-- ==========================

filter "configurations:Debug"

    runtime "Debug"

    symbols "On"

    targetdir "bin/Debug"
    objdir "obj/Debug"


filter "configurations:Release"

    runtime "Release"

    optimize "Full"
    symbols "Off"

    linktimeoptimization "On"

    targetdir "bin/Release"
    objdir "obj/Release"


-- ==========================
-- Windows static runtime
-- ==========================

filter {
    "system:windows",
    "configurations:Debug"
}

    staticruntime "on"


filter {
    "system:windows",
    "configurations:Release"
}

    staticruntime "on"


filter {}