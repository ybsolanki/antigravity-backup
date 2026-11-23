<#
.SYNOPSIS
    AdvisorManager - Compatibility Tool for Sarine Advisor and Roblox.
.DESCRIPTION
    This script helps manage conflicts between Sarine Advisor's HASP drivers and Roblox's anti-cheat.
    It provides backup, repair (updating drivers/services), and rollback functionality.
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Check", "Fix", "Rollback")]
    [string]$Action
)

$BackupPath = Join-Path $env:TEMP "AdvisorBackup"
if (!(Test-Path $BackupPath)) { New-Item -ItemType Directory -Path $BackupPath | Out-Null }

function Get-State {
    Write-Host "--- Current System State ---" -ForegroundColor Cyan
    
    # Check TestSigning
    $testSigning = bcdedit /enum {current} | Select-String "testsigning"
    if ($testSigning) { Write-Host "TestSigning: $($testSigning.ToString().Trim())" -ForegroundColor Yellow }
    else { Write-Host "TestSigning: Off (Ideal for Roblox)" -ForegroundColor Green }
    
    # Check HASP Drivers
    $drivers = driverquery /v /fo csv | ConvertFrom-Csv | Where-Object { $_."Display Name" -like "*Sentinel*" -or $_.Name -like "aks*" }
    foreach ($d in $drivers) {
        Write-Host "Driver: $($d.Name) ($($d."Display Name")) - Status: $($d.State) - Date: $($d."Link Date")"
    }
    
    # Check Advisor Service
    if (Test-Path "C:\MSService76\MSService.exe") {
        Write-Host "Advisor Path: C:\MSService76 (Found)" -ForegroundColor Green
    } else {
        Write-Host "Advisor Path: Not found in standard location." -ForegroundColor Red
    }
}

function Backup-State {
    Write-Host "Creating backup in $BackupPath..." -ForegroundColor Cyan
    bcdedit /enum {current} > "$BackupPath\bcdedit_backup.txt"
    driverquery /v /fo csv > "$BackupPath\driver_backup.csv"
    Get-Service | Where-Object { $_.Name -like "aks*" -or $_.Name -like "hasp*" } | Export-Clixml "$BackupPath\services_backup.xml"
    Write-Host "Backup complete." -ForegroundColor Green
}

function Repair-Compatibility {
    Write-Host "Applying Compatibility Fixes..." -ForegroundColor Cyan
    
    # 1. Ensure TestSigning is OFF (Crucial for Roblox)
    Write-Host "Ensuring TestSigning is Disabled..."
    bcdedit /set testsigning off | Out-Null
    
    # 2. Service Optimization
    Write-Host "Optimizing Sentinel Services..."
    $services = Get-Service | Where-Object { $_.Name -like "hasplms" }
    foreach ($s in $services) {
        Set-Service -Name $s.Name -StartupType Automatic
        Restart-Service -Name $s.Name -Force
    }
    
    Write-Host "`n--- IMPORTANT ---" -ForegroundColor Red
    Write-Host "To complete the fix, you should download the latest Sentinel LDK Runtime."
    Write-Host "URL: https://supportportal.thalesgroup.com/csm?id=kb_article_view&sysparm_article=KB0018320"
    Write-Host "This will replace the vulnerable 2016 drivers with modern versions that Roblox allows."
}

function Restore-OriginalState {
    Write-Host "Restoring Original State..." -ForegroundColor Yellow
    
    if (Test-Path "$BackupPath\bcdedit_backup.txt") {
        $oldBcd = Get-Content "$BackupPath\bcdedit_backup.txt"
        if ($oldBcd -match "testsigning\s+Yes") {
            Write-Host "Re-enabling TestSigning (as per backup)..."
            bcdedit /set testsigning on
        }
    }
    
    Write-Host "Rollback finished. Please restart your computer." -ForegroundColor Green
}

if ($Action) {
    switch ($Action) {
        "Check" { Get-State }
        "Fix" { Backup-State; Repair-Compatibility }
        "Rollback" { Restore-OriginalState }
    }
    exit
}

# Simple Menu (for manual run)
Clear-Host
Write-Host "====================================" -ForegroundColor Magenta
Write-Host "   Roblox & Advisor Smooth Tool     " -ForegroundColor Magenta
Write-Host "====================================" -ForegroundColor Magenta
Write-Host "1. Check System Status"
Write-Host "2. Backup and Run Fix"
Write-Host "3. Restore / Rollback"
Write-Host "4. Exit"

$choice = Read-Host "`nSelect an option"

switch ($choice) {
    "1" { Get-State }
    "2" { Backup-State; Repair-Compatibility }
    "3" { Restore-OriginalState }
    "4" { exit }
    default { Write-Host "Invalid choice." }
}
