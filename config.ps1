Clear-Host
#Path where terminal is executing the script.
$TERMINAL_DIR = $pwd | Select-Object -ExpandProperty Path

#Relative TERMINAL_DIR path where is the current script.
$SCRIPT_DIR = $PSScriptRoot

# Temp dir.
$TMP_DIR = "$SCRIPT_DIR/tmp" 

. "$SCRIPT_DIR/Get-FileFromWeb.ps1"

# function atexit()
# {
#     cd $TERMINAL_DIR
# }

# trap atexit EXIT

New-Item -Path $SCRIPT_DIR -Name "tmp" -ItemType "directory" -Force | Out-Null

Write-Output "DSPBoard SDK Installer configurator for Windows x64"
Write-Output ""

Write-Output 'Downloading "gcc arm none eabi 10.3-2021.10"'
Get-FileFromWeb -URL "https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-win32.zip" -OutFile "$TMP_DIR/gcc-arm-none-eabi-10.3-2021.10-win32.zip" -SkipIfExist $true

Write-Output 'Uncompressing "gcc-arm-none-eabi-10.3-2021.10-win32.zip"'
Remove-Item "$SCRIPT_DIR/gcc/*" -Exclude ".gitkeep" -Recurse -Force
Expand-Archive -LiteralPath "$TMP_DIR/gcc-arm-none-eabi-10.3-2021.10-win32.zip" -DestinationPath "$SCRIPT_DIR/gcc" -Force
Move-Item "$SCRIPT_DIR/gcc/gcc-arm-none-eabi-10.3-2021.10/*" "$SCRIPT_DIR/gcc" -Force
Remove-Item "$SCRIPT_DIR/gcc/gcc-arm-none-eabi-10.3-2021.10" -Force

Write-Output 'Downloading "STM32CubeF4 1.27.1"'
Get-FileFromWeb -URL "https://github.com/STMicroelectronics/STM32CubeF4/archive/refs/tags/v1.27.1.zip" -OutFile "$TMP_DIR/v1.27.1.zip" -SkipIfExist $true

Write-Output 'Uncompressing "STM32CubeF4-1.27.1.zip"'
Remove-Item "$SCRIPT_DIR/packs/*" -Exclude ".gitkeep" -Recurse -Force
Expand-Archive -LiteralPath "$TMP_DIR/v1.27.1.zip" -DestinationPath "$SCRIPT_DIR/packs" -Force
Rename-Item "$SCRIPT_DIR/packs/STM32CubeF4-1.27.1" "STM32CubeF4"

Write-Output 'Downloading "Powershell 7.4.2"'
Get-FileFromWeb -URL "https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/PowerShell-7.4.2-win-x64.zip" -OutFile "$TMP_DIR/PowerShell-7.4.2-win-x64.zip" -SkipIfExist $true

Write-Output 'Uncompressing "PowerShell-7.4.2-win-x64.zip"'
Expand-Archive -LiteralPath "$TMP_DIR/PowerShell-7.4.2-win-x64.zip" -DestinationPath "$SCRIPT_DIR/powershell" -Force

Write-Output 'Downloading "Doxygen 1.10.0"'
Get-FileFromWeb -URL "https://www.doxygen.nl/files/doxygen-1.10.0.windows.x64.bin.zip" -OutFile "$TMP_DIR/doxygen-1.10.0.windows.x64.bin.zip" -SkipIfExist $true

Write-Output 'Uncompressing "doxygen-1.10.0.windows.x64.bin.zip"'
Remove-Item "$SCRIPT_DIR/doxygen/*" -Force -Exclude ".gitkeep"
Expand-Archive -LiteralPath "$TMP_DIR/doxygen-1.10.0.windows.x64.bin.zip" -DestinationPath "$SCRIPT_DIR/doxygen" -Force

Write-Output 'Downloading "VSCode 1.89.0 (April 2024)"'
Get-FileFromWeb -URL "https://update.code.visualstudio.com/1.89.0/win32-x64-archive/stable" -OutFile "$TMP_DIR/VSCode-win32-x64-1.89.0.zip" -SkipIfExist $true

Write-Output 'Uncompressing "VSCode-win32-x64-1.89.0.zip" & DSPBoard IDE settings'
Expand-Archive -LiteralPath "$TMP_DIR/VSCode-win32-x64-1.89.0.zip" -DestinationPath "$SCRIPT_DIR/vscode" -Force
tar -xf "$SCRIPT_DIR/vscode/data.tar.gz" -C "$SCRIPT_DIR/vscode"

Write-Output 'Downloading "XPack 4.4.1-2"'
Get-FileFromWeb -URL "https://github.com/xpack-dev-tools/windows-build-tools-xpack/releases/download/v4.4.1-2/xpack-windows-build-tools-4.4.1-2-win32-x64.zip" -OutFile "$TMP_DIR/xpack-windows-build-tools-4.4.1-2-win32-x64.zip" -SkipIfExist $true

Write-Output 'Uncompressing "xpack-windows-build-tools-4.4.1-2-win32-x64.zip"'
Remove-Item "$SCRIPT_DIR/utils/xpack" -Force -ErrorAction Ignore
Expand-Archive -LiteralPath "$TMP_DIR/xpack-windows-build-tools-4.4.1-2-win32-x64.zip" -DestinationPath "$SCRIPT_DIR/utils" -Force
Rename-Item "$SCRIPT_DIR/utils/xpack-windows-build-tools-4.4.1-2" "xpack" -Force

Write-Output 'Downloading "OpenOCD 12.0"'
Get-FileFromWeb -URL "https://github.com/openocd-org/openocd/releases/download/v0.12.0/openocd-v0.12.0-i686-w64-mingw32.tar.gz" -OutFile "$TMP_DIR/openocd-v0.12.0-i686-w64-mingw32.tar.gz" -SkipIfExist $true

Write-Output 'Uncompressing "openocd-v0.12.0-i686-w64-mingw32.tar.gz"'
New-Item -Path "$SCRIPT_DIR/utils/" -Name "openocd" -ItemType "directory" -Force | Out-Null
tar -xf "$TMP_DIR/openocd-v0.12.0-i686-w64-mingw32.tar.gz" -C "$SCRIPT_DIR/utils/openocd"

Write-Output 'DSPBoard SDK Installer is configured :). Now you can generate the installer with Inno Setup'

exit

