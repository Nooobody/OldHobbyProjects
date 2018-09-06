AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/ce_ls3additional/plants/plantfull.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

function ENT:Think()
	self:NextThink(CurTime() + 1)
	
	if self.Planet and self.Planet:GetClass() == "sa_planet" then
		if self.Planet.RealAtmosphere.Carbon_dioxide and self.Planet:GetAtmosphere("Carbon_dioxide") > 0 then
			self.Planet:AddAtmosphere("Oxygen",12)
			self.Planet:AddAtmosphere("Carbon_dioxide",-12)
		else
			self:Remove()
		end
	end
	
	return true
end