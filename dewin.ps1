###################################
# File    : dewin.ps1
# Author  : Avishek Dutta
# URL     : https://github.com/tyroruyk/dewin/
# LICENSE : MIT license
###################################

# Write a log file for future reference
$logFile = "$env:SystemDrive\DeWinLog.txt"
function Write-Log {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $logFile -Value $Message
}

Write-Log "----- Starting System Cleanup and Optimization -----" -Color Cyan

# Fixing ngen.exe and optimizing assemblies
Write-Log "Fixing ngen.exe and optimizing .NET assemblies..."

try {
    $env:PATH = [Runtime.InteropServices.RuntimeEnvironment]::GetRuntimeDirectory()
    [AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
        $path = $_.Location
        if ($path) {
            $name = Split-Path $path -Leaf
            Write-Log "`r`nRunning ngen.exe on '$name'" -Color Yellow
            # Start-Process is safer than calling ngen.exe directly
            Start-Process -FilePath "ngen.exe" -ArgumentList "install $path /nologo" -NoNewWindow -Wait
        }
    }
    Write-Log "ngen.exe optimization completed." -Color Green
} catch {
    Write-Log "Error while running ngen.exe: $_" -Color Red
}

# Cleaning up temporary files in multiple directories
Write-Log "Deleting Temporary Files..." -Color Cyan

$foldersToClean = @(
    "C:\Windows\Temp",
    "C:\Users\$env:UserName\AppData\Local\Temp",
    "C:\Users\$env:UserName\AppData\Local\Microsoft\Windows\INetCache",
    "C:\Users\$env:UserName\AppData\Local\Microsoft\Windows\Explorer"
)

foreach ($folder in $foldersToClean) {
    try {
        Write-Log "Cleaning: $folder" -Color Yellow
        # -Recurse ensures all files and folders are removed
        Get-ChildItem -Path $folder -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Log "Successfully cleaned: $folder" -Color Green
    } catch {
        Write-Log "Error cleaning ${folder}: $($_.Exception.Message)" -Color Red
    }
}

# Optional: Cleaning Windows Update Cache (can free up space but be cautious)
$clearWindowsUpdateCache = $true
if ($clearWindowsUpdateCache) {
    Write-Log "Cleaning Windows Update Cache..." -Color Cyan
    $wuFolder = "C:\Windows\SoftwareDistribution\Download"
    try {
        Get-ChildItem -Path $wuFolder -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Log "Successfully cleaned Windows Update cache." -Color Green
    } catch {
        Write-Log "Error cleaning Windows Update cache: $_" -Color Red
    }
}

# Removing prefetch files (Optional)
$cleanPrefetch = $true
if ($cleanPrefetch) {
    Write-Log "Cleaning Prefetch files..." -Color Cyan
    $prefetchFolder = "C:\Windows\Prefetch"
    try {
        Get-ChildItem -Path $prefetchFolder -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
        Write-Log "Successfully cleaned Prefetch files." -Color Green
    } catch {
        Write-Log "Error cleaning Prefetch files: $_" -Color Red
    }
}

# Optional: Disk Cleanup via cleanmgr (use cautiously)
$runDiskCleanup = $true
if ($runDiskCleanup) {
    Write-Log "Running Disk Cleanup (cleanmgr)..." -Color Cyan
    try {
        Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait
        Write-Log "Disk Cleanup completed." -Color Green
    } catch {
        Write-Log "Error running Disk Cleanup: $_" -Color Red
    }
}

# Final Status
Write-Log "----- System Cleanup and Optimization Completed -----" -Color Cyan
Write-Host "`nLog saved to: $logFile" -ForegroundColor Green

