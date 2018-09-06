AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/smallbridge/life support/sbfusiongen.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "LS"
	self.SubClass = "Blower"
	self.RInputs.Energy = math.pow(2,6)
	self.RInputs.Nitrogen = math.pow(2,5)
	self.ROutputs.Nitrogen = math.pow(2,5)
	
	self.Inputs = Wire_CreateInputs(self,{"On","Sound Off"})
	self.Outputs = Wire_CreateOutputs(self,{"Status"})
end

function ENT:ThinkStart()
	if self.Online and not self.Planet then self:Off() return false end
end

function ENT:LifeSupport()
	if not table.HasValue(self.Got,"Nitrogen") then return end
	self.Planet.Pressure = Lerp(0.01,self.Planet.Pressure,1)
	return true
end