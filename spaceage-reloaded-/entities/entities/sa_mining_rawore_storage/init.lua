AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "M"
	self.SubClass = "Storage"
	
	self.Storage.RawOre = 0
	self.StorageMax.RawOre = math.pow(2,10)
	self.Outputs = Wire_CreateOutputs(self,{"RawOre","RawOreMax"})
end

function ENT:Use()
end

function ENT:ThinkStart()
	self:TriggerOutput()
end

function ENT:CheckLevel()
	if self.SizeNumber > tonumber(self:GetNWEntity("Owner"):GetResearch("Storage_Tech_Research")) then return false end
	return true
end

function ENT:TriggerOutput()
	if not self.SentStor then
		self.SentStor = 0
		self.SentStorMax = 0
	end
	local Stor = self:UpdateStorage()
	if self.SentStor ~= Stor.RawOre[1] then
		Wire_TriggerOutput(self,"RawOre",Stor.RawOre[1])
		self.SentStor = Stor.RawOre[1]
	end
	if self.SentStorMax ~= Stor.RawOre[2] then
		Wire_TriggerOutput(self,"RawOreMax",Stor.RawOre[2])
		self.SentStorMax = Stor.RawOre[2]
	end
end

local Numbs = {"Tiny","Small","Medium","Large","Huge"}
function ENT:SetSizeNumber(Num)
	Mul = math.pow(4,Num)
	self.SizeNumber = Num
	self.ScreenName = Numbs[Num].." Raw Ore Storage"
	self:SetNWString("ScreenName",self.ScreenName)
	
	self.StorageMax.RawOre = math.Round(math.pow(2,10) * Mul * (1 + (self:GetPlayer():GetResearch("Raw_Ore_Storage_"..Numbs[Num]) / 100)))
end

