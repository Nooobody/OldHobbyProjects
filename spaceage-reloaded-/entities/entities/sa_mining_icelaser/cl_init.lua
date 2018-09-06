include("shared.lua")

local MININGRANGE = 2024

function ENT:BeforeTooltip()
	if not self:GetNetworkedBool("Online") then return end
	local Min,Max = self:WorldSpaceAABB()
	local Off = Max - Min
	local Start = self:GetPos() + self:GetAngles():Up() * (Off.x / 2) * 1.6
	local End = Start + self:GetAngles():Up() * MININGRANGE

	local Trace = util.TraceLine({
		start = Start,
		endpos = End,
		filter = self
	})
	
	if not self.Col then
		self.Col = Color(0,0,255)
	end
	
	if not self.Col then return end
	
	if Trace.Hit then
		self:SetRenderBounds(Vector(80,0,0),self:WorldToLocal(Trace.HitPos))
		local Ef = EffectData()
		Ef:SetOrigin(Start)
		Ef:SetNormal(Vector(self.Col.r,self.Col.g,self.Col.b))
		Ef:SetStart(Trace.HitPos)
		/*if not self.LaserPos then self.LaserPos = 1 end
		Ef:SetScale(self.LaserPos)
		self.LaserPos = self.LaserPos + 1
		if self.LaserPos >= 360 then self.LaserPos = 0 end*/
		util.Effect("MiningLaserTracer",Ef)
		Ef:SetOrigin(Trace.HitPos)
		Ef:SetAngles((Start - Trace.HitPos):Angle())
		util.Effect("MiningLaserHit",Ef)
	else
		self:SetRenderBounds(Vector(80,0,0),self:WorldToLocal(End))
		local Ef = EffectData()
		Ef:SetOrigin(Start)
		Ef:SetNormal(Vector(self.Col.r,self.Col.g,self.Col.b))
		Ef:SetStart(End)
		Ef:SetScale(400)
		util.Effect("MiningLaserTracer",Ef)
	end
end