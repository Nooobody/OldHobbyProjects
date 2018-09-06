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
	self.Storage.Carbon_dioxide = 0
	self.StorageMax.Carbon_dioxide = math.pow(2,11)
	
	self.Outputs = Wire_CreateOutputs(self,{"CarbonDioxide","CarbonDioxideMax"})
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
	if self.SentStor ~= Stor.Carbon_dioxide[1] then
		Wire_TriggerOutput(self,"CarbonDioxide",Stor.Carbon_dioxide[1])
		self.SentStor = Stor.Carbon_dioxide[1]
	end
	if self.SentStorMax ~= Stor.Carbon_dioxide[2] then
		Wire_TriggerOutput(self,"CarbonDioxideMax",Stor.Carbon_dioxide[2])
		self.SentStorMax = Stor.Carbon_dioxide[2]
	end
end