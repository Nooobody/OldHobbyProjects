include("shared.lua")

function ENT:Draw()
	local r,g,b,a = self.Entity:GetColor()
	if SelfPly:Team() == 2 then
		if a <= 0 then self.Entity:SetColor(255,255,255,255) end
		self.Entity:DrawModel()
	elseif IsScavenger(SelfPly) and self:GetNWBool("Defused") then
		if a <= 0 then self.Entity:SetColor(255,255,255,255) end
		self.Entity:DrawModel()
	else
		if a > 0 then
			self.Entity:SetColor(255,255,255,0)
		end
	end
end