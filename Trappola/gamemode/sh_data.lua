TrapData = {}

local function InsertData(Trap,Data)
	table.insert(TrapData,{["Name"] = Trap,["Data"] = Data})
end

InsertData("trap_explosive",{{["Name"] = "Damage",[1] = 15,[2] = 17.5,[3] = 20},
							{["Name"] = "Radius",[1] = 75,[2] = 100,[3] = 125},
							{["Name"] = "Cooldown",[1] = 15,[2] = 13.75,[3] = 12.5,[4] = 11.25,[5] = 10}})
InsertData("trap_fakeartifact",{{["Name"] = "Cooldown",[1] = 120}})
InsertData("trap_poison",{{["Name"] = "Damage",[1] = 1.5,[2] = 2,[3] = 2.5,[4] = 3},
							{["Name"] = "Radius",[1] = 75,[2] = 100,[3] = 125},
							{["Name"] = "Cooldown",[1] = 45,[2] = 43.75,[3] = 42.5,[4] = 40},
							{["Name"] = "Duration",[1] = 4,[2] = 5,[3] = 6},
							{["Name"] = "CloudDuration",[1] = 12.5,[2] = 15,[3] = 17.5}})
InsertData("trap_harpoon",{{["Name"] = "Damage",[1] = 15,[2] = 20,[3] = 25},
							{["Name"] = "Cooldown",[1] = 90,[2] = 85,[3] = 80,[4] = 75}})
InsertData("trap_spike",{{["Name"] = "Damage",[1] = 1,[2] = 1.25,[3] = 1.5,[4] = 1.75,[5] = 2},
							{["Name"] = "Model",[1] = "models/props/spiketrapgen1.mdl",[2] = "models/props/spiketrapgen2.mdl",[3] = "models/props/spiketrapgen3.mdl"},
							{["Name"] = "Cooldown",[1] = 120,[2] = 110,[3] = 100}})
InsertData("trap_fakewall",{{["Name"] = "Model",[1] = "models/hunter/blocks/cube2x2x1.mdl",[2] = "models/hunter/blocks/cube4x4x1.mdl",[3] = "models/hunter/blocks/cube4x6x1.mdl",[4] = "models/hunter/blocks/cube6x6x1.mdl",[5] = "models/hunter/blocks/cube6x8x1.mdl",[6] = "models/hunter/blocks/cube8x8x8x1.mdl"},
							{["Name"] = "Cooldown",[1] = 300}})
InsertData("Scavenger",{{["Name"] = "MaxHealth",[1] = 100,[2] = 105,[3] = 110,[4] = 115,[5] = 120},
						{["Name"] = "Endurance",[1] = 10,[2] = 12,[3] = 14,[4] = 17,[5] = 20},
						{["Name"] = "FatigueDrain",[1] = -0.05,[2] = -0.075,[3] = -0.1,[4] = -0.125,[5] = -0.15},
						{["Name"] = "PingAmount",[1] = 1,[2] = 2,[3] = 3},
						{["Name"] = "Medic",[1] = 35,[2] = 47.5,[3] = 60}})
InsertData("Scout",{{["Name"] = "RadarMaxEnergy",[1] = 95,[2] = 100,[3] = 105},
					{["Name"] = "RadarRegain",[1] = 0.2,[2] = 0.4,[3] = 0.6},
					{["Name"] = "RadarDelay",[1] = 1,[2] = 0.75, [3] = 0.5,[4] = 0.25},
					{["Name"] = "RadarPingSpeed",[1] = 4,[2] = 7,[3] = 10}})
InsertData("Defuser",{{["Name"] = "DefuseTime",[1] = 1.75,[2] = 1.5,[3] = 1.25,[4] = 1},
						{["Name"] = "DefuseRadius",[1] = 50,[2] = 75,[3] = 100},
						{["Name"] = "DefuseChance",[1] = 20,[2] = 15,[3] = 10,[4] = 5}})


function GetData(Trap,Var,lvl)
	for I,P in pairs(TrapData) do
		if P["Name"] == Trap then
			for N,T in pairs(P["Data"]) do
				if T["Name"] == Var then
					return T[lvl]
				end
			end
		end
	end
end