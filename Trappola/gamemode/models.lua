CSSModels = {{"[CSS] Gasmask","models/player/gasmask.mdl"},
			{"[CSS] Riot","models/player/riot.mdl"},
			{"[CSS] Swat","models/player/swat.mdl"},
			{"[CSS] Urban","models/player/urban.mdl"},
			{"[CSS] Leet","models/player/leet.mdl"},
			{"[CSS] Guerilla","models/player/guerilla.mdl"},
			{"[CSS] Phoenix","models/player/phoenix.mdl"},
			{"[CSS] Arctic","models/player/arctic.mdl"}}
		
if CLIENT then

	function InitModels()
		if table.HasValue(GetMountedContent(),"cstrike") then FoundCSS = true else FoundCSS = false end
	end
	
	function DefaultModels()
		local First
		if not PlayerModels or #PlayerModels <= 0 then First = true end
		PlayerModels = {}
		local function AddModel(Name,Path)
			if First then util.PrecacheModel(Path) end
			table.insert(PlayerModels,{Name,Path})
		end

		AddModel("Kleiner","models/player/kleiner.mdl")
		AddModel("Combine Soldier","models/player/combine_soldier.mdl")
		AddModel("Combine Super Soldier","models/player/combine_super_soldier.mdl")
		AddModel("Combine Prisonguard","models/player/combine_soldier_prisonguard.mdl")
		AddModel("Alyx","models/player/alyx.mdl")
		AddModel("Barney","models/player/barney.mdl")
		AddModel("Dr.Breen","models/player/breen.mdl")
		AddModel("Eli","models/player/eli.mdl")
		AddModel("Gman","models/player/gman_high.mdl")
		AddModel("Mossman","models/player/mossman.mdl")
		AddModel("Odessa","models/player/odessa.mdl")
		AddModel("Zombie","models/player/classic.mdl")
		AddModel("Fast Zombie","models/player/zombiefast.mdl")
		AddModel("Zombie soldier","models/player/zombie_soldier.mdl")

		if FoundCSS then
			for I,M in pairs(CSSModels) do
				AddModel(M[1],M[2])
			end
		end
	end
else
	PlayerModels = {}
	local function AddModel(Name,Path)
		table.insert(PlayerModels,{Name,Path})
	end
	AddModel("Kleiner","models/player/kleiner.mdl")
	AddModel("Combine Soldier","models/player/combine_soldier.mdl")
	AddModel("Combine Super Soldier","models/player/combine_super_soldier.mdl")
	AddModel("Combine Prisonguard","models/player/combine_soldier_prisonguard.mdl")
	AddModel("Alyx","models/player/alyx.mdl")
	AddModel("Barney","models/player/barney.mdl")
	AddModel("Dr.Breen","models/player/breen.mdl")
	AddModel("Eli","models/player/eli.mdl")
	AddModel("Gman","models/player/gman_high.mdl")
	AddModel("Mossman","models/player/mossman.mdl")
	AddModel("Odessa","models/player/odessa.mdl")
	AddModel("Zombie","models/player/classic.mdl")
	AddModel("Fast Zombie","models/player/zombiefast.mdl")
	AddModel("Zombie soldier","models/player/zombie_soldier.mdl")
	for I,M in pairs(CSSModels) do
		AddModel(M[1],M[2])
	end
	AddModel("Miku","models/player/miku.mdl")
	for I,P in pairs(DoshUpgs) do
		if P["Class"] == "Models" then
			AddModel(P["Name"],P["Var"])
		end
	end
end