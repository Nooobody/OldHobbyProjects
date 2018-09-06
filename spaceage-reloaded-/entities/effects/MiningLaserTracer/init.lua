
local Laser = Material("effects/laser1")
//local Laser = Material("effects/tool_tracer")
//local Laser = Material("effects/bluelaser1")
//Laser:SetVector("$color",Vector(255,1,1))
//local Laser = Material("effects/blueblacklargebeam") Set width to 10
//local Laser = Material("effects/bloodstream")

function EFFECT:Init( effectdata )
	self.Start = effectdata:GetOrigin()
	self.End = effectdata:GetStart()
	self.Int = effectdata:GetScale()
	local Norm = effectdata:GetNormal()
	self.Col = Color(Norm.x,Norm.y,Norm.z)
	self:SetRenderBounds(self:WorldToLocal(self.Start),self:WorldToLocal(self.End))
	self.Spawned = true
end 

function EFFECT:Think()
	if self.Spawned then 
		self.Spawned = false
		return true
	end
	return false
end

function EFFECT:Render()
	local Ang = (self.End - self.Start):Angle()
	render.SetMaterial(Laser)
	render.DrawBeam(self.Start,self.End,50,1,1,self.Col)
	/*if self.Int == 400 then return end
	local Pos = Ang:Right() * math.sin(math.rad(self.Int)) + Ang:Up() * math.cos(math.rad(self.Int))
	local Max = 6
	render.StartBeam(Max + 2)
		render.AddBeam(self.Start,50,1,self.Col)
		for I = 1,Max / 2,1 do
			local Mul = math.sin(I / (Max / 2))
			render.AddBeam(self.Start + ((self.End - self.Start) / Max) * I + Pos * 100 * Mul,50,1,self.Col)
		end
		for I = Max / 2 + 1,Max,1 do
			local Mul = math.sin(2 - (I / (Max / 2)))
			render.AddBeam(self.Start + ((self.End - self.Start) / Max) * I + Pos * 100 * Mul,50,1,self.Col)
		end
		render.AddBeam(self.End,50,1,self.Col)
	render.EndBeam()
	//Pos = Ang:Right() * math.sin(math.rad(self.Int)) + Ang:Up() * math.cos(math.rad(self.Int))
	render.StartBeam(Max + 2)
		render.AddBeam(self.Start,50,1,self.Col)
		for I = 1,Max / 2,1 do
			local Mul = I / Max
			render.AddBeam(self.Start + ((self.End - self.Start) / Max) * I + -Pos * 100 * Mul,50,1,self.Col)
		end
		for I = Max / 2 + 1,Max,1 do
			local Mul = 1 - (I / Max)
			render.AddBeam(self.Start + ((self.End - self.Start) / Max) * I + -Pos * 100 * Mul,50,1,self.Col)
		end
		render.AddBeam(self.End,50,1,self.Col)
	render.EndBeam()*/
end