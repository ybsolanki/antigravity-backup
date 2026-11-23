# Advisor Mode - Enable TestSigning
# Run this as Administrator to use Sarine Advisor

Write-Host "Switching to Advisor Mode..." -ForegroundColor Cyan
Write-Host "Enabling TestSigning (Test Mode)..."

# Run the command to turn on test mode
bcdedit /set testsigning on

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[SUCCESS] TestSigning has been enabled." -ForegroundColor Green
    Write-Host "CRITICAL: You MUST restart your computer for this to take effect." -ForegroundColor Red
    Write-Host "After restart, Sarine Advisor will work properly."
} else {
    Write-Host "`n[ERROR] Failed to update BCD configuration. Please ensure you are running as Administrator." -ForegroundColor Red
}

Read-Host "`nPress Enter to exit"
