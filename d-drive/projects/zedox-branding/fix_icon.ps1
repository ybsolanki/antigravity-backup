Add-Type -AssemblyName System.Drawing
$sourcePath = "d:\MinecraftServer\server-icon.png"
$destPath = "d:\MinecraftServer\server-icon-fixed.png"
$img = [System.Drawing.Image]::FromFile($sourcePath)
$newImg = New-Object System.Drawing.Bitmap(64, 64)
$g = [System.Drawing.Graphics]::FromImage($newImg)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($img, 0, 0, 64, 64)
$newImg.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$newImg.Dispose()
$img.Dispose()
Move-Item -Path $destPath -Destination $sourcePath -Force
Write-Host "Resized to 64x64 successfully."
