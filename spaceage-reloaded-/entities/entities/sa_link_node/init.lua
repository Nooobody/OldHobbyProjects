AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

local Sizes = {
	512,
	768,
	1024,
	1536
}

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "RD"
	self.SubClass = "Node"
	self.ScreenName = "Link node #"..self:EntIndex()
	self.Range = 512
end

function ENT:SetSizeNumber(Num)
	for I,P in pairs(list.Get(self:GetClass())) do
		if P == self:GetModel() then
			if I ~= Num then
				Num = I
			end
			break
		end
	end
	self.SizeNumber = Num
	self.Range = Sizes[Num]
end