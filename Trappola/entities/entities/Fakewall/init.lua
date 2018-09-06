AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:SetModel("models/hunter/blocks/cube8x8x1.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	local Phys = self.Entity:GetPhysicsObject()
	if Phys then
		Phys:Wake()
	end
end

/*---------------------------------------------------------
   Name: Think
   Desc: Entity's think function. 
---------------------------------------------------------*/
function ENT:Think()
	if not self.Entity.Trap:IsValid() then return end
	local Pos = self.Entity:GetPos()
	local Min,Max = self.Entity:WorldSpaceAABB()
	local Scl = Max - Min
	local Front = self.Entity:GetAngles():Forward()
	local Right = self.Entity:GetAngles():Right()
	local Find1,Find2 = Pos + Front * (Scl.x / 2) + Right * (Scl.y / 2),Pos - Front * (Scl.x / 2) - Right * (Scl.y / 2) + Vector(0,0,Scl.z)
	for I,P in pairs(ents.FindInBox(Find1,Find2)) do
		if IsScavenger(P) and P:Health() > 0 then
			P:TakeDamage(P:Health() * 2,self.Entity:GetOwner(),self.Entity.Trap)
		end
	end
end

function ENT:PhysicsCollide(ent)
end