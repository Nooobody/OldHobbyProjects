AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/ce_ls3additional/compressor/compressor_large.mdl")
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
	self.ROutputs.Oxygen = math.pow(2,5)
	self.ROutputs.Hydrogen = math.pow(2,6)
	self.RInputs.Water = math.pow(2,5)
	self.RInputs.Energy = math.pow(2,6)
	self.Humming = CreateSound(self,Sound("ambient/machines/train_idle.wav"))
	
	self.Outputs = Wire_CreateOutputs(self,{"Status"})
	self:AddMultiplier()
end