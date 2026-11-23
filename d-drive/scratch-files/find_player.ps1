$logs = Get-ChildItem "d:\MinecraftServer\logs" -Filter "*.log.gz"
$outputPath = "C:\Users\EI\.gemini\antigravity\scratch\tmp_search.log"

foreach ($log in $logs) {
    try {
        $input = [System.IO.File]::OpenRead($log.FullName)
        $output = [System.IO.File]::Create($outputPath)
        $gzip = New-Object System.IO.Compression.GzipStream($input, [System.IO.Compression.CompressionMode]::Decompress)
        $gzip.CopyTo($output)
        $gzip.Close()
        $output.Close()
        $input.Close()

        $matches = Get-Content $outputPath | Select-String "Meetpansuriya"
        if ($matches) {
            Write-Host "--- File: $($log.Name) ---"
            $matches | ForEach-Object { Write-Host $_ }
        }
    } catch { }
}

# Also check latest.log
if (Test-Path "d:\MinecraftServer\logs\latest.log") {
    $matches = Get-Content "d:\MinecraftServer\logs\latest.log" | Select-String "Meetpansuriya"
    if ($matches) {
        Write-Host "--- File: latest.log ---"
        $matches | ForEach-Object { Write-Host $_ }
    }
}

if (Test-Path $outputPath) { Remove-Item $outputPath }
