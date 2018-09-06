AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')

/*---------------------------------------------------------
   Name: Initialize
   Desc: First function called. Use to set up your entity
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:SetModel("models/props/fakewalltrap.mdl")
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
		local Target = self.Entity:GetPos()
		local Prop = ents.Create("Fakewall")
		Prop:Spawn()
		Prop.Trap = self.Entity
		Prop:SetPos(Target + Vector(0,0,500))
		Prop:SetAngles(self.Entity:GetAngles())
		Prop:SetModel(self.Entity.Mdl)
		Prop:SetOwner(self.Entity:GetOwner())
		timer.Create("Crush - "..Prop:EntIndex(),0,0,function(Target,Idx)
			if not Prop or not Prop:IsValid() then
				if self.Entity and self.Entity:IsValid() then
					self.Entity:Remove()
				end
				timer.Remove("Crush - "..Idx)
			end
			local Pos = Prop:GetPos()
			if Pos.z > Target.z + 10 then
				Prop:SetPos(Vector(Target.x,Target.y,Pos.z - (Pos.z - Target.z) / 15))
			elseif Pos.z < Target.z + 10 then
				Prop:SetPos(Target)
				Prop:GetPhysicsObject():EnableMotion(false)
				local Prop1 = ents.Create("prop_physics")
				Prop1:SetModel(Prop:GetModel())
				Prop1:SetPos(Prop:GetPos())
				Prop1:SetAngles(Prop:GetAngles())
				Prop1.Think = function(self)
					if GetGlobalBool("Lobby") then
						self:Remove()
					end
				end
				Prop:Remove()
				Prop1:Spawn()
				Prop1:GetPhysicsObject():EnableMotion(false)
				self.Entity:Remove()
				timer.Remove("Crush - "..Idx)
			end
		end,Target,Prop:EntIndex())
	end
end