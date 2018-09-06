AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

local MININGRANGE = 2024

function ENT:Initialize()
	self.Entity:SetModel("models/ce_miningmodels/mininglasers/laser_mk1_standard.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "M"
	self.SubClass = "IceLaser"
	self.Humming = CreateSound(self,Sound("ambient/energy/electric_loop.wav"))
	
	self.Percent = 0
	self.RInputs.Energy = math.pow(2,4)
	self.Mine = math.pow(2,3)
	
	self.Inputs = Wire_CreateInputs(self,{"On"})
	self.Outputs = Wire_CreateOutputs(self,{"Status","Cycle Progress"})
end

function ENT:CheckLevel()
	if self.SizeNumber > tonumber(self:GetNWEntity("Owner"):GetResearch("Ice_Laser_Tech_Research")) then return false end
	return true
end

function ENT:ThinkStart()
	if self.AFKed and not self:GetNWEntity("Owner"):GetNWBool("AFK") then
		self.AFKed = nil
		self:On()
	end
end

function ENT:BeforeQueue()
	if self:GetNWEntity("Owner"):GetNWBool("AFK") then
		self.AFKed = true
		self:Off()
		return false
	end
	if self:GetNWEntity("Owner"):GetPos():Distance(self:GetPos()) > 1024 then return false end
	local Min,Max = self:WorldSpaceAABB()
	local Off = Max - Min
	local Start = self:GetPos() + self:GetAngles():Up() * (Off.x / 2) * 1.6
	local End = Start + self:GetAngles():Up() * MININGRANGE
	local Trace = TraceLine({
		start = Start,
		endpos = End,
		filter = self
	})
	
	local Roid = false
	if Trace.Hit and IsValid(Trace.Entity) then 
		if Trace.Entity:GetClass() == "sa_ice" then
			Roid = true
			if self.IceHit ~= Trace.Entity then	self.Percent = 0 end
			if not self.ROutputs["Raw_"..Trace.Entity.IceType] then
				self.ROutputs = {}
				self.ROutputs["Raw_"..Trace.Entity.IceType] = 0
				for I,P in pairs(self.SentData) do
					player.GetByID(I):ConCommand("sa_tooltipreset "..self:EntIndex())
				end
				self:UpdateLinks()
			end
			self.IceHit = Trace.Entity
			self.Percent = self.Percent + math.random(5,10)
			Wire_TriggerOutput(self,"Cycle Progress",self.Percent)
			if self.Percent >= 100 then
				self.Percent = 0
				Wire_TriggerOutput(self,"Cycle Progress",self.Percent)
				self.IceType = Trace.Entity.IceType
				Trace.Entity.OrePer = math.floor((Trace.Entity.OrePer - math.random(5,10)) * 10) / 10
				local Res = "Raw_"..self.IceType
				self:GetStorage(Res,self.Mine)
				if Trace.Entity.OrePer <= 0 then
					Trace.Entity:Remove()
				end
			end
		else
			Trace.Entity:TakeDamage(15,self,self)
			if Trace.Entity:IsPlayer() then
				Trace.Entity:EmitSound("player/pl_burnpain"..math.random(1,3)..".wav",100,100)
			end
		end
	end
	
	if not Roid then 
		self.Percent = 0
		Wire_TriggerOutput(self,"Cycle Progress",self.Percent)
		self.IceHit = nil
		for I,P in pairs(self.SentData) do
			player.GetByID(I):ConCommand("sa_tooltipreset "..self:EntIndex())
		end
		if next(self.ROutputs) then
			self.ROutputs = {}
			self:UpdateLinks()
		end
	end
	return true
end

local Numbs = {"I","II","III","IV","V"}
function ENT:SetSizeNumber(Num)
	Mul = math.pow(4,Num)
	self.SizeNumber = Num
	self.ScreenName = "Ice Laser Mark "..Numbs[Num]
	self:SetNWString("ScreenName",self.ScreenName)
	
	self.RInputs.Energy = math.pow(2,4) * Mul * (1 - (self:GetPlayer():GetResearch("Laser_Power_Reduction") / 100))
	self.Mine = math.pow(2,3) * Mul * (1 + (self:GetNWEntity("Owner"):CheckFaction("Mining_Ice") / 100)) * (1 + (self:GetPlayer():GetResearch("Ice_Laser_Mark_"..Numbs[Num]) / 100))
end
