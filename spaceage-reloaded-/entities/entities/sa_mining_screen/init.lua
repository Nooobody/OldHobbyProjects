AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("helperfunctions/cl_mstates.lua")

include("shared.lua")

util.AddNetworkString("Terminal_StartData")
util.AddNetworkString("Terminal_RefreshTable")
util.AddNetworkString("Terminal_MiningStorageTable")
util.AddNetworkString("Terminal_MiningSendStorage")
util.AddNetworkString("Terminal_MiningTransmit")
util.AddNetworkString("Terminal_MiningTransmitProgress")

function ENT:CheckLink()
	return IsValid(self.Socket.Connected) and IsValid(self.Socket.ConnectedSocket)
end

function ENT:Check(CameFromC)
	if not self.PlayerUsing then return false end
	if self:CheckLink() then
		local Port = self.Socket.Connected.LinkPlug.Connected
		local Sto = {}
		for I,P in pairs(Port:UpdateLinks()) do
			if P.Storage and next(P.Storage) then
				for R,S in pairs(P.Storage) do
					if R ~= "Energy" then
						if Sto[R] then
							Sto[R][1] = Sto[R][1] + S
							Sto[R][2] = Sto[R][2] + P.StorageMax[R]
						else
							Sto[R] = {S,P.StorageMax[R]}
						end
					end
				end
			end
		end
		net.Start("Terminal_StartData")	
			net.WriteEntity(self)
			net.WriteBit(true)
			net.WriteTable(Sto)
			net.WriteBit(CameFromC or false)
		net.Send(self.PlayerUsing)
		return true
	else
		net.Start("Terminal_StartData")
			net.WriteEntity(self)
			net.WriteBit(false)
		net.Send(self.PlayerUsing)
		timer.Simple(1,function() self:Check() end)
		return false
	end
end

function ENT:UseAction(act,cal)
	self:Check()
	local Int = 0
	timer.Create(self.TimerName,1,0,function()
		if not IsValid(self.PlayerUsing) or not self.PlayerUsing:IsPlayer() then 
			self:TimeOut(true)
			return 
		end
		if self.UniID and timer.Exists(self.UniID) then return end
		local Tr = self.PlayerUsing:GetEyeTrace()
		if not Tr.Entity or Tr.Entity ~= self or self:GetPos():Distance(self.PlayerUsing:GetPos()) > 100 then
			Int = Int + 1
		elseif Int > 0 then
			Int = 0
		end
		
		if self:CheckLink() then				
			if Int > 30 then
				self:TimeOut()
			end
		else
			if Int > 10 then
				self:TimeOut()
			end
		end
	end)
end

function ENT:TimeOutAction()
	if IsValid(self.Socket.Connected) and IsValid(self.Socket.Connected:GetPhysicsObject()) then
		constraint.RemoveConstraints(self.Socket,"Weld")
		self.Socket.Connected:GetPhysicsObject():EnableMotion(true)
	end
end

function ENT:TransmitFromShip(Res,Am)
	self.Socket.Status = PORT_INCOMING
	self.Socket.ConnectedSocket.Status = PORT_SENDING
	
	self.Socket.TransmitAmount = Am
	
	self.Socket.ConnectedSocket.RInputs[Res] = 1
	
	local Amount
	if self.Socket.Connected.Plasma and self.Socket.ConnectedSocket:GetNWEntity("Owner"):GetResearch("Socket_Plasma_Fiber") > 0 then
		Amount = math.Round(self.Socket.DefAmount * math.pow(2,10) * (1 + self.Socket.ConnectedSocket:GetNWEntity("Owner"):GetResearch("Socket_Plasma_Fiber") / 10))
	elseif self.Socket.Connected.Golden and self.Socket.ConnectedSocket:GetNWEntity("Owner"):GetResearch("Socket_Optic_Fiber") > 0 then
		Amount = math.Round(self.Socket.DefAmount * math.pow(2,5) * (1 + self.Socket.ConnectedSocket:GetNWEntity("Owner"):GetResearch("Socket_Optic_Fiber") / 10))
	else
		Amount = math.Round(self.Socket.DefAmount * (1 + self.Socket.ConnectedSocket:GetNWEntity("Owner"):GetResearch("Socket_Transmission_Speed") / 100))
	end
	
	self.Socket.Receiving = Res
	self.Socket.ConnectedSocket.Sending = Res
	
	local PL = math.Round(self.Socket.TransmitAmount * (0.05 - 0.001 * self.PlayerUsing:GetResearch("Socket_Packet_Loss")))
	if Amount < self.Socket.TransmitAmount then
		PL = math.Round(PL / (self.Socket.TransmitAmount / Amount))
	end

	self.Socket.Amount = Amount - PL
	self.Socket.ConnectedSocket.Amount = Amount
	
	self.Socket.ConnectedSocket:UpdateLinks()
	
	self.Socket:TriggerOutput()
	self.Socket.ConnectedSocket:TriggerOutput()
	
	if not self.UniID then self.UniID = "TransmitProgress #"..self:EntIndex() end
	timer.Create(self.UniID,0.5,0,function()
		if not self:CheckLink() then 			// Fuck
			self.Socket.Receiving = ""
			self.Socket.TransmitAmount = 0
			self.Socket.Status = PORT_UNPLUGGED
			self.Socket:TriggerOutput()
			net.Start("Terminal_MiningTransmitProgress")
				net.WriteEntity(self)
				net.WriteFloat(-1)
			net.Send(self.PlayerUsing)
			timer.Destroy(self.UniID)
			self:Check()
			return
		end
		
		net.Start("Terminal_MiningTransmitProgress")
			net.WriteEntity(self)
			net.WriteFloat(1 - self.Socket.TransmitAmount / Am)
			net.WriteBit(true)
		net.Send(self.PlayerUsing)
		
		if self.Socket.TransmitAmount == 0 then // Job done!
			self.Socket.Receiving = ""
			self.Socket.ConnectedSocket.Sending = ""
			self.Socket.Status = PORT_STANDBY
			self.Socket.ConnectedSocket.Status = PORT_STANDBY
			
			self.Socket.ConnectedSocket:ResetValues()
			self.Socket.ConnectedSocket:TriggerOutput()
			self.Socket:TriggerOutput()
			timer.Destroy(self.UniID)
		end
	end)
end

function ENT:TransmitFromStation(Res,Am)
	self.Socket.ConnectedSocket.Status = PORT_INCOMING
	self.Socket.Status = PORT_SENDING

	self.Socket.TransmitAmount = Am
	
	self.Socket.ConnectedSocket.ROutputs[Res] = 1
	
	local Amount
	if self.Socket.Connected.Plasma and self.PlayerUsing:GetResearch("Socket_Plasma_Fiber") > 0 then
		Amount = math.Round(self.Socket.DefAmount * math.pow(2,10) * (1 + self.PlayerUsing:GetResearch("Socket_Plasma_Fiber") / 10))
	elseif self.Socket.Connected.Golden and self.PlayerUsing:GetResearch("Socket_Optic_Fiber") > 0 then
		Amount = math.Round(self.Socket.DefAmount * math.pow(2,5) * (1 + self.PlayerUsing:GetResearch("Socket_Optic_Fiber") / 10))
	else
		Amount = math.Round(self.Socket.DefAmount * (1 + self.PlayerUsing:GetResearch("Socket_Transmission_Speed") / 100))
	end
	
	self.Socket.Sending = Res
	self.Socket.ConnectedSocket.Receiving = Res
	
	local PL = math.Round(self.Socket.TransmitAmount * (0.05 - 0.001 * self.PlayerUsing:GetResearch("Socket_Packet_Loss")))
	if Amount < self.Socket.TransmitAmount then
		PL = math.Round(PL / (self.Socket.TransmitAmount / Amount))
	end
	
	self.Socket.ConnectedSocket.Amount = Amount - PL
	self.Socket.Amount = Amount
	
	self.Socket.ConnectedSocket:UpdateLinks()
	
	self.Socket:TriggerOutput()
	self.Socket.ConnectedSocket:TriggerOutput()
	
	if not self.UniID then self.UniID = "TransmitProgress #"..self:EntIndex() end
	timer.Create(self.UniID,0.5,0,function()
		if not self:CheckLink() then 			// Fuck
			self.Socket.Sending = ""
			self.Socket.TransmitAmount = 0
			self.Socket.Status = PORT_UNPLUGGED
			self.Socket:TriggerOutput()
			net.Start("Terminal_MiningTransmitProgress")
				net.WriteEntity(self)
				net.WriteFloat(-1)
			net.Send(self.PlayerUsing)
			timer.Destroy(self.UniID)
			self:Check()
			return
		end
		
		net.Start("Terminal_MiningTransmitProgress")
			net.WriteEntity(self)
			net.WriteFloat(1 - self.Socket.TransmitAmount / Am)
			net.WriteBit(false)
		net.Send(self.PlayerUsing)
		
		if self.Socket.TransmitAmount == 0 then // Job done!
			self.Socket.Sending = ""
			self.Socket.ConnectedSocket.Receiving = ""
			self.Socket.Status = PORT_STANDBY
			self.Socket.ConnectedSocket.Status = PORT_STANDBY
			
			self.Socket.ConnectedSocket:ResetValues()
			self.Socket.ConnectedSocket:TriggerOutput()
			self.Socket:TriggerOutput()
			timer.Destroy(self.UniID)
		end
	end)
end

net.Receive("Terminal_RefreshTable",function(len,ply)
	local Ent = net.ReadEntity()
	Ent:Check(true)
end)

net.Receive("Terminal_MiningStorageTable",function(len,ply)
	local Ent = net.ReadEntity()
	if not Ent.PlayerUsing then return end
	net.Start("Terminal_MiningSendStorage")
		net.WriteEntity(Ent)
		net.WriteTable(Ent.PlayerUsing.Storage)
		local CL = Ent:CheckLink()
		net.WriteBit(CL)
		if CL then
			local Sto = {}
			for I,P in pairs(Ent.Socket.ConnectedSocket:UpdateLinks()) do
				if P.Storage and next(P.Storage) then
					for R,S in pairs(P.Storage) do
						if Sto[R] then
							Sto[R][1] = Sto[R][1] + S
							Sto[R][2] = Sto[R][1] + P.StorageMax[R]
						else
							Sto[R] = {}
							Sto[R][1] = S
							Sto[R][2] = P.StorageMax[R]
						end
					end
				end
			end
			
			net.WriteTable(Sto)
		end
	net.Send(ply)
end)

net.Receive("Terminal_MiningTransmit",function(len,ply)
	local Ent = net.ReadEntity()
	if not IsValid(Ent.Socket.ConnectedSocket) then return end
	local FromShip = net.ReadBit() == 1
	local Res = net.ReadTable()
	
	if Ent.Socket.ConnectedSocket:GetNWEntity("Owner") ~= Ent.PlayerUsing and (table.HasValue(MARKETABLE,Res[1]) or table.HasKey(REFINE_MATERIALS,Res[1])) then
		ShoutIt("You can't do that!",Ent.PlayerUsing)
		ShoutIt("Someone tried to steal your valuables!",Ent.Socket.ConnectedSocket:GetNWEntity("Owner"))
		return
	end
	
	if Ent.Socket:GetNWEntity("Owner") ~= Ent or not Ent.Socket.Terminal or Ent.Socket.Terminal ~= Ent then 
		Ent.Socket:SetNWOwner(Ent)
		Ent.Socket.Terminal = Ent
	end
	
	if FromShip then
		Ent:TransmitFromShip(Res[1],Res[2])
	else
		if Ent.PlayerUsing.Storage[Res[1]] and Ent.PlayerUsing.Storage[Res[1]] > 0 then
			Ent:TransmitFromStation(Res[1],Res[2])
		else
			ShoutIt("Transmission failed!",Ent.PlayerUsing)
			net.Start("Terminal_MiningTransmitProgress")
				net.WriteEntity(Ent)
				net.WriteFloat(-1)
			net.Send(Ent.PlayerUsing)
		end
	end
end)