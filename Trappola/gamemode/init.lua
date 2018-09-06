AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_lobby.lua" )
AddCSLuaFile( "cl_mapvote.lua" )
AddCSLuaFile( "cl_message.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "models.lua" )
AddCSLuaFile( "cl_chat.lua" )
AddCSLuaFile( "cl_draw.lua" )
AddCSLuaFile( "cl_tut.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_traps.lua" )
AddCSLuaFile( "sh_data.lua" )
AddCSLuaFile( "arcade/pong.lua" )
AddCSLuaFile( "arcade/AlienAttack.lua" )
AddCSLuaFile( "arcade/Pacman.lua" )

include( "ArtifactSpawn.lua" )
include( "mapvote.lua" )
include( "shared.lua" )
include( "chat.lua" )
include( "extract.lua" )
include( "Player.lua" )
include( "models.lua" )
include( "FileSaveLoad.lua" )
include( "BanSystem.lua" )
require"gatekeeper"

resource.AddFile(game.GetMap())
resource.AddFile("sound/itempickup.wav")
resource.AddFile("models/player/miku.mdl")
resource.AddFile("models/w_models/weapons/w_eq_medkit.mdl")
resource.AddFile("models/rin.mdl")
resource.AddFile("models/player/sam.mdl")
resource.AddFile("models/grim.mdl")
resource.AddFile("materials/models/w_models/eq_medkit/w_eq_medkit.vmt")
resource.AddSingleFile("materials/models/v_models/eq_medkit/v_eq_medkit.vmt")
resource.AddFile("materials/Skull.vmt")
resource.AddFile("materials/Toxic Byproduct.vmt")
resource.AddFile("materials/Alien.vmt")
resource.AddFile("materials/Heart.vmt")
resource.AddFile("materials/Medkit.vmt")
resource.AddFile("materials/pacccman.vmt")
resource.AddFile("materials/stillpac.vmt")
resource.AddFile("materials/yellow_ball.vmt")
resource.AddFile("materials/pacman_ghost.vmt")
local Table = {"Artifact1",
				"Spiketrapgen1",
				"Spiketrapgen2",
				"Spiketrapgen3",
				"ViewFlareModel",
				"spiketrap",
				"poisontrap",
				"harpoontrap",
				"explosivetrap",
				"fakewalltrap"}

for I,P in pairs(Table) do
	resource.AddFile("models/props/"..P..".mdl")
end

for I,P in pairs(Table) do
	for i,p in pairs(file.Find("materials/models/props/"..P.."/*",true)) do
		resource.AddFile("materials/models/props/"..P.."/"..p)
	end
end

for I,P in pairs(file.Find("materials/models/player/hatsunemiku/*",true)) do
	resource.AddFile("materials/models/player/hatsunemiku/"..P)
end

for I,P in pairs(file.Find("materials/models/player/rin/*",true)) do
	resource.AddFile("materials/models/player/rin/"..P)
end

for I,P in pairs(file.Find("materials/models/player/libertyprime*",true)) do
	resource.AddFile("materials/models/player/"..P)
end

for I,P in pairs(file.Find("materials/models/grim/*",true)) do
	resource.AddFile("materials/models/grim/"..P)
end

function GM:ShowHelp(ply)
	if not ply:GetNWBool("InLobby") then
		ply:SetNWBool("InLobby",true)
		umsg.Start("Lobby",ply)
			local Tab = gatekeeper.GetNumClients()
			umsg.Short(Tab.total)
		umsg.End()
	end
end

function GM:ShowTeam(ply)
	if ply:Team() ~= 3 then
		ply:ConCommand("Trappola_InitTut")
	end
end

function GM:ShowSpare1(ply)

end

function GM:ShowSpare2(ply)

end

function GM:EntityTakeDamage(ent,inf,atk,amount,dmginf)
	if IsScavenger(ent) then
		ent.DamageTaken = ent.DamageTaken + amount
		if atk:IsPlayer() and atk:Team() == 2 then
			atk.DmgExp = math.Round(atk.DmgExp + (amount / 2))
		end
	end
end

local function AllowTrap(Trap,P)
	local Trp,I = FindTrap(Trap)
	local tr = P:GetEyeTrace()
	if Trp["PlayerLocalized"] then
		if P:GetNWBool(Trap) then
			local Time,Max = P:GetNWInt(Trap.." Start"),GetData(Trap,"Cooldown",P.Cooldowns[I])
			local Num = (Max + Time) - CurTime()
			Num = math.Round(Num * 10) / 10
			ShoutIt("You have to wait before placing any more of these traps",P,1,"Time left: "..Num.." seconds")
			return false
		end
	else
		if GetGlobalBool(Trap) then
			local Time,Max = GetGlobalInt(Trap.." Start"),GetData(Trap,"Cooldown",P.Cooldowns[I])
			local Num = (Max + Time) - CurTime()
			Num = math.Round(Num * 10) / 10
			ShoutIt("You have to wait before placing any more of these traps",P,1,"Time left: "..Num.." seconds")
			return false
		end
	end
	if not util.IsInWorld(tr.HitPos) then
		ShoutIt("The point is outside the map boundaries!",P)
		return false
	end
	local C1,C2 = MapExtract()
	local X,Y = (C1.x + C2.x) / 2,(C1.y + C2.y) / 2
	if tr.HitPos:Distance(Vector(X,Y,C1.z)) < 750 then
		ShoutIt("Too close to the extract point!",P,2,"Minimum distance allowed: ".. 750,"Distance: "..math.Round(tr.HitPos:Distance(Vector(X,Y,C1.z))))
		return false
	end
	local Find = ents.FindInSphere(tr.HitPos,450)
	for I,A in pairs(Find) do
		if string.Left(A:GetClass(),5) == "trap_" and A:GetPos():Distance(tr.HitPos) <= 450 then
			local name = FindTrap(A:GetClass())
			ShoutIt("Too close to other traps.",P,3,"Minimum distance allowed: ".. 450,"Distance: "..math.Round(tr.HitPos:Distance(A:GetPos())),"Trap: "..name["Trap name"].." Owned by: "..A:GetOwner():Name())
			return false
		end
	end
	local Find = ents.FindInSphere(tr.HitPos,350)
	for I,A in pairs(Find) do
		if IsScavenger(A) and A:Health() > 0 and A:GetPos():Distance(tr.HitPos) <= 350 then
			ShoutIt("Too close to Scavengers.",P,3,"Minimum distance allowed: ".. 350,"Distance: "..math.Round(tr.HitPos:Distance(A:GetPos())),"Player: "..A:Name())
			return false
		end
	end
	return true
end

local function TrapPlace(P)
	local tr = P:GetEyeTraceNoCursor()
	if not tr.Entity:IsValid() then
		local Trap = P:GetTrap()
		if IsValidTrap(Trap) then
			if AllowTrap(Trap,P) then
				local Prop = ents.Create(Trap)
				Prop:SetPos(Vector(0,0,0))
				Prop:SetOwner(P)
				Prop:Spawn()
				Prop:DrawShadow(false)
				local Nor = tr.HitNormal
				local Ang = Nor:Angle()
				local Min,Max = Prop:WorldSpaceAABB()
				local Val = Max - Min
				if Trap == "trap_fakewall" or Trap == "trap_spike" then
					Prop.Mdl = GetData(Trap,"Model",Ply_SelectLvl(P:SteamID(),Trap.."_Model"))
				end
				Prop:SetAngles(Angle(Ang.p + 90,0,0))
				Prop:SetPos(tr.HitPos + Prop:GetAngles():Up() * (Val.z / 2) )
				if Trap ~= "trap_fakeartifact" then
					local Upgds = {}
					for I,T in pairs(TrapUpgrades) do
						if T["Trap"] == Trap and T["Var"] ~= "Unlock" and T["Var"] ~= "Model" then
							table.insert(Upgds,T["Var"])
						end
					end
					for I,T in pairs(Upgds) do
						local Lvl = Ply_SelectLvl(P:SteamID(),Trap.."_"..T)
						local Val = GetData(Trap,T,Lvl)
						Prop[T] = Val
					end
				end
				if P.CooldownsOff ~= Trap then
					local Trp,I = FindTrap(Trap)
					if Trp["PlayerLocalized"] then
						P:SetNWBool(Trap,true)
						P:SetNWInt(Trap.." Start",CurTime())
						local Time = GetData(Trap,"Cooldown",P.Cooldowns[I])
						timer.Simple(Time,function() P:SetNWBool(Trap,false) end)
					else
						SetGlobalBool(Trap,true)
						SetGlobalInt(Trap.." Start",CurTime())
						local Time = GetData(Trap,"Cooldown",P.Cooldowns[I])
						timer.Create(Trap,1,0,function()
							if GetGlobalBool("Lobby") then timer.Remove(Trap) return end
							Time = Time - 1
							if Time <= 0 then
								SetGlobalBool(Trap,false) 
								timer.Remove(Trap)
							end
						end)
					end
				end
				P.TrapsSpawnd = P.TrapsSpawnd + 1
				DB_UpdateAddIndPly(P:SteamID(),Trap,1)
			end
		else
			ShoutIt("No trap has been selected.",P)
		end
	end
end

local function TrapRemove(P)
	local tr = P:GetEyeTraceNoCursor().Entity
	if tr:IsValid() and string.Left(tr:GetClass(),5) == "trap_" and P:GetPos():Distance(tr:GetPos()) <= 500 then
		if tr:GetOwner() ~= P then
			ShoutIt("You can't remove that!",P,1,"Owner: "..tr:GetOwner():Name())
		elseif tr:GetOwner() == P and tr:GetNWBool("Defused") then
			ShoutIt("This trap has been defused, you can't remove it.",P)
		elseif tr:GetOwner() == P and tr.Triggered then
			ShoutIt("This trap has triggered already, you can't remove it.",P)
		elseif tr:GetOwner() == P and not tr:GetNWBool("Defused") then
			tr:SetNWBool("BeingRemoved",true)
			tr:SetNWInt("RemovalTime",2)
			local Tra = tr
			timer.Create("Remove - "..P:Name(),0.1,0,function(Name)
				if not P:GetEyeTrace().Entity or not P:GetEyeTrace().Entity:IsValid() then
					timer.Remove("Remove - "..Name)
				end
				if P:KeyReleased(IN_ATTACK2) or not P:KeyDown(IN_ATTACK2) or P:GetEyeTrace().Entity ~= Tra or Tra:GetNWBool("Defused") then 
					Tra:SetNWBool("BeingRemoved",false)
					Tra:SetNWInt("RemovalTime",2)
					timer.Remove("Remove - "..Name)
				end
				Tra:SetNWInt("RemovalTime",Tra:GetNWInt("RemovalTime") - 0.1)
				if Tra:GetNWInt("RemovalTime") <= 0 then
					P:GetEyeTrace().Entity:Remove()
					timer.Remove("Remove - "..Name)
					P.TrapsRemovd = P.TrapsRemovd + 1
					local Trap = FindTrap(Tra:GetClass())
					if Trap["PlayerLocalized"] then
						P:SetNWBool(Tra:GetClass(),false)
						P:SetNWInt(Tra:GetClass().." Start",0)
					else
						SetGlobalBool(Tra:GetClass(),false)
						SetGlobalInt(Tra:GetClass().." Start",0)
					end
				end
			end,P:Name())
		end
	end
end

function GM:KeyPress(P,key)
	if GetGlobalBool("Lobby") then return end
	if P:Team() == 1 and P:Health() > 0 then
		local Ent = P:GetEyeTraceNoCursor().Entity
		if key == IN_USE and string.find(Ent:GetClass(),"artifact") and Ent:GetPos():Distance(P:GetPos()) < 250 then
			Ent:Use(P)
		end
		if key == IN_JUMP then
			P.Jumped = P.Jumped + 1
		end
		if P:GetActiveWeapon():GetClass() == "flare" and Ent:GetClass() == "prop_ragdoll" and P:GetPos():Distance(Ent:GetPos()) < 250 then
			local ply = Ent:GetOwner()
			if ply:GetNWBool("Medkit") and not P:GetNWBool("Medkit") and key == IN_ATTACK then
				ply:SetNWBool("Medkit",false)
				P:SetNWBool("Medkit",true)
				P:Give("Medkit")
			elseif (ply:GetNWBool("Radar") or ply:GetNWBool("Defuser")) and not P:GetNWBool("Radar") and not P:GetNWBool("Defuser") and key == IN_ATTACK2 then
				if ply:GetNWBool("Radar") then
					ply:SetNWBool("Radar",false)
					P:SetNWBool("Radar",true)
					P:Give("TrapRadar")
				elseif ply:GetNWBool("Defuser") then
					ply:SetNWBool("Defuser",false)
					P:SetNWBool("Defuser",true)
					P:Give("TrapDefuser")
				end
			end
		end
	elseif P:Team() == 2 then
		if key == IN_ATTACK then
			TrapPlace(P)
		elseif key == IN_ATTACK2 then
			TrapRemove(P)
		end
	end
end

local function SendTraps(ply)
	if ply:IsBot() then return end
	local txt = ""
	local xtx = ""
	for I,P in pairs(Traps) do
		if P["Unlockable"] then
			local Str = P["Trap"].."_Unlock"
			local Num = Ply_SelectLvl(ply:SteamID(),Str)
			txt = txt..Num
		end
		local Str = P["Trap"].."_Cooldown"
		local Num = Ply_SelectLvl(ply:SteamID(),Str)
		xtx = xtx..Num
	end
	ply.Unlocks = string.ToTable(txt)
	ply.Unlocks[6] = tonumber(ply.Unlocks[6])
	ply.Unlocks[5] = tonumber(ply.Unlocks[5])
	ply.Unlocks[4] = tonumber(ply.Unlocks[4])
	ply.Unlocks[3] = tonumber(ply.Unlocks[3])
	ply.Unlocks[2] = tonumber(ply.Unlocks[2])
	ply.Unlocks[1] = tonumber(ply.Unlocks[1])
	ply.Cooldowns = string.ToTable(xtx)
	ply.Cooldowns[6] = tonumber(ply.Cooldowns[6])
	ply.Cooldowns[5] = tonumber(ply.Cooldowns[5])
	ply.Cooldowns[4] = tonumber(ply.Cooldowns[4])
	ply.Cooldowns[3] = tonumber(ply.Cooldowns[3])
	ply.Cooldowns[2] = tonumber(ply.Cooldowns[2])
	ply.Cooldowns[1] = tonumber(ply.Cooldowns[1])
	umsg.Start("TrapUnlocks&Cooldowns",ply)
		umsg.String(txt)
		umsg.String(xtx)
		if Ply_SelectDosh(ply:SteamID(),"Tokens_Cooldown") > 0 then
			umsg.Bool(true)
		end
	umsg.End()
end

function GM:Think()
	if #player.GetAll() > 0 and Connect and ((DB and DB:status() ~= 0) or not DB) then
		Connect = false
		DB_Connect()
		timer.Simple(1,function() Connect = true end)
	end
	if not SinglePlayer() and DB:status() == 0 and not GetGlobalBool("MySQL") then
		SetGlobalBool("MySQL",true)
	end
	if GetGlobalBool("Lobby") then
		local Playa = #team.GetPlayers(1) + #team.GetPlayers(2)
		if #Ready == Playa and Playa >= 2 and not timer.IsTimer("StartingUp") then
			timer.Create("StartingUp",1,0,function()
				if #Ready < Playa then return end
				SetGlobalInt("Starting",GetGlobalInt("Starting") - 1)
				if GetGlobalInt("Starting") < 10 then
					ShoutIt(GetGlobalInt("Starting").."...")
				end
				if GetGlobalInt("Starting") == 1 and #team.GetPlayers(2) > 0 then
					for I,P in pairs(team.GetPlayers(2)) do
						P:SetTeam(1)
					end
				end
			end)
		elseif #Ready < Playa then
			SetGlobalInt("Starting",10)
		elseif GetGlobalInt("Starting") <= 0 then
			timer.Remove("StartingUp")
			SetGlobalBool("Lobby",false)
			Start()
		end
	end
	if not GetGlobalBool("Lobby") then
		for I,P in pairs(team.GetPlayers(1)) do
			if P:Health() > 0 then
				P:FatigueCheck()
				P:MovementCheck()
			end
		end
	end
end

function InitStats()
	Ready = {}
	for I,P in pairs(team.GetPlayers(2)) do
		P:SetFrags(0)
		P.TrapsSpawnd = 0
		P.TrapsRemovd = 0
		P.CooldownsOff = nil
		P.DmgExp = 0
		P.OldExp = P:GetExp()
		P:SetNWBool("Ready",false)
		if not P:IsBot() then
			P:SetNWInt("FlareR",Ply_Select(P:SteamID(),"FlareR"))
			P:SetNWInt("FlareG",Ply_Select(P:SteamID(),"FlareG"))
			P:SetNWInt("FlareB",Ply_Select(P:SteamID(),"FlareB"))
		end
		if P.Rag then
			P.Rag:Remove()
			P.Rag = nil
		end
	end
	for I,P in pairs(team.GetPlayers(1)) do
		if not P:IsBot() then
			for i,U in pairs(ScavUpgrades) do
				local Lvl = Ply_SelectLvl(P:SteamID(),U["Var"])
				local Data = GetData(U["Class"],U["Var"],Lvl)
				P[U["Var"]] = Data
			end
			P.OldExp = P:GetExp()
			P.FlareR = Ply_Select(P:SteamID(),"FlareR")
			P.FlareG = Ply_Select(P:SteamID(),"FlareG")
			P.FlareB = Ply_Select(P:SteamID(),"FlareB")
			P:SetNWInt("MaxHealth",GetData("Scavenger","MaxHealth",Ply_SelectLvl(P:SteamID(),"MaxHealth")))
		end
		P.Respawned = nil
		P.Jumped = 0
		P.DistTraveld = 0
		P.Pinged = 0
		P.PingedAmount = 0
		P.Defused = 0
		P.DamageTaken = 0
		P.Triggered = 0
		P:SetFatigue(0)
		P:SetFrags(0)
		P:SetNWString("Healing",0)
		P:SetNWBool("Medkit",false)
		P:SetNWBool("Ready",false)
		if GetPlyArtStat(P) then
			P:SetNWBool("Arti",false)
			P:SetNWBool("FakeArti",false)
		end
		if P:GetNWBool("Poisoned") then
			P:SetNWBool("Poisoned",false)
		end
		if P.Rag then
			P.Rag:Remove()
			P.Rag = nil
		end
	end
end

function Start()
	local Plies = team.GetPlayers(1)
	local TrapA = math.Round(#team.GetPlayers(1) / 3)
	local Trp = {}
	local Trappers = {}
	for I,P in pairs(OldTrappers) do
		for A,B in pairs(Plies) do
			if P == B then
				table.remove(Plies,A)
				table.insert(Trp,P)
			end
		end
	end
	local TrapPref = {}
	for I,P in pairs(Plies) do
		if P.PreferTrap then
			table.insert(Plies,P)
			table.insert(TrapPref,P)
		end
	end
	for I = 1,TrapA do
		local R = math.random(1,#Plies)
		local P = Plies[R]
		table.insert(Trappers,P)
		table.remove(Plies,R)
	end
	for I,P in pairs(Plies) do
		for a,b in pairs(TrapPref) do
			if P == b then
				table.remove(Plies,I)
			end
		end
	end
	TrapPref = nil
	for I,P in pairs(Trp) do
		table.insert(Plies,P)
	end
	OldTrappers = {}
	Trp = nil
	local RadarA = math.Round(#team.GetPlayers(1) / 4)
	for I = 1,RadarA do
		local R = math.random(1,#Plies)
		local P = Plies[R]
		if P.OldRadar and #Plies > 1 then
			table.remove(Plies,R)
			local Ra = math.random(1,#Plies)
			local Pl = Plies[Ra]
			if Pl.OldRadar and #Plies > 2 then
				table.remove(Plies,Ra)
				local Ran = math.random(1,#Plies)
				local Ply = Plies[Ran]
				Ply:SetNWBool("Radar",true)
				Ply.Radar = true
				Ply.OldRadar = true
				table.remove(Plies,Ran)
				table.insert(Plies,Pl)
				table.insert(Plies,P)
			else
				Pl:SetNWBool("Radar",true)
				Pl.Radar = true
				Pl.OldRadar = true
				table.remove(Plies,Ra)
				table.insert(Plies,P)
			end
		else
			P:SetNWBool("Radar",true)
			P.Radar = true
			P.OldRadar = true
			table.remove(Plies,R)
		end
	end
	local DefA = math.Round(#team.GetPlayers(1) / 5)
	for I = 1,DefA do
		local R = math.random(1,#Plies)
		local P = Plies[R]
		if P.OldDefuser and #Plies > 1 then
			table.remove(Plies,R)
			local Ra = math.random(1,#Plies)
			local Pl = Plies[Ra]
			if Pl.OldDefuser and #Plies < 2 then
				table.remove(Plies,Ra)
				local Ran = math.random(1,#Plies)
				local Ply = Plies[Ran]
				Ply.Defuser = true
				Ply.OldDefuser = true
				Ply:SetNWBool("Defuser",true)
				table.remove(Plies,Ran)
				table.insert(Plies,Pl)
				table.insert(Plies,P)
			else
				Pl:SetNWBool("Defuser",true)
				Pl.Defuser = true
				Pl.OldDefuser = true
				table.remove(Plies,Ra)
				table.insert(Plies,P)
			end
		else
			P:SetNWBool("Defuser",true)
			P.Defuser = true
			P.OldDefuser = true
			table.remove(Plies,R)
		end
	end
	for I,P in pairs(Trappers) do
		P:SetTeam(2)
		table.insert(OldTrappers,P)
		SendTraps(P)
	end
	Trappers = {}
	InitStats()
	for I,P in pairs(player.GetAll()) do
		if P.OldRadar and not P.Radar and P:Team() == 1 then
			P.OldRadar = false
			P:SetNWBool("Radar",false)
		end
		if P.OldDefuser and not P.Defuser and P:Team() == 1 then
			P.OldDefuser = false
			P:SetNWBool("Defuser",false)
		end
		if P:Team() ~= 3 then
			P.WasPlaying = true
			if P.FirstTime2 then
				P.FirstTime2 = false
				P:ConCommand("Trappola_InitTut")
			end
			if P:GetNWBool("InLobby") then
				P:ConCommand("Trappola_CloseLobby")
			end
			P:SendLua("if ArcadePlaying and not Paused then PauseGeemu() end")
			P:Spawn()
		end
	end
	ArtifactSpawn()
	InitTraps()
	SetGlobalInt("Arties",0)
	SetGlobalInt("RoundStart",CurTime())
	SetGlobalInt("ExtraTime",0)
	SetGlobalInt("Time",600)
	SetGlobalBool("OverTime",false)
	timer.Create("Timer",1,0,function()
		SetGlobalInt("Time",GetGlobalInt("Time") - 1)
		local Time = GetGlobalInt("Time")
		if Time == 300 then
			local Arties,MaxArties = GetGlobalInt("Arties"),GetGlobalInt("MaxArties")
			local Per = math.floor((Arties / MaxArties)*1000)/10
			ShoutIt("5 minutes left!",nil,1,Per.."% of artifacts found!")
			SendSound("common/warning.wav")
		elseif Time == 120 then
			local Arties,MaxArties = GetGlobalInt("Arties"),GetGlobalInt("MaxArties")
			local Per = math.floor((Arties / MaxArties)*1000)/10
			ShoutIt("2 minutes left!",nil,1,Per.."% of artifacts found!")
			SendSound("common/warning.wav")
		elseif Time == 60 then
			local Arties,MaxArties = GetGlobalInt("Arties"),GetGlobalInt("MaxArties")
			local Per = math.floor((Arties / MaxArties)*1000)/10
			ShoutIt("One minute remaining!!",nil,1,Per.."% of artifacts found!")
			SendSound("common/warning.wav")
		elseif Time <= 10 and Time > 0 then
			ShoutIt(Time.."...")
		end
		local Pl = team.GetPlayers(1)
		local Ded = {}
		for I,P in pairs(Pl) do
			if P:Health() <= 0 then
				table.insert(Ded,P)
			end
		end
		if Time <= 0 and GetGlobalInt("ExtraTime") > 0 then
			ShoutIt("Overtime!")
			SetGlobalBool("OverTime",true)
			timer.Create("ExtraTimer",1,0,function()
				local Time = GetGlobalInt("ExtraTime") - 1
				SetGlobalInt("ExtraTime",Time)
				if Time == 120 then
					local Arties,MaxArties = GetGlobalInt("Arties"),GetGlobalInt("MaxArties")
					local Per = math.floor((Arties / MaxArties)*1000)/10
					ShoutIt("2 Minutes left of overtime!",nil,1,Per.."% of artifacts found!")
					SendSound("common/warning.wav")
				elseif Time == 60 then
					local Arties,MaxArties = GetGlobalInt("Arties"),GetGlobalInt("MaxArties")
					local Per = math.floor((Arties / MaxArties)*1000)/10
					ShoutIt("One minute remaining of overtime!!",nil,1,Per.."% of artifacts found!")
					SendSound("common/warning.wav")
				elseif Time <= 10 and Time > 0 then
					ShoutIt(Time.."...")
				end
				if #team.GetPlayers(2) <= 0 then
					RoundEnd()
				end
				local Pl = team.GetPlayers(1)
				local Ded = {}
				for I,P in pairs(Pl) do
					if P:Health() <= 0 then
						table.insert(Ded,P)
					end
				end
				if Time <= 0 or #Ded == #Pl or GetGlobalInt("Arties") == GetGlobalInt("MaxArties") then
					RoundEnd()
				end
			end)
			timer.Remove("Timer")
		elseif Time <= 0 and GetGlobalInt("ExtraTime") <= 0 then
			RoundEnd()
		end
		
		if #team.GetPlayers(2) <= 0 then
			RoundEnd()
		end
		
		if #Ded == #Pl or GetGlobalInt("Arties") == GetGlobalInt("MaxArties") then
			RoundEnd()
		end
		
	end)
end

function RoundEnd()
	if timer.IsTimer("Timer") then
		timer.Remove("Timer")
	end
	if timer.IsTimer("ExtraTimer") then
		timer.Remove("ExtraTimer")
	end
	SetGlobalBool("Lobby",true)
	SetGlobalInt("Starting",10)
	for I,P in pairs(ents.FindByClass("trap_*")) do
		P:Remove()
	end
	for I,P in pairs(ents.FindByClass("Fakewall")) do
		P:Remove()
	end
	for I,P in pairs(ents.FindByClass("prop_physics")) do
		if P:GetModel() ~= "models/combine_helicopter/helicopter_bomb01.mdl" then
			P:Remove()
		end
	end
	for I,P in pairs(team.GetPlayers(2)) do
		if P.DmgExp then
			P:AddExp(P.DmgExp)
		end
	end
	local Ded = {}
	for I,P in pairs(team.GetPlayers(1)) do
		if P:Health() <= 0 then
			table.insert(Ded,P)
		end
	end
	
	if (#Ded == #team.GetPlayers(1) or (GetGlobalInt("Time") <= 0 and GetGlobalInt("ExtraTime") <= 0) or GetGlobalInt("Arties") < GetGlobalInt("MaxArties")) or #team.GetPlayers(2) <= 0 then
		for I,P in pairs(team.GetPlayers(2)) do
			P:AddExp(150)
		end
	elseif #Ded < #team.GetPlayers(1) and (GetGlobalInt("Time") > 0 or GetGlobalInt("Extratime") > 0) and GetGlobalInt("Arties") >= GetGlobalInt("MaxArties") then
		for I,P in pairs(team.GetPlayers(1)) do
			P:AddExp(300)
		end
	end
	for I,P in pairs(player.GetAll()) do
		if P.WasPlaying then
			P.WasPlaying = false
			P.CooldownsOff = nil
			P.Respawned = nil
			P.Defuser = nil
			P.Radar = nil
			P:SetNWInt("ExpGain",P:GetExp() - P.OldExp)
			if P:Team() == 1 then
				if GetPlyArtStat(P) then
					P:SetNWBool("Arti",false)
					P:SetNWBool("FakeArti",false)
				end
				P:SetNWInt("DistanceTravelled",P.DistTraveld)
				P:SetNWInt("Jumped",P.Jumped)
				P:SetNWInt("DamageTaken",P.DamageTaken)
				P:SetNWInt("Defused",P.Defused)
				P:SetNWInt("Pinged",P.PingedAmount)
				P:SetNWInt("Triggered",P.Triggered)
				P:StripWeapons()
			elseif P:Team() == 2 then
				P:SetNWInt("TrapsSpawned",P.TrapsSpawnd)
				P:SetNWInt("TrapsRemoved",P.TrapsRemovd)
			end
		end
	end
	timer.Simple(1,function()
		umsg.Start("RoundEnd")
			umsg.Bool(true)
		umsg.End()
	end)
end

function GM:Initialize()
	SetGlobalInt("Arties",0)
	SetGlobalBool("Lobby",true)
	SetGlobalBool("OverTime",false)
	SetGlobalBool("MySQL",false)
	SetGlobalInt("Starting",10)
	SetGlobalInt("Time",0)
	SetGlobalInt("ExtraTime",0)
	SetGlobalInt("RoundStart",0)
	umsg.PoolString("Message")
	umsg.PoolString("Shout")
	Joining = {}
	OldTrappers = {}
	Ready = {}
	Players = {}
	PlayerUpgrades = {}
	PlayerDosh = {}
	OldRadars = {}
	OldDefusers = {}
	OldMedics = {}
	IDQueue = {}
	Connect = true
	InitExtract()
	CountBans()
	if not DB then
		DB_Connect()
	end
end

function InitTraps()
	for I,P in pairs(Traps) do
		if P["PlayerLocalized"] then
			for I,p in pairs(team.GetPlayers(2)) do
				p:SetNWInt(P["Trap"],0)
				p:SetNWBool(P["Trap"],false)
			end
		elseif P["Trap"] == "trap_fakewall" then
			SetGlobalInt(P["Trap"],300)
			SetGlobalInt(P["Trap"].." Start",CurTime())
			SetGlobalBool(P["Trap"],true)
			local I = 300
			timer.Create("trap_fakewall",1,0,function()
				if GetGlobalBool("Lobby") then timer.Remove("trap_fakewall") return end
				I = I - 1
				if I <= 0 then
					SetGlobalBool(P["Trap"],false)
					timer.Remove("trap_fakewall")
				end
			end)
		else
			SetGlobalInt(P["Trap"],0)
			SetGlobalBool(P["Trap"],false)
		end
	end
end

function SendSound(sound)
	umsg.Start("Sound")
		umsg.String(sound)
	umsg.End()
end

concommand.Add("Trappola_Join_Scav",function(ply)
	if IsScavenger(ply) then
		ChatIt("You can't join that team.",ply)
	else
		ply:SetTeam(1)
		if not GetGlobalBool("Lobby") then
			ply:Spectate(6)
			ply:SetHealth(0)
		end
	end
end)

concommand.Add("Trappola_Join_Spec",function(ply)
	if ply:Team() == 3 then
		ChatIt("You can't join that team.",ply)
	else
		ply:SetTeam(3)
		ply:Spawn()
		if ply:GetNWBool("Ready") then
			ply:SetNWBool("Ready",false)
			for I,P in pairs(Ready) do
				if P == ply then
					table.remove(Ready,I)
				end
			end
		end
	end
end)

concommand.Add("Trappola_SaveModel",function(ply,cmd,arg)
	if not arg[1] then return end
	local Mdl = arg[1]
	if not table.HasValue(PlayerModels,Mdl) then return end
	local Dosh = false
	local Name
	for I,P in pairs(DoshUpgs) do
		if Mdl == P["Var"] then
			Dosh = true
			Name = P["Name"]
			break
		end
	end
	if Dosh then
		if not Ply_SelectDosh(ply:SteamID(),"Models_"..Name) then
			return
		end
	end
	
	ply:SetNWString("PlayerModel",Mdl)
	if ply:Team() == 1 and not GetGlobalBool("Lobby") then
		ply:SetModel(Mdl)
	end
	DB_UpdateStrPly(ply:SteamID(),"Model",Mdl)
end)

concommand.Add("Trappola_NewTrap",function(ply,cmd,arg)
	if not arg[1] then return end
	local Trap = arg[1]
	if IsValidTrap(Trap) then
		local Trp = FindTrap(Trap)
		if Trp["Unlockable"] then
			local Unlock = Ply_SelectLvl(ply:SteamID(),Trap.."_Unlock")
			if Unlock == 1 then
				ply:SetTrap(Trap)
			end
		else
			ply:SetTrap(Trap)
		end
	end
end)

concommand.Add("Trappola_Ready",function(ply,cmd,arg)
	if not GetGlobalBool("Lobby") then return end
	if ply:GetNWBool("Ready") then
		ply:SetNWBool("Ready",false)
		local Ind
		for I,P in pairs(Ready) do
			if P == ply then
				Ind = I
				break
			end
		end
		table.remove(Ready,Ind)
	else
		ply:SetNWBool("Ready",true)
		table.insert(Ready,ply)
	end
end)

concommand.Add("Trappola_Upgrade",function(ply,cmd,arg)
	if not GetGlobalBool("Lobby") then return end
	local Var = arg[1]
	if not Var then return end
	local Lvl = Ply_SelectLvl(ply:SteamID(),Var)
	local Cost
	if string.find(Var,"_") then
		for I,P in pairs(TrapUpgrades) do
			if Var == P["Trap"].."_"..P["Var"] then
				Cost = P["Cost"] + P["CostInc"] * (Lvl - 1)
				break
			end
		end
	else
		for I,P in pairs(ScavUpgrades) do
			if Var == P["Var"] then
				Cost = P["Cost"] + P["CostInc"] * (Lvl - 1)
				break
			end
		end
	end
	if ply:GetExp() < Cost then return end
	ply:AddExp(-Cost)
	DB_UpgradeLevel(ply:SteamID(),Var,Lvl + 1)
end)

concommand.Add("Trappola_Dosh",function(ply,cmd,arg)
	if not GetGlobalBool("Lobby") then return end
	local Var = arg[1]
	if not Var then return end
	if Ply_SelectDosh(ply:SteamID(),Var) == 1 and string.Explode("_",Var)[1] == "Models" then return end
	local Cost
	for I,P in pairs(DoshUpgs) do
		if Var == P["Class"].."_"..P["Name"] then
			Cost = P["Cost"]
			break
		end
	end
	if ply:GetDosh() < Cost then return end
	local Lvl = Ply_SelectDosh(ply:SteamID(),Var)
	ply:AddDosh(-Cost)
	DB_DoshPly(ply:SteamID(),Var,Lvl + 1)
	print("Player "..ply:Name().." with the SteamID "..ply:SteamID().." bought "..Var.." with "..Cost.." dosh.")
end)

concommand.Add("Trappola_FlareColor",function(ply,cmd,arg)
	if not arg[1] or not arg[2] or not arg[3] then return end
	if arg[1] == 0 and arg[2] == 0 and arg[3] == 0 then return end
	DB_UpdateIndPly(ply:SteamID(),"FlareR",arg[1])
	DB_UpdateIndPly(ply:SteamID(),"FlareG",arg[2])
	DB_UpdateIndPly(ply:SteamID(),"FlareB",arg[3])
end)

concommand.Add("Trappola_PreferTrap",function(ply,cmd,arg)
	ply.PreferTrap = arg[1]
end)

concommand.Add("Trappola_DisableCooldown",function(ply,cmd,arg)
	local Tokens = Ply_SelectDosh(ply:SteamID(),"Tokens_Cooldown")
	if Tokens <= 0 then return end
	if ply.CooldownsOff then return end
	if not arg[1] then return end
	local Trap = arg[1]
	if Trap == "trap_fakeartifact" or Trap == "trap_fakewall" then return end
	DB_DoshPly(ply:SteamID(),"Tokens_Cooldown",Tokens - 1)
	ply.CooldownsOff = Trap
	ChatIt("WARNING!! "..ply:Name().." used a cooldown token")
end)

concommand.Add("Trappola_Respawn",function(ply,cmd,arg)
	local Tokens = Ply_SelectDosh(ply:SteamID(),"Tokens_Respawn")
	if Tokens <= 0 or ply.Respawned then return end
	if GetGlobalBool("Lobby") or ply:Health() > 0 or ply:Team() ~= 1 then return end
	DB_DoshPly(ply:SteamID(),"Tokens_Respawn",Tokens - 1)
	ply:Spawn()
	ply.Respawned = true
	ChatIt(ply:Name().." used a respawn token")
end)

concommand.Add("Trappola_Hat",function(ply,cmd,arg)
	local Mdl,Name = arg[1],arg[2]
	if not Mdl or not Name then return end
	if Ply_SelectDosh(ply:SteamID(),"Hats_"..Name) <= 0 then return end
	ply.HatMdl = Mdl
	ply.HatName = Name
	DB_UpdateStrPly(ply:SteamID(),"LastUsedHat",Name)
end)