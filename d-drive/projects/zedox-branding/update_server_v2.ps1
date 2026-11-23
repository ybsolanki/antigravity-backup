$ErrorActionPreference = "Stop"
$serverRoot = "d:\MinecraftServer"

# Set security protocol for TLS 1.2/1.3
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

function Download-Url($url, $target) {
    Write-Host "Downloading $url to $target"
    try {
        Invoke-WebRequest -Uri $url -OutFile $target -TimeoutSec 300
        Write-Host "Downloaded successfully."
    } catch {
        Write-Warning "Downloading with Invoke-WebRequest failed. Retrying with curl.exe..."
        curl.exe -L $url -o $target
    }
}

# 1. Download Paper 1.21.11
$paperUrl = "https://api.papermc.io/v2/projects/paper/versions/1.21.11/builds/127/downloads/paper-1.21.11-127.jar"
$targetJar = Join-Path $serverRoot "server.jar"
Download-Url $paperUrl $targetJar

# 2. Update ViaVersion
$viaUrl = "https://github.com/ViaVersion/ViaVersion/releases/latest/download/ViaVersion.jar"
$viaTarget = Join-Path $serverRoot "plugins\ViaVersion.jar"
Download-Url $viaUrl $viaTarget

# 3. Update Geyser
$geyserUrl = "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
$geyserTarget = Join-Path $serverRoot "plugins\Geyser-Spigot.jar"
Download-Url $geyserUrl $geyserTarget

Write-Host "Updates completed successfully."
