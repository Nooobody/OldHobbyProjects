include("shared.lua")
include("helperfunctions/cl_tqstates.lua")

TERMINAL_LIQREFINERY = 25

function ENT:AddCheckStates()
	if self.State == TERMINAL_LIQREFINERY then
		self:AddTabs()
		self:HandleLoader()
	end
end

function ENT:MoreInit()
	self.StartState = TERMINAL_LIQREFINERY
	self.Tib_Ref = {0,0}
end

net.Receive("Terminal_StartLiqTib",function(len)
	local Ent = net.ReadEntity()
	Ent.Tib_Ref = {net.ReadInt(32),net.ReadInt(32)}
	Ent.Connected = net.ReadBit() == 1
	if Ent.Connected then
		Ent.FoundStorage = {net.ReadInt(32),net.ReadInt(32)}
		Ent:ChangeState(TERMINAL_LIQREFINERY)
	end
end)

net.Receive("Terminal_LiqTibTransmitProgress",function(len)
	local Ent = net.ReadEntity()
	Ent.Tib_Ref[2] = net.ReadInt(32)
	Ent.FoundStorage[1] = net.ReadInt(32)
	Ent:ChangeState(TERMINAL_LIQREFINERY)
end)