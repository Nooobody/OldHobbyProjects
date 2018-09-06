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
	if GetGlobalBool("Lobby") then return end
	local Tar
	for I,P in pairs(ents.FindInSphere(self.Entity:GetPos(),self.Entity:BoundingRadius())) do
		if IsScavenger(P) and not GetPlyArtStat(P) and P:Health() > 0 then
			Tar = P
		end
	end
	if not Tar then return end
	Tar:SetNWBool("Arti",true)
	Tar:EmitSound(Sound("itempickup.wav"))
	if self.Pinged and self.Pinger ~= Tar then
		Tar.ArtiPinger = self.Pinger
	end
	self.Entity:Remove()
	ShoutIt("Return the artifact to spawn.",Tar)
	local RF = RecipientFilter()
	for I,P in pairs(team.GetPlayers(2)) do
		RF:AddPlayer(P)
	end
	ShoutIt("An artifact has been picked up!",RF,1,"By: "..Tar:Name())
end

function ENT:Use(ply)
	if ply:Team() ~= 1 or (ply:Team() == 1 and ply:Health() <= 0) then return end
	if self.Pinged then
		ShoutIt("This artifact has already been pinged!",ply)
	elseif ply.Pinged >= ply.PingAmount then
		ShoutIt("You can't have that many artifacts pinged at once!",ply)
	elseif ply.Pinged < ply.PingAmount then
		self.Pinged = true
		self.Pinger = ply
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
				self.Pinger = nil
				ply.Pinged = ply.Pinged - 1
				timer.Remove("PingCheck - "..Idx)
			end
		end,self:EntIndex())
	end
end