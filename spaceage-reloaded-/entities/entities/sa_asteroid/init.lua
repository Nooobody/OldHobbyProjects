AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

local Pos = {
	Vector(60,0,0),
	Vector(-60,0,0),
	Vector(0,60,0),
	Vector(0,-60,0),
	Vector(0,0,60),
	Vector(0,0,-60)
}

local Models = {
	"models/ce_ls3additional/asteroids/asteroid_200.mdl",
	"models/ce_ls3additional/asteroids/asteroid_250.mdl",
	"models/ce_ls3additional/asteroids/asteroid_300.mdl",
	"models/ce_ls3additional/asteroids/asteroid_350.mdl",
	"models/ce_ls3additional/asteroids/asteroid_400.mdl",
	"models/ce_ls3additional/asteroids/asteroid_450.mdl",
	"models/ce_ls3additional/asteroids/asteroid_500.mdl"
}

function ENT:PostEntityPaste(ply,ent,CreateEnts)
	self:Remove()
	ply:SendLua("notification.AddLegacy('You may not do that!',NOTIFY_ERROR,5)")
end

local Conc = {0.8,0.9,1.0,1.1,1.2,1.3,1.4}

function ENT:Initialize()
	self.Int = math.random(1,7)
	self:SetModel(Models[self.Int])
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end
	self.OrePer = 100
	self.Concentration = Conc[self.Int] + math.Rand(-0.1,0.1)
	/*
	if self.Inc == 3 then return true end
	if self.Inc == 0 then
		self.BaseRoids = {}
		self.Roids = {}
		for I,P in pairs(Pos) do
			local Ent = ents.Create("sa_asteroid")
			Ent.Inc = self.Inc + 1
			Ent.Parent = self
			Ent:SetPos(self:LocalToWorld(Vector(P.x + math.Rand(-10,10),P.y + math.Rand(-10,10),P.z + math.Rand(-10,10))))
			Ent:SetAngles(Angle(math.Rand(0,360),math.Rand(0,360),math.Rand(0,360)))
			timer.Simple(math.Rand(0.8,1.2),function() 
				Ent:Spawn()
				table.insert(self.BaseRoids,Ent)
			end)
		end
	else
		for I=0,2 do
			local Ent = ents.Create("sa_asteroid")
			Ent.Inc = self.Inc + 1
			Ent.Parent = self.Parent
			Ent:SetPos(self.Parent:LocalToWorld(Vector((math.random(-30,30) * self.Inc) * (self.Inc + 1) + math.Rand(-10,10),
													   (math.random(-30,30) * self.Inc) * (self.Inc + 1) + math.Rand(-10,10),
													   (math.random(-30,30) * self.Inc) * (self.Inc + 1) + math.Rand(-10,10))))
			Ent:SetAngles(Angle(math.Rand(0,360),math.Rand(0,360),math.Rand(0,360)))
			timer.Simple(math.Rand(1.5 * self.Inc,5 * self.Inc),function() 
				Ent:Spawn() 
				table.insert(Ent.Parent.Roids,Ent)
			end)
		end
	end*/
end
/*
function ENT:OnRemove()
	if self.Inc > 0 then return end
	local Count = 0
	for I,P in pairs(self.BaseRoids) do
		if IsValid(P) then Count = Count + 1 end
	end
	if Count == 0 then
		for I,P in pairs(self.Roids) do
			if IsValid(P) then P:Remove() end
		end
		for I,P in pairs(Roids) do
			if P:EntIndex() == self:EntIndex() then 
				table.remove(Roids,I) 
				break 
			end
		end
	else
		local R = table.Random(self.BaseRoids)
		while (not IsValid(R)) do
			R = table.Random(self.BaseRoids)
		end
		R.Inc = 0
		R.BaseRoids = table.Copy(self.BaseRoids)
		R.Roids = self.Roids
		for I,P in pairs(Roids) do
			if P == self then
				Roids[I] = R
				break
			end
		end
	end
end*/