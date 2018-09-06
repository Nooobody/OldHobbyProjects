AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/punisher239/punisher239_reactor_small.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "M"
	self.SubClass = "Refinery"
	
	self.Percent = 0
	self.Refine = 2
	self.ReduceTime = 1
	
	self.Outputs = Wire_CreateOutputs(self,{"Cycle Progress"})
end

function ENT:ThinkStart()
	if self.AFKed and not self:GetNWEntity("Owner"):GetNWBool("AFK") then
		self.AFKed = nil
		self:On()
	end
	
	if self:GetNWEntity("Owner"):GetNWBool("AFK") then
		self.AFKed = true
		self:Off()
		return false
	end
	if not self.Pump and self.Online then
		self.RInputs = {}
		self.ROutputs = {}
		for I,P in pairs(self.SentData) do
			player.GetByID(I):ConCommand("sa_tooltipreset "..self:EntIndex())
		end
		self.SentData = {}
		self.Percent = 0
		Wire_TriggerOutput(self,"Cycle Progress",0)
		self:UpdateLinks()
		self:Off()
	end
	if not self.Pump or not self.Online then return end

	if self.Percent == 0 and next(self.ROutputs) then
		self.RInputs = {}
		self.ROutputs = {}
		self:UpdateLinks()
	end
	
	local Stor = false
	if not next(self.ROutputs) then
		local Links = self:UpdateLinks()
		for I,P in pairs(Links) do
			if P:GetClass() == "sa_mining_rawice_storage" then
				Stor = P
				break
			end
		end
	end
	
	if Stor then
		self.Percent = self.Percent + math.random(10,20) * self.ReduceTime
		Wire_TriggerOutput(self,"Cycle Progress",self.Percent)
		if self.Percent >= 100 then
			self.Percent = 0
			Wire_TriggerOutput(self,"Cycle Progress",0)
			local St = Stor:UpdateStorage()
			local Am = self.Refine
			for I,P in pairs(St) do
				local Ref = "Refined_"..string.Split(I,"_")[2]
				if P[1] > 0 then
					if P[1] >= Am then
						self.RInputs[I] = Am
						self.ROutputs[Ref] = Am
						break
					else
						Am = Am - P[1]
						self.RInputs[I] = P[1]
						self.ROutputs[Ref] = P[1]
					end
				elseif self.RInputs[I] then
					self.RInputs[I] = nil
					self.ROutputs[Ref] = nil
				end
			end
			self:UpdateLinks()
		end
	else
		self.Percent = 0
		Wire_TriggerOutput(self,"Cycle Progress",0)
		self:Off()
	end
end

function ENT:CheckLevel()
	if self.SizeNumber > tonumber(self:GetNWEntity("Owner"):GetResearch("Refinery_Tech")) then return false end
	return true
end

local Numbs = {"I","II","III"}
function ENT:SetSizeNumber(Num)
	Mul = math.pow(6,Num)
	self.SizeNumber = Num
	self.ScreenName = "Ice Refinery Mark "..Numbs[Num]
	self:SetNWString("ScreenName",self.ScreenName)
	
	self.Refine = Mul * (1 + (self:GetNWEntity("Owner"):GetResearch("Refinery_Mark_"..Numbs[Num]) / 100))
	self.ReduceTime = Num
end

function ENT:Use(cal,act)
	if not self.Pump or CurTime() < self.NextUse then return end
	self.NextUse = CurTime() + 1
	if self:WorldToLocal(cal:GetEyeTrace().HitPos).x < 0 then
		self.SentData = {}
		if self.Online then 
			self:Off()
			self.Percent = 0
			Wire_TriggerOutput(self,"Cycle Progress",0)
		else 
			self:On() 
			self.Percent = 0
			for I,P in pairs(self.SentData) do
				player.GetByID(I):ConCommand("sa_tooltipreset "..self:EntIndex())
			end
			self.SentData = {}
			self:UpdateLinks()
		end
	else
		if cal:IsPlayer() then
			constraint.RemoveAll(self)
			self.Pump = nil
			self.Weld = nil
			self.Used = true
			timer.Simple(1,function() self.Used = false end)
			self:GetPhysicsObject():EnableMotion(true)
		end
	end
end