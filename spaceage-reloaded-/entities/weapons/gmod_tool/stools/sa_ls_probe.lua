TOOL.Mode 		= "sa_ls_probe"
TOOL.Tab 		= "SA"
TOOL.Category 	= "LS"
TOOL.Name		= "Atmosphere Probe"
TOOL.Command	= nil
TOOL.ConfigName	= ""
TOOL.ClientConVar["Frozen"] = 0

if CLIENT then
	language.Add( "tool.sa_ls_probe.name", "Probe Tool" )
	language.Add( "tool.sa_ls_probe.desc", "Left-click to spawn Probes." )
	language.Add( "tool.sa_ls_probe.0", "Left Click: Spawn a Probe" )
	language.Add("Undone_Atmosphere Probe","Undone Atmosphere Probe")
end

cleanup.Register("sa_atmosphere_probe")

function TOOL:RightClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	
	if not self:GetSWEP():CheckLimit("sa_atmosphere_probe") then return false end 
	
	local Ang = trace.HitNormal:Angle()
	Ang.p = Ang.p + 90
	
	Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = "sa_atmosphere_probe",["Pos"] = trace.HitPos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{})
	
	
	undo.Create("Atmosphere Probe")
		undo.AddEntity(Ent)
		undo.SetPlayer(self:GetOwner())
	undo.Finish()
	
	self:GetOwner():AddCleanup("sa_atmosphere_probe",Ent)
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
	local Mdl = "models/slyfo/moisture_condenser.mdl"

	if not IsValid(self.GhostEntity) then
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
	Ang.p = Ang.p + 90
	self.GhostEntity:SetPos(Trace.HitPos)
	local Min,Max = self.GhostEntity:WorldSpaceAABB()
	self.GhostEntity:SetAngles(Ang)
	self.GhostEntity:SetPos(Trace.HitPos + Ang:Up() * (Trace.HitPos.z - Min.z))
end

function TOOL.BuildCPanel(Panel)
	local Ch = vgui.Create("DCheckBoxLabel")
	Ch:SetConVar("sa_rd_node_Frozen")
	Ch:SetText("Frozen?")
	Ch:SizeToContents()
	Ch:Dock(TOP)
	Panel:AddItem(Ch)
end