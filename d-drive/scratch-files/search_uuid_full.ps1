$logs = Get-ChildItem "d:\MinecraftServer\logs" -Filter "*.log.gz"
$uuid = "5ee0356e-bcb5-3bc5-a27f-ea7f0b014533"
$outputPath = "C:\Users\EI\.gemini\antigravity\scratch\uuid_search.log"

foreach ($log in $logs) {
    try {
        $input = [System.IO.File]::OpenRead($log.FullName)
        $output = [System.IO.File]::Create($outputPath)
        $gzip = New-Object System.IO.Compression.GzipStream($input, [System.IO.Compression.CompressionMode]::Decompress)
        $gzip.CopyTo($output)
        $gzip.Close()
        $output.Close()
        $input.Close()

        $matches = Get-Content $outputPath | Select-String $uuid
        if ($matches) {
            Write-Host "--- File: $($log.Name) ---"
            $matches | ForEach-Object { Write-Host $_ }
        }
    } catch { }
}

if (Test-Path $outputPath) { Remove-Item $outputPath }
