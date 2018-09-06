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
	self.ROutputs.Water = math.pow(2,4)
	self.RInputs.Steam = math.pow(2,5)
	self.RInputs.Energy = math.pow(2,6)
	self.Humming = CreateSound(self,Sound("ambient/machines/machine6.wav"))
	
	self.Outputs = Wire_CreateOutputs(self,{"Status"})
	self:AddMultiplier()
end