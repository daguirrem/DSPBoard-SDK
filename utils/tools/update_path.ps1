$fileList = Get-ChildItem settings.json -Recurse
foreach ($file in $fileList)
{
    Write-Host $file
    try
    {
        $raw = Get-Content $file -raw | ConvertFrom-Json
        $raw.path_sdk = $Args[0]
        $raw | ConvertTo-Json -depth 32| set-content $file
    }
    catch
    {
        Write-Host "Elemento no válido"
    }
}
