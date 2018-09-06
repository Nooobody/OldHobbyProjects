TOOL.Mode 		= "sa_ls_inhaler"
TOOL.Tab 		= "SA"
TOOL.Category 	= "LS"
TOOL.Name		= "Gas Compressor"
TOOL.Command	= nil
TOOL.ConfigName	= ""

TOOL.ClientConVar["Class"] = "sa_inhaler_oxygen"
TOOL.ClientConVar["Size"] = 1
TOOL.ClientConVar["Frozen"] = 0
TOOL.ClientConVar["Multiplier"] = 2

if CLIENT then
	language.Add( "tool.sa_ls_inhaler.name", "Compressor Tool" )
	language.Add( "tool.sa_ls_inhaler.desc", "Left-click to spawn Gas Compressors." )
	language.Add( "tool.sa_ls_inhaler.0", "Left Click: Spawn a Compressor    Right Click: Spawn without Weld" )
	language.Add( "Undone_Atmosphere Inhaler", "Undone Gas Compressor")
end

cleanup.Register("sa_inhaler_oxygen")
cleanup.Register("sa_inhaler_methane")
cleanup.Register("sa_inhaler_hydrogen")
cleanup.Register("sa_inhaler_nitrogen")
cleanup.Register("sa_inhaler_sulfur")
cleanup.Register("sa_inhaler_carbon_dioxide")

function TOOL:RightClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	
	local Class = self:GetClientInfo("Class")
	if Class == "" then return end
	
	local Mdl = list.Get(Class)[self:GetClientNumber("Size")]
	if Mdl == "" then return end
	
	if not self:GetSWEP():CheckLimit(Class) then return false end 
	
	local Ang = trace.HitNormal:Angle()
	Ang.p = Ang.p + 90
	
	local Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = Class,["Model"] = Mdl,["Pos"] = trace.HitPos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{})
	
	Ent:TriggerInput("Multiplier",self:GetClientNumber("Multiplier"))
	
	undo.Create("Atmosphere Inhaler")
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
	local Mdl = list.Get(self:GetClientInfo("Class"))[self:GetClientNumber("Size")]
	if not Mdl or Mdl == "" then return end

	if not IsValid(self.GhostEntity) or not self.GhostEntity:GetModel() != Mdl then
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
	Ch:SetConVar("sa_ls_inhaler_Frozen")
	Ch:SetText("Frozen?")
	Ch:SizeToContents()
	Ch:Dock(TOP)
	local Slid = vgui.Create("DNumSlider")
	Slid:SetConVar("sa_rd_generator_Multiplier")
	Slid:SetValue(20)
	Slid:SetMin(1)
	Slid:SetMax(100)
	Slid:SetDecimals(0)
	Slid:Dock(TOP)
	Slid:SizeToContents()
	Panel:AddItem(Ch)
	Panel:AddItem(Slid)
	local VG = vgui.Create("DTree")
	VG:SetSize(200,500)
	local A = {"Small","Medium","Large"}
	for I,P in pairs(list.Get("sa_inhaler")) do
		local No = VG:AddNode(P)
		for i,p in pairs(list.Get("sa_inhaler_"..string.lower(P))) do
			local Btn = No:AddNode(A[i])
			Btn.Icon:SetImage("icon16/page.png")
			Btn.DoClick = function(btn)
				RunConsoleCommand("sa_ls_inhaler_Class","sa_inhaler_"..string.lower(P))
				RunConsoleCommand("sa_ls_inhaler_Size",i)
			end
		end
	end
	Panel:AddItem(VG)
end