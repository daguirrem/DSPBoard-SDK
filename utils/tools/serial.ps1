$COM = [System.IO.Ports.SerialPort]::getportnames()

$selection = $COM

If($selection.Count -gt 1){
    $title = "Folder Selection"
    $message = "Which folder would you like to use?"

    # Build the choices menu
    $choices = @()
    For($index = 0; $index -lt $selection.Count; $index++){
        $choices += New-Object System.Management.Automation.Host.ChoiceDescription ($selection[$index])
    }
    
    $options = [System.Management.Automation.Host.ChoiceDescription[]]$choices
    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 

    $selection = $selection[$result]
}

$selection

#$port= new-Object System.IO.Ports.SerialPort $COM,115200,None,8,one

Write-Host "[ALTELEC - HOTBET OF RESEARCH]" -ForegroundColor 'Green'
Write-Host "[DSP Board SDK] [Serial Monitor] [$COM]" -ForegroundColor 'Green'
Write-Host "Press CTRL + C to close session"
Write-Host ""

function read-com {
    $port.Open()
    do {
        $line = $port.ReadLine()
        Write-Host $line
    }
    while ($port.IsOpen)
}

try 
{
    # read-com
} 
catch
{
    Write-Output "Error: " $_
}

finally
{
    Write-Host ""
    Write-Host "Ending session" -ForegroundColor DarkYellow
    if($selection.Count -eq 0)
    {
        Write-Host "No COMs available" -ForegroundColor DarkYellow
    }
    if($port -ne $null)
    {
        Write-Host "Closing $COM" -ForegroundColor DarkYellow
        $port.Close()
    }
}