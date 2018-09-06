AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

local MININGRANGE = 2024

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "M"
	self.SubClass = "Laser"
	self.Humming = CreateSound(self,Sound("ambient/energy/electric_loop.wav"))
	
	self.RInputs.Energy = math.pow(2,4)
	self.ROutputs.RawOre = math.pow(2,3)
	
	self.Inputs = Wire_CreateInputs(self,{"On"})
	self.Outputs = Wire_CreateOutputs(self,{"Status"})
end

function ENT:CheckLevel()
	if self.SizeNumber > tonumber(self:GetNWEntity("Owner"):GetResearch("Laser_Tech_Research")) then return false end
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
	local Min,Max = self:WorldSpaceAABB()
	local Off = Max - Min
	local Start = self:GetPos() - self:GetAngles():Forward() * (Off.x / 2)
	local End = Start - self:GetAngles():Forward() * MININGRANGE
	local Trace = util.TraceLine({
		start = Start,
		endpos = End,
		filter = self
	})
	
	local Roid = false
	if Trace.Hit and IsValid(Trace.Entity) then 
		if Trace.Entity:GetClass() == "sa_asteroid" then
			Roid = true
			Trace.Entity.OrePer = math.floor((Trace.Entity.OrePer - math.Rand(5,8)) * 10) / 10
			for I,P in pairs(self.Queue) do
				if P[2] == "RawOre" then
					self.Queue[I][3] = self.Queue[I][3] * Trace.Entity.Concentration * (1 + (self:GetNWEntity("Owner"):CheckFaction("Mining_Ore") / 100))
				end
			end
			if Trace.Entity.OrePer <= 0 then
				Trace.Entity:Remove()
			end
		else
			Trace.Entity:TakeDamage(15,self,self)
			if Trace.Entity:IsPlayer() then
				Trace.Entity:EmitSound("player/pl_burnpain"..math.random(1,3)..".wav",100,100)
			end
		end
	end
	
	if not Roid then
		for I,P in pairs(self.Queue) do
			if P[2] == "RawOre" then
				table.remove(self.Queue,I)
				break
			end
		end
	end
	
	return true
end

local Numbs = {"I","II","III","IV","V"}
function ENT:SetSizeNumber(Num)
	Mul = math.pow(4,Num)
	self.SizeNumber = Num
	self.ScreenName = "Mining Laser Mark "..Numbs[Num]
	self:SetNWString("ScreenName",self.ScreenName)
	
	self.RInputs.Energy = math.pow(2,4) * Mul * (1 - (self:GetPlayer():GetResearch("Laser_Power_Reduction") / 100))
	self.ROutputs.RawOre = math.pow(2,3) * Mul * (1 + (self:GetNWEntity("Owner"):CheckFaction("Mining_Tib") / 100)) * (1 + (self:GetPlayer():GetResearch("Mining_Laser_Mark_"..Numbs[Num]) / 100))
end

