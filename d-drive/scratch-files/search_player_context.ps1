$logs = Get-ChildItem "d:\MinecraftServer\logs" -Filter "*.log.gz"
$outputPath = "C:\Users\EI\.gemini\antigravity\scratch\player_activity.log"

foreach ($log in $logs) {
    try {
        $input = [System.IO.File]::OpenRead($log.FullName)
        $output = [System.IO.File]::Create($outputPath)
        $gzip = New-Object System.IO.Compression.GzipStream($input, [System.IO.Compression.GzipStreamMode]::Decompress)
        $gzip.CopyTo($output)
        $gzip.Close()
        $output.Close()
        $input.Close()

        $matches = Get-Content $outputPath | Select-String "Meetpansuriya" -Context 0,2
        if ($matches) {
            Write-Host "--- File: $($log.Name) ---"
            $matches | ForEach-Object { Write-Host $_ }
        }
    } catch { }
}

if (Test-Path $outputPath) { Remove-Item $outputPath }
