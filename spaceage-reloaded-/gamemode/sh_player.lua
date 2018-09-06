
function UnSafe_CanSomethingDo(ply,ent,mode)
	if not SA_DisablePP then return true end
	if game.SinglePlayer() then return true end
	if ent:GetClass() == "sa_asteroid" or ent:IsPlayer() then return false end
	if CLIENT and ply ~= LocalPlayer() then return true end
	if ply:IsWorld() or not IsValid(ply) then return true end
	if ent:GetNetworkedEntity("Owner") ~= ply then 
		local Own = ent:GetNetworkedEntity("Owner")
		if not IsValid(Own) and not Own:IsWorld() then return true end
		if Own:IsWorld() then return false // DON'T TOUCH MY TERMINALS!
		else
			if CLIENT then
				if not LocalPlayer().Pliers[ply:SteamID()] then
					LocalPlayer().Pliers[ply:SteamID()] = table.Copy(DEFAULT_PP)
					if LocalPlayer().AllPP then
						for I,P in pairs(LocalPlayer().AllPP) do
							LocalPlayer().Pliers[ply:SteamID()][I] = P
						end
					end
				end
			else
				if not Own.Pliers then 
					Own.Pliers = {}
					Own.Pliers[ply:SteamID()] = table.Copy(DEFAULT_PP)
				elseif not Own.Pliers[ply:SteamID()] then
					Own.Pliers[ply:SteamID()] = table.Copy(DEFAULT_PP)
				end
			end
			if (SERVER and Own.Pliers[ply:SteamID()][mode]) or (CLIENT and LocalPlayer().Pliers[ply:SteamID()][mode]) then return true
			else return ply:IsAdmin() or IsOwner(ply) end
		end
	end
	return true
end

function CanSomethingDo(ply,ent,mode)
	local Res,Err = pcall(UnSafe_CanSomethingDo,ply,ent,mode)
	if not Res then
		print("PP has failed with the following error:")
		print(Err)
		print("With "..ply:Name().." and "..tostring(ent))
		print("Entity owner: "..tostring(ent:GetNWEntity("Owner")))
		return false
	end
	return Err
end

function GM:CanProperty(ply,property,ent)
	return CanSomethingDo(ply,ent,"ConstrainAble")
end

function GM:GravGunPunt(ply,ent)
	if ply == ent then return true end
	if ent:IsPlayer() then return ent.Pliers[ply:SteamID()].PhysGunAble end
	return CanSomethingDo(ply,ent,"PhysGunAble")
end

function GM:PlayerNoClip(ply,desiredstate)
	if ply:GetNWBool("GravityGot") then return true end
	if not ply:GetNWBool("Planet") then return IsOwner(ply) end
	return true
end

function GM:PhysgunPickup(ply,ent)
	if ent:GetClass() == "player" then return false end
	local B = CanSomethingDo(ply,ent,"PhysGunAble")
	if not B then return false end
	if ent:GetClass() == "sa_plug" then ent.PlayerHolding = true end
	return true
end

function GM:PhysgunDrop(ply,ent)
	if ent:GetClass() == "sa_plug" then ent.PlayerHolding = false end
end

FACTIONS = {}
FACTIONS.Connecting = {
	Col = Color(240,120,10),
	Num = 0,
	Name = "Connecting"
}
FACTIONS.Freelancers = {
	Col = Color(180,160,140),
	Num = 1,
	Name = "Freelancers"
}
FACTIONS.Corporation = {
	Col = Color(102,178,225),
	Num = 2,
	Name = "The Corporation",
	Icon = Material("VGUI/CS.png"),
	Upgrades = {
		Money_Ore = 5,
		Money_Tib = 5,
		Money_Ice = 5,
	},
	Desc = "The world has not seen better businessmen than what The Corporation can offer. Everything they touch turns into credits. The normal man can only imagine to be one of them.\n\nJoining The Corporation gives a 5% increase to all money gains."
}
FACTIONS.MajorMiners = {
	Col = Color(153,76,0),
	Num = 3,
	Name = "Major Miners",
	Icon = Material("VGUI/MM.png"),
	Upgrades = {
		Mining_Ore = 15,
	},
	Desc = "If there's an asteroid in space left unmined, these guys will be at it in no time. They are the experts on pointing a laser at an asteroid. They do not know the fear of facing the horrors of the asteroid field.\n\nJoining Major Miners gives a 15% increase to Mining Laser's output."
}
FACTIONS.Legion = {
	Col = Color(20,255,20),
	Num = 4,
	Name = "The Legion",
	Icon = Material("VGUI/Legion.png"),
	Upgrades = {
		Mining_Tib = 15,
	},
	Desc = "Space ships? Bleh. Asteroids? Blah. Who cares about space anyway? Not these guys, they are the professionals on land-based exploration. The dirt crawlers they make are the best on the market.\n\nJoining The Legion gives a 15% increase to Mining Drill's output."
}
FACTIONS.StarFleet = {
	Col = Color(200,200,200),
	Num = 5,
	Name = "StarFleet",
	Icon = Material("VGUI/SF.png"),
	Upgrades = {
		Mining_Ice = 15
	},
	Desc = "Is that an asteroid? Is that a meteor? It's...it's a starfleet ship. These guys usually don't care about size limits. When they build, they go big. 'With big ships, comes little responsibility' is their motto.\n\nJoining StarFleet gives a 15% increase to Ice Laser's output."
}

for I,P in pairs(FACTIONS) do
	team.SetUp(P.Num,P.Name,P.Col,false)
end

local Ply = FindMetaTable("Player")

function Ply:GetFact()
	for I,P in pairs(FACTIONS) do
		if self:Team() == P.Num then
			return P
		end
	end
	return nil
end

function Ply:IsAdmin()
	return self:GetPrivilege() >= PRIV_ADMIN
end

function Ply:IsSuperAdmin()
	return self:GetPrivilege() >= PRIV_OWNER
end

function Ply:GetMoney()
	return tonumber(self:GetNWInt("Money"))
end

function Ply:GetScore()
	return tonumber(self:GetNWInt("Score"))
end

function Ply:GetPrivilege()
	return tonumber(self:GetNWInt("Privilege"))
end