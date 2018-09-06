AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/slyfo/sat_resourcetank.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "M"
	self.SubClass = "Storage"
	
	self.Storage.RawTiberium = 0
	self.StorageMax.RawTiberium = math.pow(2,10)
	
	self.GreenTiberium = 0
	self.BlueTiberium = 0
	
	self.Outputs = Wire_CreateOutputs(self,{"RawTiberium","RawTiberiumMax"})
end

function ENT:ThinkStart()
	self:TriggerOutput()
end

function ENT:TriggerOutput()
	if not self.SentStor then
		self.SentStor = 0
		self.SentStorMax = 0
	end
	local Stor = self:UpdateStorage()
	if self.SentStor ~= Stor.RawTiberium[1] then
		Wire_TriggerOutput(self,"RawTiberium",Stor.RawTiberium[1])
		self.SentStor = Stor.RawTiberium[1]
	end
	if self.SentStorMax ~= Stor.RawTiberium[2] then
		Wire_TriggerOutput(self,"RawTiberiumMax",Stor.RawTiberium[2])
		self.SentStorMax = Stor.RawTiberium[2]
	end
end

function ENT:GetTib()
	local Am = math.Round(self.StorageMax.RawTiberium / 10)
	local A = math.min(Am,self.StorageMax.RawTiberium)
	
	local Blue = 0
	if self.BlueTiberium > 0 then
		Blue = math.min(self.BlueTiberium,A)
		self.BlueTiberium = self.BlueTiberium - Blue
		A = A - Blue
	end
	
	local Green = 0
	if self.GreenTiberium > 0 and A > 0 then
		Green = math.min(self.GreenTiberium,A)
		self.GreenTiberium = self.GreenTiberium - Green
	end
	
	self.Storage["RawTiberium"] = math.Clamp(self.GreenTiberium + self.BlueTiberium,0,self.StorageMax["RawTiberium"])
	self:TriggerOutput()
	
	if Blue > 0 then
		return true,Blue,Green
	else
		return false,Green
	end
end

function ENT:CheckLevel()
	if self.SizeNumber > tonumber(self:GetNWEntity("Owner"):GetResearch("Tiberium_Storage_Tech_Research")) then return false end
	return true
end

function ENT:AddResource(Str,Val,Ent)
	if Str ~= "RawTiberium" or not IsValid(Ent) then return end
	local IsBlue = Ent.IsBlue
	
	Val = math.Round(Val)
	
	if Val + self.Storage["RawTiberium"] > self.StorageMax["RawTiberium"] then
		Val = math.Clamp(Val,0,self.StorageMax["RawTiberium"] - self.Storage["RawTiberium"])
	end
	
	if not IsBlue then
		self.GreenTiberium = self.GreenTiberium + Val
	else
		self.BlueTiberium = self.BlueTiberium + Val
	end
	
	self.Storage["RawTiberium"] = math.Clamp(self.GreenTiberium + self.BlueTiberium,0,self.StorageMax["RawTiberium"])
end

local Numbs = {"Small","Medium","Large","Huge"}
function ENT:SetSizeNumber(Num)
	Mul = math.pow(4,Num)
	self.SizeNumber = Num
	self.ScreenName = Numbs[Num].." Raw Tiberium Storage"
	self:SetNWString("ScreenName",self.ScreenName)
	
	self.StorageMax.RawTiberium = math.Round(math.pow(2,10) * Mul * (1 + (self:GetPlayer():GetResearch("Raw_Tiberium_Storage_"..Numbs[Num]) / 100)))
end

function ENT:Use(cal,act)
	if cal:IsPlayer() and IsValid(self.Hold) then
		constraint.RemoveAll(self)
		if self.Hold.Vectors[1][2] == self then self.Hold.Vectors[1][2] = nil 
		elseif self.Hold.Vectors[2][2] == self then self.Hold.Vectors[2][2] = nil end
		self.Weld = nil
		self.NC = nil
		self.Hold = nil
		self.Used = true
		self.DoNotDuplicate = nil
		timer.Simple(1,function() self.Used = false end)
		self:GetPhysicsObject():EnableMotion(true)
		for I,P in pairs(self.Links) do
			self:Unlink(P)
		end
	end
end