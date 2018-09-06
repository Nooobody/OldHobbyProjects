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
	self.Storage.Argon = 0
	self.StorageMax.Argon = math.pow(2,11)
	
	self.Outputs = Wire_CreateOutputs(self,{"Argon","ArgonMax"})
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
	if self.SentStor ~= Stor.Argon[1] then
		Wire_TriggerOutput(self,"Argon",Stor.Argon[1])
		self.SentStor = Stor.Argon[1]
	end
	if self.SentStorMax ~= Stor.Argon[2] then
		Wire_TriggerOutput(self,"ArgonMax",Stor.Argon[2])
		self.SentStorMax = Stor.Argon[2]
	end
end