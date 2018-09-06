AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

util.AddNetworkString("Terminal_Teleport")

function ENT:Initialize()
	self.Entity:SetModel("models/cheeze/pcb/pcb8.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.CD = 0
	self:SetNWString("Name",self.ScreenName)
	
	local MinX = -32
	local MaxX = 32
	
	local MinY = -32
	local MaxY = 64
	timer.Create("SA_TerminalBlockCheck #"..self:EntIndex(),2,0,function()
		local RanX = math.random(MinX,MaxX)
		local RanY = math.random(MinY,MaxY)
		local Tr = {}
		Tr.start = self:LocalToWorld(Vector(RanX,RanY,0))
		Tr.endpos = self:LocalToWorld(Vector(RanX,RanY,80))
		Tr.filter = {self,unpack(player.GetAll())}
		Tr.ignoreworld = true
		local Trace = util.TraceLine(Tr)
		if IsValid(Trace.Entity) and IsValid(Trace.Entity:GetPhysicsObject()) and not Trace.Entity:IsPlayer() then
			Trace.Entity:GetPhysicsObject():EnableMotion(true)
			/*Trace.Entity:Remove()
			if IsValid(Trace.Entity) then
				local P = Trace.Entity:GetNWEntity("Owner")
				local Name = P:Name()
				local Reason = "Tried to block important screens."
				P:Kick(Reason)
				ChatIt("Player "..Name.." has been kicked from the server.")
				ChatIt("Reason: "..Reason)
			end*/
		end
	end)
end

net.Receive("Terminal_Teleport",function(len,ply)
	local Str = net.ReadString()
	local Teles = {}
	for I,P in pairs(ents.FindByClass("sa_teleporter_screen")) do
		if P:GetNWString("Name") == Str then
			table.insert(Teles,P)
		end
	end
	local Tele = table.Random(Teles)
	local Ent = ents.Create("prop_physics")
	Ent:SetModel("models/props_borealis/bluebarrel001.mdl")
	Ent:SetPos(ply:GetPos())
	Ent:Spawn()
	Ent:SetNoDraw(true)
	Ent:SetSolid(0)
	Ent:GetPhysicsObject():EnableMotion(false)
	Ent:EmitSound("ambient/machines/teleport4.wav",100,255)
	ply:SetPos(Tele:LocalToWorld(Vector(-55,20,81)))
	ply:EmitSound("ambient/machines/teleport4.wav",100,255)		
	if ply.Planet ~= Tele.Planet then
		if ply.Planet then ply.Planet:RemoveEnt(ply) end
	end
	timer.Simple(0.4,function() Ent:Remove() end)
end)