# David A. Aguirre M.  <daguirre.m@outlook.com>
# Print the ELF program size and show important size sections
# MIT LICENSE @2022

function Blue
{
    process { Write-Host $_ -ForegroundColor DarkBlue }
}

function Yellow
{
    process { Write-Host $_ -ForegroundColor Yellow }
}

function Red
{
    process { Write-Host $_ -ForegroundColor Red }
}

function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}

Function Get-FriendlySize {
    Param($bytes)
    switch($bytes){
        {$_ -gt 1MB}{"{0:N1} MB" -f ($_ / 1MB);break}
        {$_ -gt 1KB}{"{0:N1} kB" -f ($_ / 1KB);break}
        default {"{0:N1} B" -f $_}
    }
}

Write-Host "$($PSStyle.bold)[ALTELEC - HOTBET OF RESEARCH]$($PSStyle.BoldOff)" -ForegroundColor 'Green';
Write-Host "$($PSStyle.bold)[DSP Board SDK] [ELF Size]$($PSStyle.BoldOff)" -ForegroundColor 'Green'


$arm_size = $args[0]
$elf = $args[1]

$MAX_FLASH_SIZE = [int] $args[2] * 1024
$MAX_RAM_SIZE = [int] $args[3] * 1024
$MAX_CCM_SIZE = [int] $args[4] * 1024
$MAX_BKPRAM_SIZE = [int] $args[5] * 1024

[array] $cmdOut = & $arm_size -A $elf
$name_elf = $cmdOut[0].ToString().Split('/');
$name_elf = $name_elf[$name_elf.Lenght - 1].Split(' ')[0]

$size_isr       = $cmdOut[2].ToString()  -replace '\D+([0-9]*).*','$1'
$size_text      = $cmdOut[3].ToString()  -replace '\D+([0-9]*).*','$1'
$size_rodata    = $cmdOut[4].ToString()  -replace '\D+([0-9]*).*','$1'
$size_data      = $cmdOut[10].ToString() -replace '\D+([0-9]*).*','$1'
$size_bss       = $cmdOut[11].ToString() -replace '\D+([0-9]*).*','$1'
$size_heap      = $cmdOut[12].ToString() -replace '\D+([0-9]*).*','$1'
$size_ccmdata   = $cmdOut[13].ToString() -replace '\D+([0-9]*).*','$1'
$size_ccmbss    = $cmdOut[14].ToString() -replace '\D+([0-9]*).*','$1'
$total_bkpram   = $cmdOut[15].ToString() -replace '\D+([0-9]*).*','$1'

$total_flash = ($size_isr -as [int]) `
            + ($size_text -as [int]) `
            + ($size_data -as [int]) `
            + ($size_rodata -as [int])


$total_ram = ($size_data -as [int]) `
            + ($size_bss -as [int]) `
            + ($size_heap -as [int])

$total_ccm = ($size_ccmdata -as [int]) `
            + ($size_ccmbss -as [int]) 

$porcentage_flash = [System.Math]::Round($total_flash/$MAX_FLASH_SIZE * 100, 2)
$porcentage_ram = [System.Math]::Round($total_ram/$MAX_RAM_SIZE * 100, 2)
$porcentage_ccm = [System.Math]::Round($total_ccm/$MAX_CCM_SIZE * 100, 2)
$porcentage_bkpram = [System.Math]::Round($total_bkpram/$MAX_BKPRAM_SIZE * 100, 2)

$total_flash = Get-FriendlySize($total_flash)
$total_ram = Get-FriendlySize($total_ram)
$total_ccm = Get-FriendlySize($total_ccm)
$total_bkpram = Get-FriendlySize($total_bkpram)

$MAX_FLASH_SIZE = Get-FriendlySize($MAX_FLASH_SIZE)
$MAX_RAM_SIZE = Get-FriendlySize($MAX_RAM_SIZE)
$MAX_CCM_SIZE = Get-FriendlySize($MAX_CCM_SIZE)
$MAX_BKPRAM_SIZE = Get-FriendlySize($MAX_BKPRAM_SIZE)

Write-Output "$($PSStyle.bold)[$name_elf]$($PSStyle.BoldOff)" | Blue
Write-Host ""

Write-Output $cmdOut

switch ($porcentage_bkpram) {
    {$_ -ge 90} { 
        Write-Output "$($PSStyle.bold)BRAM:" | Red
        Write-Output "[$total_bkpram / $MAX_BKPRAM_SIZE] [$porcentage_bkpram %]" | Red 
        break
    }
    {$_ -ge 50} {
        Write-Output "$($PSStyle.bold)BRAM:" | Yellow
        Write-Output "[$total_bkpram / $MAX_BKPRAM_SIZE] [$porcentage_bkpram %]" | Yellow
        break
    }
    Default {
        Write-Output "$($PSStyle.bold)BRAM:" | Green
        Write-Output "[$total_bkpram / $MAX_BKPRAM_SIZE] [$porcentage_bkpram %]" | Green
        break
    }
}
Write-Output ""

switch ($porcentage_ccm) {
    {$_ -ge 90} { 
        Write-Output "$($PSStyle.bold)CCM:" |  Red
        Write-Output "[$total_ccm / $MAX_CCM_SIZE] [$porcentage_ccm %]" | Red 
        break
    }
    {$_ -ge 50} {
        Write-Output "$($PSStyle.bold)CCM:" | Yellow
        Write-Output "[$total_ccm / $MAX_CCM_SIZE] [$porcentage_ccm %]" | Yellow
        break
    }
    Default {
        Write-Output "$($PSStyle.bold)CCM:$($PSStyle.BoldOff)" | Green
        Write-Output "[$total_ccm / $MAX_CCM_SIZE] [$porcentage_ccm %]" | Green
        break
    }
}
Write-Output " .ccmdata:    $size_ccmdata Bytes" | Blue
Write-Output " .ccmbss:     $size_ccmbss Bytes" | Blue
Write-Output ""

switch ($porcentage_flash) {
    {$_ -ge 90} { 
        Write-Output "$($PSStyle.bold)FLASH:$($PSStyle.BoldOff)" | Red
        Write-Output "[$total_flash / $MAX_FLASH_SIZE] [$porcentage_flash %]" | Red 
        break
    }
    {$_ -ge 50} {
        Write-Output "$($PSStyle.bold)FLASH:$($PSStyle.BoldOff)" | Yellow
        Write-Output "[$total_flash / $MAX_FLASH_SIZE] [$porcentage_flash %]" | Yellow
        break
    }
    Default {
        Write-Output "$($PSStyle.bold)FLASH:$($PSStyle.BoldOff)" | Green
        Write-Output "[$total_flash / $MAX_FLASH_SIZE] [$porcentage_flash %]" | Green
        break
    }
}
Write-Output " .isrvectors: $size_isr Bytes" | Blue
Write-Output " .text:       $size_text Bytes" | Blue
Write-Output " .data:       $size_data Bytes" | Blue
Write-Output " .rodata:     $size_rodata Bytes" | Blue
Write-Output ""



switch ($porcentage_ram) {
    {$_ -ge 90} { 
        Write-Output "$($PSStyle.bold)RAM:$($PSStyle.BoldOff)" | Red
        Write-Output "[$total_ram / $MAX_RAM_SIZE] [$porcentage_ram %]" | Red 
        break
    }
    {$_ -ge 50} {
        Write-Output "$($PSStyle.bold)RAM:$($PSStyle.BoldOff)" | Yellow
        Write-Output "[$total_ram / $MAX_RAM_SIZE] [$porcentage_ram %]" | Yellow
        break
    }
    Default {
        Write-Output "$($PSStyle.bold)RAM:$($PSStyle.BoldOff)" | Green
        Write-Output "[$total_ram / $MAX_RAM_SIZE] [$porcentage_ram %]" | Green
        break
    }
}
Write-Output " .data:       $size_data Bytes" | Blue
Write-Output " .bss:        $size_bss Bytes" | Blue
Write-Output " .heap:       $size_heap Bytes" | Blue