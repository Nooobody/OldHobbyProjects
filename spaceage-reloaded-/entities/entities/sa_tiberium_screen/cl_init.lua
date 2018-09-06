include("shared.lua")
include("helperfunctions/cl_tstates.lua")

TERMINAL_REFINERY = 20

function ENT:AddCheckStates()
	if self.State == TERMINAL_REFINERY then		// Receive stuff from Ship
		self:AddTabs()
		self:SendTiberium()
	end
end

function ENT:MoreInit()
	self.AddTabs = self.T_AddTabs
	self.Transmit1 = false
	self.Transmit2 = false
	self.StartState = TERMINAL_REFINERY
end

net.Receive("Terminal_StartTib",function(len)
	local Ent = net.ReadEntity()
	Ent.Connected = net.ReadBit() == 1
	if Ent.Connected then
		Ent.Transmit1 = false
		Ent.Transmit2 = false
		Ent.FoundStorage = net.ReadTable()
		Ent:ChangeState(TERMINAL_REFINERY)
	end
end)

net.Receive("Terminal_TibTransmitProgress",function(len)
	local Ent = net.ReadEntity()
	Ent.FoundStorage = net.ReadTable()
	Ent:ChangeState(TERMINAL_REFINERY)
end)