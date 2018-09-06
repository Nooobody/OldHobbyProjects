AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

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
	self.SubClass = "Storage"
	
	self.Storage.Raw_BlueIce = 0
	self.Storage.Raw_ClearIce = 0
	self.Storage.Raw_GlareCrust = 0
	self.Storage.Raw_GlacialMass = 0
	self.Storage.Raw_WhiteGlaze = 0
	self.Storage.Raw_Gelidus = 0
	self.Storage.Raw_Krystallos = 0
	self.Storage.Raw_DarkGlitter = 0
	self.StorageMax.Raw_BlueIce = math.pow(2,8)
	self.StorageMax.Raw_ClearIce = math.pow(2,8)
	self.StorageMax.Raw_GlareCrust = math.pow(2,8)
	self.StorageMax.Raw_GlacialMass = math.pow(2,8)
	self.StorageMax.Raw_WhiteGlaze = math.pow(2,8)
	self.StorageMax.Raw_Gelidus = math.pow(2,8)
	self.StorageMax.Raw_Krystallos = math.pow(2,8)
	self.StorageMax.Raw_DarkGlitter = math.pow(2,8)
	
	self.Outputs = Wire_CreateOutputs(self,{"Raw_BlueIce","Raw_BlueIceMax",
											"Raw_ClearIce","Raw_ClearIceMax",
											"Raw_GlareCrust","Raw_GlareCrustMax",
											"Raw_GlacialMass","Raw_GlacialMassMax",
											"Raw_WhiteGlaze","Raw_WhiteGlazeMax",
											"Raw_Gelidus","Raw_GelidusMax",
											"Raw_Krystallos","Raw_KrystallosMax",
											"Raw_DarkGlitter","Raw_DarkGlitterMax"})
end

function ENT:Use()
end

function ENT:CheckLevel()
	if self.SizeNumber > tonumber(self:GetNWEntity("Owner"):GetResearch("Raw_Ice_Tech_Research")) then return false end
	return true
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

local Numbs = {"Small","Medium","Large","Huge","Colossal"}
function ENT:SetSizeNumber(Num)
	Mul = math.pow(4,Num)
	self.SizeNumber = Num
	self.ScreenName = Numbs[Num].." Raw Ice Storage"
	self:SetNWString("ScreenName",self.ScreenName)
	
	for I,P in pairs(self.StorageMax) do
		self.StorageMax[I] = math.Round(math.pow(2,8) * Mul * (1 + (self:GetPlayer():GetResearch("Raw_Ice_Storage_"..Numbs[Num]) / 100)))
	end
end