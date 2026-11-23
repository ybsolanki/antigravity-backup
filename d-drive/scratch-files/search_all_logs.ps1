$logs = Get-ChildItem "d:\MinecraftServer\logs" -Filter "2026-03-*.log.gz"
$outputPath = "C:\Users\EI\.gemini\antigravity\scratch\tmp_log.log"

foreach ($log in $logs) {
    try {
        $input = [System.IO.File]::OpenRead($log.FullName)
        $output = [System.IO.File]::Create($outputPath)
        $gzip = New-Object System.IO.Compression.GzipStream($input, [System.IO.Compression.CompressionMode]::Decompress)
        $gzip.CopyTo($output)
        $gzip.Close()
        $output.Close()
        $input.Close()

        Get-Content $outputPath
    } catch {
        # Skip errors for single files
    } finally {
        if (Test-Path $outputPath) { Remove-Item $outputPath }
    }
}
