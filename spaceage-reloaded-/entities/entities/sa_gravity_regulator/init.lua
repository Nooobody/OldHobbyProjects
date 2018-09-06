AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_combine/combine_mine01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "LS"
	self.SubClass = "Regulator"
	self.RInputs.Energy = math.pow(2,7)
	self.Range = 512
	self.Gravit = 1
	
	self.Inputs = Wire_CreateInputs(self,{"On","Range","Amount","Sound Off"})
	self.Outputs = Wire_CreateOutputs(self,{"Status"})
end

function ENT:TriggerInput(Name,Value)
	if Name == "On" then
		if Value == 1 and not self.Online then self:On() 
		elseif self.Online then self:Off() end
	elseif Name == "Range" then
		Value = math.Clamp(Value,512,5148)
		self.Range = Value
	elseif Name == "Amount" then
		self.Gravit = Value or self.Gravit
	elseif Name == "Sound Off" then
		self.SoundOff = Value == 1
		if self.SoundOff and self.Humming then self.Humming:Stop()
		elseif not self.SoundOff and self.Humming then 
			self.Humming:Play()
			self.Humming:ChangeVolume(0.5,0.1)
		end
	end
end

function ENT:ThinkStart()
	self.PlayersInRange = {}
	for I,P in pairs(player.GetAll()) do
		if P:GetPos():Distance(self:GetPos()) <= self.Range then
			table.insert(self.PlayersInRange,P)
		elseif P.GravityGot == self then
			P.GravityGot = nil
			P:SetNWBool("GravityGot",false)
			if P.Planet then
				P:SetGravity(P.Grav)
			else
				P:SetGravity(0.000001)
			end
		end
	end
	
	self.RInputs.Energy = math.pow(2,7) * (self.Range / 512) * #self.PlayersInRange
end

function ENT:OnRemove()
	for I,P in pairs(player.GetAll()) do
		if P.GravityGot == self then
			P.GravityGot = nil
			P:SetNWBool("GravityGot",false)
			if P.Planet then
				P:SetGravity(P.Grav)
			else
				P:SetGravity(0.000001)
			end
		end
	end
end

function ENT:LifeSupport()
	for I,P in pairs(self.PlayersInRange) do
		if P.GravityGot ~= self then
			P.GravityGot = self
			P:SetNWBool("GravityGot",true)
			P:SetGravity(self.Gravit)
		end
	end
	
	return true
end