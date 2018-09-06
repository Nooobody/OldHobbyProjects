AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

local S_CLOSED = 0
local S_OPENED = 1
local S_MOVING = 2
local S_LOADED = 3
local S_TRANSMIT = 4

function ENT:Initialize()
	self.Entity:SetModel("models/hunter/plates/plate4x4.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.Terminal = nil
	
	self.Pos = {
		Vector(80,-6,0),
		Vector(6,80,0),
		Vector(-80,6,0),
		Vector(-6,-80,0)
	}
				
	self.Locals = {
		Vector(0,1,12.4),
		Vector(0,1,12.4),
		Vector(0,1,12.4),
		Vector(0,1,12.4)
	}

	self:SetMaterial("phoenix_storms/metalset_1-2")
	self.Primary = {}
	self.Secondary = {}
	self.Stage = 0
	self.State = S_OPENED
	self.TickInt = 0
	self.Queue = {}
	
	for I = 1,4 do
		local Prop = ents.Create("prop_physics")
		Prop:SetModel("models/hunter/blocks/cube025x4x025.mdl")
		Prop:SetAngles(self:LocalToWorldAngles(Angle(-180,90 * I + 180,-90)))
		Prop:SetPos(self:LocalToWorld(self.Pos[I]))
		Prop:SetPos(Prop:LocalToWorld(-Prop:OBBMins()))
		Prop:Spawn()
		Prop:GetPhysicsObject():EnableMotion(false)
		Prop:SetNWEntity("Owner",ents.GetAll()[1])
		Prop:SetMaterial("phoenix_storms/metalset_1-2")
		self.Primary[I] = Prop
		local Sec = ents.Create("prop_physics")
		Sec:SetModel("models/hunter/blocks/cube025x4x025.mdl")
		local Pos = Prop:OBBMaxs()
		Sec:SetAngles(Prop:GetAngles())
		Sec:SetPos(Prop:LocalToWorld(Pos))
		Sec:SetPos(Sec:LocalToWorld(-Pos))
		Sec:Spawn()
		Sec:GetPhysicsObject():EnableMotion(false)
		Sec:SetNWEntity("Owner",ents.GetAll()[1])
		Sec:SetMaterial("phoenix_storms/metalset_1-2")
		self.Secondary[I] = Sec
	end
	
	self:Close()
end

function ENT:Think()
	self:NextThink(CurTime() + 0.01)
	if self.Stage > 0 and self.Queue[self.Stage] then
		self.Queue[self.Stage]()
	end
	return true
end

function ENT:Transmit()
	if self.State == S_MOVING then print("Still moving!") return false end
	if self.State ~= S_LOADED then print("Not loaded!") return false end
	self.State = S_TRANSMIT
	self.Stage = 1
	local Snd = CreateSound(self.Stor,Sound("ambient/energy/electric_loop.wav"))
	Snd:Play()
	self.TickInt = 0
	table.insert(self.Queue,function()
		Snd:ChangePitch(Lerp(self.TickInt / 200,0,100),0.1)
		self.TickInt = self.TickInt + 1
		if self.TickInt > 200 then
			self.Stage = 2
		end
	end)
	table.insert(self.Queue,function()
		if self.DoneTransmit then
			self.Stage = 3
		end
	end)
	table.insert(self.Queue,function()
		Snd:ChangePitch(Lerp(self.TickInt / 200,0,100),0.1)
		self.TickInt = self.TickInt - 1
		if self.TickInt < 0 then
			Snd:Stop()
			self.Stage = 0
			self.Queue = {}
			self.State = S_LOADED
		end
	end)
	return true
end

function ENT:Open(Callback)
	if self.State == S_MOVING then print("Still moving!") return false end
	if self.State ~= S_CLOSED then print("Not closed!") return false end
	self.State = S_MOVING
	self.Stage = 1
	self.TickInt = -180
	self:EmitSound("ambient/machines/hydraulic_1.wav")
	table.insert(self.Queue,function()
		self:MovePrim(self.TickInt)
		self.TickInt = self.TickInt + 1
		if self.TickInt > -90 then
			self.TickInt = 0
			self.Stage = 2
		end
	end)
	table.insert(self.Queue,function()
		self:MoveSec(self.TickInt,true)
		self.TickInt = self.TickInt + 1
		if self.TickInt > 180 then
			self.Stage = 0
			self.State = S_OPENED
			self.Queue = {}
			if Callback then Callback() end
		end
	end)
	return true
end

function ENT:Close(Callback)
	if self.State == S_MOVING then print("Still moving!") return false end
	if self.State ~= S_OPENED then print("Not opened!") return false end
	self.State = S_MOVING
	self.Stage = 1
	self.TickInt = 180
	self:EmitSound("ambient/machines/hydraulic_1.wav")
	table.insert(self.Queue,function()
		self:MoveSec(self.TickInt,false)
		self.TickInt = self.TickInt - 1
		if self.TickInt < 0 then
			self.TickInt = -90
			self.Stage = 2
		end
	end)
	
	table.insert(self.Queue,function()
		self:MovePrim(self.TickInt)
		self.TickInt = self.TickInt - 1
		if self.TickInt < -180 then
			self.Stage = 0
			self.State = S_CLOSED
			self.Queue = {}
			if Callback then Callback() end
		end
	end)
	return true
end

function ENT:Load(Callback)
	if self.State == S_MOVING then print("Still moving!") return false end
	if self.State ~= S_OPENED then print("Not opened!") return false end
	local Trace = {}
	Trace.start = self:GetPos() + self:GetAngles():Up() * 10
	Trace.endpos = self:GetPos() + self:GetAngles():Up() * 200
	Trace.filter = self
	
	local Tr = util.TraceLine(Trace)
	if Tr.Hit and Tr.Entity and Tr.Entity:GetClass() == "sa_mining_liquidtib_storage" then
		self.Stor = Tr.Entity
	else
		print("No entity found!")
		print("Hit: "..tostring(Tr.Hit))
		print("Ent: "..tostring(Tr.Entity))
		return false
	end
	
	self.State = S_MOVING
	self.Stage = 1
	self.TickInt = 180
	self.Stor:GetPhysicsObject():EnableMotion(false)
	self.StorOwner = self.Stor:GetNWEntity("Owner")
	self.Stor:SetNWEntity("Owner",ents.GetAll()[1])
	local Pos = self.Stor:GetPos()
	local Ang = self.Stor:GetAngles()
	table.insert(self.Queue,function()
		self:MoveSec(self.TickInt,false)
		local Lerped = LerpVector(1 - (self.TickInt - 165) / 15,Pos,self:LocalToWorld(Vector(0,self.Stor:OBBMins().y - 20,self.Stor:OBBMaxs().z - 10)))
		local LerpedAng = LerpAngle(1 - (self.TickInt - 165) / 15,Ang,self:LocalToWorldAngles(Angle(90,90,0)))
		self.Stor:SetPos(Lerped)
		self.Stor:SetAngles(LerpedAng)
		self.TickInt = self.TickInt - 1
		if self.TickInt < 165 then
			self.Stage = 0
			self.State = S_LOADED
			self.Queue = {}
			if Callback then Callback() end
		end
	end)
	return true
end

function ENT:Unload(Callback)
	if self.State == S_MOVING then print("Still moving!") return false end
	if self.State ~= S_LOADED then print("Not loaded!") return false end
	self.State = S_MOVING
	self.Stage = 1
	self.TickInt = 165
	table.insert(self.Queue,function()
		self:MoveSec(self.TickInt,true)
		self.TickInt = self.TickInt + 1
		if self.TickInt > 180 then
			self.Stage = 0
			self.State = S_OPENED
			self.Queue = {}
			self.Stor:SetNWOwner(self.StorOwner)
			self.StorOwner = nil
			self.Stor = nil
			if Callback then Callback() end
		end
	end)
	return
end

function ENT:MoveSec(Ang,IsUp)
	for I,P in pairs(self.Secondary) do
		local Loc = LerpVector(1 - (Ang / 180),self.Locals[I],Vector())
		if IsUp then Loc = LerpVector(Ang / 180,Vector(),self.Locals[I]) end
		local Prim = self.Primary[I]
		P:SetAngles(Prim:LocalToWorldAngles(Angle(0,0,Ang)))
		P:SetPos(Prim:LocalToWorld(Prim:OBBMaxs()))
		P:SetPos(P:LocalToWorld(-Prim:OBBMaxs() + Loc))
	end
end

function ENT:MovePrim(Ang)
	for I,P in pairs(self.Primary) do
		local Sec = self.Secondary[I]
		P:SetAngles(self:LocalToWorldAngles(Angle(-180,90 * I + 180,Ang)))
		P:SetPos(self:LocalToWorld(self.Pos[I]))
		P:SetPos(P:LocalToWorld(-P:OBBMins()))
		Sec:SetPos(P:GetPos())
		Sec:SetAngles(P:GetAngles())
	end
end