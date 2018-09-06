TOOL.Mode 		= "sa_m_ice"
TOOL.Tab 		= "SA"
TOOL.Category 	= "M"
TOOL.Name		= "Ice Mining"
TOOL.Command	= nil
TOOL.ConfigName	= ""

TOOL.ClientConVar["Class"] = "sa_mining_icelaser"
TOOL.ClientConVar["Size"] = 1
TOOL.ClientConVar["Frozen"] = 0

if CLIENT then
	language.Add( "tool.sa_m_ice.name", "Ice Mining" )
	language.Add( "tool.sa_m_ice.desc", "Spawn a device used to mine Ice" )
	language.Add( "tool.sa_m_ice.0", "Left Click: Spawn a device    Right Click: Spawn without Weld" )
	language.Add( "Undone_Raw Ice Storage", "Undone a Raw Ice Storage")
	language.Add( "Undone_Ice Mining Laser","Undone an Ice Mining Laser")
	language.Add( "Undone_Ice Refinery","Undone an Ice Refinery")
	language.Add( "Undone_Refined Ice Storage","Undone a Refined Ice Storage")
end

cleanup.Register("sa_mining_rawice_storage")
cleanup.Register("sa_mining_icelaser")
cleanup.Register("sa_mining_refinery")
cleanup.Register("sa_mining_refinedice_storage")

function TOOL:RightClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
		
	local Class = self:GetClientInfo("Class")
	
	if not self:GetSWEP():CheckLimit(Class) then return false end
	
	local Size = tonumber(self:GetClientNumber("Size"))
	local Ent
	if Class == "sa_mining_rawice_storage" then
		if Size > tonumber(self:GetOwner():GetResearch("Raw_Ice_Tech_Research")) then 
			self:GetOwner():SendLua("notification.AddLegacy('You do not have sufficient research level for that yet!',NOTIFY_ERROR,5)")
			return false 
		end
		
		local Mdl = list.Get("sa_mining_rawice_storage")[Size]
		if Mdl == "" then return end
		
		local Ang = trace.HitNormal:Angle()
		Ang.p = Ang.p + 90

		local Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = "sa_mining_rawice_storage",["Model"] = Mdl,["Pos"] = trace.HitPos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{},Size)
		
		undo.Create("Raw Ice Storage")
			undo.AddEntity(Ent)
			undo.SetPlayer(self:GetOwner())
		undo.Finish()
	elseif Class == "sa_mining_icelaser" then
		if Size > tonumber(self:GetOwner():GetResearch("Ice_Laser_Tech_Research")) then 
			self:GetOwner():SendLua("notification.AddLegacy('You do not have sufficient research level for that yet!',NOTIFY_ERROR,5)")
			return false 
		end
				
		local Ang = trace.HitNormal:Angle()
		Ang.p = Ang.p + 90
		
		local Pos = trace.HitPos
		Pos = Pos + Ang:Up() * 20
		
		local Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = "sa_mining_icelaser",["Pos"] = Pos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{},Size)
			
		undo.Create("Ice Mining Laser")
			undo.AddEntity(Ent)
			undo.SetPlayer(self:GetOwner())
		undo.Finish()
	elseif Class == "sa_mining_refinedice_storage" then
		if Size > tonumber(self:GetOwner():GetResearch("Refined_Ice_Tech_Research")) then 
			self:GetOwner():SendLua("notification.AddLegacy('You do not have sufficient research level for that yet!',NOTIFY_ERROR,5)")
			return false 
		end
		
		local Mdl = list.Get("sa_mining_refinedice_storage")[Size]
		if Mdl == "" then return end
		
		local Ang = trace.HitNormal:Angle()
		Ang.p = Ang.p + 90

		local Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = "sa_mining_refinedice_storage",["Model"] = Mdl,["Pos"] = trace.HitPos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{},Size)
		
		undo.Create("Refined Ice Storage")
			undo.AddEntity(Ent)
			undo.SetPlayer(self:GetOwner())
		undo.Finish()
	elseif Class == "sa_mining_refinery" then
		if Size > tonumber(self:GetOwner():GetResearch("Refinery_Tech")) then
			self:GetOwner():SendLua("notification.AddLegacy('You do not have sufficient research level for that yet!',NOTIFY_ERROR,5)")
			return false 
		end
		
		local Ang = trace.HitNormal:Angle()
		Ang.p = Ang.p + 90
		
		local Pos = trace.HitPos
		Pos = Pos + Ang:Up() * 20
		
		local Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = "sa_mining_refinery",["Pos"] = Pos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{},Size)
			
		undo.Create("Ice Refinery")
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
	
	local Weld = constraint.Weld(Ent,trace.Entity,0,trace.PhysicsBone,0,0,true)
	trace.Entity:DeleteOnRemove(Weld)
	Ent:DeleteOnRemove(Weld)
	
	return true
end

function TOOL:Think()
	local Class = self:GetClientInfo("Class")
	local Mdl = ""
	if Class == "sa_mining_icelaser" then Mdl = "models/ce_miningmodels/mininglasers/laser_mk1_standard.mdl"
	elseif Class == "sa_mining_refinery" then Mdl = "models/punisher239/punisher239_reactor_small.mdl"
	else Mdl = list.Get(self:GetClientInfo("Class"))[self:GetClientNumber("Size")] end
	if Mdl == "" then return end
	
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
	Ch:SetConVar("sa_m_ice_Frozen")
	Ch:SetText("Frozen?")
	Ch:SizeToContents()
	Ch:Dock(TOP)
	Panel:AddItem(Ch)
	local VG = vgui.Create("DTree")
	VG:SetSize(200,500)
	local A = { ["Ice Mining Laser"] = {"sa_mining_icelaser",{"I","II","III","IV","V"}},
				["Raw Ice Storage"] = {"sa_mining_rawice_storage",{"Small","Medium","Large","Huge","Colossal"}},
				["Refined Ice Storage"] = {"sa_mining_refinedice_storage",{"Small","Medium","Large"}},
				["Refinery"] = {"sa_mining_refinery",{"I","II","III"}}}
	for I,P in pairs(A) do
		local Btn = VG:AddNode(I)
		if P[2] then
			for i,p in pairs(P[2]) do
				local File = Btn:AddNode(p)
				File.Icon:SetImage("icon16/page.png")
				File.DoClick = function(self)
					RunConsoleCommand("sa_m_ice_Class",P[1])
					RunConsoleCommand("sa_m_ice_Size",i)
				end
			end
		else
			Btn.Icon:SetImage("icon16/page.png")
			Btn.DoClick = function(btn)
				RunConsoleCommand("sa_m_ice_Class",P[1])
			end
		end
	end
	Panel:AddItem(VG)
end