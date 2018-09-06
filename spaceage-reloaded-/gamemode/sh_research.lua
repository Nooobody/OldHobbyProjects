
local Research = {
	Mining_Laser_Mark_I = {
		InitialCost = 2000,
		CostMulPer = 600,
		Levels = 300,
		Category = "Laser",
		Desc = "Mark 1 lasers get the job done, they are a good starting point for all the newbie miners out there.",
		Class = "sa_mining_laser"
	},
	Mining_Laser_Mark_II = {
		InitialCost = 182000,
		CostMulPer = 2050,
		Levels = 300,
		Category = "Laser",
		Desc = "Mark 2 lasers is the next generation thing for everyone. It has super-efficiency compared to the previous generation. (Dog AI not included)",
		PreReqs = {
			Laser_Tech_Research = 2
		},
		Class = "sa_mining_laser"
	},
	Mining_Laser_Mark_III = {
		InitialCost = 797000,
		CostMulPer = 9000,
		Levels = 300,
		Category = "Laser",
		Desc = "Mark 3 lasers pack the punch when dealing with asteroids. (No asteroids were hurt when this advertisement was made.)",
		PreReqs = {
			Laser_Tech_Research = 3
		},
		Class = "sa_mining_laser"
	},
	Mining_Laser_Mark_IV = {
		InitialCost = 3497000,
		CostMulPer = 37500,
		Levels = 300,
		Category = "Laser",
		Desc = "Mark 4 lasers, when Mark 3 isn't enough.",
		PreReqs = {
			Laser_Tech_Research = 4
		},
		Class = "sa_mining_laser"
	},
	Mining_Laser_Mark_V = {
		InitialCost = 14747000,
		CostMulPer = 160000,
		Levels = 300,
		Category = "Laser",
		Desc = "Congratulations, you've evolved into a grown miner with a huge beard and whatnot, haven't you?",
		PreReqs = {
			Laser_Tech_Research = 5
		},
		Class = "sa_mining_laser"
	},
	Laser_Tech_Research = {
		InitialCost = 0,
		CostMulPer = 0,
		Costs = {
			0,
			290000,
			980000,
			3950000,
			15500000
		},
		PreReqs = {
			[2] = {Mining_Laser_Mark_I = 300},
			[3] = {Mining_Laser_Mark_II = 300},
			[4] = {Mining_Laser_Mark_III = 300},
			[5] = {Mining_Laser_Mark_IV = 300}
		},
		Levels = 5,
		Category = "Tech",
		Desc = "When you're just not satisfied with your equipment."
	},
	Laser_Power_Reduction = {
		InitialCost = 5000,
		CostMulPer = 5000,
		Levels = 75,
		Category = "Laser",
		Desc = "This can be handy if you don't know how to set up a proper resource system for your miner ship.",
		Class = "sa_mining_laser"
	},
	
	
	Raw_Ore_Storage_Tiny = {
		InitialCost = 2500,
		CostMulPer = 660,
		Levels = 300,
		Category = "Storage",
		Desc = "Tiny storages are not enough, except for you.",
		Class = "sa_mining_rawore_storage"
	},
	Raw_Ore_Storage_Small = {
		InitialCost = 200500,
		CostMulPer = 2250,
		Levels = 300,
		Category = "Storage",
		Desc = "A small storage is like 2 tiny storages put together, wait, what?",
		PreReqs = {
			Storage_Tech_Research = 2
		},
		Class = "sa_mining_rawore_storage"
	},
	Raw_Ore_Storage_Medium = {
		InitialCost = 875500,
		CostMulPer = 9750,
		Levels = 300,
		Category = "Storage",
		Desc = "Medium storages are starting to make a difference in that they devour your ore while you sleep.",
		PreReqs = {
			Storage_Tech_Research = 3
		},
		Class = "sa_mining_rawore_storage"
	},
	Raw_Ore_Storage_Large = {
		InitialCost = 3800500,
		CostMulPer = 41750,
		Levels = 300,
		Category = "Storage",
		Desc = "Large is the next step from...medium.",
		PreReqs = {
			Storage_Tech_Research = 4
		},
		Class = "sa_mining_rawore_storage"
	},
	Raw_Ore_Storage_Huge = {
		InitialCost = 16325500,
		CostMulPer = 175000,
		Levels = 300,
		Category = "Storage",
		Desc = "My god, that's like a planet full of ore, better protect it well.",
		PreReqs = {
			Storage_Tech_Research = 5
		},
		Class = "sa_mining_rawore_storage"
	},
	Storage_Tech_Research = {
		InitialCost = 0,
		CostMulPer = 0,
		Costs = {
			0,
			315000,
			1395000,
			4890000,
			23600000
		},
		PreReqs = {
			[2] = {Raw_Ore_Storage_Tiny = 300},
			[3] = {Raw_Ore_Storage_Small = 300},
			[4] = {Raw_Ore_Storage_Medium = 300},
			[5] = {Raw_Ore_Storage_Large = 300}
		},
		Levels = 5,
		Category = "Tech",
		Desc = "The desire for more resources has driven mankind to get bigger storages."
	},
	Drill_Efficiency_Mark_I = {
		InitialCost = 5000,
		CostMulPer = 1425,
		Levels = 400,
		Category = "Drill",
		Desc = "For the aspiring tiberium harvesters out there, these are a viable choice of weaponry against tiberium.",
		Class = "sa_mining_drill"
	},
	Drill_Efficiency_Mark_II = {
		InitialCost = 575000,
		CostMulPer = 7000,
		Levels = 400,
		Category = "Drill",
		Desc = "Mark I not enough for you? Guess you need the big guns then. Here, have some.",
		PreReqs = {
			Drill_Tech_Research = 2
		},
		Class = "sa_mining_drill"
	},
	Drill_Efficiency_Mark_III = {
		InitialCost = 3375000,
		CostMulPer = 45750,
		Levels = 400,
		Category = "Drill",
		Desc = "Mark III should have the power needed to penetrate those crystals.",
		PreReqs = {
			Drill_Tech_Research = 3
		},
		Class = "sa_mining_drill"
	},
	Drill_Tech_Research = {
		InitialCost = 0,
		CostMulPer = 0,
		Costs = {
			0,
			800000,
			4800000
		},
		PreReqs = {
			[2] = {Drill_Efficiency_Mark_I = 400},
			[3] = {Drill_Efficiency_Mark_II = 400}
		},
		Levels = 3,
		Category = "Tech",
		Desc = "For making your pur-I mean mankind's wealth rise, we've developed even bigger drills to achieve our goals."
	},
	Raw_Tiberium_Storage_Small = {
		InitialCost = 15000,
		CostMulPer = 1375,
		Levels = 300,
		Category = "Storage",
		Desc = "A lot of tiberium will fit into a small storage...JUST KIDDING!",
		Class = "sa_mining_rawtib_storage"
	},
	Raw_Tiberium_Storage_Medium = {
		InitialCost = 427500,
		CostMulPer = 4950,
		Levels = 300,
		Category = "Storage",
		Desc = "Medium storages for tiberium you say? Okay then, have it your way.",
		PreReqs = {
			Tiberium_Storage_Tech_Research = 2
		},
		Class = "sa_mining_rawtib_storage"
	},
	Raw_Tiberium_Storage_Large = {
		InitialCost = 1912500,
		CostMulPer = 20750,
		Levels = 300,
		Category = "Storage",
		Desc = "Large storages? Is that a thing? Guess it is now.",
		PreReqs = {
			Tiberium_Storage_Tech_Research = 3
		},
		Class = "sa_mining_rawtib_storage"
	},
	Raw_Tiberium_Storage_Huge = {
		InitialCost = 8137500,
		CostMulPer = 81750,
		Levels = 300,
		Category = "Storage",
		Desc = "And I thought this was a joke.",
		PreReqs = {
			Tiberium_Storage_Tech_Research = 3
		},
		Class = "sa_mining_rawtib_storage"
	},
	Tiberium_Storage_Tech_Research = {
		InitialCost = 0,
		CostMulPer = 0,
		Costs = {
			0,
			650000,
			3250000,
			10000000
		},
		PreReqs = {
			[2] = {Raw_Tiberium_Storage_Small = 300},
			[3] = {Raw_Tiberium_Storage_Medium = 300},
			[4] = {Raw_Tiberium_Storage_Large = 300}
		},
		Levels = 4,
		Category = "Tech",
		Desc = "I'm not sure what's with all the people rushing for bigger storages. I think it's because of the payout getting bigger."
	},
	
	Ice_Laser_Mark_I = {
		InitialCost = 6000,
		CostMulPer = 3750,
		Levels = 300,
		Category = "Ice",
		Desc = "For Ice, Mark I is where you start",
		Class = "sa_mining_icelaser"
	},
	Ice_Laser_Mark_II = {
		InitialCost = 1131000,
		CostMulPer = 3900,
		Levels = 300,
		Category = "Ice",
		Desc = "Mark II huh? Just don't hurt yourself, okay?",
		PreReqs = {
			Ice_Laser_Tech_Research = 2
		},
		Class = "sa_mining_icelaser"
	},
	Ice_Laser_Mark_III = {
		InitialCost = 2301000,
		CostMulPer = 24575,
		Levels = 300,
		Category = "Ice",
		Desc = "You're halfway there! Keep it up!",
		PreReqs = {
			Ice_Laser_Tech_Research = 3
		},
		Class = "sa_mining_icelaser"
	},
	Ice_Laser_Mark_IV = {
		InitialCost = 9673500,
		CostMulPer = 29750,
		Levels = 300,
		Category = "Ice",
		Desc = "Mark IV you said? That's nice. It seems you do have the skill to operate them after all.",
		PreReqs = {
			Ice_Laser_Tech_Research = 4
		},
		Class = "sa_mining_icelaser"
	},
	Ice_Laser_Mark_V = {
		InitialCost = 18598500,
		CostMulPer = 177500,
		Levels = 300,
		Category = "Ice",
		Desc = "The end of the road, almost.",
		PreReqs = {
			Ice_Laser_Tech_Research = 5
		},
		Class = "sa_mining_icelaser"
	},
	Ice_Laser_Tech_Research = {
		InitialCost = 0,
		CostMulPer = 0,
		Costs = {
			0,
			1500000,
			2950000,
			11000000,
			24500000
		},
		PreReqs = {
			[2] = {Ice_Laser_Mark_I = 300},
			[3] = {Ice_Laser_Mark_II = 300},
			[4] = {Ice_Laser_Mark_III = 300},
			[5] = {Ice_Laser_Mark_IV = 300}
		},
		Levels = 5,
		Category = "Tech",
		Desc = "Leveling up, aren't you? That's nice."
	},
	Raw_Ice_Storage_Small = {
		InitialCost = 6500,
		CostMulPer = 3500,
		Levels = 300,
		Category = "Ice",
		Desc = "You sure it's small enough for you?",
		Class = "sa_mining_rawice_storage"
	},
	Raw_Ice_Storage_Medium = {
		InitialCost = 1056500,
		CostMulPer = 4500,
		Levels = 300,
		Category = "Ice",
		Desc = "I wonder what comes after medium...",
		PreReqs = {
			Raw_Ice_Tech_Research = 2
		},
		Class = "sa_mining_rawice_storage"
	},
	Raw_Ice_Storage_Large = {
		InitialCost = 2406500,
		CostMulPer = 24750,
		Levels = 300,
		Category = "Ice",
		Desc = "Large storages, here we go!",
		PreReqs = {
			Raw_Ice_Tech_Research = 3
		},
		Class = "sa_mining_rawice_storage"
	},
	Raw_Ice_Storage_Huge = {
		InitialCost = 9831500,
		CostMulPer = 27500,
		Levels = 300,
		Category = "Ice",
		Desc = "Wait, did someone forget the size limits?",
		PreReqs = {
			Raw_Ice_Tech_Research = 4
		},
		Class = "sa_mining_rawice_storage"
	},
	Raw_Ice_Storage_Colossal = {
		InitialCost = 18081500,
		CostMulPer = 187500,
		Levels = 300,
		Category = "Ice",
		Desc = "Size limits? What size limits?",
		PreReqs = {
			Raw_Ice_Tech_Research = 5
		},
		Class = "sa_mining_rawice_storage"
	},
	Raw_Ice_Tech_Research = {
		InitialCost = 0,
		CostMulPer = 0,
		Costs = {
			0,
			1735000,
			3145000,
			19500000,
			24000000
		},
		PreReqs = {
			[2] = {Raw_Ice_Storage_Small = 300},
			[3] = {Raw_Ice_Storage_Medium = 300},
			[4] = {Raw_Ice_Storage_Large = 300},
			[5] = {Raw_Ice_Storage_Huge = 300}
		},
		Levels = 5,
		Category = "Tech",
		Desc = "More Ice equals more profits. That's what momma used to say."
	},
	Refinery_Mark_I = {
		InitialCost = 6600,
		CostMulPer = 3000,
		Levels = 500,
		Category = "Ice",
		Desc = "Refining is for wussies, didn't your mom tell you that?",
		Class = "sa_mining_refinery"
	},
	Refinery_Mark_II = {
		InitialCost = 1506600,
		CostMulPer = 17500,
		Levels = 500,
		Category = "Ice",
		Desc = "Still want to keep going? Okay, I won't stop you. Just remember what I said!",
		PreReqs = {
			Refinery_Tech = 2
		},
		Class = "sa_mining_refinery"
	},
	Refinery_Mark_III = {
		InitialCost = 10256600,
		CostMulPer = 122750,
		Levels = 500,
		Category = "Ice",
		Desc = "I guess you've changed my mind. Refining seems like a good business after all.",
		PreReqs = {
			Refinery_Tech = 3
		},
		Class = "sa_mining_refinery"
	},
	Refinery_Tech = {
		InitialCost = 0,
		CostMulPer = 0,
		Costs = {
			0,
			3000000,
			15000000,
		},
		PreReqs = {
			[2] = {Refinery_Mark_I = 500},
			[3] = {Refinery_Mark_II = 500},
		},
		Levels = 3,
		Category = "Tech",
		Desc = "Refining Refineries, aren't you?"
	},
	Refined_Ice_Storage_Small = {
		InitialCost = 70000,
		CostMulPer = 3000,
		Levels = 500,
		Category = "Ice",
		Desc = "Storing refined Ice is like storing raw ice, but in bigger quantities.",
		Class = "sa_mining_refinedice_storage"
	},
	Refined_Ice_Storage_Medium = {
		InitialCost = 1570000,
		CostMulPer = 18750,
		Levels = 500,
		Category = "Ice",
		Desc = "Medium storages for refined Ice? That's a lot to fathom.",
		PreReqs = {
			Refined_Ice_Tech_Research = 2
		},
		Class = "sa_mining_refinedice_storage"
	},
	Refined_Ice_Storage_Large = {
		InitialCost = 10945000,
		CostMulPer = 127500,
		Levels = 500,
		Category = "Ice",
		Desc = "Sure this is enough? Still need bigger than this? Can't help you there.",
		PreReqs = {
			Refined_Ice_Tech_Research = 3
		},
		Class = "sa_mining_refinedice_storage"
	},
	Refined_Ice_Tech_Research = {
		InitialCost = 0,
		CostMulPer = 0,
		Costs = {
			0,
			2245000,
			19750000,
		},
		PreReqs = {
			[2] = {Refined_Ice_Storage_Small = 500},
			[3] = {Refined_Ice_Storage_Medium = 500},
		},
		Levels = 3,
		Category = "Tech",
		Desc = "Not enough space to process your long trip's plunders? Try this for a cure."
	},
	
	Socket_Transmission_Speed = {
		InitialCost = 500,
		CostMulPer = 500,
		Levels = 300,
		Category = "Resource",
		Desc = "Speed is the key for profit! So why not speed up a little?"
	},
	Socket_Optic_Fiber = {
		InitialCost = 57250,
		CostMulPer = 15150,
		Levels = 100,
		Category = "Resource",
		Desc = "Normal plugwires not good enough? Try optic fiber, it should put the plug on transmission times.",
		PreReqs = {
			Socket_Transmission_Speed = 300
		}
	},
	Socket_Plasma_Fiber = {
		InitialCost = 10000000,
		CostMulPer = 86250,
		Levels = 100,
		Category = "Resource",
		Desc = "Tell you what. I know the economy is bad. I know we are all suffering. So let's share a bit of brotherly love, okay? Here, take these. These'll help you.",
		PreReqs = {
			Socket_Optic_Fiber = 100
		}
	},
	Socket_Packet_Loss = {
		InitialCost = 1500000,
		CostMulPer = 45000,
		Levels = 50,
		Category = "Resource",
		Desc = "Physical Transmit always has some packet loss, try this for a cure.",
		PreReqs = {
			Laser_Tech_Research = 3
		}
	},
	Fusion_Generator_Coolant = {
		InitialCost = 493100,
		CostMulPer = 493100,
		Levels = 10,
		Category = "Resource",
		Desc = "Problems with fusion generators overheating? Not anymore! This one reduces the amount of heat the fusion generates."
	},
	Solar_Panel_Output = {
		InitialCost = 10000,
		CostMulPer = 9500,
		Levels = 30,
		Category = "Resource",
		Desc = "The solar way is the only way. Increases output."
	},
	Fusion_Power_Up = {
		InitialCost = 1000000,
		CostMulPer = 250000,
		Levels = 30,
		Category = "Resource",
		Desc = "Here, have some more energy.",
		PreReqs = {
			Laser_Tech_Research = 4
		},
		Class = "sa_generator_fusion"
	},
	Multiple_Resource_Storage = {
		InitialCost = 0,
		CostMulPer = 0,
		Levels = 4,
		Costs = {
			[1] = 50000,
			[2] = 1000000,
			[3] = 5000000,
			[4] = 100000000
		},
		Category = "Tech",
		Desc = "Running out of space? No problem! The latest in storage research has unveiled a new way to store resources, in a multi-use storage cache!"
	},
	Solar_Research = {
		InitialCost = 0,
		CostMulPer = 0,
		Levels = 2,
		Costs = {
			[1] = 0,
			[2] = 10000000
		},
		Category = "Tech",
		Desc = "Not contempt with current solar panel's performance? Try these to brighten up your mood."
	},
	Fusion_Research = {
		InitialCost = 0,
		CostMulPer = 0,
		Levels = 4,
		Costs = {
			[1] = 0,
			[2] = 50000,
			[3] = 1875000,
			[4] = 25000000
		},
		Category = "Tech",
		Desc = "Fusioning up is the reasonable thing to do."
	},
	Hydro_Turbine_Research = {
		InitialCost = 0,
		CostMulPer = 0,
		Levels = 3,
		Costs = {
			[1] = 0,
			[2] = 175000,
			[3] = 2750000
		},
		Category = "Tech",
		Desc = "Harnessing the power of water is a good thing, do it more often!"
	},	
	Teleportation = {
		InitialCost = 1000000,
		CostMulPer = 1,
		Levels = 1,
		Category = "Tech",
		Desc = "Traveling within the limits of physics seem boring? With this technology, you'll unlock the Hoverdrive, which allows for hyperdrive-ish movement."
	},
	PropCore_Unlock = {
		InitialCost = 100000000,
		CostMulPer = 1,
		Levels = 1,
		Category = "Tech",
		Desc = "Wanting to make a ship so awesome no other man could do it? With this, you'll be able to move any prop anywhere anytime! (Expression2 only)"
	}
}

function GetResearch(Name)
	return Research[Name]
end

if SERVER then
	function GetAllResearch()
		return Research
	end
	
	local Ply = FindMetaTable("Player")
	
	function Ply:GetResearch(str)
		if not self.Research then return 0 end
		if self.Research[str] then
			return self.Research[str]
		else
			local Res = GetResearch(str)
			if not Res.PreReqs then
				self.Research[str] = 0
				return 0
			end
		end
		return 0
	end
end