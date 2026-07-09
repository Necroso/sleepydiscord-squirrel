# Compiling the Plugin on Windows

## Prerequisites

- Visual Studio 2022
- vcpkg installed and configured

For more information about vcpkg, visit https://vcpkg.io/

---

## Installing Dependencies

Install the required dependencies using the commands below.

### For 64-bit builds (`x64-windows-static`)

```bash
vcpkg install asio:x64-windows-static
vcpkg install boost:x64-windows-static
vcpkg install cpr:x64-windows-static
vcpkg install curl:x64-windows-static
vcpkg install openssl:x64-windows-static
vcpkg install opus:x64-windows-static
vcpkg install sleepy-discord:x64-windows-static
vcpkg install libsodium:x64-windows-static
```

### For 32-bit builds (`x86-windows-static`)

Replace the `x64-windows-static` triplet with `x86-windows-static` in all of the commands above:

```bash
vcpkg install asio:x86-windows-static
vcpkg install boost:x86-windows-static
vcpkg install cpr:x86-windows-static
vcpkg install curl:x86-windows-static
vcpkg install openssl:x86-windows-static
vcpkg install opus:x86-windows-static
vcpkg install sleepy-discord:x86-windows-static
vcpkg install libsodium:x86-windows-static
```

---

## Generating the Visual Studio Solution

1. Clone or download the repository.
2. Navigate to the `premake` folder.
3. Run:

```text
win-build.bat
```

This will generate a **Visual Studio 2022** solution in the project's root directory.

---

## Building

Open the generated solution in **Visual Studio 2022** and build using one of the following configurations:

| Configuration | Output File |
|--------------|-------------|
| **Release + Win32** | `discord04rel32.dll` |
| **Release + x64** | `discord04rel64.dll` |

---

# Compiling the Plugin on Linux

## Installing Dependencies

### For 64-bit builds

If you are compiling the plugin for a native 64-bit Linux system, install the required development packages:

```bash
sudo apt update
sudo apt install libcurl4-openssl-dev libopus-dev libsodium-dev zlib1g-dev libssl-dev
```

### For 32-bit builds

If you need to build a 32-bit shared library (`.so`) on a 64-bit system, first enable multiarch support and install the 32-bit development packages:

```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install libcurl4-openssl-dev:i386 libopus-dev:i386 libsodium-dev:i386 zlib1g-dev:i386 libssl-dev:i386
```

### Possible Multiarch Conflict (libcurl)

When installing the 32-bit packages, `dpkg` may report a file conflict involving `curl-config`. If this happens, force the package installation and repair any pending dependencies:

```bash
# Force installation (adjust the package version if necessary)
sudo dpkg -i --force-overwrite /var/cache/apt/archives/libcurl4-openssl-dev_*_i386.deb

# Repair pending dependencies
sudo apt install -f
```

---

## Building Sleepy-Discord

The project depends on a manually built copy of **Sleepy-Discord**.

### Clone the repository and its dependencies

```bash
cd ~
git clone https://github.com/yourWaifu/sleepy-discord.git
cd sleepy-discord

mkdir deps

git clone https://github.com/libcpr/cpr.git deps/cpr
git clone https://github.com/chriskohlhoff/asio.git deps/asio
```

---

## Required Source Patch

Recent compiler versions require an additional include in Sleepy-Discord.

Open the following file:

```text
~/sleepy-discord/include/sleepy_discord/json_wrapper.h
```

Immediately below:

```cpp
#pragma once
```

add:

```cpp
#include <algorithm>
```

The beginning of the file should look like this:

```cpp
#pragma once

#include <algorithm>
#include <string>
#include "nonstd/string_view.hpp"
```

---

## Configuring the Build

Create a build directory:

```bash
mkdir build
cd build
```

### For 64-bit builds

```bash
cmake .. \
    -DAUTO_DOWNLOAD_LIBRARY=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON

make
```

### For 32-bit builds

If you are running this after compiling for x64, you must clean the build directory first (and vice versa when switching from x86 to x64):

```bash
cd ~/sleepy-discord
mkdir -p build && cd build
rm -rf *
```

```bash
cmake .. \
    -DAUTO_DOWNLOAD_LIBRARY=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DCMAKE_CXX_FLAGS="-m32" \
    -DCMAKE_C_FLAGS="-m32"

make
```

---

## Building the plugin

Before compiling, choose the correct configuration command depending on your target server architecture (**x64** or **x86**). Each command will output a specific binary file:

| Command | Architecture | Generated Binary | Description |
| :--- | :---: | :--- | :--- |
| `make config=release` | **x64** (64-bit) | `discord04rel64.so` | Standard build for modern 64-bit systems. |
| `make config=release32` | **x86** (32-bit) | `discord04rel32.so` | Required if your game server runs on a 32-bit environment. |

To compile the plugin using your chosen configuration, run the following commands (example using x64):

```bash
cd ~/sleepydiscord-squirrel
make config=release
```

Once the build completes successfully, the generated static library can be linked against the plugin during compilation.

---

### Example of a Squirrel script:
```squirrel
sessions <- {};

class MyDiscord {
    eventFuncs = null;
    session = null;
    connID = null;

    publicChannelID = "YOUR_MAIN_CHANNEL_ID_HERE";
    privateChannelID = "YOUR_PRIVATE_CHANNEL_ID_HERE";

    commandPrefix = "!"; // Command prefix for both public and private commands
    messagePrefix = "."; // Prefix for messages sent by users (if empty, all messages will be processed)
    
    function constructor() {
        session = SqDiscord.CSession();
        connID = session.ConnID;
            
        sessions.rawset(connID, this);
        
        eventFuncs = [
            onReady,
            onMessage,
            onError,
            onDisconnect,
            onQuit
        ];

        session.InternalCacheEnabled = true;
    }
    
    function Connect(token) {
        session.Connect(token);
    }
    
    function sendMessage(channelID, message) {
        session.Message(channelID, message);
    }
    
    function sendEmbed(channelID, embed) {
        session.MessageEmbed(channelID, "", embed);
    }
    
    function onReady(readyData = null) {
        local connectionID = (session != null) ? session.ConnID : connID;
        local cacheStatus = (session != null && session.InternalCacheEnabled) ? "Enabled" : "Disabled";

        if ("User" in this && this.User != null) {
                this.selfID <- this.User.ID;
        } else if ("Client" in this && this.Client != null) {
            this.selfID <- this.Client.ID;
        }

        print(format("Discord Bot connected | Session ID: %d | Cache: %s", connectionID, cacheStatus));
    }
    
    function onMessage(message) {
        local author = message.Author;
        
        if (author != null) {
            if (("Bot" in author && author.Bot) || ("IsBot" in author && author.IsBot)) {
                return; 
            }
        }

        local member = message.Member;
        local serverID = message.ServerID;
        
        local username = (author != null) ? author.Username : "Unknown User";
        local content = (message.Content != "") ? message.Content : "[Attachment/Empty Message]";
        
        local rolesStr = "";
        if(member != null && serverID != null && member.Roles.len() > 0) {
            local rolesList = [];
            foreach(roleID in member.Roles) {
                local roleName = session.GetRoleName(serverID, roleID);
                if (roleName != null) rolesList.push(roleName);
            }
            
            if (rolesList.len() > 0) {
                rolesStr = " [";
                for(local i = 0; i < rolesList.len(); i++) {
                    rolesStr += rolesList[i] + (i == rolesList.len() - 1 ? "" : ", ");
                }
                rolesStr += "]";
            }
        }

        local channelName = message.ChannelID; 
        if (session != null) {
            local channelObj = session.GetOtherChannel(message.ChannelID);
            if (channelObj != null && "Name" in channelObj) {
                channelName = channelObj.Name;
            }
        }

        if (content.len() > 0 && this.commandPrefix.len() > 0 && content[0] == this.commandPrefix[0]) {
            local tokens = split(content, " ");
            local command = tokens[0].slice(1).tolower();

            local args = "";
            if (tokens.len() > 1) {
                for (local i = 1; i < tokens.len(); i++) {
                    args += tokens[i] + (i == tokens.len() - 1 ? "" : " ");
                }
            }

            local user = author; 
            local channel = message.ChannelID;

            if (message.ChannelID == this.publicChannelID) {
                if ("onPublicCommand" in this) {
                    this.onPublicCommand(command, args, user, channel);
                } else {
                    print("[Warning] onPublicCommand is not defined in this class.");
                }
            }
            else if (message.ChannelID == this.privateChannelID) {
                if ("onPrivateCommand" in this) {
                    this.onPrivateCommand(command, args, user, channel);
                } else {
                    print("[Warning] onPrivateCommand is not defined in this class.");
                }
            }
        }
       else {
            local channel = message.ChannelID;

            if (this.messagePrefix != "" && content.len() > 0 && content[0] == this.messagePrefix[0]) {
                local cleanContent = content.slice(1);
                
                if ("onChatMessage" in this) {
                    this.onChatMessage(message, cleanContent, channel);
                }
            } 
        }
    }
    
    function onError(code, message) {
        print(format("%d - %s", code, message));
    }
    
    function onDisconnect() {
        print("Discord session has disconnected.");
    }
    
    function onQuit() {
        print("Discord session has quit.");
    }
}

myDiscord <- MyDiscord();
myDiscord.Connect("YOUR_BOT_TOKEN"); // Replace with your bot token

function onDiscordUpdate(connID, eventType, ...) {
    if(sessions.rawin(connID)) {
        local session = sessions.rawget(connID);
        vargv.insert(0, session);
        session.eventFuncs[eventType].acall(vargv);
    }
}

// =============== MESSAGE HANDLING ================
function MyDiscord::onChatMessage(message, content, channel) {
    local author = message.Author;
    local msg = content.len() > 0 ? content : "";

    if (author != null) {
        myDiscord.sendMessage(channel, format(":keyboard: **%s**: %s", author.Username, msg));
        ::Message(format("[#FFFFFF][[#5662F6]Discord[#FFFFFF]] %s: %s", author.Username, MyDiscord.sanitizeString(msg)));
        print(format("Message from %s: %s", author.Username, MyDiscord.sanitizeString(msg)));
    }
}
// ================ PUBLIC COMMANDS ================
function MyDiscord::onPublicCommand(command, args, user, channel) {
    print(format("Public Command Received: %s | Args: %s | User: %s | Channel: %s", command, args, user.Username, channel));
    if(command == "ping") {
        myDiscord.sendMessage(channel, "Pong!");
    }

    else if (command == "embed") {
        local embed = SqDiscord.Embed.Embed();
        
        embed.SetTitle("Sample Embed");
        embed.SetDescription("This is a sample embed message.");
        embed.SetColor(0x00FF00);

        this.sendEmbed(channel, embed);
    }
}

// ================ PRIVATE COMMANDS ===============
function MyDiscord::onPrivateCommand(command, args, user, channel) {
    print(format("Private Command Received: %s | Args: %s | User: %s | Channel: %s", command, args, user.Username, channel));
    if(command == "ping") {
        myDiscord.sendMessage(user, "Pong!");
    }

    else if (command == "embed") {
        local embed = SqDiscord.Embed.Embed();
        
        embed.SetTitle("Sample Embed");
        embed.SetDescription("This is a sample embed message.");
        embed.SetColor(0x00FF00);

        this.sendEmbed(channel, embed);
    }
}
// ================ ESSENTIAL FUNCTIONS ===============
function MyDiscord::sanitizeString(str) {
    local accentMap = {
        // á à â ã ä ā å æ
        ["\xC3\xA1"]="a", ["\xC3\xA0"]="a", ["\xC3\xA2"]="a", ["\xC3\xA3"]="a", ["\xC3\xA4"]="a", ["\xC4\x81"]="a", ["\xC3\xA5"]="a", ["\xC3\xA6"]="a",
        // Á À Â Ã Ä Ā Å Æ
        ["\xC3\x81"]="A", ["\xC3\x80"]="A", ["\xC3\x82"]="A", ["\xC3\x83"]="A", ["\xC3\x84"]="A", ["\xC4\x80"]="A", ["\xC3\x85"]="A", ["\xC3\x86"]="A",
        // é è ê ë ē ę ė
        ["\xC3\xA9"]="e", ["\xC3\xA8"]="e", ["\xC3\xAA"]="e", ["\xC3\xAB"]="e", ["\xC4\x93"]="e", ["\xC4\x99"]="e", ["\xC4\x97"]="e",
        // É È Ê Ë Ē Ę Ė
        ["\xC3\x89"]="E", ["\xC3\x88"]="E", ["\xC3\x8A"]="E", ["\xC3\x8B"]="E", ["\xC4\x92"]="E", ["\xC4\x98"]="E", ["\xC4\x96"]="E",
        // í ì î ï ī į
        ["\xC3\xAD"]="i", ["\xC3\xAC"]="i", ["\xC3\xAE"]="i", ["\xC3\xAF"]="i", ["\xC4\xAB"]="i", ["\xC4\xAF"]="i",
        // Í Ì Î Ï Ī Į
        ["\xC3\x8D"]="I", ["\xC3\x8C"]="I", ["\xC3\x8E"]="I", ["\xC3\x8F"]="I", ["\xC4\xAA"]="I", ["\xC4\xAE"]="I",
        // ó ò ô õ ö ō ø œ
        ["\xC3\xB3"]="o", ["\xC3\xB2"]="o", ["\xC3\xB4"]="o", ["\xC3\xB5"]="o", ["\xC3\xB6"]="o", ["\xC5\x8D"]="o", ["\xC3\xB8"]="o", ["\xC5\x93"]="o",
        // Ó Ò Ô Õ Ö Ō Ø Œ
        ["\xC3\x93"]="O", ["\xC3\x92"]="O", ["\xC3\x94"]="O", ["\xC3\x95"]="O", ["\xC3\x96"]="O", ["\xC5\x8C"]="O", ["\xC3\x98"]="O", ["\xC5\x92"]="O",
        // ú ù û ü ū
        ["\xC3\xBA"]="u", ["\xC3\xB9"]="u", ["\xC3\xBB"]="u", ["\xC3\xBC"]="u", ["\xC5\xAB"]="u",
        // Ú Ù Û Ü Ū
        ["\xC3\x9A"]="U", ["\xC3\x99"]="U", ["\xC3\x9B"]="U", ["\xC3\x9C"]="U", ["\xC5\xAA"]="U",
        // ç ć č © Ç Ć Č
        ["\xC3\xA7"]="c", ["\xC4\x87"]="c", ["\xC4\x8D"]="c", ["\xC2\xA9"]="c", ["\xC3\x87"]="C", ["\xC4\x86"]="C", ["\xC4\x8C"]="C",
        // ñ Ñ
        ["\xC3\xB1"]="n", ["\xC3\x91"]="N",
        // º ª ° ®
        ["\xC2\xBA"]="o", ["\xC2\xAA"]="a", ["\xC2\xB0"]="o", ["\xC2\xAE"]="r",
    };
    local result = "";

    for (local i = 0; i < str.len(); ) {
        // Remove color tags [#RRGGBB]
        if (i + 8 < str.len() && str.slice(i, i + 2) == "[#" && str.slice(i + 8, i + 9) == "]") {
            i += 9;
            continue;
        }

        if (i + 1 < str.len()) {
            local two = str.slice(i, i + 2);
            if (accentMap.rawin(two)) {
                result += accentMap[two];
                i += 2;
                continue;
            }
        }

        result += str.slice(i, i + 1);
        i += 1;
    }

    return result;
}
```