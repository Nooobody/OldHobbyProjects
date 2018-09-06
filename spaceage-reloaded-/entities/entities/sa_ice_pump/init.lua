AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/hunter/tubes/tubebend2x2x90square.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetMaterial("phoenix_storms/metalset_1-2")
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.LoadedRefinery = nil
	self.LocalVector = Vector(0.067,126.983,-32.064)
	self.LocalAngle = Angle(0,-90,0)
	
	self.Pitch = 0
	self.State = 0
	
	self.Humming = CreateSound(self,Sound("ambient/machines/machine_whine1.wav"))
end

function ENT:StartTouch(Ent)
	if IsValid(self.LoadedRefinery) and IsValid(self.Weld) then return end
	if not IsValid(self.Weld) and IsValid(self.LoadedRefinery) then
		self.Weld = nil
		
		self.LoadedRefinery.Pump = nil
		self.LoadedRefinery = nil
	end
	
	if IsValid(Ent) and Ent:GetClass() == "sa_mining_refinery" and not Ent.Used then
		if not self.DefaultPos then self.DefaultPos = self:GetPos() end
		if self:WorldToLocal(Ent:GetPos()).y < 100 then return end
		Ent:SetPos(self:LocalToWorld(self.LocalVector))
		Ent:SetAngles(self:LocalToWorldAngles(self.LocalAngle))
		Ent:GetPhysicsObject():EnableMotion(false)
		local weld = constraint.Weld(self,Ent,0,0,500,true)
		if IsValid(weld) then
			Ent:DeleteOnRemove(weld)
			Ent.Weld = weld
			self:DeleteOnRemove(weld)
			self.Weld = weld
		end
		Ent.Pump = self
	end
end

function ENT:EndTouch(Ent)
	if Ent == self.LoadedRefinery then
		self.Weld:Remove()
		self.LoadedRefinery.Pump = nil
		self.LoadedRefinery = nil
	end
end

function ENT:Think()
	if self.DefaultPos and self.DefaultPos ~= self:GetPos() then
		if IsValid(self.LoadedRefinery) and IsValid(self.Weld) then
			self.LoadedRefinery.Pump = nil
			self.LoadedRefinery = nil
			self.Weld:Remove() 
			self.Weld = nil
		end
		self:SetPos(self.DefaultPos)
	end
	if not IsValid(self.Weld) and IsValid(self.LoadedRefinery) then
		self.Weld = nil
		
		self.LoadedRefinery.Pump = nil
		self.LoadedRefinery = nil
	end
	
	if self.State == 1 then
		self.Pitch = self.Pitch + 1
		if self.Pitch >= 100 then
			self.Humming:ChangePitch(100,0.1)
			self.State = 0
		end
		self.Humming:ChangePitch(self.Pitch,0.1)
		self:NextThink(CurTime() + 0.1)
	elseif self.State == 2 then
		self.Pitch = self.Pitch - 1
		if self.Pitch <= 0 then
			self.Humming:Stop()
			self.Humming:ChangePitch(0,0.1)
			self.State = 0
		end
		self.Humming:ChangePitch(self.Pitch,0.1)		
		self:NextThink(CurTime() + 0.1)
	else
		self:NextThink(CurTime() + 1)
	end
	
	return true
end

function ENT:TurnOn()
	self.Humming:Play()
	self.Humming:ChangePitch(0,0.1)
	self.State = 1
	self.Pitch = 0
end

function ENT:TurnOff()
	self.Humming:ChangePitch(100,0.1)
	self.State = 2
	self.Pitch = 100
end

function ENT:PostEntityPaste(ply,ent,CreateEnts)
	self:Remove()
	ply:SendLua("notification.AddLegacy('You may not do that!',NOTIFY_ERROR,5)")
end