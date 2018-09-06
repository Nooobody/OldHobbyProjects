AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/slyfo/electrolysis_gen.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "M"
	self.SubClass = "MiningStorage"
	self.NextThnk = 0.5
	
	self.Storage.LiquidTiberium = 0
	self.StorageMax.LiquidTiberium = math.pow(2,14)
	self.Outputs = Wire_CreateOutputs(self,{"LiquidTiberium","LiquidTiberiumMax"})
end

function ENT:ThinkStart()
	self:TriggerOutput()
	
	if self.Storage.LiquidTiberium <= 100 then return end
	if not self.OldPos then self.OldPos = self:GetPos() end
	
	local Per = self.Storage.LiquidTiberium / self.StorageMax.LiquidTiberium
	
	local Pos = self:GetPos()
	if self:GetVelocity():Length() > 1000 or Pos:Distance(self.OldPos) > 1000 then
		util.BlastDamage(self,self,Pos,500 * Per,4000 * Per)
		local Ef = EffectData()
		Ef:SetOrigin(self:GetPos())
		Ef:SetScale(300 * Per)
		util.Effect("LiquidTiberiumExplosion",Ef)
		self:Remove()
		local Ents = ents.FindInSphere(Pos,1000 * Per)
		for I,P in pairs(Ents) do
			if not P:IsPlayer() and IsValid(P:GetPhysicsObject()) and P:GetNWEntity("Owner"):IsPlayer() then
				P:Remove()
			end
		end
	end
	self.OldPos = Pos
end

function ENT:Use()
end

function ENT:TriggerOutput()
	if not self.SentStor then
		self.SentStor = 0
		self.SentStorMax = 0
	end
	local Stor = self:UpdateStorage()
	if self.SentStor ~= Stor.LiquidTiberium[1] then
		Wire_TriggerOutput(self,"LiquidTiberium",Stor.LiquidTiberium[1])
		self.SentStor = Stor.LiquidTiberium[1]
	end
	if self.SentStorMax ~= Stor.LiquidTiberium[2] then
		Wire_TriggerOutput(self,"LiquidTiberiumMax",Stor.LiquidTiberium[2])
		self.SentStorMax = Stor.LiquidTiberium[2]
	end
end

