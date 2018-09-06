TOOL.Mode 		= "sa_ls_dispenser"
TOOL.Tab 		= "SA"
TOOL.Category 	= "LS"
TOOL.Name		= "Suit Dispenser"
TOOL.Command	= nil
TOOL.ConfigName	= ""
TOOL.ClientConVar["Frozen"] = 0

if CLIENT then
	language.Add( "tool.sa_ls_dispenser.name", "Dispenser Tool" )
	language.Add( "tool.sa_ls_dispenser.desc", "Left-click to spawn Dispensers." )
	language.Add( "tool.sa_ls_dispenser.0", "Left Click: Spawn a Dispenser" )
	language.Add( "Undone_Suit Dispenser", "Undone Suit Dispenser")
end

cleanup.Register("sa_dispenser_suit")

function TOOL:RightClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	
	if not self:GetSWEP():CheckLimit("sa_dispenser_suit") then return false end 
	
	Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = "sa_dispenser_suit",["Pos"] = trace.HitPos,["Angle"] = trace.HitNormal:Angle(),["frozen"] = self:GetClientNumber("Frozen") == 1},{})
	
	undo.Create("Suit Dispenser")
		undo.AddEntity(Ent)
		undo.SetPlayer(self:GetOwner())
	undo.Finish()
	
	self:GetOwner():AddCleanup("sa_dispenser_suit",Ent)
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
	local Mdl = "models/props_combine/suit_charger001.mdl"
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
	self.GhostEntity:SetPos(Trace.HitPos)
	self.GhostEntity:SetAngles(Trace.HitNormal:Angle())
end

function TOOL.BuildCPanel(Panel)
	local Ch = vgui.Create("DCheckBoxLabel")
	Ch:SetConVar("sa_ls_dispenser_Frozen")
	Ch:SetText("Frozen?")
	Ch:SizeToContents()
	Ch:Dock(TOP)
	Panel:AddItem(Ch)
end