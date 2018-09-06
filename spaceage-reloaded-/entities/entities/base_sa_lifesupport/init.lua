AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')

function ENT:Initialize()
	self.Class = "LS"
	self:Int()
end

function ENT:LifeSupport()
	if not self.Planet or self.Planet.Locked then return false end
	
	if self.SubClass == "Puller" then
		for I,P in pairs(self.RInputs) do
			if self:IsGas(I) then
				local In = math.min(self.Planet.RealAtmosphere[I] or 0,P)
				if In == 0 then return false end
				self:AddToQueue(self.Planet,I,-In)
			end
		end
	elseif self.SubClass == "Blower" then
		for I,P in pairs(self.ROutputs) do
			if table.HasValue(self.Got,I) and self:IsGas(I) then self:AddToQueue(self.Planet,I,P) end
		end
	end
	
	return true
end