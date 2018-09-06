AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

hook.Add("EntityTakeDamage","TiberiumHit",function(Targ,dmginfo)
	if IsValid(dmginfo:GetAttacker()) and (dmginfo:GetAttacker():GetClass() == "sa_mining_laser" or dmginfo:GetAttacker():GetClass() == "sa_tiberium_tower" or dmginfo:GetAttacker():GetClass() == "sa_tiberium_crystal") then
		dmginfo:SetDamageType(DMG_DISSOLVE)
	end
	return dmginfo
end)

function ENT:Initialize()
	self.Entity:SetModel("models/chipstiks_mining_models/SmallGreenTower/smallgreentower.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end
	
	self.TibModel = "models/chipstiks_mining_models/SmallGreenCrystal/smallgreencrystal.mdl"
	self.Tibs = {}
	self.SpawnCD = 0
	self.TibAmount = 25
	self.Descended = 0
end

local Radius = 1000

function ENT:Think()
	self:NextThink(CurTime() + 0.2)
	
	local Ents = ents.FindInSphere(self:GetPos(),100)
	for I,P in pairs(Ents) do
		if P:IsPlayer() then
			P:TakeDamage(100,self,self)
		elseif IsValid(P) and not P.RemoveEffect and IsValid(P:GetPhysicsObject()) and IsValid(P:GetNWEntity("Owner")) and P:GetNWEntity("Owner"):IsPlayer() then
			local Ef = EffectData()
			Ef:SetEntity(P)
			util.Effect("propremove",Ef)
			P:SetSolid(0)
			P:SetGravity(0.00001)
			P.RemoveEffect = true
			timer.Simple(0.49,function() if IsValid(P) then P:Remove() end end)
		end
	end
	
	if self.Descending then
		if self.Descended >= self.Height then
			self:Remove()
			return
		end
		self:SetPos(self:LocalToWorld(Vector(0,0,-1)))
		self.Descended = self.Descended + 1
		return true
	end
	
	if #self.Tibs >= 5 or self.SpawnCD > CurTime() then return true end
	
	local RanX,RanY = math.sin(math.rad(math.random(0,360))) * math.random(200,Radius),math.cos(math.rad(math.random(0,360))) * math.random(200,Radius)
	local Tr = {}
	Tr.start = self:LocalToWorld(Vector(RanX,RanY,500))
	Tr.endpos = self:LocalToWorld(Vector(RanX,RanY,-500))
	Tr.filter = self
	local Trace = util.TraceLine(Tr)
	
	if Trace.HitWorld then
		self.TibAmount = self.TibAmount - 1
		if self.TibAmount < 0 then
			self.Descending = true
			self.Height = self:OBBMaxs().z
			return true
		end
		local Tib = ents.Create("sa_tiberium_crystal")
		Tib:SetPos(Trace.HitPos)
		Tib:Spawn()
		Tib:SetModel(self.TibModel)
		Tib:SetNWEntity("Owner",ents.GetAll()[1])
		Tib.IsBlue = self.IsBlue
		Tib.Tower = self
		table.insert(self.Tibs,Tib)
		self.SpawnCD = CurTime() + math.random(20,60)
	end
	
	return true
end

function ENT:StartTouch(Ent)
	if Ent.RemoveEffect then return end
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

function ENT:PostEntityPaste(ply,ent,CreateEnts)
	self:Remove()
	ply:SendLua("notification.AddLegacy('You may not do that!',NOTIFY_ERROR,5)")
end