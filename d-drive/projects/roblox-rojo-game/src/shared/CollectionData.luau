local CollectionData = {}

CollectionData.Inventory = {} -- List of currently held high-rarity auras
CollectionData.MAX_SLOTS = 20

-- Returns true if we can store more auras
function CollectionData.CanStore(): boolean
	return #CollectionData.Inventory < CollectionData.MAX_SLOTS
end

-- Adds an aura to the inventory list
function CollectionData.AddAura(auraName: string)
	if #CollectionData.Inventory >= CollectionData.MAX_SLOTS then
		-- In a real game, logic for "Auto-Delete" would happen here
		-- For now, we just cap it.
		return
	end
	table.insert(CollectionData.Inventory, auraName)
end

-- Returns true if the player owns this aura
function CollectionData.IsUnlocked(auraName: string): boolean
	return table.find(CollectionData.Inventory, auraName) ~= nil
end

return CollectionData
