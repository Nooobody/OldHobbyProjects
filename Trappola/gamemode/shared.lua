include("sh_traps.lua")
include("sh_data.lua")

GM.Name 	= "Trappola"
GM.Author 	= "No-Oil Productions"
GM.Email 	= "Management@no-oilproductions.ukgamers.com"
GM.Website 	= "www.no-oilproductions.webs.com"

team.SetUp(1,"Scavengers",Color(160,82,45,255))
team.SetUp(2,"Traplayers",Color(173,255,47,255))
team.SetUp(3,"Spectate",Color(189,183,107,255))

local Meta = FindMetaTable("Player")

function Meta:GetPrivilege()
	return self:GetNWInt("Privilege")
end

function Meta:GetExp()
	return tonumber(self:GetNWInt("Experience"))
end

function Meta:GetDosh()
	return tonumber(self:GetNWInt("Dosh"))
end

function GetPlyArtStat(ply)
	if ply:GetNWBool("Arti") or ply:GetNWBool("FakeArti") then
		return true
	else
		return false
	end
end

function IsScavenger(ply)
	if not ply then return false end
	if ply:IsPlayer() and ply:Team() == 1 then
		return true
	end
	return false
end

if SERVER then
	
	function Meta:SetPrivilege(priv)
		if priv == 2 then
			Owner = self
		end
		self:SetNWInt("Privilege",priv)
	end
	
	function Meta:GetFatigue()
		return self.Fatigue
	end
	
	function Meta:SetExp(Int)
		self:SetNWInt("Experience",Int)
	end
	
	function Meta:Dosh(Dosh)
		self:SetNWInt("Dosh",Dosh)
	end
	
	function Meta:AddDosh(Dosh)
		local Dosh = self:GetNWInt("Dosh") + Dosh
		self:SetNWInt("Dosh",Dosh)
		DB_DoshPly(self:SteamID(),"Dosh",Dosh)
	end
	
	function Meta:AddExp(Int)
		self:SetNWInt("Experience",self:GetNWInt("Experience") + Int)
		DB_UpdateAddIndPly(self:SteamID(),"Experience",Int)
		if Int > 0 then
			DB_UpdateAddIndPly(self:SteamID(),"TotalExperience",Int)
		end
	end
	
end

function GM:ShouldCollide(ent1,ent2)
	if ent1:IsPlayer() and ent2:IsPlayer() then
		return false
	end
	if ent1:IsPlayer() and string.find(ent2:GetClass(),"artifact") then
		return false
	elseif ent2:IsPlayer() and string.find(ent1:GetClass(),"artifact") then
		return false
	end
	if ent1:IsPlayer() and string.find(ent2:GetClass(),"trap_") then
		return false
	elseif	ent2:IsPlayer() and string.find(ent1:GetClass(),"trap_") then
		return false
	end
	if ent1:IsPlayer() and ent2:GetClass() == "prop_physics" and not string.find(ent2:GetModel(),"cube") then
		return false
	elseif	ent2:IsPlayer() and ent1:GetClass() == "prop_physics" and not string.find(ent1:GetModel(),"cube") then
		return false
	end
	return true
end

TrapUpgrades = {}

local function InsertTrapUpg(Trap,Var,Cost,CostIncrement,Maxlvl,Desc)
	table.insert(TrapUpgrades,{["Trap"] = Trap,["Var"] = Var,["Cost"] = Cost,["CostInc"] = CostIncrement,["Maxlvl"] = Maxlvl,["Description"] = Desc})
end

InsertTrapUpg("trap_explosive","Damage",500,750,3,"Increases the damage of the explosive trap.")
InsertTrapUpg("trap_explosive","Radius",500,750,3,"Increases the radius of the explosive trap.")
InsertTrapUpg("trap_explosive","Cooldown",500,750,5,"Decreases the cooldown of the explosive trap.")
InsertTrapUpg("trap_poison","Unlock",300,0,1,"Unlocks the poison trap.")
InsertTrapUpg("trap_poison","Damage",750,1000,4,"Increases the damage over time of the poison trap.")
InsertTrapUpg("trap_poison","Radius",1000,1250,3,"Increases the radius of the poison trap.")
InsertTrapUpg("trap_poison","Cooldown",1250,1250,4,"Decreases the cooldown of the poison trap.")
InsertTrapUpg("trap_poison","Duration",650,875,3,"Increases the duration of the poison effect.")
InsertTrapUpg("trap_poison","CloudDuration",850,675,3,"Increases the duration of the poison cloud.")
InsertTrapUpg("trap_harpoon","Unlock",450,0,1,"Unlocks the harpoon trap.")
InsertTrapUpg("trap_harpoon","Damage",750,750,3,"Increases the damage of the harpoon trap.")
InsertTrapUpg("trap_harpoon","Cooldown",750,750,4,"Decreases the cooldown of the harpoon trap.")
InsertTrapUpg("trap_fakewall","Unlock",2500,0,1,"Unlocks the fakewall trap.")
InsertTrapUpg("trap_fakewall","Model",1500,1500,6,"Increases the size of the fakewall.")
InsertTrapUpg("trap_spike","Unlock",750,0,1,"Unlocks the spike trap.")
InsertTrapUpg("trap_spike","Model",1000,1000,3,"Increases the size of the spiketrap.")
InsertTrapUpg("trap_spike","Damage",1000,1000,5,"Increases the damage over time of the spiketrap.")
InsertTrapUpg("trap_spike","Cooldown",750,750,3,"Decreases the cooldown of the spike trap.")

ScavUpgrades = {}

local function InsertScavUpg(Class,Var,Cost,CostIncrement,Maxlvl,Desc)
	table.insert(ScavUpgrades,{["Class"] = Class,["Var"] = Var,["Cost"] = Cost,["CostInc"] = CostIncrement,["Maxlvl"] = Maxlvl,["Description"] = Desc})
end

InsertScavUpg("Scavenger","MaxHealth",500,500,5,"Increases the health of the player.")
InsertScavUpg("Scavenger","Endurance",500,500,5,"Increases the length of time it takes for the player to get fatigued.")
InsertScavUpg("Scavenger","FatigueDrain",500,500,5,"Fastens the fatigue drain, making the time it takes to run again shorter.")
InsertScavUpg("Scavenger","PingAmount",1111,1111,3,"Increases the amount of pings you can have at one time.")
InsertScavUpg("Scavenger","Medic",500,500,3,"Increases the health given by the medkit.")
InsertScavUpg("Defuser","DefuseTime",500,500,4,"Reduces the time it takes to defuse something with the defuser.")
InsertScavUpg("Defuser","DefuseRadius",450,350,3,"Increases the radius of the defuser.")
InsertScavUpg("Defuser","DefuseChance",550,400,4,"Increases the chance of success when defusing.")
InsertScavUpg("Scout","RadarMaxEnergy",750,750,3,"Increases radar's max energy.")
InsertScavUpg("Scout","RadarRegain",550,550,3,"Increases the rate of energy gain on radar.")
InsertScavUpg("Scout","RadarDelay",500,250,4,"Decreases time between pings. Also increases rate at which energy is drained.")
InsertScavUpg("Scout","RadarPingSpeed",500,350,3,"Increases speed of radar ping.")

DoshUpgs = {}

local function InsertDosh(Class,Name,Var,Data,Cost,Desc)
	table.insert(DoshUpgs,{["Class"] = Class,["Name"] = Name,["Var"] = Var,["Data"] = Data,["Cost"] = Cost,["Desc"] = Desc})
end

InsertDosh("Models","Rin",Model("models/rin.mdl"),nil,5)
InsertDosh("Models","LibertyPrime",Model("models/player/sam.mdl"),nil,5)
InsertDosh("Models","GrimReaper",Model("models/grim.mdl"),nil,5)
InsertDosh("Tokens","Respawn",nil,nil,15,"Used to respawn after dying in a round, can only be used once per round")
InsertDosh("Tokens","Cooldown",nil,nil,5,"Used to eliminate cooldowns on one trap, can only be used once per round")
InsertDosh("Hats","Cone",Model("models/props_junk/TrafficCone001a.mdl"),{function(pos,ang) pos = pos + ang:Forward()*18 + ang:Right()*1
	ang:RotateAroundAxis(ang:Right(),-90) end,function(pos,ang) return pos,ang end},5)
InsertDosh("Hats","HelicopterBomb",Model("models/combine_helicopter/helicopter_bomb01.mdl"),{function(pos,ang) return pos,ang end,function(pos,ang) return pos,ang end},5)
InsertDosh("Hats","SawBlade",Model("models/props_junk/sawblade001a.mdl"),{function(pos,ang) return pos,ang end,function(pos,ang) return pos,ang end},5)
InsertDosh("Hats","PropaneCanister",Model("models/props_junk/propanecanister001a.mdl"),{function(pos,ang) return pos,ang end,function(pos,ang) return pos,ang end},5)
InsertDosh("Hats","Skull",Model("models/Gibs/HGIBS.mdl"),{function(pos,ang,Ent) Ent:SetModelScale(Vector(2,2,2)) return pos,ang end,function(pos,ang,Ent) Ent:SetModelScale(Vector(2,2,2)) return pos,ang end},5)
InsertDosh("Hats","AntlionHead",Model("models/Gibs/Antlion_gib_Large_2.mdl"),{function(pos,ang) 
	pos = pos + ang:Forward()*6 + ang:Right()*4
	ang:RotateAroundAxis(ang:Up(),90)
	ang:RotateAroundAxis(ang:Forward(),270)
	ang:RotateAroundAxis(ang:Right(), 180) end,function(pos,ang) return pos,ang end},5)
InsertDosh("Hats","Melon",Model("models/props_junk/watermelon01.mdl"),{function(pos,ang) return pos,ang end,function(pos,ang) return pos,ang end},5)
InsertDosh("Hats","Baby",Model("models/props_c17/doll01.mdl"),{function(pos,ang) return pos,ang end,function(pos,ang) return pos,ang end},5)