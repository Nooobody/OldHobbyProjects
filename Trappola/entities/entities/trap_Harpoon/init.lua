AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:SetModel("models/props/harpoontrap.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_NONE )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Entity:SetNWBool("Defused",false)
	self.OwnPos = self.Entity:GetOwner():EyePos()
	self.Triggered = false
end

/*---------------------------------------------------------
   Name: Think
   Desc: Entity's think function. 
---------------------------------------------------------*/
function ENT:Think()
	if self.Entity:GetNWBool("Defused") or self.Triggered or CLIENT then return end
	local Tar = nil
	for I,P in pairs(ents.FindInSphere(self.Entity:GetPos() + self.Entity:GetAngles():Up() * 10,100)) do
		if IsScavenger(P) and P:Health() > 0 then
			Tar = P
			break
		end
	end
	if not Tar then return end
	local Trace = {}
	Trace.start = Tar:EyePos()
	Trace.endpos = self.Entity:GetPos() + self.Entity:GetAngles():Up() * 10
	Trace.filter = self.Entity,Tar
	local Tra = util.TraceLine(Trace)
	if not Tra.HitWorld and not self.Triggered and not self:GetNWBool("Defused") then
		self:Trigger(Tar)
	end
end

if SERVER then
	function ENT:Trigger(Tar)
		self.Triggered = true
		Tar.Triggered = Tar.Triggered + 1
		DB_UpdateAddIndPly(Tar:SteamID(),"Triggered",1)
		local Harpoon = ents.Create("Harpoon")
		Harpoon:Spawn()
		Harpoon.Trap = self.Entity
		Harpoon.Damage = self.Entity.Damage
		Harpoon:SetPos(self.OwnPos)
		local ang = ((Tar:GetPos() + Vector(0,0,50)) - self.OwnPos):Angle()
		Harpoon:SetAngles(ang)
		Harpoon:GetPhysicsObject():ApplyForceCenter(((Tar:GetPos() + Vector(0,0,50)) - self.OwnPos) * 10000)
		Harpoon:SetOwner(self.Entity:GetOwner())
		timer.Simple(5,function()
			if Harpoon and Harpoon:IsValid() then
				Harpoon:Remove()
				self.Entity:Remove()
			elseif self.Entity and self.Entity:IsValid() then
				self.Entity:Remove()
			end
		end)
	end
end