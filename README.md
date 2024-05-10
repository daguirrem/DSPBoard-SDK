# DSP Board SDK Builder

This repository have all necesary files, folders and scripts to build DSP Board SDK installer to Windows and Linux (Debian based) machines.

**Note**: Only x86_64 cpu architecture is supported.

# How to build?

## Windows
1. TODO

## Linux
1. Give execution permisions to builder scripts.

    ```bash
    chmod +x ./build
    chmod +x ./config
    chmod +x ./dependencies
    ```

2. Prepare your pc with the dependencies necessary to download and build the SDK tools.
   This script download and install the next tools:
   - wget
   - make
   - unzip
   - libusb-1.0
   - pkg-config
   - build-essential
   - libtool

    ```bash
    ./dependencies
    ```
3. Configure the workspace downloading the tools from **trusted** (official) soruces and build the necessary tools (like openocd).

    ```bash
    ./config
    ```

4. Build the DSPBoard SDK Installer. The output file is by default named "dsp_board_sdk_linux_x64.run" if you want to change the name, remplace the SETUP_NAME variable on build file.

    ```bash
    ./build
    ```

# How to Install?

## Windows

TODO

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