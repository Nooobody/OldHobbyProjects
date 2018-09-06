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
	self.SubClass = "Generator"
	self.ROutputs.Energy = math.pow(2,8)
	self.Humming = CreateSound(self,Sound("ambient/machines/engine1.wav"))
	
	self.Inputs = Wire_CreateInputs(self,{"On","Sound Off"})
	self.Outputs = Wire_CreateOutputs(self,{"Status"})
end

function ENT:CheckLevel()
	if self:GetNWEntity("Owner"):GetResearch("Hydro_Turbine_Research") < self.SizeNumber then return false end
	return true
end

function ENT:GetWaterLevel()
	if self:WaterLevel() >= 2 then return true else return false end
end