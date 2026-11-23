-- KARYŌ Cleanup Script
local Debris = game:GetService("Debris")

print("KARYŌ: Starting Cleanup...")

-- Remove STUDS residues from Workspace
for _, child in ipairs(workspace:GetChildren()) do
    if child:IsA("Folder") or child:IsA("Model") or child:IsA("Part") then
        if child.Name ~= "Terrain" then
            print("KARYŌ: Removing " .. child.Name)
            child:Destroy()
        end
    end
end

-- Refresh Lighting for "Sorrow" theme
local Lighting = game:GetService("Lighting")
 Lighting.Ambient = Color3.fromRGB(40, 45, 60)
 Lighting.FogColor = Color3.fromRGB(30, 35, 50)
 Lighting.FogEnd = 150
 Lighting.Brightness = 1

print("KARYŌ: Cleanup Complete. Atmosphere set to 'Sorrow'.")
