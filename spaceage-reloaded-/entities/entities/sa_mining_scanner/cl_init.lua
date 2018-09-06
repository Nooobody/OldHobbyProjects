include("shared.lua")

local MININGRANGE = 2024

function ENT:BeforeTooltip()
	if not self:GetNetworkedBool("Online") then return end
	local Min,Max = self:WorldSpaceAABB()
	local Off = Max - Min
	local Start = self:GetPos() + self:GetAngles():Up() * (Off.x / 2) * 0.95
	local End = Start - self:GetAngles():Up() * -MININGRANGE

	local Trace = util.TraceLine({
		start = Start,
		endpos = End,
		filter = self
	})
	
	local Ef = EffectData()
	Ef:SetOrigin(Start)
	Ef:SetNormal(Vector(255,255,255))
	if Trace.Hit then
		self:SetRenderBounds(Vector(80,0,0),self:WorldToLocal(Trace.HitPos))
		Ef:SetStart(Trace.HitPos)
	else
		self:SetRenderBounds(Vector(80,0,0),self:WorldToLocal(End))
		Ef:SetStart(End)
	end
	util.Effect("MiningLaserTracer",Ef)
end