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
	self.Storage.Ice = 0
	self.StorageMax.Ice = math.pow(2,11)
	self.Outputs = Wire_CreateOutputs(self,{"Ice","IceMax"})
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
	if self.SentStor ~= Stor.Ice[1] then
		Wire_TriggerOutput(self,"Ice",Stor.Ice[1])
		self.SentStor = Stor.Ice[1]
	end
	if self.SentStorMax ~= Stor.Ice[2] then
		Wire_TriggerOutput(self,"IceMax",Stor.Ice[2])
		self.SentStorMax = Stor.Ice[2]
	end
end