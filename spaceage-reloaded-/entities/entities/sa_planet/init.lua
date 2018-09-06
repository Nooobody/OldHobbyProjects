AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("")
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self:Init()
end