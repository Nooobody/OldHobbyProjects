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
	self.SubClass = "Drill"
	self.Humming = CreateSound(self,Sound("plats/elevator_loop1.wav"))
	self.sStart = Sound("plats/elevator_large_start1.wav")
	self.sEnd = Sound("plats/elevator_large_stop1.wav")
	
	self.RInputs.Energy = math.pow(2,5)
	self.ROutputs.RawTiberium = math.pow(2,4)
	
	self.Numbs = {"I","II","III"}
	self.IsBlue = false
	
	self.Inputs = Wire_CreateInputs(self,{"On"})
	self.Outputs = Wire_CreateOutputs(self,{"Status"})
end

function ENT:CheckLevel()
	if self.SizeNumber > tonumber(self:GetNWEntity("Owner"):GetResearch("Drill_Tech_Research")) then return false end
	return true
end

function ENT:ThinkStart()
	if self.AFKed and not self:GetNWEntity("Owner"):GetNWBool("AFK") then
		self.AFKed = nil
		self:On()
	end
	if not self.Online or not IsValid(self.Touching) then return end
	if self.Touching.IsBlue and not self.IsBlue then
		self.IsBlue = true
		self.ROutputs.RawTiberium = math.pow(2,4) * math.pow(4,self.SizeNumber) * (1 + (self:GetNWEntity("Owner"):CheckFaction("Mining_Tib") / 100)) * (1 + (self:GetPlayer():GetResearch("Drill_Efficiency_Mark_"..self.Numbs[self.SizeNumber]) / 100)) * 3
	elseif not self.Touching.IsBlue and self.IsBlue then
		self.IsBlue = false
		self.ROutputs.RawTiberium = math.pow(2,4) * math.pow(4,self.SizeNumber) * (1 + (self:GetNWEntity("Owner"):CheckFaction("Mining_Tib") / 100)) * (1 + (self:GetPlayer():GetResearch("Drill_Efficiency_Mark_"..self.Numbs[self.SizeNumber]) / 100))
	end
end

function ENT:BeforeQueue()
	if self:GetNWEntity("Owner"):GetNWBool("AFK") then
		self.AFKed = true
		self:Off()
		return false
	end
	if self.Touching and not IsValid(self.Touching) then self.Touching = nil end
	if self.Touching then
		local BlueOff = 1
		if self.IsBlue then BlueOff = 2 end
		self.Touching.OrePer = math.floor((self.Touching.OrePer - math.random(10,25) * self.SizeNumber) * 10) / 10
		if self.Touching.OrePer <= 0 then
			self.Touching:Remove()
		end
	else
		for I,P in pairs(self.Queue) do
			if P[2] == "RawTiberium" then
				table.remove(self.Queue,I)
				break
			end
		end
	end
	
	return true
end

function ENT:SetSizeNumber(Num)
	Mul = math.pow(5,Num)
	self.SizeNumber = Num
	self.ScreenName = "Mining Drill Mark "..self.Numbs[Num]
	self:SetNWString("ScreenName",self.ScreenName)
	
	self.RInputs.Energy = math.pow(2,5) * Mul
	self.ROutputs.RawTiberium = math.pow(2,4) * Mul * (1 + (self:GetNWEntity("Owner"):CheckFaction("Mining_Tib") / 100)) * (1 + (self:GetPlayer():GetResearch("Drill_Efficiency_Mark_"..self.Numbs[Num]) / 100))
end

