AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "M"
	self.SubClass = "Storage"
	
	self.Storage.Refined_BlueIce = 0
	self.Storage.Refined_ClearIce = 0
	self.Storage.Refined_GlareCrust = 0
	self.Storage.Refined_GlacialMass = 0
	self.Storage.Refined_WhiteGlaze = 0
	self.Storage.Refined_Gelidus = 0
	self.Storage.Refined_Krystallos = 0
	self.Storage.Refined_DarkGlitter = 0
	self.StorageMax.Refined_BlueIce = math.pow(2,6)
	self.StorageMax.Refined_ClearIce = math.pow(2,6)
	self.StorageMax.Refined_GlareCrust = math.pow(2,6)
	self.StorageMax.Refined_GlacialMass = math.pow(2,6)
	self.StorageMax.Refined_WhiteGlaze = math.pow(2,6)
	self.StorageMax.Refined_Gelidus = math.pow(2,6)
	self.StorageMax.Refined_Krystallos = math.pow(2,6)
	self.StorageMax.Refined_DarkGlitter = math.pow(2,6)
	
	self.Outputs = Wire_CreateOutputs(self,{"Refined_BlueIce","Refined_BlueIceMax",
											"Refined_ClearIce","Refined_ClearIceMax",
											"Refined_GlareCrust","Refined_GlareCrustMax",
											"Refined_GlacialMass","Refined_GlacialMassMax",
											"Refined_WhiteGlaze","Refined_WhiteGlazeMax",
											"Refined_Gelidus","Refined_GelidusMax",
											"Refined_Krystallos","Refined_KrystallosMax",
											"Refined_DarkGlitter","Refined_DarkGlitterMax"})
end

function ENT:CheckLevel()
	if self.SizeNumber > tonumber(self:GetNWEntity("Owner"):GetResearch("Refined_Ice_Tech_Research")) then return false end
	return true
end

local Numbs = {"Small","Medium","Large"}
function ENT:SetSizeNumber(Num)
	Mul = math.pow(6,Num)
	self.SizeNumber = Num
	self.ScreenName = Numbs[Num].." Refined Ice Storage"
	self:SetNWString("ScreenName",self.ScreenName)
	
	for I,P in pairs(self.StorageMax) do
		self.StorageMax[I] = math.Round(math.pow(2,6) * Mul * (1 + (self:GetPlayer():GetResearch("Refined_Ice_Storage_"..Numbs[Num]) / 100)))
	end
end

function ENT:Use()
end

function ENT:ThinkStart()
	self:TriggerOutput()
end

function ENT:TriggerOutput()
	if not self.SentStor then
		self.SentStor = {}
		self.SentStorMax = {}
		for I,P in pairs(self.Storage) do
			self.SentStor[I] = 0
			self.SentStorMax[I] = 0
		end
	end
	local Stor = self:UpdateStorage()
	for I,P in pairs(Stor) do
		if self.SentStor[I] ~= P[1] then
			Wire_TriggerOutput(self,I,P[1])
			self.SentStor[I] = P[1]
		end
		if self.SentStorMax[I] ~= P[2] then
			Wire_TriggerOutput(self,I.."Max",P[2])
			self.SentStorMax[I] = P[2]
		end	
	end
end