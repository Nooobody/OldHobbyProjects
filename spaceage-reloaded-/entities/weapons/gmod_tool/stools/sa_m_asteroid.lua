TOOL.Mode 		= "sa_m_asteroid"
TOOL.Tab 		= "SA"
TOOL.Category 	= "M"
TOOL.Name		= "Asteroid Mining"
TOOL.Command	= nil
TOOL.ConfigName	= ""

TOOL.ClientConVar["Class"] = "sa_mining_laser"
TOOL.ClientConVar["Size"] = 1
TOOL.ClientConVar["Frozen"] = 0

if CLIENT then
	language.Add( "tool.sa_m_asteroid.name", "Asteroid Mining" )
	language.Add( "tool.sa_m_asteroid.desc", "Spawn a device used to mine Asteroids" )
	language.Add( "tool.sa_m_asteroid.0", "Left Click: Spawn a device    Right Click: Spawn without Weld" )
	language.Add( "Undone_Raw Ore Storage", "Undone a Raw Ore Storage")
	language.Add( "Undone_Asteroid Mining Laser","Undone a Asteroid Mining Laser")
end

cleanup.Register("sa_mining_rawore_storage")
cleanup.Register("sa_mining_laser")

function TOOL:RightClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
		
	local Class = self:GetClientInfo("Class")
	
	if not self:GetSWEP():CheckLimit(Class) then return false end
	
	local Size = tonumber(self:GetClientNumber("Size"))
	local Ent
	if Class == "sa_mining_rawore_storage" then
		if Size > tonumber(self:GetOwner():GetResearch("Storage_Tech_Research")) then 
			self:GetOwner():SendLua("notification.AddLegacy('You do not have sufficient research level for that yet!',NOTIFY_ERROR,5)")
			return false 
		end
		
		local Mdl = list.Get("sa_mining_rawore_storage")[Size]
		if Mdl == "" then return end
		
		local Ang = trace.HitNormal:Angle()
		Ang.p = Ang.p + 90

		local Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = "sa_mining_rawore_storage",["Model"] = Mdl,["Pos"] = trace.HitPos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{},Size)
		
		undo.Create("Raw Ore Storage")
			undo.AddEntity(Ent)
			undo.SetPlayer(self:GetOwner())
		undo.Finish()
	elseif Class == "sa_mining_laser" then
		if Size > tonumber(self:GetOwner():GetResearch("Laser_Tech_Research")) then 
			self:GetOwner():SendLua("notification.AddLegacy('You do not have sufficient research level for that yet!',NOTIFY_ERROR,5)")
			return false 
		end
		
		local Mdl = list.Get("sa_mining_laser")[Size]
		if Mdl == "" then return end
		
		local Ang = trace.HitNormal:Angle()
		Ang.p = Ang.p + 90
		
		local Pos = trace.HitPos
		Pos = Pos + Ang:Up() * 20
		
		local Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = "sa_mining_laser",["Model"] = Mdl,["Pos"] = Pos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{},Size)
			
		undo.Create("Asteroid Mining Laser")
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
	local Mdl = list.Get(self:GetClientInfo("Class"))[self:GetClientNumber("Size")]
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
	Ch:SetConVar("sa_m_asteroid_Frozen")
	Ch:SetText("Frozen?")
	Ch:SizeToContents()
	Ch:Dock(TOP)
	Panel:AddItem(Ch)
	local VG = vgui.Create("DTree")
	VG:SetSize(200,500)
	local A = { ["Asteroid Mining Laser"] = {"sa_mining_laser",{"I","II","III","IV","V"}},
				["Raw Ore Storage"] = {"sa_mining_rawore_storage",{"Tiny","Small","Medium","Large","Huge"}}}
	for I,P in pairs(A) do
		local Btn = VG:AddNode(I)
		if P[2] then
			for i,p in pairs(P[2]) do
				local File = Btn:AddNode(p)
				File.Icon:SetImage("icon16/page.png")
				File.DoClick = function(self)
					RunConsoleCommand("sa_m_asteroid_Class",P[1])
					RunConsoleCommand("sa_m_asteroid_Size",i)
				end
			end
		else
			Btn.Icon:SetImage("icon16/page.png")
			Btn.DoClick = function(btn)
				RunConsoleCommand("sa_m_asteroid_Class",P[1])
			end
		end
	end
	Panel:AddItem(VG)
end