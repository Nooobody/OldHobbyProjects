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
	self.Storage.Energy = 0
	self.StorageMax.Energy = math.pow(2,11)
	self.Outputs = Wire_CreateOutputs(self,{"Energy","EnergyMax"})
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
	if self.SentStor ~= Stor.Energy[1] then
		Wire_TriggerOutput(self,"Energy",Stor.Energy[1])
		self.SentStor = Stor.Energy[1]
	end
	if self.SentStorMax ~= Stor.Energy[2] then
		Wire_TriggerOutput(self,"EnergyMax",Stor.Energy[2])
		self.SentStorMax = Stor.Energy[2]
	end
end