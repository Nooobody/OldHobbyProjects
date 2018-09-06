AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "RD"
	self.SubClass = "Storage"
	self.Storage.Heavy_Water = 0
	self.StorageMax.Heavy_Water = math.pow(2,11)
	self.Outputs = Wire_CreateOutputs(self,{"HeavyWater","HeavyWaterMax"})
end

function ENT:Use()
end

function ENT:ThinkStart()
	self:TriggerOutput()
end

function ENT:TriggerOutput()
	if not self.SentStor then
		self.SentStor = 0
		self.SentStorMax = 0
	end
	local Stor = self:UpdateStorage()
	if self.SentStor ~= Stor.Heavy_Water[1] then
		Wire_TriggerOutput(self,"HeavyWater",Stor.Heavy_Water[1])
		self.SentStor = Stor.Heavy_Water[1]
	end
	if self.SentStorMax ~= Stor.Heavy_Water[2] then
		Wire_TriggerOutput(self,"HeavyWaterMax",Stor.Heavy_Water[2])
		self.SentStorMax = Stor.Heavy_Water[2]
	end
end