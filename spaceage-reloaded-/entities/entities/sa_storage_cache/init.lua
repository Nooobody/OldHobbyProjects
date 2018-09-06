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
	self.Class = "RD"
	self.SubClass = "Storage"
	self.Storage.Water = 0
	self.Storage.Steam = 0
	self.Storage.Ice = 0
	self.Storage.Oxygen = 0
	self.Storage.Hydrogen = 0
	self.StorageMax.Water = math.pow(2,11)
	self.StorageMax.Steam = math.pow(2,11)
	self.StorageMax.Ice = math.pow(2,11)
	self.StorageMax.Oxygen = math.pow(2,11)
	self.StorageMax.Hydrogen = math.pow(2,11)
	
	self.Outputs = Wire_CreateOutputs(self,{"Water","WaterMax",
											"Steam","SteamMax",
											"Ice","IceMax",
											"Oxygen","OxygenMax",
											"Hydrogen","HydrogenMax"})
end

function ENT:CheckLevel()
	if tonumber(self:GetNWEntity("Owner"):GetResearch("Multiple_Resource_Storage")) < self.SizeNumber then return false end
	return true
end

function ENT:Use()
end

function ENT:SetSizeNumber(Num)
	local Mul = Num
	if Num == 2 then
		Mul = 5
	elseif Num == 3 then
		Mul = 10
	elseif Num == 4 then
		Mul = 40
	end
		
	self.SizeNumber = Num
	if next(self.RInputs) then
		if not self.OrgInputs then
			self.OrgInputs = table.Copy(self.RInputs)
		end
		for I,P in pairs(self.RInputs) do
			self.RInputs[I] = self.OrgInputs[I] * Mul
		end
	end
	
	if next(self.ROutputs) then
		if not self.OrgOutputs then
			self.OrgOutputs = table.Copy(self.ROutputs)
		end
		for I,P in pairs(self.ROutputs) do
			self.ROutputs[I] = self.OrgOutputs[I] * Mul
		end
	end
	
	if next(self.StorageMax) then
		if not self.OrgStorage then
			self.OrgStorage = table.Copy(self.StorageMax)
		end
		for I,P in pairs(self.StorageMax) do
			self.StorageMax[I] = self.OrgStorage[I] * Mul
		end
	end
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