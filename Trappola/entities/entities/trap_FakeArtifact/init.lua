AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:SetModel("models/props/artifact1.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
	self.Entity:SetMoveType( MOVETYPE_NONE )   -- after all, gmod is a physics
	self.Entity:SetSolid( SOLID_VPHYSICS )         -- Toolbox
end

/*---------------------------------------------------------
   Name: Think
   Desc: Entity's think function. 
---------------------------------------------------------*/
function ENT:Think()
	if self.Entity:GetNWBool("Defused") then return end
	local Tar
	for I,P in pairs(ents.FindInSphere(self.Entity:GetPos(),self.Entity:BoundingRadius())) do
		if IsScavenger(P) and not GetPlyArtStat(P) and P:Health() > 0 then
			Tar = P
		end
	end
	if not Tar then return end
	Tar:SetNWBool("FakeArti",true)
	Tar.FakeArtiOwner = self:GetOwner()
	Tar:EmitSound(Sound("itempickup.wav"))
	self.Entity:Remove()
	ShoutIt("Return the artifact to spawn.",Tar)
	ShoutIt("Your fake artifact has been picked up!",self:GetOwner(),1,"By: "..Tar:Name())
end

if SERVER then
	function ENT:Trigger(Tar)
		util.BlastDamage(self:GetOwner(),self:GetOwner(),self:GetPos(),200,35)
		local ef = EffectData()
		ef:SetOrigin(self:GetPos())
		ef:SetScale(1)
		util.Effect("Explosion",ef)
		self:Remove()
		Tar.Triggered = Tar.Triggered + 1
		DB_UpdateAddIndPly(Tar:SteamID(),"Triggered",1)
	end

	function ENT:Use(ply)
		if self:GetNWBool("Defused") then return end
		if ply:Team() ~= 1 or (ply:Team() == 1 and ply:Health() <= 0) then return end
		if self.Pinged then
			ShoutIt("This artifact has already been pinged!",ply)
		elseif ply.Pinged >= ply.PingAmount then
			ShoutIt("You can't have that many artifacts pinged at once!",ply)
		elseif ply.Pinged < ply.PingAmount then
			self.Pinged = true
			ply.Pinged = ply.Pinged + 1
			ply.PingedAmount = ply.PingedAmount + 1
			DB_UpdateAddIndPly(ply:SteamID(),"Pinged",1)
			umsg.Start("Ping")
				umsg.String(ply:Name())
				umsg.Short(self:EntIndex())
			umsg.End()
			ShoutIt("An artifact has been pinged!",nil,1,"By: "..ply:Name())
			local I = 0
			timer.Create("PingCheck - "..self:EntIndex(),1,0,function(Idx)
				if not self:IsValid() then
					ply.Pinged = ply.Pinged - 1
					timer.Remove("PingCheck - "..Idx)
				end
				I = I + 1
				if I >= 60 then
					self.Pinged = false
					ply.Pinged = ply.Pinged - 1
					timer.Remove("PingCheck - "..Idx)
				end
			end,self:EntIndex())
		end
	end
end