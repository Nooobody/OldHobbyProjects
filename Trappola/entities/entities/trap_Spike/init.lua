AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:SetModel("models/props/spiketrap.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_NONE )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Triggered = false
end

/*---------------------------------------------------------
   Name: Think
   Desc: Entity's think function. 
---------------------------------------------------------*/
function ENT:Think()
	if self.Entity:GetNWBool("Defused") or self.Triggered or CLIENT then return end
	local Tar = nil
	for I,P in pairs(ents.FindInSphere(self.Entity:GetPos() + self.Entity:GetAngles():Up() * 10,64)) do
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
	if not Tra.HitWorld and not self.Triggered and not self:GetNWBool("Defused") then
		self:Trigger(Tar)
	end
end

if SERVER then
	function ENT:Trigger(Tar)
		self.Triggered = true
		Tar.Triggered = Tar.Triggered + 1
		DB_UpdateAddIndPly(Tar:SteamID(),"Triggered",1)
		local Base = ents.Create("prop_physics")
		Base:SetPos(self.Entity:GetPos() - Vector(0,0,8))
		Base:SetModel(self.Entity.Mdl)
		Base:SetAngles(self.Entity:GetAngles())
		Base:Spawn()
		Base:GetPhysicsObject():EnableMotion(false)
		local Idx = self.Entity:EntIndex()
		local Time = CurTime() + self.Entity.Cooldown
		timer.Create("SpikeTrap - "..Idx,0.1,0,function()
			if CurTime() >= Time then
				if self and self:IsValid() and not self:GetNWBool("Defused") then
					self:Remove()
				end
				if Base and Base:IsValid() and not self:GetNWBool("Defused") then
					Base:Remove()
				end
				timer.Remove("SpikeTrap - "..Idx)
			end
			if not self or not self:IsValid() or self:GetNWBool("Defused") then 
				if Base and Base:IsValid() then
					Base:Remove()
				end
				timer.Remove("SpikeTrap - "..Idx) 
				return 
			end
			local SelfPos = Base:GetPos()
			local Min,Max = Base:WorldSpaceAABB()
			local Scl = Max - Min
			local Find1,Find2 = SelfPos + Vector(Scl.x / 2,Scl.y / 2,40),SelfPos - Vector(Scl.x / 2,Scl.y / 2,0)
			for I,P in pairs(ents.FindInBox(Find1,Find2)) do
				if IsScavenger(P) and P:Health() > 0 then
					P:TakeDamage(self.Entity.Damage,self.Entity:GetOwner(),self.Entity)
					P:EmitSound(Sound("player/pl_pain"..math.random(5,7)..".wav"))
				end
			end
		end)
	end
end