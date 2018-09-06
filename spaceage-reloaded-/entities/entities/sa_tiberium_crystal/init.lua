AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/chipstiks_mining_models/SmallGreenCrystal/smallgreencrystal.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end
	
	self.OrePer = 100
	self.Concentration = 1
	self.OrgPos = self:GetPos()
	self:SetPos(self:LocalToWorld(Vector(0,0,-self:OBBMaxs().z)))
	self.Moving = true
end

function ENT:Think()
	self:NextThink(CurTime() + 0.2)
	
	if self.Moving then
		self:SetPos(self:LocalToWorld(Vector(0,0,0.5)))
		if self:GetPos():Distance(self.OrgPos) < 1 then
			self.Moving = false
			self.Think = function(self) end
		end
	end
	return true
end

function ENT:StartTouch(Ent)
	if Ent.RemoveEffect then return end
	if Ent:GetClass() == "sa_mining_drill" then	
		Ent.Touching = self
	else
		if Ent:IsPlayer() then
			Ent:TakeDamage(100,self,self)
		elseif IsValid(Ent) and IsValid(Ent:GetPhysicsObject()) and IsValid(Ent:GetNWEntity("Owner")) and Ent:GetNWEntity("Owner"):IsPlayer() and Ent:GetClass() ~= "sa_mining_drill" then
			local Ef = EffectData()
			Ef:SetEntity(Ent)
			util.Effect("propremove",Ef)
			Ent:SetSolid(0)
			Ent:SetGravity(0.00001)
			Ent.RemoveEffect = true
			timer.Simple(0.49,function() if IsValid(Ent) then Ent:Remove() end end)
		end
	end
end

function ENT:EndTouch(Ent)
	if Ent.Touching then Ent.Touching = nil	end
end

function ENT:OnRemove()
	if not IsValid(self.Tower) then return end
	local Tab = self.Tower.Tibs
	for I,P in pairs(Tab) do
		if P == self then
			self.Tower.Tibs[I] = nil
			break
		end
	end
end

function ENT:PostEntityPaste(ply,ent,CreateEnts)
	self:Remove()
	ply:SendLua("notification.AddLegacy('You may not do that!',NOTIFY_ERROR,5)")
end