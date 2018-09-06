TOOL.Mode 		= "sa_rd_port"
TOOL.Tab 		= "SA"
TOOL.Category 	= "RD"
TOOL.Name		= "Port"
TOOL.Command	= nil
TOOL.ConfigName	= ""
TOOL.ClientConVar["Frozen"] = 0

if CLIENT then
	language.Add( "tool.sa_rd_port.name", "Port Tool" )
	language.Add( "tool.sa_rd_port.desc", "Left-click to spawn Ports." )
	language.Add( "tool.sa_rd_port.0", "Left Click: Spawn a Port    Right Click: Spawn without Weld" )
	language.Add( "Undone_Port", "Undone Port")
	language.Add("SBoxLimit_sa_port","You've hit the limit for ports!")
end

cleanup.Register("sa_port")

function TOOL:RightClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	
	if not self:GetSWEP():CheckLimit("sa_port") then return false end 
	
	local Ang = trace.HitNormal:Angle()
	Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = "sa_port",["Model"] = "models/props_lab/tpplugholder_single.mdl",["Pos"] = trace.HitPos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{})

	undo.Create("Port")
		undo.AddEntity(Ent)
		undo.SetPlayer(self:GetOwner())
	undo.Finish()
	
	self:GetOwner():AddCleanup("sa_port",Ent)
	return true,Ent
end

function TOOL:LeftClick(trace)
	local B,Ent,S = self:RightClick(trace,true)
	if CLIENT then return true end
	
	if S or not B then return true end
	if not trace.Entity:IsValid() or trace.Entity:IsWorld() then return true end
	
	local Weld = constraint.Weld(Ent,trace.Entity,0,trace.PhysicsBone,0,0,true)
	trace.Entity:DeleteOnRemove(Weld)
	Ent:DeleteOnRemove(Weld)
	
	return true
end

function TOOL:Think()
	local Mdl = "models/props_lab/tpplugholder_single.mdl"
	if not IsValid(self.GhostEntity) or self.GhostEntity:GetModel() != Mdl then
		self:MakeGhostEntity(Mdl,Vector(),Angle())
	end
	
	if not IsValid(self.GhostEntity) then return end
	
	local tr = util.GetPlayerTrace(self:GetOwner())
	local Trace = util.TraceLine(tr)
	
	if not Trace.Hit then return end
	
	if Trace.Entity:IsPlayer() then
		self.GhostEntity:SetNoDraw(true)
		return
	end
	
	self.GhostEntity:SetNoDraw(false)
	local Ang = Trace.HitNormal:Angle()
	self.GhostEntity:SetPos(Trace.HitPos)
	self.GhostEntity:SetAngles(Ang)
end

function TOOL.BuildCPanel(Panel)
	local Ch = vgui.Create("DCheckBoxLabel")
	Ch:SetConVar("sa_rd_port_Frozen")
	Ch:SetText("Frozen?")
	Ch:SizeToContents()
	Ch:Dock(TOP)
	Panel:AddItem(Ch)
end