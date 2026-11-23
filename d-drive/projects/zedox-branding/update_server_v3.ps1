$serverRoot = "d:\MinecraftServer"

# 1. Download Paper 1.21.11 Build 69
$paperUrl = "https://api.papermc.io/v2/projects/paper/versions/1.21.11/builds/69/downloads/paper-1.21.11-69.jar"
$targetJar = Join-Path $serverRoot "server.jar"
Write-Host "Downloading Paper 1.21.11 build 69..."
curl.exe -L $paperUrl -o $targetJar

# 2. Update ViaVersion
$viaUrl = "https://github.com/ViaVersion/ViaVersion/releases/latest/download/ViaVersion.jar"
$viaTarget = Join-Path $serverRoot "plugins\ViaVersion.jar"
Write-Host "Updating ViaVersion..."
curl.exe -L $viaUrl -o $viaTarget

# 3. Update Geyser
$geyserUrl = "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
$geyserTarget = Join-Path $serverRoot "plugins\Geyser-Spigot.jar"
Write-Host "Updating Geyser..."
curl.exe -L $geyserUrl -o $geyserTarget

Write-Host "Updates completed successfully."
