AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_combine/combine_light001b.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "LS"
	self.SubClass = "Exchanger"
	self.RInputs.Energy = math.pow(2,5)
	self.RInputs.Ice = math.pow(2,6)
	
	self.Inputs = Wire_CreateInputs(self,{"On","Sound Off"})
	self.Outputs = Wire_CreateOutputs(self,{"Status"})
end

function ENT:LifeSupport()
	if not table.HasValue(self.Got,"Ice") then return false end
	if self.Planet and self.Planet.Temperature < TEMP_MAX then
		return false
	end

	for I,P in pairs(player.GetAll()) do
		if P:GetPos():Distance(self:GetPos()) < 1024 and not P.IceGot then
			P.IceGot = self
		end
	end
	return true
end