AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("helperfunctions/cl_helper.lua")
AddCSLuaFile("helperfunctions/cl_states.lua")

include("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/cheeze/pcb/pcb8.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self.Socket = nil
	self.PlayerUsing = nil
	self.Started = 0
	self.CD = 0
	self.TimerName = "SA_TerminalCheck #"..self:EntIndex()

	local MinX = -32
	local MaxX = 32
	
	local MinY = -32
	local MaxY = 64
	local Name = "SA_TerminalBlockCheck #"..self:EntIndex()
	timer.Create(Name,2,0,function()
		if not IsValid(self) then timer.Destroy(Name) return end
		if math.random(1,2) == 1 and IsValid(self.Socket) and not self.Socket.Connected then
			local Tr = {}
			Tr.start = self.Socket:LocalToWorld(Vector(5,12,9))
			Tr.endpos = self.Socket:LocalToWorld(Vector(50,12,9))
			Tr.filter = {self.Socket,unpack(player.GetAll())}
			Tr.ignoreworld = true
			local Trace = util.TraceLine(Tr)
			if IsValid(Trace.Entity) and IsValid(Trace.Entity:GetPhysicsObject()) and not Trace.Entity:IsPlayer() and not Trace.Entity:GetNWEntity("Owner"):IsWorld() then
				Trace.Entity:GetPhysicsObject():EnableMotion(true)
				/*Trace.Entity:Remove()
				if IsValid(Trace.Entity) then
					local P = Trace.Entity:GetNWEntity("Owner")
					local Name = P:Name()
					local Reason = "Tried to block world ports."
					P:Kick(Reason)
					ChatIt("Player "..Name.." has been kicked from the server.")
					ChatIt("Reason: "..Reason)
				end*/
			end
		else
			local RanX = math.random(MinX,MaxX)
			local RanY = math.random(MinY,MaxY)
			local Tr = {}
			Tr.start = self:LocalToWorld(Vector(RanX,RanY,0))
			Tr.endpos = self:LocalToWorld(Vector(RanX,RanY,80))
			Tr.filter = {self,unpack(player.GetAll())}
			Tr.ignoreworld = true
			local Trace = util.TraceLine(Tr)
			if IsValid(Trace.Entity) and not Trace.Entity:IsPlayer() and not Trace.Entity:GetNWEntity("Owner"):IsWorld() then
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
		end
	end)
end

util.AddNetworkString("Terminal_PlayerLeft")

function ENT:Use(act,cal)
	if self.CD > CurTime() then return end
	self.CD = CurTime() + 2
	if not IsValid(self.PlayerUsing) then self.PlayerUsing = nil end
	if self.RestrictedToOne then
		if self.PlayerUsing and cal ~= self.PlayerUsing then cal:SendLua("notification.AddLegacy('Wait for your turn!',NOTIFY_ERROR,5)") return end
		if self.PlayerUsing then return end
		if cal == self.OldPlayer then
			if self.OldPlayer.CD > CurTime() then 
				self.OldPlayer:SendLua("notification.AddLegacy('You cannot use it that often!',NOTIFY_ERROR,5)")
				return
			else 
				self.OldPlayer.CD = 0 
				self.OldPlayer = nil
			end
		end
	else
		return
	end
		
	if cal.TerminalUsing and cal.TerminalUsing ~= self then 
		cal:SendLua("notification.AddLegacy('You can use only one terminal at a time!',NOTIFY_ERROR,5)")
		return
	end
	
	cal:SendLua("notification.AddLegacy('Welcome to the terminal, sir!',NOTIFY_HINT,5)")
	self.PlayerUsing = cal
	cal.TerminalUsing = self
	self.Started = CurTime()
	
	self:SetNWInt("Started",self.Started)
	self:SetNetworkedEntity("Using",self.PlayerUsing)
	self:UseAction()
end

function ENT:TimeOut(NotTimeOut)
	if IsValid(self.PlayerUsing) then
		self.OldPlayer = self.PlayerUsing
		self.OldPlayer.CD = CurTime() + 5
		self.OldPlayer.TerminalUsing = nil
	end
	self.PlayerUsing = nil
	self.Started = 0
	self.CD = CurTime() + 2
	
	self:SetNWEntity("Using",NULL)
	self:SetNWInt("Started",0)
	
	if timer.Exists(self.TimerName) then timer.Destroy(self.TimerName) end
	
	self:TimeOutAction()
	if not NotTimeOut and IsValid(self.OldPlayer) then
		self.OldPlayer:SendLua("notification.AddLegacy('"..self:TimeOutMsg().."',NOTIFY_ERROR,5)")
	end
end

function ENT:TimeOutAction()
end

function ENT:TimeOutMsg()
	return "You have been logged out of a terminal!"
end

net.Receive("Terminal_PlayerLeft",function(len,ply)
	local Ent = net.ReadEntity()
	Ent:TimeOut(true)
end)

function ENT:PostEntityPaste(ply,ent,CreateEnts)
	self:Remove()
	ply:SendLua("notification.AddLegacy('You may not do that!',NOTIFY_ERROR,5)")
end
