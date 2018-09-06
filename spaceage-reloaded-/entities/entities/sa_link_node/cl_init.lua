include("shared.lua")

function ENT:Initialize()
	self.ScreenName = "Link node #"..self:EntIndex()
end