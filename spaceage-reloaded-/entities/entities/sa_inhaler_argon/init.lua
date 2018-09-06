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
	self.Class = "LS"
	self.SubClass = "Puller"
	self.RInputs.Energy = math.pow(2,6)
	self.RInputs.Argon = math.pow(2,5)
	self.ROutputs.Argon = math.pow(2,5)
	self.Humming = CreateSound(self,Sound("ambient/machines/thumper_amb.wav"))
	
	self:AddMultiplier()
	self.Outputs = Wire_CreateOutputs(self,{"Status"})
end