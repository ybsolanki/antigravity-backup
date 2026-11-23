local ZoneConfig = {
	Zones = {
		{
			Name = "Cafe",
			Position = Vector3.new(80, 10, 0), -- Matches old ConstructionService pos
			Size = Vector3.new(60, 40, 40)
		},
		{
			Name = "SpawnHub",
			Position = Vector3.new(0, 10, 0),
			Size = Vector3.new(50, 40, 50)
		}
	}
}

return ZoneConfig
