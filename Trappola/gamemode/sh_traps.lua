
Traps = {}

local function SetUpTrap(Name,Trap,Mdl,PlayerLocalized,Unlockable,Info)
	local T = {["Trap"] = Name, ["Trap name"] = Trap, ["Model"] = Model(Mdl), ["PlayerLocalized"] = PlayerLocalized, ["Unlockable"] = Unlockable, ["Info"] = Info}
	table.insert(Traps,T)
end

SetUpTrap("trap_explosive","Explosive trap","models/props/explosivetrap.mdl",true,false,"Highly explosive trap,\nUsed to kill players. (Duh...)")
SetUpTrap("trap_fakeartifact","Fake Artifact trap","models/props/artifact1.mdl",false,false,"Fool players to pick this up,\nwill explode on the player when returned to\nthe spawn.")
SetUpTrap("trap_poison","Poison trap","models/props/poisontrap.mdl",true,true,"Evil Poison trap will scare\npeople away.")
SetUpTrap("trap_harpoon","Harpoon trap","models/props/harpoontrap.mdl",true,true,"A trap that launches a harpoon at\npeople who pass by.\nThe harpoon will launch from the\n position where you were\nwhen you placed it.")
SetUpTrap("trap_fakewall","Fakewall trap","models/props/fakewalltrap.mdl",false,true,"Insert a trigger that calls down\n a wall that crushes players.")
SetUpTrap("trap_spike","Spike trap","models/props/spiketrap.mdl",true,true,"Spawns a permanent spike trap that\n does dmg over time to players\n that are on top of it.")

function FindTrap(Trap)
	for I,P in pairs(Traps) do
		if P["Trap"] == Trap then
			return P,I
		end
	end
end

local Meta = FindMetaTable("Player")

function Meta:GetTrap()
	return self:GetNWString("SelectedTrap")
end

function IsValidTrap(Trap)
	if not Trap then return false end
	local Alr = false
	for I,P in pairs(Traps) do
		if P["Trap"] == Trap then
			Alr = true
			break
		end
	end
	
	if Alr then
		return true
	else
		return false
	end
	
end

if SERVER then

	function Meta:SetTrap(trap)
		self:SetNWString("SelectedTrap",trap)
	end
	
end