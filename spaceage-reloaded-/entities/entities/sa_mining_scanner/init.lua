AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

local MININGRANGE = 2024

function ENT:Initialize()
	self.Entity:SetModel("models/jaanus/wiretool/wiretool_beamcaster.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "M"
	self.SubClass = "Scanner"
	self.Humming = nil
	
	self.RInputs.Energy = math.pow(2,4)
	
	self.Inputs = Wire_CreateInputs(self,{"On","Sound Off"})
	self.Outputs = WireLib.CreateSpecialOutputs(self,{"Status","Ore Concentration","Ore Amount","IceType"},{"NORMAL","NORMAL","NORMAL","STRING"})
end

function ENT:BeforeQueue()
	local Min,Max = self:WorldSpaceAABB()
	local Off = Max - Min
	local Start = self:GetPos() - self:GetAngles():Up() * -(Off.x / 2)
	local End = Start - self:GetAngles():Up() * -MININGRANGE
	local Trace = TraceLine({
		start = Start,
		endpos = End,
		filter = self
	})
	
	if Trace.Hit and IsValid(Trace.Entity) and (Trace.Entity:GetClass() == "sa_asteroid" or Trace.Entity:GetClass() == "sa_tiberium_crystal" or Trace.Entity:GetClass() == "sa_ice") then
		self.Concentration = Trace.Entity.Concentration
		self.Amount = Trace.Entity.OrePer
		if Trace.Entity.IceType then
			self.IceType = Trace.Entity.IceType
		end
		self:TriggerOutput()
	elseif self.Concentration ~= 0 or self.Amount ~= 0 then
		self.Concentration = 0
		self.Amount = 0
		self.IceType = nil
		self:TriggerOutput()
	end
	
	return true
end

function ENT:TriggerOutput()
	local Num = 0
	if self.Online then Num = 1 end
	self:SetNetworkedBool("Online",self.Online)
	Wire_TriggerOutput(self,"Status",Num)
	if not self.Online then
		Wire_TriggerOutput(self,"Ore Concentration",0)
		Wire_TriggerOutput(self,"Ore Amount",0)
		Wire_TriggerOutput(self,"IceType","")
	else
		Wire_TriggerOutput(self,"Ore Concentration",self.Concentration)
		Wire_TriggerOutput(self,"Ore Amount",self.Amount)
		Wire_TriggerOutput(self,"IceType",self.IceType or "")
	end
end
