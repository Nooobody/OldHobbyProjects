AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_combine/suit_charger001.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "LS"
	self.SubClass = "Dispenser"
	self:SetUseType(CONTINUOUS_USE)
	self.RInputs.Energy = math.pow(2,4)
	self.RInputs.Steam = math.pow(2,6)
	self.RInputs.Oxygen = math.pow(2,6)
	self.RInputs.Ice = math.pow(2,6)
	self.Humming = CreateSound(self,Sound("items/suitcharge1.wav"))
	self.sStart = Sound("items/suitchargeok1.wav")
	self.sDenied = Sound("items/suitchargeno1.wav")
	self.sEnd = Sound("items/suitchargeno1.wav")
	self.PlyUsing = nil
	self.NextThnk = 0.4
end

function ENT:ThinkStart()
	if self.Online and IsValid(self.PlyUsing) and self.PlyUsing:IsPlayer() then
		local Tr = self.PlyUsing:GetEyeTrace()
		if not self.PlyUsing:KeyDown(IN_USE) or (not Tr.Entity or Tr.Entity ~= self) then
			local P = self.PlyUsing
			net.Start("PlayerSurv")
				net.WriteUInt(P.Oxy,8)
				net.WriteUInt(P.Ice,8)
				net.WriteUInt(P.Steam,8)
				if not P.Planet then
					net.WriteInt(-200,16)
					net.WriteFloat(0)
				else
					net.WriteInt(P.Planet.Temperature,16)
					net.WriteFloat(P.Planet.Pressure)
				end
				net.WriteBit(true)
			net.Send(P)
			self.PlyUsing = nil
			self:Off()
		end
	elseif self.Online then
		self:Off()
	end
end

function ENT:Use(Act,Cal)
	if self.PlyUsing and self.PlyUsing ~= Cal then return end
	if not Cal:IsPlayer() then return end
	if CurTime() < self.NextUse then return end
	self.NextUse = CurTime() + 0.5
	
	if Cal.Oxy + Cal.Ice + Cal.Steam >= 300 then 
		ShoutIt("You have full of everything!",Cal)
		self.PlyUsing = nil
		net.Start("PlayerSurv")
			net.WriteUInt(Cal.Oxy,8)
			net.WriteUInt(Cal.Ice,8)
			net.WriteUInt(Cal.Steam,8)
			if not Cal.Planet then
				net.WriteInt(-200,16)
				net.WriteFloat(0)
			else
				net.WriteInt(Cal.Planet.Temperature,16)
				net.WriteFloat(Cal.Planet.Pressure)
			end
			net.WriteBit(true)
		net.Send(Cal)
		self:Off() 
		return 
	end
	
	if not self.Online then
		self:On()
	end
	
	self.PlyUsing = Cal 
end

function ENT:LifeSupport()
	if not self.PlyUsing then return false end

	if self.PlyUsing.Steam + self.PlyUsing.Ice + self.PlyUsing.Oxy >= 300 then
		ShoutIt("You have full of everything!",self.PlyUsing)
		return false
	end
	
	local Remove = {}
	
	if self.PlyUsing.Steam + self.PlyUsing.Ice < 200 then
		if table.HasValue(self.Got,"Steam") then self.PlyUsing.Steam = self.PlyUsing.Steam + 1 end
		if table.HasValue(self.Got,"Ice") then self.PlyUsing.Ice = self.PlyUsing.Ice + 1 end
	else
		ShoutIt("You have full Ice & Steam!",self.PlyUsing)
		table.insert(Remove,"Ice")
		table.insert(Remove,"Steam")
	end
	
	if table.HasValue(self.Got,"Oxygen") and self.PlyUsing.Oxy < 100 then 
		self.PlyUsing.Oxy = self.PlyUsing.Oxy + 1 
	elseif self.PlyUsing.Oxy >= 100 then
		table.insert(Remove,"Oxygen")
	end
	
	if #Remove > 0 then
		local I = #self.Queue
		while I > 0 do
			if table.HasValue(Remove,self.Queue[I][2]) then
				table.remove(self.Queue,I)
			end	
			I = I - 1
		end
	end
	
	local P = self.PlyUsing
	net.Start("PlayerSurv")
		net.WriteUInt(P.Oxy,8)
		net.WriteUInt(P.Ice,8)
		net.WriteUInt(P.Steam,8)
		if not P.Planet then
			net.WriteInt(-200,16)
			net.WriteFloat(0)
		else
			net.WriteInt(P.Planet.Temperature,16)
			net.WriteFloat(P.Planet.Pressure)
		end
		net.WriteBit(false)
	net.Send(P)
	
	return true
end

function ENT:TriggerOutput()
end