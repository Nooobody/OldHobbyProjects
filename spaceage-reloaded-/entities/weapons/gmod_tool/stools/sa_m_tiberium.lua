TOOL.Mode 		= "sa_m_tiberium"
TOOL.Tab 		= "SA"
TOOL.Category 	= "M"
TOOL.Name		= "Tiberium Mining"
TOOL.Command	= nil
TOOL.ConfigName	= ""

TOOL.ClientConVar["Class"] = "sa_mining_drill"
TOOL.ClientConVar["Size"] = 1
TOOL.ClientConVar["Frozen"] = 0

if CLIENT then
	language.Add( "tool.sa_m_tiberium.name", "Tiberium Mining" )
	language.Add( "tool.sa_m_tiberium.desc", "Spawn a device used to mine Tiberium" )
	language.Add( "tool.sa_m_tiberium.0", "Left Click: Spawn a device    Right Click: Spawn without Weld" )
	language.Add( "Undone_Tiberium Storage", "Undone a Tiberium Storage")
	language.Add( "Undone_Liquid Tiberium Storage","Undone a Liquid Tiberium Storage")
	language.Add( "Undone_Tiberium Drill","Undone a Tiberium Drill")
	language.Add( "Undone_Tiberium Storage Holder","Undone a Tiberium Storage Holder")
end

cleanup.Register("sa_mining_rawtib_storage")
cleanup.Register("sa_mining_drill")
cleanup.Register("sa_tiberium_storage_holder")
cleanup.Register("sa_mining_liquidtib_storage")

function TOOL:RightClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
		
	local Class = self:GetClientInfo("Class")
	
	if not self:GetSWEP():CheckLimit(Class) then return false end
	
	local Size = tonumber(self:GetClientNumber("Size"))
	local Ent
	if Class == "sa_tiberium_storage_holder" then
		local Ang = trace.HitNormal:Angle()
		Ang.p = Ang.p + 90
		
		Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = Class,["Pos"] = trace.HitPos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{})
		
		undo.Create("Tiberium Storage Holder")
			undo.AddEntity(Ent)
			undo.SetPlayer(self:GetOwner())
		undo.Finish()
	elseif Class == "sa_mining_drill" then
		if Size > tonumber(self:GetOwner():GetResearch("Drill_Tech_Research")) then 
			self:GetOwner():SendLua("notification.AddLegacy('You do not have sufficient research level for that yet!',NOTIFY_ERROR,5)")
			return false 
		end
		
		local Mdl = list.Get("sa_mining_drill")[Size]
		if Mdl == "" then return end
	
		local Ang = trace.HitNormal:Angle()
		Ang.p = Ang.p + 90
		
		local Pos = trace.HitPos
		Pos = Pos + Ang:Up() * 20
		
		local Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = "sa_mining_drill",["Model"] = Mdl,["Pos"] = Pos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{},Size)
			
		undo.Create("Tiberium Drill")
			undo.AddEntity(Ent)
			undo.SetPlayer(self:GetOwner())
		undo.Finish()
	elseif Class == "sa_mining_rawtib_storage" then
		if Size > tonumber(self:GetOwner():GetResearch("Tiberium_Storage_Tech_Research")) then 
			self:GetOwner():SendLua("notification.AddLegacy('You do not have sufficient research level for that yet!',NOTIFY_ERROR,5)")
			return false 
		end
		
		local Ang = trace.HitNormal:Angle()
		Ang.p = Ang.p + 90
		
		local Pos = trace.HitPos
		Pos = Pos + Ang:Up() * 20

		Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = "sa_mining_rawtib_storage",["Pos"] = Pos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{},Size)
		
		undo.Create("Tiberium Storage")
			undo.AddEntity(Ent)
			undo.SetPlayer(self:GetOwner())
		undo.Finish()
	elseif Class == "sa_mining_liquidtib_storage" then
		local Ang = trace.HitNormal:Angle()
		Ang.p = Ang.p + 90
		
		local Pos = trace.HitPos
		Pos = Pos + Ang:Up() * 40

		Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = "sa_mining_liquidtib_storage",["Pos"] = Pos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{})
		
		undo.Create("Liquid Tiberium Storage")
			undo.AddEntity(Ent)
			undo.SetPlayer(self:GetOwner())
		undo.Finish()
	end
		
	if not IsValid(Ent) then return false end
		
	self:GetOwner():AddCleanup(Class,Ent)
	return true,Ent
end

function TOOL:LeftClick(trace)
	local B,Ent,S = self:RightClick(trace,true)
	if CLIENT then return true end
	
	if S or not B then return true end
	if not trace.Entity:IsValid() or trace.Entity:IsWorld() then return true end
	if Ent:GetClass() == "sa_mining_rawtib_storage" and trace.Entity:GetClass() == "sa_tiberium_storage_holder" then return true end
	
	local Weld = constraint.Weld(Ent,trace.Entity,0,trace.PhysicsBone,0,0,true)
	trace.Entity:DeleteOnRemove(Weld)
	Ent:DeleteOnRemove(Weld)
	
	return true
end

function TOOL:Think()
	local Mdl = ""
	local Class = self:GetClientInfo("Class")
	if Class == "sa_tiberium_storage_holder" then Mdl = "models/slyfo/sat_rtankstand.mdl"
	elseif Class == "sa_mining_rawtib_storage" then Mdl = "models/slyfo/sat_resourcetank.mdl"
	elseif Class == "sa_mining_liquidtib_storage" then Mdl = "models/slyfo/electrolysis_gen.mdl"
	else
		Mdl = list.Get("sa_mining_drill")[self:GetClientNumber("Size")]
		if Mdl == "" then return end
	end
	
	if not IsValid(self.GhostEntity) or self.GhostEntity:GetModel() != Mdl then
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
	Ch:SetConVar("sa_m_tiberium_Frozen")
	Ch:SetText("Frozen?")
	Ch:SizeToContents()
	Ch:Dock(TOP)
	Panel:AddItem(Ch)
	local VG = vgui.Create("DTree")
	VG:SetSize(200,500)
	local A = { ["Liquid Tiberium Storage"] = {"sa_mining_liquidtib_storage"},
				["Raw Tiberium Storage"] = {"sa_mining_rawtib_storage",{"Small","Medium","Large","Huge"}},
				["Tiberium Drill"] = {"sa_mining_drill",{"I","II","III"}},
				["Tiberium Storage Holder"] = {"sa_tiberium_storage_holder"}}
	for I,P in pairs(A) do
		local Btn = VG:AddNode(I)
		if P[2] then
			for i,p in pairs(P[2]) do
				local File = Btn:AddNode(p)
				File.Icon:SetImage("icon16/page.png")
				File.DoClick = function(self)
					RunConsoleCommand("sa_m_tiberium_Class",P[1])
					RunConsoleCommand("sa_m_tiberium_Size",i)
				end
			end
		else
			Btn.Icon:SetImage("icon16/page.png")
			Btn.DoClick = function(btn)
				RunConsoleCommand("sa_m_tiberium_Class",P[1])
			end
		end
	end
	Panel:AddItem(VG)
end