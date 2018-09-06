AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_draw.lua")
AddCSLuaFile("cl_hud.lua")
AddCSLuaFile("cl_team.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_spawnmenu.lua")
AddCSLuaFile("cl_player.lua")
AddCSLuaFile("sh_player.lua")
AddCSLuaFile("sh_research.lua")
AddCSLuaFile("sh_pp.lua")
AddCSLuaFile("sh_cppi.lua")
AddCSLuaFile("cl_chat.lua")

AddCSLuaFile("cl_help_data.lua")
AddCSLuaFile("cl_help_panel.lua")

AddCSLuaFile("custom_vgui/sa_button.lua")
AddCSLuaFile("custom_vgui/sa_checkbox.lua")

include("mysql.lua")
include("tib.lua")
include("Hoverdrive.lua")
include("E2_Fixes.lua")
include("entitylimits.lua")
include("shared.lua")
include("chat.lua")
include("news.lua")
include("log.lua")
include("util.lua")
include("sh_player.lua")
include("player.lua")
include("team.lua")
include("plants.lua")
include("sh_research.lua")
include("sh_pp.lua")
include("sh_cppi.lua")
include("cppi.lua")

resource.AddFile("resource/fonts/cour.TTF")
resource.AddFile("resource/fonts/lucon.TTF")
//resource.AddFile("materials/VGUI/Logo.png")
//resource.AddFile("materials/VGUI/Logo_Wide.png")
resource.AddFile("materials/VGUI/Logo_NewBG.png")
resource.AddFile("materials/VGUI/LogoTxt.png")
resource.AddFile("materials/VGUI/MM.png")
resource.AddFile("materials/VGUI/SF.png")
resource.AddFile("materials/VGUI/CS.png")
resource.AddFile("materials/VGUI/Legion.png")
resource.AddWorkshop("104691717")
resource.AddWorkshop("111929524")
resource.AddWorkshop("104542705")
resource.AddWorkshop("160250458")
resource.AddWorkshop("163806212")
resource.AddWorkshop("110305835")
resource.AddWorkshop("104815552")
resource.AddWorkshop("108941774")
resource.AddWorkshop("155060185")
resource.AddWorkshop("148070174")
resource.AddWorkshop("105993004")

local function AddFolder(path)
	local fil,dir = file.Find(path,"GAME")
	for I,P in pairs(fil) do
		resource.AddFile(path..P)
	end
	for I,P in pairs(dir) do
		AddFolder(path.."/"..P)
	end
end

//AddFolder("models/mini_roid/")
//AddFolder("models/ce_miningmodels/miningstorage/")

SA_DisablePP = true

function GM:PostCleanupMap()
	local Removables = {}
	
	table.insert(Removables,"env_smokestack")
	table.insert(Removables,"func_dustcloud")
	table.insert(Removables,"func_physbox_multiplayer")
	table.insert(Removables,"func_physbox")
	
	for I,P in pairs(ents.GetAll()) do
		if table.HasValue(Removables,P:GetClass()) then
			P:Remove()
		end
	end
	GM:InitPostEntity()
end

local function SpawnProp(Mdl,Pos,Ang)
	local Ent = ents.Create("prop_physics")
	Ent:SetModel(Mdl)
	Ent:SetPos(Pos)
	Ent:SetAngles(Ang)
	Ent:Spawn()
	Ent:SetNWEntity("Owner",ents.GetAll()[1])
	Ent:GetPhysicsObject():EnableMotion(false)
	return Ent
end

function GM:InitPostEntity()
	AsteroidPos = Vector(0,0,0)
	TibPos = Vector(0,0,0)
	local Removables = {}
	local IceTypes = {}
	
	table.insert(Removables,"env_smokestack")
	table.insert(Removables,"func_dustcloud")
	table.insert(Removables,"func_physbox_multiplayer")
	table.insert(Removables,"func_physbox")
	
	if game.GetMap() == "sb_gooniverse" then
		SA_SUN = ents.Create("sa_sun")
		SA_SUN:SetPos(Vector(-3138,-15788,1000))
		SA_SUN:Spawn()
		AsteroidPos = Vector(-8751.319336,-3704.754395,8794.752930)
		TibPos = Vector(8582.253906,-10068.008789,-1720.659180)

		IceTypes = {
			BlueIce = {
				Vector(-13953,-1977,-5092),
				Vector(-13221,-11361,-5456),
				Vector(-5686,-12112,-5682)
			},
			ClearIce = {
				{Vector(16,10,4612),1300},
				{Vector(9771,9252,3100),2000}
			},
			GlareCrust = {
				{Vector(9771,9252,5500),2000}
			},
			GlacialMass = {
				Vector(7405,13489,5342),
				Vector(12966,14112,4721),
				Vector(14899,9285,5205)
			},
			WhiteGlaze = {
				Vector(-8080,7905,14480),
				Vector(-13236,9220,10171),
				Vector(-8264,8675,5828)
			},
			Gelidus = {
				Vector(12342,-6025,-4376),
				Vector(12827,-11595,-5656),
				Vector(6937,-14318,-5994)
			},
			Krystallos = {
				Vector(-2055,8389,-11394),
				Vector(1043,11342,-11438),
				Vector(5547,8008,-11427)
			},
			DarkGlitter = {
				Vector(13006,-11092,-6559),
				Vector(12117,13931,2477),
				Vector(-8035,14149,10188),
				Vector(-13337,9239,11809),
				Vector(-2969,7241,8558)
			}
		}
		
		local TibSt = nil
		local TibPlan = nil
		local TermPlan = nil
		
		for I,P in pairs(map_goon) do
			Pln = ents.Create("sa_planet")
			Pln.Pos = P.Pos
			Pln.Size = P.Size
			Pln:Spawn()
			Pln.Locked = P.Locked or false
			Pln.ScreenName = I
			if Pln.ScreenName == "Earth" then Earth = Pln 
			elseif Pln.ScreenName == "TibStation" then TibSt = Pln
			elseif Pln.ScreenName == "Brown" then TibPlan = Pln
			elseif Pln.ScreenName == "Terminal" then TermPlan = Pln end
			if not Pln:LoadAtmo() or Pln.Locked then
				Pln.Pressure = P.Pressure
				Pln.RealAtmosphere = P.RealAtmosphere
				Pln:CalcAtmo()
				Pln:SaveAtmo()
			end
		end
		
		if TibSt and TibPlan then
			TibSt.ParentPlanet = TibPlan
		end
		
		CreateTeleporter("Spawn",Earth,Vector(-11130,-2945,-8000),Angle(-90,90,0))
		
		local Tib = SpawnProp("models/Slyfo/refinery_large.mdl",Vector(4191,-10412,-2047),Angle())
		CreateTeleporter("Tiberium",TibPlant,Tib:LocalToWorld(Vector(-195,0,60)),Tib:LocalToWorldAngles(Angle(-90,180,0)))
				
		local Term = SpawnProp("models/SmallBridge/Station Parts/sbhubl.mdl",Vector(-9828,-5984,-2657),Angle(0,0,0))
	
		SpawnProp("models/sbep_community/d12airscrubber.mdl",Term:LocalToWorld(Vector(-500,72.2,-11.156250)),Term:LocalToWorldAngles(Angle(0,90,90)))
		SpawnProp("models/sbep_community/d12airscrubber.mdl",Term:LocalToWorld(Vector(-500,-72.2,-11.156250)),Term:LocalToWorldAngles(Angle(0,-90,90)))
		CreateMineTerminal(Term:LocalToWorld(Vector(-480,71.8,-10)),Term:LocalToWorld(Vector(-510,-71.8,-20)),Term:LocalToWorldAngles(Angle(-90,90,0)),Term:LocalToWorldAngles(Angle(0,90,0)))
		
		SpawnProp("models/sbep_community/d12airscrubber.mdl",Term:LocalToWorld(Vector(500,72.2,-11.156250)),Term:LocalToWorldAngles(Angle(0,90,90)))
		SpawnProp("models/sbep_community/d12airscrubber.mdl",Term:LocalToWorld(Vector(500,-72.2,-11.156250)),Term:LocalToWorldAngles(Angle(0,-90,90)))
		CreateMineTerminal(Term:LocalToWorld(Vector(480,-71.8,-10)),Term:LocalToWorld(Vector(510,71.8,-20)),Term:LocalToWorldAngles(Angle(-90,-90,0)),Term:LocalToWorldAngles(Angle(0,-90,0)))
		
		SpawnProp("models/sbep_community/d12airscrubber.mdl",Term:LocalToWorld(Vector(72.2,-500,-11.156250)),Term:LocalToWorldAngles(Angle(0,0,90)))
		SpawnProp("models/sbep_community/d12airscrubber.mdl",Term:LocalToWorld(Vector(-72.2,-500,-11.156250)),Term:LocalToWorldAngles(Angle(0,180,90)))
		CreateMineTerminal(Term:LocalToWorld(Vector(-71.8,-480,-10)),Term:LocalToWorld(Vector(71.8,-510,-20)),Term:LocalToWorldAngles(Angle(-90,180,0)),Term:LocalToWorldAngles(Angle(0,180,0)))
		
		SpawnProp("models/sbep_community/d12airscrubber.mdl",Term:LocalToWorld(Vector(72.2,500,-11.156250)),Term:LocalToWorldAngles(Angle(0,0,90)))
		SpawnProp("models/sbep_community/d12airscrubber.mdl",Term:LocalToWorld(Vector(-72.2,500,-11.156250)),Term:LocalToWorldAngles(Angle(0,180,90)))
		CreateMineTerminal(Term:LocalToWorld(Vector(71.8,480,-10)),Term:LocalToWorld(Vector(-71.8,510,-20)),Term:LocalToWorldAngles(Angle(-90,0,0)),Term:LocalToWorldAngles(Angle(0,0,0)))		
		
		SpawnProp("models/sbep_community/d12airscrubber.mdl",Term:LocalToWorld(Vector(-6.3,23.6,-132.5)),Term:LocalToWorldAngles(Angle(0,-180,-90)))
		CreateTeleporter("Terminal",TermPlan,Term:LocalToWorld(Vector(-5.2,16.4,-130)),Term:LocalToWorldAngles(Angle(-90,-180,0)))
		
		SpawnProp("models/sbep_community/d12airscrubber.mdl",Term:LocalToWorld(Vector(-17.2,-18.8,133)),Term:LocalToWorldAngles(Angle(0,90,90)))
		CreateTeleporter("Terminal",TermPlan,Term:LocalToWorld(Vector(22,-19.4,133)),Term:LocalToWorldAngles(Angle(-90,90,0)))
		
		SpawnProp("models/sbep_community/d12airscrubber.mdl",Term:LocalToWorld(Vector(305.2,4.4,100)),Term:LocalToWorldAngles(Angle(0,0,0)))
		CreateResTerminal(Term:LocalToWorld(Vector(305.2,-12,125)),Term:LocalToWorldAngles(Angle(-90,0,0)))
		
		SpawnProp("models/sbep_community/d12airscrubber.mdl",Term:LocalToWorld(Vector(-305.2,4.4,100)),Term:LocalToWorldAngles(Angle(0,180,0)))
		CreateResTerminal(Term:LocalToWorld(Vector(-305.2,20,125)),Term:LocalToWorldAngles(Angle(-90,180,0)))
		
		SpawnProp("models/sbep_community/d12airscrubber.mdl",Term:LocalToWorld(Vector(0,341,-150)),Term:LocalToWorldAngles(Angle(0,90,0)))
		CreateResTerminal(Term:LocalToWorld(Vector(15,341,-127)),Term:LocalToWorldAngles(Angle(-90,90,0)))
		
		SpawnProp("models/sbep_community/d12airscrubber.mdl",Term:LocalToWorld(Vector(0,-341,-150)),Term:LocalToWorldAngles(Angle(0,-90,0)))
		CreateResTerminal(Term:LocalToWorld(Vector(-15,-341,-127)),Term:LocalToWorldAngles(Angle(-90,-90,0)))	
		
		SpawnProp("models/Slyfo/dw_cargodoor.mdl",Tib:LocalToWorld(Vector(-220,620,120)),Tib:LocalToWorldAngles(Angle(0,0,0)))
		SpawnProp("models/Slyfo/dw_cargodoor.mdl",Tib:LocalToWorld(Vector(162.3,1009,120)),Tib:LocalToWorldAngles(Angle(0,-90,0)))
		SpawnProp("models/hunter/plates/plate3x8.mdl",Tib:LocalToWorld(Vector(36,1004,78)),Tib:LocalToWorldAngles(Angle(-90,-90,0)))
		
		CreateTibTerminal(Tib:LocalToWorld(Vector(-5,1002,60)),Tib:LocalToWorld(Vector(-110,1002,60)),Tib:LocalToWorldAngles(Angle(-90,90,0)),Tib:LocalToWorldAngles(Angle(90,-90,0)))
		CreateTibTerminal(Tib:LocalToWorld(Vector(107,1002,60)),Tib:LocalToWorld(Vector(180,1002,60)),Tib:LocalToWorldAngles(Angle(-90,90,0)),Tib:LocalToWorldAngles(Angle(90,-90,0)))
		
		CreateLiqTibTerminal(Tib:LocalToWorld(Vector(80,1020,60)),Tib:LocalToWorld(Vector(-80,1012,120)),Tib:LocalToWorldAngles(Angle(-90,90,180)),Tib:LocalToWorldAngles(Angle(-90,-90,0)))
		CreateLiqTibTerminal(Tib:LocalToWorld(Vector(240,1020,60)),Tib:LocalToWorld(Vector(400,1012,120)),Tib:LocalToWorldAngles(Angle(-90,90,180)),Tib:LocalToWorldAngles(Angle(-90,-90,0)))
		
		CreateLavaPump(Vector(1519.28,7638.84,-10183.59),Angle(0,180,0),Vector(1519.28,7638.84,-10254.59),Angle(0,-90,0))
		CreateLavaPump(Vector(1619.90,7702.59,-10185.06),Angle(0,-90,0),Vector(1620.06,7702.40,-10256.25),Angle(0,0,0))
		CreateLavaPump(Vector(1520.28,7767.46,-10182.93),Angle(0,0,0),Vector(1520.31,7767.43,-10254.09),Angle(0,90,0))
		CreateLavaPump(Vector(1443.59,7702.00,-10183.59),Angle(0,90,0),Vector(1443.59,7702.00,-10254.59),Angle(0,-90,0))
		
	elseif game.GetMap() == "sb_omen_v2" then
		table.insert(Removables,"npc_maker")
		table.insert(Removables,"npc_vortigaunt")
	end
	
	for I,P in pairs(ents.GetAll()) do
		if table.HasValue(Removables,P:GetClass()) then
			P:Remove()
		end
	end
	
	StartRoids(AsteroidPos,4000,20)
	StartTibs(TibPos,2500,5)
	StartIce(100,IceTypes)
end

function GM:Initialize()
	TIB_REF = {}
	TIB_REF.RawTiberium = 0
	TIB_REF.Tiberium = 0

	NEWS = {}
	
	if not file.Exists("Players","DATA") then
		file.CreateDir("Players")
		file.CreateDir("Players_Bans")
	end
	
	SA_pcall(LoadTib)	
	SA_pcall(LoadNews)
end

function GM:ShutDown()
	for I,P in pairs(player.GetAll()) do
		if P.Joined and P.TimePlayed then
			local ID = FormatSteamID(P:SteamID())
			local Str = SavePlayerInfo(P)
			file.Write("Players/"..ID..".txt",Str)
		end
	end
end

function StartRoids(Pos,Rad,Count)
	timer.Create("SA_Asteroids",5,0,function()
		if #ents.FindByClass("sa_asteroid") <= Count then
			local Roid = ents.Create("sa_asteroid")
			Roid:SetPos(Pos + Vector(math.random(-Rad,Rad),math.random(-Rad,Rad),math.random(-Rad,Rad)))
			Roid:Spawn()
		end
	end)
end

function StartTibs(Pos,Rad,Count)
	local Towers = {}
	local IsServerStart = true
	timer.Create("SA_Tiberium",5,0,function()
		for I,P in pairs(Towers) do
			if not IsValid(P) then
				table.remove(Towers,I)
				break
			end
		end
		if #Towers <= Count then
			local Vec = Vector(math.random(-Rad,Rad),math.random(-Rad,Rad),0)
			local Tr = {}
			Tr.start = Pos + Vec + Vector(0,0,300)
			Tr.endpos = Pos + Vec - Vector(0,0,600)
			local Trace = util.TraceLine(Tr)
			if Trace.HitWorld then
				local Break = false
				for I,P in pairs(ents.FindByClass("sa_tiberium_tower")) do
					if P:GetPos():Distance(Trace.HitPos) < 1000 then
						Break = true
						break
					end
				end
				if not Break then
					local Rand = math.random(1,100)
					local IsBlue = Rand > 95
					local Tib = ents.Create("sa_tiberium_tower")
					Tib:SetPos(Trace.HitPos)
					Tib:Spawn()
					Tib:SetNWEntity("Owner",ents.GetAll()[1])
					if IsBlue and not IsServerStart then
						Tib.IsBlue = true
						Tib:SetModel("models/chipstiks_mining_models/SmallBlueTower/smallbluetower.mdl")
						Tib.TibModel = "models/chipstiks_mining_models/SmallBlueCrystal/smallbluecrystal.mdl"
					else
						Tib.IsBlue = false
					end
					table.insert(Towers,Tib)
				end
			end
		elseif IsServerStart then
			IsServerStart = nil
		end
	end)
end

function StartIce(Count,IceTypes)
	local Value = {"BlueIce","ClearIce","GlareCrust","GlacialMass","WhiteGlaze","Gelidus","Krystallos","DarkGlitter"}
	local IceRoids = {}
	timer.Create("SA_ICE",5,0,function()
		for I,P in pairs(IceRoids) do
			if not IsValid(P) then
				table.remove(IceRoids,I)
				break
			end
		end
		if #IceRoids >= Count then return end
		local Type = math.random(0,100)
		local IceType
		local Alpha = 255
		if Type >= 98 then
			IceType = "DarkGlitter"
			Alpha = 25
		elseif Type >= 94 then
			IceType = "Krystallos"
			Alpha = 45
		elseif Type >= 90 then
			IceType = "Gelidus"
			Alpha = 70
		elseif Type >= 80 then
			IceType = "WhiteGlaze"
			Alpha = 100
		elseif Type >= 68 then
			IceType = "GlacialMass"
			Alpha = 160
		elseif Type >= 34 then
			IceType = "GlareCrust"
			Alpha = 200
		elseif Type >= 0 then
			if math.random(1,2) == 1 then
				IceType = "ClearIce"
				Alpha = 230
			else
				IceType = "BlueIce"
			end
		end
		
		local Num = table.KeyFromValue(Value,IceType)
		local Vec = table.Random(IceTypes[Value[math.random(Num,math.Clamp(Num + 2,1,#Value))]])
		if type(Vec) == "table" then
			local Ang = math.Rand(-math.pi,math.pi)
			Vec = Vec[1] + Vector(Vec[2] * math.cos(Ang),Vec[2] * math.sin(Ang),0)
		end
		local Ent = ents.Create("sa_ice")
		Ent:SetPos(Vec + VectorRand() * 200)
		Ent:SetAngles(Angle(math.Rand(-360,360),math.Rand(-360,360),math.Rand(-360,360)))
		Ent:Spawn()
		Ent:SetRenderMode(1)
		Ent:SetNWEntity("Owner",ents.GetAll()[1])
		Ent:SetColor(Color(0,0,0,Alpha))
		Ent.IceType = IceType
		table.insert(IceRoids,Ent)
	end)
end

function CreateLavaPump(Pos1,Ang1,Pos2,Ang2)
	local Ent = ents.Create("sa_ice_pump")
	Ent:SetPos(Pos1)
	Ent:SetAngles(Ang1)
	Ent:Spawn()
	Ent:GetPhysicsObject():EnableMotion(false)
	Ent:SetNWEntity("Owner",ents.GetAll()[1])
	Ent.DefaultPos = Pos1
	local Prop = ents.Create("prop_physics")
	Prop:SetModel("models/hunter/tubes/tube2x2x1.mdl")
	Prop:SetPos(Pos2)
	Prop:SetAngles(Ang2)
	Prop:Spawn()
	Prop:GetPhysicsObject():EnableMotion(false)
	Prop:SetNWEntity("Owner",ents.GetAll()[1])
	Prop:SetMaterial("phoenix_storms/metalset_1-2")
end

function CreateMineTerminal(Pos1,Pos2,Ang1,Ang2)
	local Ent = ents.Create("sa_mining_screen")
	Ent:SetPos(Pos1)
	Ent:SetAngles(Ang1)
	Ent:Spawn()
	Ent:SetNWEntity("Owner",ents.GetAll()[1])
	Ent.UseAllowed = true
	local Plug = ents.Create("sa_port")
	Plug:SetPos(Pos2)
	Plug:SetAngles(Ang2)
	Plug:Spawn()
	Plug:GetPhysicsObject():EnableMotion(false)
	Plug.UseAllowed = true
	timer.Simple(3,function() Plug:SetMoveType(MOVETYPE_NONE) end)
	Plug:SetNWEntity("Owner",ents.GetAll()[1])
	Plug.Terminal = Ent
	Ent.Socket = Plug
end

function CreateTeleporter(Name,Planet,Pos1,Ang1)
	local Ent = ents.Create("sa_teleporter_screen")
	Ent:SetPos(Pos1)
	Ent:SetAngles(Ang1)
	Ent.ScreenName = Name
	Ent.Planet = Planet
	Ent:Spawn()
	Ent:SetNWEntity("Owner",ents.GetAll()[1])
	Ent.UseAllowed = true
end

function CreateResTerminal(Pos1,Ang1)
	local Ent = ents.Create("sa_research_screen")
	Ent:SetPos(Pos1)
	Ent:SetAngles(Ang1)
	Ent:Spawn()
	Ent:SetNWEntity("Owner",ents.GetAll()[1])
	Ent.UseAllowed = true
end

function CreateLiqTibTerminal(Pos1,Pos2,Ang1,Ang2)
	local Scrn = ents.Create("sa_liquidtiberium_screen")
	Scrn:SetPos(Pos1)
	Scrn:SetAngles(Ang1)
	Scrn:Spawn()
	Scrn:SetNWEntity("Owner",ents.GetAll()[1])
	Scrn.UseAllowed = true
	local Ent = ents.Create("sa_tiberium_loader")
	Ent:SetPos(Pos2)
	Ent:SetAngles(Ang2)
	Ent:Spawn()
	Ent:SetNWEntity("Owner",ents.GetAll()[1])
	Ent:GetPhysicsObject():EnableMotion(false)
	Scrn.Loader = Ent
end

function CreateTibTerminal(Pos1,Pos2,Ang1,Ang2)
	local Ent = ents.Create("sa_tiberium_screen")
	Ent:SetPos(Pos1)
	Ent:SetAngles(Ang1)
	Ent:Spawn()
	Ent:SetNWEntity("Owner",ents.GetAll()[1])
	Ent.UseAllowed = true
	local Plug = ents.Create("sa_tiberium_storage_holder")
	Plug:SetPos(Pos2)
	Plug:SetAngles(Ang2)
	Plug:Spawn()
	Plug:GetPhysicsObject():EnableMotion(false)
	timer.Simple(3,function() Plug:SetMoveType(MOVETYPE_NONE) end)
	Plug:SetNWEntity("Owner",ents.GetAll()[1])
	Plug.Terminal = Ent
	Ent.Holder = Plug
end