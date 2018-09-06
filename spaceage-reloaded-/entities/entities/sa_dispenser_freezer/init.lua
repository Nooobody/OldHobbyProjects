AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

local RANGE = 124

function ENT:Initialize()
	self:SetModel("models/mandrac/hybride/cap_railgun_base.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "LS"
	self.SubClass = "Suit"
	self.RInputs.Energy = math.pow(2,4)
	self.RInputs.Ice = math.pow(2,5)
	self.Humming = CreateSound(self,Sound("items/suitcharge1.wav"))
	self.sStart = "items/suitchargeok1.wav"
	self.sDenied = "items/suitchargeno1.wav"
	self.sEnd = "items/suitchargeno1.wav"
	self.NextThnk = 0.5
	self.PlysUsing = {}
end

function ENT:Use()
end

function ENT:ThinkStart()
	if not next(self.StoredLinks.Inputs) or not next(self.StoredLinks.Inputs.Energy) or not next(self.StoredLinks.Inputs.Ice) then return end
	
	local I = 1
	while I <= #self.PlysUsing do
		local P = self.PlysUsing[I]
		if not IsValid(P) then
			table.remove(self.PlysUsing,I)
		elseif P:GetPos():Distance(self:GetPos()) > RANGE or P:GetPos().z < self:GetPos().z or P.Steam == 0 then
			table.remove(self.PlysUsing,I)
			net.Start("PlayerSurv")
				net.WriteUInt(P.Oxy,8)
				net.WriteUInt(P.Ice,8)
				net.WriteUInt(P.Steam,8)
				if P.Planet then
					net.WriteInt(P.Planet.Temperature,16)
					net.WriteFloat(P.Planet.Pressure)
				else
					net.WriteInt(-100,16)
					net.WriteFloat(0)
				end
				net.WriteBit(true)
			net.Send(P)
		else
			I = I + 1
		end
	end

	for I,P in pairs(player.GetAll()) do
		if P:GetPos():Distance(self:GetPos()) < RANGE and P:GetPos().z > self:GetPos().z and P.Steam > 0 then
			table.insert(self.PlysUsing,P)
		end
	end
	
	if #self.PlysUsing > 0 and not self.Online then self:On()
	elseif #self.PlysUsing == 0 and self.Online then self:Off() end
end

function ENT:LifeSupport()
	if not table.HasValue(self.Got,"Ice") then return end
	for I,P in pairs(self.PlysUsing) do
		if IsValid(P) and P.Steam > 0 then
			P.Steam = P.Steam - 1
			P.Ice = P.Ice + 1
		end
		net.Start("PlayerSurv")
			net.WriteUInt(P.Oxy,8)
			net.WriteUInt(P.Ice,8)
			net.WriteUInt(P.Steam,8)
			if P.Planet then
				net.WriteInt(P.Planet.Temperature,16)
				net.WriteFloat(P.Planet.Pressure)
			else
				net.WriteInt(-100,16)
				net.WriteFloat(0)
			end
			net.WriteBit(false)
		net.Send(P)
	end
	
	return true
end