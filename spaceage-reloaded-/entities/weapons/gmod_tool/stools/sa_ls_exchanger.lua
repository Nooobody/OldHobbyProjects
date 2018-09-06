TOOL.Mode 		= "sa_ls_exchanger"
TOOL.Tab 		= "SA"
TOOL.Category 	= "LS"
TOOL.Name		= "Exchanger"
TOOL.Command	= nil
TOOL.ConfigName	= ""

TOOL.ClientConVar["Class"] = "sa_exchanger_oxygen"
TOOL.ClientConVar["Frozen"] = 0

if CLIENT then
	language.Add( "tool.sa_ls_exchanger.name", "Exchanger Tool" )
	language.Add( "tool.sa_ls_exchanger.desc", "Left-click to spawn Exchangers." )
	language.Add( "tool.sa_ls_exchanger.0", "Left Click: Spawn an Exchanger    Right Click: Spawn without Weld" )
	language.Add( "Undone_Atmosphere Exchanger", "Undone Atmosphere Exchanger")
end

cleanup.Register("sa_exchanger_oxygen")
cleanup.Register("sa_exchanger_steam")
cleanup.Register("sa_exchanger_ice")

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

	undo.Create("Atmosphere Exchanger")
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
	local Mdl = "models/props_combine/combine_light001b.mdl"

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
	Ch:SetConVar("sa_ls_exchanger_Frozen")
	Ch:SetText("Frozen?")
	Ch:SizeToContents()
	Ch:Dock(TOP)
	Panel:AddItem(Ch)
	local VG = vgui.Create("DTree")
	VG:SetSize(200,500)
	local Names = {
		Ice = "Freezer",
		Oxygen = "Air",
		Steam = "Heater"
	}
	for I,P in pairs(list.Get("sa_exchanger")) do
		local Btn = VG:AddNode(Names[P] or P)
		Btn.Icon:SetImage("icon16/page.png")
		Btn.DoClick = function(btn)
			RunConsoleCommand("sa_ls_exchanger_Class","sa_exchanger_"..string.lower(P))
		end
	end
	Panel:AddItem(VG)
end