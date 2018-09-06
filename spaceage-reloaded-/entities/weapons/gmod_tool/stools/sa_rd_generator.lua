TOOL.Mode 		= "sa_rd_generator"
TOOL.Tab 		= "SA"
TOOL.Category 	= "RD"
TOOL.Name		= "Resource Generator"
TOOL.Command	= nil
TOOL.ConfigName	= ""

TOOL.ClientConVar["Class"] = "sa_generator_fusion"
TOOL.ClientConVar["Model"] = "models/ce_ls3additional/solar_generator/solar_generator_c_huge.mdl"
TOOL.ClientConVar["Frozen"] = 0
TOOL.ClientConVar["Size"] = 1
TOOL.ClientConVar["Multiplier"] = 5

if CLIENT then
	language.Add( "tool.sa_rd_generator.name", "Generator Tool" )
	language.Add( "tool.sa_rd_generator.desc", "Left-click to spawn Generators." )
	language.Add( "tool.sa_rd_generator.0", "Left Click: Spawn a Generator    Right Click: Spawn without Weld" )
	language.Add( "Undone_Resource Generator", "Undone Resource Generator")
end

cleanup.Register("sa_generator_gas")
cleanup.Register("sa_generator_fusion")
cleanup.Register("sa_generator_energy")
cleanup.Register("sa_generator_steam")
cleanup.Register("sa_generator_water")
cleanup.Register("sa_generator_ice")
cleanup.Register("sa_generator_solar")
cleanup.Register("sa_generator_hydro")
cleanup.Register("sa_generator_water_splitter")
cleanup.Register("sa_compressor_steam")
cleanup.Register("sa_compressor_heavy_water")

function TOOL:RightClick(trace)
	if not trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	
	local Class = self:GetClientInfo("Class")
	if Class == "" then return end
	
	if not self:GetSWEP():CheckLimit(Class) then return false end 
	
	local Ang = trace.HitNormal:Angle()
	Ang.p = Ang.p + 90
	
	local Pos = trace.HitPos
	
	local Mdl
	if Class == "sa_generator_fusion" or Class == "sa_generator_hydro" then
		local Size = self:GetClientNumber("Size")
		Mdl = list.Get(Class)[Size]
	elseif Class == "sa_generator_solar" then
		local Size = self:GetClientNumber("Size")
		if Size == 1 then
			Mdl = self:GetClientInfo("Model")
		else
			Mdl = "models/slyfo_2/miscequipmentsolar.mdl"
		end
	else
		Mdl = scripted_ents.Get(self:GetClientInfo("Class")).Model
	end
	if Mdl == "" then return end
	local Ent = WireLib.MakeWireEnt(self:GetOwner(),{["Class"] = Class,["Model"] = Mdl,["Pos"] = Pos,["Angle"] = Ang,["frozen"] = self:GetClientNumber("Frozen") == 1},{})
	
	if not IsValid(Ent) then return false end
	
	Ent:TriggerInput("Multiplier",self:GetClientNumber("Multiplier"))
	
	undo.Create("Resource Generator")
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
	if not IsValid(Weld) then return true end
	trace.Entity:DeleteOnRemove(Weld)
	Ent:DeleteOnRemove(Weld)
	
	return true
end

function TOOL:Think()
	local Class = self:GetClientInfo("Class")
	local Mdl
	if Class == "sa_generator_fusion" or Class == "sa_generator_hydro" then
		local Size = self:GetClientNumber("Size")
		Mdl = list.Get(Class)[Size]
	elseif Class == "sa_generator_solar" then
		local Size = self:GetClientNumber("Size")
		if Size == 1 then
			Mdl = self:GetClientInfo("Model")
		else
			Mdl = "models/slyfo_2/miscequipmentsolar.mdl"
		end
	else
		Mdl = scripted_ents.Get(self:GetClientInfo("Class")).Model
	end
	if not Mdl or Mdl == "" then return end

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
	Ch:SetConVar("sa_rd_generator_Frozen")
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
	local Order = {"Water Pump","Hydro Turbine","Solar Panel","Fusion Generator","Water Splitter","Water Freezer","Water Heater","Gas Turbine","Water Condensor","Water Compressor"}
	table.sort(Order)
	local Names = {
		Water = "Water Pump",
		Hydro = "Hydro Turbine",
		Solar = "Solar Panel",
		Fusion = "Fusion Generator",
		Water_Splitter = "Water Splitter",
		Ice = "Water Freezer",
		Steam = "Water Heater",
		Gas = "Gas Turbine",
		sa_compressor_steam = "Water Condensor",
		sa_compressor_heavy_water = "Water Compressor"
	}
	local Lvls = {
		"I",
		"II",
		"III",
		"IV",
		"V"
	}
	local SolarOrder = {"22x27","23x52","49x87","90x207","224x517","54x54","80x80","160x160","282x282"}
	local Solars = {
		["22x27"] = "models/ce_ls3additional/solar_generator/solar_generator_small.mdl",
		["23x52"] = "models/ce_ls3additional/solar_generator/solar_generator_medium.mdl",
		["49x87"] = "models/ce_ls3additional/solar_generator/solar_generator_large.mdl",
		["90x207"] = "models/ce_ls3additional/solar_generator/solar_generator_huge.mdl",
		["224x517"] = "models/ce_ls3additional/solar_generator/solar_generator_giant.mdl",
		["54x54"] = "models/ce_ls3additional/solar_generator/solar_generator_c_small.mdl",
		["80x80"] = "models/ce_ls3additional/solar_generator/solar_generator_c_medium.mdl",
		["160x160"] = "models/ce_ls3additional/solar_generator/solar_generator_c_large.mdl",
		["282x282"] = "models/ce_ls3additional/solar_generator/solar_generator_c_huge.mdl"
	}
	for I,P in pairs(Order) do
		local Val = table.KeyFromValue(Names,P)
		if Val == "Solar" then
			local No = VG:AddNode(P)
			No.Icon:SetImage("icon16/folder.png")
			local Ti = No:AddNode("I")
			Ti.Icon:SetImage("icon16/folder.png")
			for I,Mdl in pairs(SolarOrder) do
				local Pa = Ti:AddNode(Mdl)
				Pa.Icon:SetImage("icon16/page.png")
				Pa.DoClick = function(self)
					RunConsoleCommand("sa_rd_generator_Model",Solars[Mdl])
					RunConsoleCommand("sa_rd_generator_Size",1)
					RunConsoleCommand("sa_rd_generator_Class","sa_generator_solar")
				end	
			end
			local Te = No:AddNode("II")
			Te.Icon:SetImage("icon16/page.png")
			Te.DoClick = function(self)
				RunConsoleCommand("sa_rd_generator_Size",2)
				RunConsoleCommand("sa_rd_generator_Class","sa_generator_solar")
			end
		elseif Val == "Hydro" then
			local No = VG:AddNode(P)
			No.Icon:SetImage("icon16/folder.png")
			for i,p in pairs(list.Get("sa_generator_hydro")) do
				local Pa = No:AddNode(Lvls[i])
				Pa.Icon:SetImage("icon16/page.png")
				Pa.DoClick = function(self)
					RunConsoleCommand("sa_rd_generator_Size",i)
					RunConsoleCommand("sa_rd_generator_Class","sa_generator_hydro")
				end
			end
		elseif Val == "Fusion" then
			local No = VG:AddNode(P)
			No.Icon:SetImage("icon16/folder.png")
			for i,p in pairs(list.Get("sa_generator_fusion")) do
				local Pa = No:AddNode(Lvls[i])
				Pa.Icon:SetImage("icon16/page.png")
				Pa.DoClick = function(self)
					RunConsoleCommand("sa_rd_generator_Size",i)
					RunConsoleCommand("sa_rd_generator_Class","sa_generator_fusion")
				end
			end
		else
			if Val == "sa_compressor_steam" or Val == "sa_compressor_heavy_water" then
				local No = VG:AddNode(P)
				No.Icon:SetImage("icon16/page.png")
				No.DoClick = function(btn)
					RunConsoleCommand("sa_rd_generator_Class",Val)
				end
			else
				local No = VG:AddNode(P)
				No.Icon:SetImage("icon16/page.png")
				No.DoClick = function(btn)
					RunConsoleCommand("sa_rd_generator_Class","sa_generator_"..string.lower(Val))
				end
			end
		end
	end
	Panel:AddItem(VG)
end