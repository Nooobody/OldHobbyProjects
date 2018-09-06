TOOL.Mode 		= "sa_rd_plug"
TOOL.Tab 		= "SA"
TOOL.Category 	= "RD"
TOOL.Name		= "Plug"
TOOL.Command	= nil
TOOL.ConfigName	= ""
TOOL.ClientConVar["Frozen"] = 0

if CLIENT then
	language.Add( "tool.sa_rd_plug.name", "Plug Tool" )
	language.Add( "tool.sa_rd_plug.desc", "Left-click to spawn Plugs." )
	language.Add( "tool.sa_rd_plug.0", "Left Click: Spawn 2 Plugs linked" )
	language.Add( "Undone_Plugs", "Undone Plugs")
	language.Add("SBoxLimit_sa_plug","You've hit the limit for plugs!")
end

cleanup.Register("sa_plug")

function TOOL:LeftClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	
	if not self:GetSWEP():CheckLimit("sa_plug") then return false end 
	
	local Ent1 = MakePlugs(self:GetOwner(),trace.HitPos,trace.HitNormal:Angle(),self:GetClientNumber("Frozen") == 1)
	local Ent2 = MakePlugs(self:GetOwner(),trace.HitPos + trace.HitNormal:Angle():Forward() * 12,trace.HitNormal:Angle(),self:GetClientNumber("Frozen") == 1)
	
	local Rope
	if self:GetOwner():GetResearch("Socket_Plasma_Fiber") > 0 then
		Ent1:SetMaterial("models/props_lab/xencrystal_sheet")
		Ent2:SetMaterial("models/props_lab/xencrystal_sheet")
		Rope = constraint.Rope(Ent1,Ent2,0,0,Vector(12,.115219,-0.085065,-0.158239),Vector(12.115219,-0.085065,-0.158239),500,0,0,10,"cable/hydra",false)
		Ent1.Plasma = true
		Ent2.Plasma = true
	elseif self:GetOwner():GetResearch("Socket_Optic_Fiber") > 0 then
		Ent1:SetMaterial("models/debug/debugwhite")
		Ent2:SetMaterial("models/debug/debugwhite")
		Rope = constraint.Rope(Ent1,Ent2,0,0,Vector(12.115219,-0.085065,-0.158239),Vector(12.115219,-0.085065,-0.158239),500,0,0,6,"cable/physbeam",false)
		Ent1.Golden = true
		Ent2.Golden = true
	else
		Rope = constraint.Rope(Ent1,Ent2,0,0,Vector(12.115219,-0.085065,-0.158239),Vector(12.115219,-0.085065,-0.158239),500,0,0,1,"cable/cable",false)
	end
	
	Ent1:DeleteOnRemove(Ent2)
	Ent2:DeleteOnRemove(Ent1)
	
	Ent1:DeleteOnRemove(Rope)
	Ent2:DeleteOnRemove(Rope)
	
	Ent1.LinkPlug = Ent2
	Ent2.LinkPlug = Ent1
	
	undo.Create("Plugs")
		undo.AddEntity(Ent1)
		undo.AddEntity(Ent2)
		undo.SetPlayer(self:GetOwner())
	undo.Finish()
	
	self:GetOwner():AddCount("sa_plug",Ent1)
	self:GetOwner():AddCount("sa_plug",Ent2)
	
	self:GetOwner():AddCleanup("sa_plug",Ent1)
	self:GetOwner():AddCleanup("sa_plug",Ent2)
	
	return true
end

if SERVER then
	
	function MakePlugs(Ply,Pos,Ang,Frozen)
		local Plug = ents.Create("sa_plug")
		Plug:SetPos(Pos)
		Plug:SetAngles(Ang)
		Plug:Spawn()
		Plug:GetPhysicsObject():EnableMotion(not Frozen)
		Plug:SetNWOwner(Ply)
		return Plug
	end
	
end

function TOOL:Think()
	local Mdl = "models/props_lab/tpplug.mdl"
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
	self.GhostEntity:SetPos(Trace.HitPos)
	self.GhostEntity:SetAngles(Ang)
end

function TOOL.BuildCPanel(Panel)
	local Ch = vgui.Create("DCheckBoxLabel")
	Ch:SetConVar("sa_rd_plug_Frozen")
	Ch:SetText("Frozen?")
	Ch:SizeToContents()
	Ch:Dock(TOP)
	Panel:AddItem(Ch)
end