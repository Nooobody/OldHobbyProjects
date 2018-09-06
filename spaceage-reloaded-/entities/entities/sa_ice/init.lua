AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

local Models = {
	"models/props_wasteland/rockcliff01b.mdl",
	"models/props_wasteland/rockcliff01c.mdl",
	"models/props_wasteland/rockcliff01e.mdl",
	"models/props_wasteland/rockcliff01f.mdl",
	"models/props_wasteland/rockcliff01g.mdl",
	"models/props_wasteland/rockcliff01j.mdl",
	"models/props_wasteland/rockcliff01k.mdl"
}

function ENT:Initialize()
	self.Int = math.random(1,7)
	self:SetModel(Models[self.Int])
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMaterial("phoenix_storms/glass")
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end
	
	self.OrePer = 100
	self.Concentration = 1
end

function ENT:PostEntityPaste(ply,ent,CreateEnts)
	self:Remove()
	ply:SendLua("notification.AddLegacy('You may not do that!',NOTIFY_ERROR,5)")
end