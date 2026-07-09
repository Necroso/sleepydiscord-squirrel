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