
function EFFECT:Init( effectdata )
	self.StartTime = CurTime()
	self:SetPos(effectdata:GetOrigin())
	self:SetAngles(effectdata:GetAngles())
	self.Time = 0.04
	self.EndTime = CurTime() + self.Time
	self.Emitter = ParticleEmitter(Vector(0,0,0))
end 

function EFFECT:Think()
	if CurTime() > self.EndTime then return false end
	
	local Pos = self:GetPos()
	local Ang = self:GetAngles()
	local Vel = Ang:Forward() * 400 + Ang:Right() * math.random(-400,400) + Ang:Up() * math.random(-400,400)
	local Part = self.Emitter:Add("effects/spark",Pos)
	Part:SetVelocity(Vel)
	Part:SetDieTime(0.2)
	Part:SetColor(255,255,255)
	Part:SetStartAlpha(255)
	Part:SetEndAlpha(0)
	Part:SetStartSize(2)
	Part:SetEndSize(0)
	Part:SetCollide(false)
	return true
end

function EFFECT:Render()
end