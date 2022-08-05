###################################
# File  : dewin.ps1
# Author: Avishek Dutta
# URL  : https://github.com/avishekdutta531/dewin/
###################################

# Writing Message
Write-Host "----- Getting Ready -----";

Write-Host "Fixing ngen.exe...";
$env:PATH = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
[AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
    $path = $_.Location
    if ($path) { 
        $name = Split-Path $path -Leaf
        Write-Host -ForegroundColor Yellow "`r`nRunning ngen.exe on '$name'"
        ngen.exe install $path /nologo
    }
}

Write-Host "Deleting Temporary Files..."
Get-ChildItem -Path "C:\Windows\Temp" *.* -Recurse | Remove-Item -Force -Recurse;
Get-ChildItem -Path "C:\Users\$env:UserName\AppData\Local\Temp" *.* -Recurse | Remove-Item -Force -Recurse;


Write-Host "----- Done! -----";
