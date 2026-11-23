$SetupDir = "C:\Users\EI\.gemini\antigravity\scratch\shader-setup"
$MinecraftDir = "$env:APPDATA\.minecraft"
$ModsDir = "$MinecraftDir\mods"
$ShadersDir = "$MinecraftDir\shaderpacks"

# URLs for 1.21.11
$Urls = @{
    "fabric-loader.exe" = "https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.exe"
    "fabric-api.jar"    = "https://cdn.modrinth.com/data/P7dR8mSH/versions/i5tSkVBH/fabric-api-0.141.3%2B1.21.11.jar"
    "sodium.jar"        = "https://cdn.modrinth.com/data/AANobbMI/versions/UddlN6L4/sodium-fabric-0.8.7%2Bmc1.21.11.jar"
    "iris.jar"          = "https://cdn.modrinth.com/data/YL57xq9U/versions/fDpuVzVr/iris-fabric-1.10.7%2Bmc1.21.11.jar"
    "shaders.zip"       = "https://cdn.modrinth.com/data/896vU96f/versions/WAbZtK9n/ComplementaryReimagined_r5.3.zip"
}

Write-Host "--- Starting Shader Installation ---"

# 1. Ensure Directories Exist
if (!(Test-Path $SetupDir)) { New-Item -ItemType Directory -Path $SetupDir -Force | Out-Null }

# 2. Download Files
foreach ($FileName in $Urls.Keys) {
    $FilePath = Join-Path $SetupDir $FileName
    if (!(Test-Path $FilePath)) {
        Write-Host "Downloading $FileName..."
        Invoke-WebRequest -Uri $Urls[$FileName] -OutFile $FilePath
    } else {
        Write-Host "$FileName already exists in setup folder."
    }
}

# 3. Setup Minecraft Folders
if (!(Test-Path $ModsDir)) { New-Item -ItemType Directory -Path $ModsDir -Force | Out-Null }
if (!(Test-Path $ShadersDir)) { New-Item -ItemType Directory -Path $ShadersDir -Force | Out-Null }

# 4. Copy Files to Minecraft
Write-Host "Moving files to Minecraft folder..."
Copy-Item (Join-Path $SetupDir "fabric-api.jar") $ModsDir -Force
Copy-Item (Join-Path $SetupDir "sodium.jar") $ModsDir -Force
Copy-Item (Join-Path $SetupDir "iris.jar") $ModsDir -Force
Copy-Item (Join-Path $SetupDir "shaders.zip") $ShadersDir -Force

Write-Host "--- DONE! ---"
Write-Host "Next Step: You MUST run the 'fabric-loader.exe' in your scratch folder to finish the install."
Write-Host "Folder: $SetupDir"
