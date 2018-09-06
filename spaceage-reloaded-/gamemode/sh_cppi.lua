
CPPI = {}

CPPI.CPPI_Defer = 1
CPPI.CPPI_NOTIMPLEMENTED = 2

local function GetName()
	return "Player Prop Protection by Nooobody"
end

local function GetVersion()
	return "1.2"
end

local function GetInterfaceVersion()
	return 1.1
end

local function GetNameFromUID(uid)
	if type(uid) ~= "number" and not tonumber(uid) then return CPPI.CPPI_DEFER end
	if CLIENT then 
		if uid == LocalPlayer():UniqueID() then return LocalPlayer():Name() else return CPPI.CPPI_DEFER end
	end
	
	for I,P in pairs(player.GetAll()) do
		if P:UniqueID() == uid then return P:Name() end
	end
	return CPPI.CPPI_DEFER
end

CPPI.GetName = GetName
CPPI.GetVersion = GetVersion
CPPI.GetInterfaceVersion = GetInterfaceVersion
CPPI.GetNameFromUID = GetNameFromUID

local Ply = FindMetaTable("Player")

function Ply:CPPIGetFriends()
	if CLIENT and self ~= LocalPlayer() then return CPPI.CPPI_NOTIMPLEMENTED end
	local T = {}
	if not self.Pliers then return T end
	for I,P in pairs(self.Pliers) do
		if P.ConstrainAble then
			for _,Ply in pairs(player.GetAll()) do
				if Ply:SteamID() == I then
					table.insert(T,Ply)
					break
				end
			end
		end
	end
	return T
end

local Ent = FindMetaTable("Entity")

function Ent:CPPIGetOwner()
	local Ply = self:GetNWEntity("Owner")
	return Ply,CPPI.CPPI_NOTIMPLEMENTED
end