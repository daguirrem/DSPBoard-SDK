# DSP Board SDK

This repository have all necesary files, folders and scripts to build DSP Board SDK **Installer** to Windows and Linux (Debian based) machines.

If you want **only install** the DSP Board SDK, please download the lastest version from [Releases](https://github.com/daguirrem/DSPBoard-SDK/releases) and follow the [*How to install?*](#how-to-install) section. 

**Note**: Only x86_64 cpu architecture is supported.

# Important note

Before all, this repository have LFS files, you need install LFS extension support to your machine:

If you are running **Linux (Debian based)** just run:
```bash
sudo apt install git git-lfs -y
```

Or **Windows** just download and install [Git](https://git-scm.com/download/win) and [Git LFS extension](https://git-lfs.com/) 

To **clone** this repo run this:

```bash
git clone --recursive https://github.com/daguirrem/DSPBoard-SDK
cd DSPBoard-SDK
git lfs fetch --all
git lfs checkout
```

# How to build?

## Windows
1. Download and install [Inno Setup](https://jrsoftware.org/isdl.php)

2. Open Windows PowerShell with unrestricted execution policy at repository path:
    ```bash
    powershell.exe -ExecutionPolicy Unrestricted
    ```

3. Configure the workspace downloading the tools from **trusted** (official) sources:

    ```pwsh
    .\config.ps1
    ```
   This script download the next tools:
   - GCC ARM NONE EABI 10.3-2021.10
   - STM32CubeF4 1.27.1
   - Powershell 7.4.2
   - Doxygen 1.10.0
   - VSCode 1.89.0 (April 2024)
   - OpenOCD 12.0
   - Xpack windows build tools 4.4-2

4. Open build.iss file (With Inno setup) and compile the installer (CTRL+F9). This generates a installer called dsp_board_sdk_win_x64.exe at root of repository folder.
    ```pwsh
    & .\build.iss
    ```

## Linux
1. Give execution permisions to builder scripts.

    ```bash
    chmod +x ./build
    chmod +x ./config
    chmod +x ./dependencies
    ```

2. Prepare your pc with the dependencies necessary to download and build the SDK tools.

    ```bash
    ./dependencies
    ```

   This script download and install the next tools:
   - wget
   - make
   - unzip
   - libusb-1.0
   - pkg-config
   - build-essential
   - libtool

3. Configure the workspace downloading the tools from **trusted** (official) sources and build the necessary tools (like openocd).

    ```bash
    ./config
    ```

   This script download the next tools:
   - GCC ARM NONE EABI 10.3-2021.10
   - STM32CubeF4 1.27.1
   - Powershell 7.4.2
   - Doxygen 1.10.0
   - VSCode 1.89.0 (April 2024)
   - OpenOCD 12.0

5. Build the DSPBoard SDK Installer. The output file is by default named "dsp_board_sdk_linux_x64.run" if you want to change the name, remplace the SETUP_NAME variable on build file.

    ```bash
    ./build
    ```

# How to Install?

## Windows

Just run the builded/downloaded installer (dsp_board_sdk_win_x64.exe) and follow the steps.

(Optional): Download and install the lastest driver for st-link debugger from [STMicroelectronics web](https://www.st.com/en/development-tools/stsw-link009.html).
## Linux

If you builded your DSPBoard SDK Installer from scratch just run at terminal:

```bash
./dsp_board_sdk_linux_x64.run
```

Else if you dowloaded the installer from *Releases*, give execution permissions and then run the file at terminal:

```bash
chmod +x ./dsp_board_sdk_linux_x64.run
./dsp_board_sdk_linux_x64.run
```

# License
  _DSPBoard SDK_ is licensed by MIT License, more information on [LICENSE.md](LICENSE.md)