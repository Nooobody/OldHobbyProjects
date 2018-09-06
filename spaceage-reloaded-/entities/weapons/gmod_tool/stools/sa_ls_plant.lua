TOOL.Mode 		= "sa_ls_plant"
TOOL.Tab 		= "SA"
TOOL.Category 	= "LS"
TOOL.Name		= "Plant"
TOOL.Command	= nil
TOOL.ConfigName	= ""
TOOL.ClientConVar["Frozen"] = 0

if CLIENT then
	language.Add( "tool.sa_ls_plant.name", "Plant Tool" )
	language.Add( "tool.sa_ls_plant.desc", "Left-click to spawn Plants." )
	language.Add( "tool.sa_ls_plant.0", "Left Click: Spawn a Plant    Right Click: Spawn without Weld" )
	language.Add("Undone_Plant","Undone Plant")
end

cleanup.Register("sa_plant")

function TOOL:RightClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end

	if not self:GetSWEP():CheckLimit("sa_plant") then return false end 
	local Ang = trace.HitNormal:Angle()
	Ang.p = Ang.p + 90
	Ent = MakePlants(self:GetOwner(),trace.HitPos,Ang,self:GetClientNumber("Frozen") == 1)

	undo.Create("Plant")
		undo.AddEntity(Ent)
		undo.SetPlayer(self:GetOwner())
	undo.Finish()
	
	self:GetOwner():AddCount("sa_plant",Ent)
	self:GetOwner():AddCleanup("sa_plant",Ent)
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

if SERVER then
	
	function MakePlants(Ply,Pos,Ang,frozen)
		local Ent = ents.Create("sa_plant")
		Ent:SetPos(Pos)
		Ent:SetAngles(Ang)
		Ent:Spawn()
		Ent:GetPhysicsObject():EnableMotion(not frozen)
		Ent:SetNWOwner(Ply)
		return Ent
	end
	
	duplicator.RegisterEntityClass( "sa_plant", MakePlants,"Pos","Ang","frozen")
	CreateConVar( "sbox_maxsa_plant", 2 )
	
end


function TOOL:Think()
	local Mdl = "models/ce_ls3additional/plants/plantfull.mdl"
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
	
	local Ang = Trace.HitNormal:Angle()
	Ang.p = Ang.p + 90
	self.GhostEntity:SetNoDraw(false)
	self.GhostEntity:SetPos(Trace.HitPos)
	self.GhostEntity:SetAngles(Ang)
end

function TOOL.BuildCPanel(Panel)
	local Ch = vgui.Create("DCheckBoxLabel")
	Ch:SetConVar("sa_ls_plant_Frozen")
	Ch:SetText("Frozen?")
	Ch:SizeToContents()
	Ch:Dock(TOP)
	Panel:AddItem(Ch)
end