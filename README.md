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

## Linux

Linux build instructions are **not available yet**.

I am currently working on documenting the Linux build process. Unfortunately, getting this project to compile on Linux has been a nightmare due to dependency compatibility and build system issues. Once I have a reliable and reproducible process, this section will be updated.
