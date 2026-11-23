$logPath = "d:\MinecraftServer\logs\2026-03-30-2.log.gz"
$outputPath = "C:\Users\EI\.gemini\antigravity\scratch\2026-03-26-1.log"

# Use .NET to decompress gzip
try {
    $input = [System.IO.File]::OpenRead($logPath)
    $output = [System.IO.File]::Create($outputPath)
    $gzip = New-Object System.IO.Compression.GzipStream($input, [System.IO.Compression.CompressionMode]::Decompress)
    $gzip.CopyTo($output)
    $gzip.Close()
    $output.Close()
    $input.Close()

    # Output everything
    Get-Content $outputPath
} catch {
    Write-Error $_.Exception.Message
} finally {
    if (Test-Path $outputPath) { Remove-Item $outputPath }
}
