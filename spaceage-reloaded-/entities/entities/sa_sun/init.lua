AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self.TickInt = 0
end

function ENT:Think()
	self:NextThink(CurTime() + 60)
	local Vec = Vector(math.sin(self.TickInt) * 10000,math.cos(self.TickInt) * 10000,0)
	self:SetPos(Vector(0,0,14200) + Vec)
	self.TickInt = self.TickInt + 0.01
	return true
end