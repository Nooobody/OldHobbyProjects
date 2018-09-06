TOOL.Mode 		= "sa_rd_node"
TOOL.Tab 		= "SA"
TOOL.Category 	= "RD"
TOOL.Name		= "Link Node"
TOOL.Command	= nil
TOOL.ConfigName	= ""
TOOL.ClientConVar["Frozen"] = 0
TOOL.ClientConVar["Size"] = 1

if CLIENT then
	language.Add( "tool.sa_rd_node.name", "Node Tool" )
	language.Add( "tool.sa_rd_node.desc", "Left-click to spawn Nodes." )
	language.Add( "tool.sa_rd_node.0", "Left Click: Spawn a Node    Right Click: Spawn without Weld" )
	language.Add( "Undone_Link Node", "Undone Link Node")
end

cleanup.Register("sa_link_node")

function TOOL:RightClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	
	if not self:GetSWEP():CheckLimit("sa_link_node") then return false end 
	
	local Size = self:GetClientNumber("Size")
	local Mdl = list.Get("sa_link_node")[Size]
	
	local Ang = trace.HitNormal:Angle()
	Ang.p = Ang.p + 90
	
	Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = "sa_link_node",["Model"] = Mdl,["Pos"] = trace.HitPos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{},Size)

	undo.Create("Link Node")
		undo.AddEntity(Ent)
		undo.SetPlayer(self:GetOwner())
	undo.Finish()
	
	self:GetOwner():AddCleanup("sa_link_node",Ent)
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
	local Mdl = list.Get("sa_link_node")[self:GetClientNumber("Size")]
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
	Ang.p = Ang.p + 90
	self.GhostEntity:SetPos(Trace.HitPos)
	self.GhostEntity:SetAngles(Ang)
end

function TOOL.BuildCPanel(Panel)
	local Ch = vgui.Create("DCheckBoxLabel")
	Ch:SetConVar("sa_rd_node_Frozen")
	Ch:SetText("Frozen?")
	Ch:SizeToContents()
	Ch:Dock(TOP)
	Panel:AddItem(Ch)
	local VG = vgui.Create("DTree")
	VG:SetSize(200,500)
	local Names = {
		"Small - Radius: 512",
		"Medium - Radius: 768",
		"Large - Radius: 1024",
		"Huge - Radius: 1536"
	}
	for I,P in pairs(list.Get("sa_link_node")) do
		local Btn = VG:AddNode(Names[I] or P)
		Btn.Icon:SetImage("icon16/page.png")
		Btn.DoClick = function(btn)
			RunConsoleCommand("sa_rd_node_Size",I)
		end
	end
	Panel:AddItem(VG)
end