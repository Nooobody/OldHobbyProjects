AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/chipstiks_ls3_models/largeh2opump/largeh2opump.mdl")
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
	self.ROutputs.Water = math.pow(2,6)
	self.RInputs.Energy = math.pow(2,6)
	self.Humming = CreateSound(self,Sound("ambient/machines/engine1.wav"))
	
	self:AddMultiplier()
	self.Outputs = Wire_CreateOutputs(self,{"Status"})
end

function ENT:GetWaterLevel()
	if self:WaterLevel() >= 2 then return true else return false end
end