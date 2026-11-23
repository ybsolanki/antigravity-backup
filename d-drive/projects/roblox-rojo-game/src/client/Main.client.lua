-- KARYŌ Main Client Entry
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CombatController = require(script.Parent:WaitForChild("CombatController"))

print("KARYŌ: Initializing Client Systems...")

-- Start Combat Controller
CombatController.Start()

print("KARYŌ: Client Systems Ready.")
