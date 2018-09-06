AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/ce_ls3additional/compressor/compressor.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "RD"
	self.SubClass = "Generator"
	self.RInputs.Carbon_dioxide = math.pow(2,6)
	self.ROutputs.Energy = math.pow(2,6)
	self.Humming = CreateSound(self,Sound("ambient/machines/engine1.wav"))
	
	self.Inputs = Wire_CreateInputs(self,{"On","Sound Off"})
	self.Outputs = Wire_CreateOutputs(self,{"Status"})
end