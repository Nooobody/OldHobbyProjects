AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/Slyfo/sat_rtankstand.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.Storages = {}
	self.Vectors = {{Vector(0.9,18.84,21.58),nil},{Vector(0.9,-18.84,21.58),nil}}
	
	self:Int()
	self.Class = "M"
	self.SubClass = "Holder"
	
	self.Inputs = Wire_CreateInputs(self,{"Eject"})
	self.Outputs = Wire_CreateOutputs(self,{"RawTiberium","RawTiberiumMax"})
end

function ENT:TriggerInput(name,val)
	if name == "Eject" and val ~= 0 then
		if IsValid(self.Vectors[1][2]) then
			self.Vectors[1][2]:Use(self:GetNWEntity("Owner"),self:GetNWEntity("Owner"),USE_ON,0)
		end
		if IsValid(self.Vectors[2][2]) then
			self.Vectors[2][2]:Use(self:GetNWEntity("Owner"),self:GetNWEntity("Owner"),USE_ON,0)
		end
	end
end

function ENT:TriggerOutput()
	if not self.SentStor then
		self.SentStor = 0
		self.SentStorMax = 0
	end
	local Stor = 0
	local Max = 0
	if IsValid(self.Vectors[1][2]) then
		Stor = Stor + self.Vectors[1][2].Storage.RawTiberium
		Max = Max + self.Vectors[1][2].StorageMax.RawTiberium
	end
	
	if IsValid(self.Vectors[2][2]) then
		Stor = Stor + self.Vectors[2][2].Storage.RawTiberium
		Max = Max + self.Vectors[2][2].StorageMax.RawTiberium
	end
	
	if self.SentStor ~= Stor then
		Wire_TriggerOutput(self,"RawTiberium",Stor)
		self.SentStor = Stor
	end
	if self.SentStorMax ~= Max then
		Wire_TriggerOutput(self,"RawTiberiumMax",Max)
		self.SentStorMax = Max
	end
end

function ENT:ThinkStart()
	self:TriggerOutput()
end

function ENT:Use()
end

function ENT:AfterLink()
	if IsValid(self.Vectors[1][2]) and IsValid(self.Vectors[1][2].Weld) then
		for I,P in pairs(self.Links) do
			self.Vectors[1][2]:Link(P)
		end
	end
	if IsValid(self.Vectors[2][2]) and IsValid(self.Vectors[2][2].Weld) then
		for I,P in pairs(self.Links) do
			self.Vectors[2][2]:Link(P)
		end
	end
end

function ENT:StartTouch(Ent)
	if not IsValid(self.Vectors[1][2]) or not IsValid(self.Vectors[1][2].Weld) then 
		self.Vectors[1][2] = nil 
	end
	
	if not IsValid(self.Vectors[2][2]) or not IsValid(self.Vectors[2][2].Weld) then 
		self.Vectors[2][2] = nil 
	end
	
	if IsValid(Ent) and Ent:GetClass() == "sa_mining_rawtib_storage" and not Ent.Hold and not Ent.Used and (not self.Vectors[1][2] or not self.Vectors[2][2]) then
		local Pos
		if self.Vectors[1][2] then Pos = self:LocalToWorld(self.Vectors[2][1])
		else Pos = self:LocalToWorld(self.Vectors[1][1]) end
		Ent:SetPos(Pos)
		Ent:SetAngles(self:LocalToWorldAngles(Angle(0,0,0)))
		Ent:GetPhysicsObject():EnableMotion(false)
		local NC = constraint.NoCollide(self,Ent,0,0)
		local weld = constraint.Weld(self,Ent,0,0,0,true)
		if not IsValid(Ent) then return end
		if IsValid(weld) and IsValid(NC) then
			Ent:DeleteOnRemove(NC)
			Ent:DeleteOnRemove(weld)
			Ent.Weld = weld
			Ent.NC = NC
			self:DeleteOnRemove(weld)
			self:DeleteOnRemove(NC)
		end
		Ent.Hold = self
		Ent.DoNotDuplicate = true
		for I,P in pairs(self.Links) do
			Ent:Link(P)
		end
		if self.Vectors[1][2] then self.Vectors[2][2] = Ent 
		else self.Vectors[1][2] = Ent end
	end
end

function ENT:ReturnStor()
	local T = {}
	if IsValid(self.Vectors[1][2]) and IsValid(self.Vectors[1][2].Weld) then T[1] = self.Vectors[1][2] end
	if IsValid(self.Vectors[2][2]) and IsValid(self.Vectors[2][2].Weld) then T[2] = self.Vectors[2][2] end
	return T
end

function ENT:BuildDupeInfo()
	local info = self.BaseClass.BuildDupeInfo(self) or {}
	local T = {}
	if IsValid(self.Vectors[1][2]) then T[1] = self.Vectors[1][2].SizeNumber else T[1] = false end
	if IsValid(self.Vectors[2][2]) then T[2] = self.Vectors[2][2].SizeNumber else T[2] = false end
	info.Storages = T
	return info
end

function ENT:ApplyDupeInfo(ply,ent,info,GetEntByID)
	self.BaseClass.ApplyDupeInfo(self,ply,ent,info,GetEntByID)
	
	if not info.Storages then return end
	undo.Create("Raw Tiberium Storages")
	if info.Storages[1] and self:GetNWEntity("Owner"):CheckLimit("sa_mining_rawtib_storage") then
		local Ent = WireLib.MakeWireEnt(self:GetNWEntity("Owner"),{Pos = self:LocalToWorld(self.Vectors[1][1]),Ang = self:LocalToWorldAngles(Angle(0,0,0)),Class = "sa_mining_rawtib_storage"},{SizeNumber = info.Storages[1]})
		self:StartTouch(Ent)
		undo.AddEntity(Ent)
	end
	
	if info.Storages[2] and self:GetNWEntity("Owner"):CheckLimit("sa_mining_rawtib_storage") then
		local Ent = WireLib.MakeWireEnt(self:GetNWEntity("Owner"),{Pos = self:LocalToWorld(self.Vectors[2][1]),Ang = self:LocalToWorldAngles(Angle(0,0,0)),Class = "sa_mining_rawtib_storage"},{SizeNumber = info.Storages[2]})
		self:StartTouch(Ent)
		undo.AddEntity(Ent)
	end
	undo.SetPlayer(ply)
	undo.Finish()
end