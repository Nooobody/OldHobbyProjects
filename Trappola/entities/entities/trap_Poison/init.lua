AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')
local End
/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:SetModel("models/props/poisontrap.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_NONE )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
	self.Triggered = false
	self.Sounds = {"player/pl_burnpain1.wav",
					"player/pl_burnpain2.wav",
					"player/pl_burnpain3.wav",
					"player/pl_pain5.wav",
					"player/pl_pain6.wav",
					"player/pl_pain7.wav"}
end

/*---------------------------------------------------------
   Name: Think
   Desc: Entity's think function. 
---------------------------------------------------------*/
function ENT:Think()
	if self.Entity:GetNWBool("Defused") or self.Triggered or CLIENT then return end
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
	if not Tra.HitWorld and not self.Triggered and not self:GetNWBool("Defused") then
		self:Trigger(Tar)
	end	
end

if SERVER then
	function ENT:Trigger(Tar)
		self.Triggered = true
		Tar.Triggered = Tar.Triggered + 1
		DB_UpdateAddIndPly(Tar:SteamID(),"Triggered",1)
		End = CurTime() + self.CloudDuration
		local Radius = self.Entity.Radius
		timer.Create("Poisoning"..self.Entity:EntIndex(),0,0,function(Idx)
			if not self.Entity or not self.Entity:IsValid() then timer.Remove("Poisoning"..Idx) return end
			if End < CurTime() then timer.Remove("Poisoning"..Idx) self.Entity:Remove() return end
			local ef = EffectData()
			local Origin = self.Entity:GetPos() + self.Entity:GetAngles():Up() * (Radius / 2)
			local Vec = Vector(math.random(-(Radius / 2),(Radius / 2)),math.random(-(Radius / 2),(Radius / 2)),math.random(-(Radius / 2),(Radius / 2)))
			Vec:Rotate(self.Entity:GetAngles():Up():Angle())
			ef:SetOrigin(Origin + Vec)
			util.Effect("antliongib",ef)
			
			local Find = ents.FindInSphere(self.Entity:GetPos() + self.Entity:GetAngles():Up() * 10,Radius)
			for I,P in pairs(Find) do
				if IsScavenger(P) and P:Health() > 0 then
					P:SetNWBool("Poisoned",true)
					P.EndPoison = CurTime() + self.Duration
					if timer.IsTimer("TakeDmg - "..P:Name()) then return end
					timer.Create("TakeDmg - "..P:Name(),1,0,function()
						if P.EndPoison < CurTime() or P:Health() <= 0 or not P:IsValid() then	P:SetNWBool("Poisoned",false) timer.Remove("TakeDmg - "..P:Name()) return end
						P:TakeDamage(self.Entity.Damage,self.Entity:GetOwner(),self.Entity)
						P:ViewPunch(Angle(math.random(-10,10),math.random(-10,10),0))
						P:EmitSound(Sound(self.Sounds[math.random(1,#self.Sounds)]))
					end)
				end
			end
		end,self.Entity:EntIndex())
	end
end