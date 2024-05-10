# David A. Aguirre M. <daguirre.m@outlook.com>
# Copy the include HAL files to the current working project
# MIT LICENSE @2022

param(
    [String] $libPath = "E:\David\Documents\MEGAsync\Trabajo\STM\.dspboardSDK\lib\hal\src", #Library Path [HAL]
    [String] $projectPath = ".", # Path of target project to copy includes
    [char] $force = '0' # Force to copy ['0' omit; '1' Forces]
)
# Label
Write-Host "[ALTELEC - HOTBET OF RESEARCH]" -ForegroundColor 'Green';
Write-Host "[DSP Board SDK] [Includes importer]" -ForegroundColor 'Green'
Write-Host ""

# Get Library List
$libList = Get-ChildItem $libPath

# Test if include folder exists, if doesn't make it.
if ($(Test-Path "$projectPath\include") -eq $false)
{
    mkdir -Path "$projectPath\include" | Out-Null
}

# Copy every include of each library to the project
# Normally if the include already exist ommit the copy
# But i can force to copy/update all the includes
foreach ($lib in $libList.Name)
{
    $files = Get-ChildItem -Path "$libPath\$lib\lib\include\*"
    foreach ($file in $files.Name)
    {
        Write-Host "Exporting includes " -NoNewline -ForegroundColor "DarkYellow"
        Write-Host "[$lib] [$file] " -NoNewline -ForegroundColor "DarkBlue"
        if($force -eq '0')
        {
            if ($(Test-Path "$projectPath\include\$file") -eq $false)
            {
                Copy-Item -Path "$libPath\$lib\lib\include\$file" -Destination "$projectPath\include" -Force | Out-Null
                Write-Host "[Done]" -ForegroundColor "Green"
            }
            else
            {
                Write-Host "[Already exist]" -ForegroundColor "Yellow"
            }
        }
        else
        {
            Copy-Item -Path "$libPath\$lib\lib\include\$file" -Destination "$projectPath\include" -Force | Out-Null
            Write-Host "[Done]" -ForegroundColor "Green"
        }
    }
}
