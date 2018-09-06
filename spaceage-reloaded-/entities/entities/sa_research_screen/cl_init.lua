include("shared.lua")
include("helperfunctions/cl_rstates.lua")

TERMINAL_RESEARCH = 20
TERMINAL_REFINE = 22
TERMINAL_MARKET = 24

function ENT:CheckCam()
	return self.State == TERMINAL_RESEARCH
end

function ENT:AddCheckStates()
	if self.State == TERMINAL_RESEARCH then
		self:AddTabs()
		self:Research()
	elseif self.State == TERMINAL_REFINE then
		self:AddTabs()
		self:Refine()
	elseif self.State == TERMINAL_MARKET then
		self:AddTabs()
		self:Market()
	end
end

function ENT:MoreInit()
	self.AddTabs = self.R_AddTabs
	
	self.StartState = TERMINAL_REFINE
end

net.Receive("Terminal_UpgradeSuccesful",function(len)
	local Ent = net.ReadEntity()
	local S = net.ReadString()
	local I = net.ReadUInt(12)
	Ent.PlyResearch[S] = I
	if Ent.OldState == TERMINAL_RESEARCH then
		Ent:ChangeState(TERMINAL_RESEARCH)
	end
end)

net.Receive("Terminal_StartResearch",function(len)
	local Ent = net.ReadEntity()
	Ent.PlyResearch = net.ReadTable()
	if Ent.OldState == TERMINAL_RESEARCH then
		Ent:ChangeState(TERMINAL_RESEARCH)
	end
end)

net.Receive("Terminal_ResearchSendStorage",function(len)
	local Ent = net.ReadEntity()
	local Upd = false
	if not Ent.PlayerStorage then Upd = true end
	Ent.PlayerStorage = net.ReadTable()
	if Ent.OldState == TERMINAL_REFINE then
		Ent:ChangeState(TERMINAL_REFINE)
	elseif Ent.OldState == TERMINAL_MARKET then
		Ent:ChangeState(TERMINAL_MARKET)
	end
end)