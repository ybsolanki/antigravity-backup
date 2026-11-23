# Roblox Mode - Disable TestSigning
# Run this as Administrator to play Roblox

Write-Host "Switching to Roblox Mode..." -ForegroundColor Cyan
Write-Host "Disabling TestSigning (Test Mode)..."

# Run the command to turn off test mode
bcdedit /set testsigning off

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[SUCCESS] TestSigning has been disabled." -ForegroundColor Green
    Write-Host "CRITICAL: You MUST restart your computer for this to take effect." -ForegroundColor Red
    Write-Host "After restart, Roblox will be able to run."
} else {
    Write-Host "`n[ERROR] Failed to update BCD configuration. Please ensure you are running as Administrator." -ForegroundColor Red
}

Read-Host "`nPress Enter to exit"
