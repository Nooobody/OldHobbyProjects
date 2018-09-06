AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:SetModel("models/props/explosivetrap.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_NONE )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
end

/*---------------------------------------------------------
   Name: Think
   Desc: Entity's think function. 
---------------------------------------------------------*/
function ENT:Think()
	if self.Entity:GetNWBool("Defused") or CLIENT then return end
	local Tar = nil
	for I,P in pairs(ents.FindInSphere(self.Entity:GetPos() + self.Entity:GetAngles():Up() * 10,self.Entity.Radius)) do
		if IsScavenger(P) and P:Health() > 0 then
			Tar = P
		end
	end
	if not Tar then return end
	local Trace = {}
	Trace.start = Tar:EyePos()
	Trace.endpos = self.Entity:GetPos() + self.Entity:GetAngles():Up() * 10
	Trace.filter = self.Entity,Tar
	local Tra = util.TraceLine(Trace)
	if not Tra.HitWorld and not self:GetNWBool("Defused") then
		self:Trigger(Tar)
	end
end

if SERVER then
	function ENT:Trigger(Tar)
		self.Triggered = true
		Tar.Triggered = Tar.Triggered + 1
		DB_UpdateAddIndPly(Tar:SteamID(),"Triggered",1)
		local Ef = EffectData()
		Ef:SetOrigin(self.Entity:GetPos())
		Ef:SetRadius(2)
		util.Effect("Explosion",Ef)
		util.BlastDamage(self.Entity,self:GetOwner(),self.Entity:GetPos(),self.Entity.Radius * 2,self.Entity.Damage)
		self.Entity:Remove()
	end
end