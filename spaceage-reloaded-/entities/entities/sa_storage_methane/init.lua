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
	self.Storage.Methane = 0
	self.StorageMax.Methane = math.pow(2,11)
	self.Outputs = Wire_CreateOutputs(self,{"Methane","MethaneMax"})
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
	if self.SentStor ~= Stor.Methane[1] then
		Wire_TriggerOutput(self,"Methane",Stor.Methane[1])
		self.SentStor = Stor.Methane[1]
	end
	if self.SentStorMax ~= Stor.Methane[2] then
		Wire_TriggerOutput(self,"MethaneMax",Stor.Methane[2])
		self.SentStorMax = Stor.Methane[2]
	end
end