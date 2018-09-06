AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props_lab/tpplug.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.ScreenName = "Plug"..self:EntIndex()
	self.LinkPlug = nil
	self.Connected = nil
	self.Spawned = false
	self.DoNotDuplicate = true
end

function ENT:Think()
	self:NextThink(CurTime() + 0.2)
	if not self.Spawned then
		if IsValid(self.LinkPlug) then
			self.Spawned = true
		end
		return true
	end
	
	if self.Spawned then
		if self.Weld and not self.IsPlugged then
			self.IsPlugged = true
			self:Plugged()
		elseif self.IsPlugged and not IsValid(self.Weld) then
			self.IsPlugged = false
			self.Weld = nil
			self:UnPlugged()
		end
		
		if not IsValid(self.Connected) then
			self.Connected = nil
		end
		
		local Constr = constraint.FindConstraints(self,"Rope")
		local Found = false
		for I,P in pairs(Constr) do
			if P.Ent2 == self.LinkPlug or P.Ent1 == self.LinkPlug then
				Found = true
				break
			end
		end
		
		if not Found then 
			self.LinkPlug = nil
			self:Remove()
		end
		
		if not IsValid(self.LinkPlug) then
			self:Remove()
		end
	end
		
	return true
end
/*
local function SetPlug(ply,ent,data)
	if data and data.LinkPlug then
		ent.LinkPlug = data.LinkPlug
		duplicator.StoreEntityModifier(ent,"LinkPlug",data)
	end
end
duplicator.RegisterEntityModifier("LinkPlug",SetPlug)

function ENT:PreEntityCopy()
	if self.Connected then self.DoNotDuplicate = true end
	duplicator.StoreEntityModifier(self,"LinkPlug",{LinkPlug = self.LinkPlug})
end

function ENT:PostEntityPaste(ply,ent,CreatedEnts)
	for I,P in pairs(CreatedEnts) do
		if I == ent.LinkPlug:EntIndex() then
			ent.LinkPlug = P
			break
		end
	end
end
*/

function ENT:PostEntityPaste(ply,ent,CreatedEnts)
	ent:Remove()
	return false
end

function ENT:Plugged()
	self:EmitSound("ambient/energy/spark6.wav")
	local Eff = EffectData()
	Eff:SetScale(1)
	Eff:SetRadius(100)
	Eff:SetAngles(self:LocalToWorldAngles(Angle(0,0,0)))
	Eff:SetOrigin(self:GetPos())
	Eff:SetStart(self:GetPos())
	util.Effect("ManhackSparks",Eff)
end

function ENT:UnPlugged()
	self:EmitSound("ambient/energy/zap6.wav")
	local Eff = EffectData()
	Eff:SetScale(1)
	Eff:SetRadius(100)
	Eff:SetAngles(self:LocalToWorldAngles(Angle(0,0,0)))
	Eff:SetOrigin(self:GetPos())
	Eff:SetStart(self:GetPos())
	util.Effect("ManhackSparks",Eff)
end