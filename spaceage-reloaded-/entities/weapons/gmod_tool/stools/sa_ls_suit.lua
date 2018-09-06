TOOL.Mode 		= "sa_ls_suit"
TOOL.Tab 		= "SA"
TOOL.Category 	= "LS"
TOOL.Name		= "Suit Manipulator"
TOOL.Command	= nil
TOOL.ConfigName	= ""

TOOL.ClientConVar["Class"] = "sa_dispenser_heater"
TOOL.ClientConVar["Frozen"] = 0

if CLIENT then
	language.Add( "tool.sa_ls_suit.name", "Suit Tool" )
	language.Add( "tool.sa_ls_suit.desc", "Left-click to spawn Suit heaters/freezers." )
	language.Add( "tool.sa_ls_suit.0", "Left Click: Spawn a heater/freezer    Right Click: Spawn without Weld" )
	language.Add( "Undone_Suit Manipulator","Undone Suit Manipulator")
end

cleanup.Register("sa_dispenser_heater")
cleanup.Register("sa_dispenser_freezer")

function TOOL:RightClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	
	local Class = self:GetClientInfo("Class")
	if Class == "" then return end
	
	if not self:GetSWEP():CheckLimit(Class) then return false end 
	
	local Ang = trace.HitNormal:Angle()
	Ang.p = Ang.p + 90
	
	local Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = Class,["Pos"] = trace.HitPos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{})
	
	local Min,Max = Ent:WorldSpaceAABB()
	Ent:SetPos(trace.HitPos + Ang:Up() * (trace.HitPos.z - Min.z))
	
	undo.Create("Suit Manipulator")
		undo.AddEntity(Ent)
		undo.SetPlayer(self:GetOwner())
	undo.Finish()
	
	self:GetOwner():AddCleanup(Class,Ent)
	
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
	local Mdl = "models/mandrac/hybride/cap_railgun_base.mdl"

	if not IsValid(self.GhostEntity) then
		self:MakeGhostEntity(Mdl,Vector(0,0,0),Angle(0,0,0))
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
	Ch:SetConVar("sa_ls_suit_Frozen")
	Ch:SetText("Frozen?")
	Ch:SizeToContents()
	Ch:Dock(TOP)
	Panel:AddItem(Ch)
	local VG = vgui.Create("DTree")
	VG:SetSize(200,500)
	for I,P in pairs(list.Get("sa_suit")) do
		local Btn = VG:AddNode(P)
		Btn.Icon:SetImage("icon16/page.png")
		Btn.DoClick = function(btn)
			RunConsoleCommand("sa_ls_suit_Class","sa_dispenser_"..string.lower(P))
		end
	end
	Panel:AddItem(VG)
end