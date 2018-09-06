AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:SetModel("models/props_junk/harpoon002a.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_NONE )         -- Toolbox
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
	for I,P in pairs(ents.FindInSphere(self.Entity:GetPos(),150)) do
		if IsScavenger(P) and P:Health() > 0 and self.Entity:GetPhysicsObject():GetVelocity():Length() > 0 then
			P:TakeDamage(self.Damage,self.Entity:GetOwner(),self.Entity.Trap)
			P:EmitSound(Sound("player/pl_pain"..math.random(5,7)..".wav"))
			local effectdata = EffectData()
			local Pos = self.Entity:GetPos()
			effectdata:SetStart(P:GetPos() + Vector(0,0,Pos.z))
			effectdata:SetOrigin(P:GetPos() + Vector(0,0,Pos.z))
			effectdata:SetScale(2)
			util.Effect("BloodImpact",effectdata)
			P:ViewPunch(Angle(-15,0,0))
			self.Entity.Trap:Remove()
			self.Entity:Remove()
			break
		end
	end
end