AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "RD"
	self.SubClass = "Generator"
	self.ROutputs.Energy = math.pow(3,3)
	
	self.Humming = CreateSound(self,Sound("ambient/energy/electric_loop.wav"))
	self.sDenied = ""
	self.sStart = ""
	self.sEnd = ""
	self.NextThnk = 0.2
	self.IsFlat = false
	self.MdlMul = 1
	
	self.Coverage = 0
	self.StartVec = Vector(10.7,0,85)
	self.Normal = Vector(-0.58,0,-0.81):Angle()
	self.SunVec = SA_SUN:GetPos()
	
	self.Inputs = Wire_CreateInputs(self,{"Sound Off"})
	self.Outputs = Wire_CreateOutputs(self,{"Status","Coverage"})
end

function ENT:Setup(info,Num)
	self:SetNWOwner(self:GetPlayer())
	local Mul = info.SizeNumber or Num
	
	if Mul then
		self:SetSizeNumber(Mul)
	else
		if self:GetModel() == "models/slyfo_2/miscequipmentsolar.mdl" then
			self:SetSizeNumber(2)
		else
			self:SetSizeNumber(1)
		end
	end
	
	if not self:CheckLevel() then
		self:GetPlayer():SendLua("notification.AddLegacy('You do not have sufficient research level for that yet!',NOTIFY_ERROR,5)")
		self:Remove()
		return false
	end
	
	self.DefaultMass = self:GetPhysicsObject():GetMass()
	self:SetMass()
end

function ENT:CheckLevel()
	if self:GetNWEntity("Owner"):GetResearch("Solar_Research") < self.SizeNumber then return false end
	return true
end

local Flats = {
	"models/ce_ls3additional/solar_generator/solar_generator_small.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_medium.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_large.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_huge.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_giant.mdl"
}
local Circles = {
	"models/ce_ls3additional/solar_generator/solar_generator_c_small.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_c_medium.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_c_large.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_c_huge.mdl"
}

function ENT:SetSizeNumber(Mul)
	self.SizeNumber = Mul
	if self.SizeNumber == 1 then
		local Size = table.KeyFromValue(Flats,self:GetModel())
		if not Size then Size = table.KeyFromValue(Circles,self:GetModel()) end
		self.MdlMul = Size / 2
		self.StartVec = Vector(0,0,0)
		self.Normal = Vector(0,0,-1):Angle()
	else
		self.MdlMul = 1
		self.StartVec = Vector(10.7,0,85)
		self.Normal = Vector(-0.58,0,-0.81):Angle()
	end
end

function ENT:Use()
end

function ENT:ThinkStart()
	self.SunVec = SA_SUN:GetPos()
	local Start = self:LocalToWorld(self.StartVec)
	local Tr = {}
	Tr.start = Start
	Tr.endpos = self.SunVec
	Tr.filter = {self}
	local Trace = util.TraceLine(Tr)
	if not Trace.Hit then
		local Vec1 = -self:LocalToWorldAngles(self.Normal):Forward() * Start:Distance(self.SunVec)
		local Vec2 = self.SunVec - Start
		local Ang = math.deg(math.acos(Vec1:Dot(Vec2) / (Vec1:Length() * Vec2:Length())))
		local Cov = 1 - Ang / 85
		if Cov ~= self.Coverage then
			self.Humming:ChangePitch(Cov * 255,0.1)
			self.Coverage = Cov
			Wire_TriggerOutput(self,"Coverage",self.Coverage)
			self.ROutputs.Energy = ((math.pow(3,3) + (math.pow(3,3) * (self.SizeNumber - 1) * 5)) * self.MdlMul * (1 + self:GetNWEntity("Owner"):GetResearch("Solar_Panel_Output") * 0.01)) * self.Coverage
			if Ang < 85 and not self.Online then
				self:On()
				self.Humming:ChangePitch(Cov * 255,0.01)
			elseif Ang >= 85 and self.Online then
				self:Off()
			end
		end
	elseif self.Online then
		self:Off()
	end
end