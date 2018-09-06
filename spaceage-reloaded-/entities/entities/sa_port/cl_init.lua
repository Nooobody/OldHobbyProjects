include("shared.lua")

function ENT:Initialize()
	self.ScreenName = "Port #"..self:EntIndex()
end