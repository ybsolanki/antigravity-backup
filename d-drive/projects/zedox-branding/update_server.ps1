$ErrorActionPreference = "Stop"
$serverRoot = "d:\MinecraftServer"

# 1. Download Paper 1.21.11
$paperUrl = "https://api.papermc.io/v2/projects/paper/versions/1.21.11/builds/127/downloads/paper-1.21.11-127.jar"
$targetJar = Join-Path $serverRoot "server.jar"
Write-Host "Downloading Paper 1.21.11..."
Invoke-WebRequest -Uri $paperUrl -OutFile $targetJar

# 2. Update ViaVersion
$viaUrl = "https://github.com/ViaVersion/ViaVersion/releases/latest/download/ViaVersion.jar"
$viaTarget = Join-Path $serverRoot "plugins\ViaVersion.jar"
Write-Host "Updating ViaVersion..."
Invoke-WebRequest -Uri $viaUrl -OutFile $viaTarget

# 3. Update Geyser
$geyserUrl = "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
$geyserTarget = Join-Path $serverRoot "plugins\Geyser-Spigot.jar"
Write-Host "Updating Geyser..."
Invoke-WebRequest -Uri $geyserUrl -OutFile $geyserTarget

Write-Host "Updates completed successfully."
