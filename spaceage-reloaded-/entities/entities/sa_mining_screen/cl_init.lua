include("shared.lua")
include("helperfunctions/cl_mstates.lua")

TERMINAL_STATION = 5
TERMINAL_SHIP = 10
TERMINAL_TRANSMIT = 12

function ENT:CheckCam()
	return self.State == TERMINAL_SHIP or self.State == TERMINAL_STATION
end

function ENT:AddCheckStates()
	if self.State == TERMINAL_SHIP then		// Receive stuff from Ship
		self:AddTabs()
		self:Ship()
	elseif self.State == TERMINAL_STATION then	// Send stuff to Ship from Station
		self:AddTabs()
		self:Station()
	elseif self.State == TERMINAL_TRANSMIT then
		self:Transmitting(self.Transmit)
	end
end

function ENT:MoreInit()
	self.AddTabs = self.M_AddTabs
	
	self.StartState = TERMINAL_SHIP
end

net.Receive("Terminal_StartData",function(len)
	local Ent = net.ReadEntity()
	local Connected = net.ReadBit() == 1
	if Connected then
		Ent.FoundStorage = net.ReadTable()
		local B = net.ReadBit() == 1
		if B and Ent.OldState == TERMINAL_SHIP then
			if not timer.Exists("Terminal_DataCheck #"..Ent:EntIndex()) then
				timer.Create("Terminal_DataCheck #"..Ent:EntIndex(),1,1,function()
					net.Start("Terminal_RefreshTable")
						net.WriteEntity(Ent)
					net.SendToServer()
					timer.Destroy("Terminal_DataCheck #"..Ent:EntIndex())
				end)
			end
		end
	end
	
	if Ent.IsConnected ~= Connected then
		Ent.IsConnected = Connected
		if Ent.OldState == TERMINAL_SHIP then
			Ent:ChangeState(TERMINAL_SHIP)
		elseif Ent.OldState == TERMINAL_STATION then
			Ent:ChangeState(TERMINAL_STATION)
		end
	end
end)

net.Receive("Terminal_MiningTransmitProgress",function(len)
	local Ent = net.ReadEntity()
	local F = net.ReadFloat()
	local IsShip = net.ReadBit() == 1
	local Ret
	if IsShip then Ret = TERMINAL_SHIP
	else Ret = TERMINAL_STATION end
	if F == -1 then // FUUUUU! We lost the link!
		Ent:ErrorPanel("Transmitting has stopped!","Link has been broken!",Ret)
		Ent.IsConnected = false
		net.Start("Terminal_MiningStorageTable")
			net.WriteEntity(Ent)
		net.SendToServer()
		return
	end
	Ent.TransmitDone = F
	if F == 1 then // Job done!
		Ent:OkayPanel("Transmit has finished",Ret)
		net.Start("Terminal_MiningStorageTable")
			net.WriteEntity(Ent)
		net.SendToServer()
		net.Start("Terminal_RefreshTable")
			net.WriteEntity(Ent)
		net.SendToServer()
	end
end)

net.Receive("Terminal_MiningSendStorage",function(len)
	local Ent = net.ReadEntity()
	local Upd = false
	if not Ent.PlayerStorage then Upd = true end
	Ent.PlayerStorage = net.ReadTable()
	if not next(Ent.PlayerStorage) then Ent.PlayerStorage = false end
	
	if Upd then Ent:ChangeState(TERMINAL_STATION) end
	local B = net.ReadBit() == 1
	if B then 
		Ent.FoundStorage = net.ReadTable() 
		if Ent.OldState == TERMINAL_STATION and not timer.Exists("Terminal_StorageCheck #"..Ent:EntIndex()) then
			timer.Create("Terminal_StorageCheck #"..Ent:EntIndex(),1,1,function()
				net.Start("Terminal_MiningStorageTable")
					net.WriteEntity(Ent)
				net.SendToServer()
				timer.Destroy("Terminal_StorageCheck #"..Ent:EntIndex())
			end)
		end
	end
	if Ent.IsConnected ~= B then
		Ent.IsConnected = B
		if Ent.OldState == TERMINAL_SHIP then
			Ent:ChangeState(TERMINAL_SHIP)
		elseif Ent.OldState == TERMINAL_STATION then
			Ent:ChangeState(TERMINAL_STATION)
		end
	end
end)