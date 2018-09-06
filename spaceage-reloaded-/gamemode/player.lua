include("player_ext.lua")
include("player_sb.lua")
include("player_ban.lua")

util.AddNetworkString("PlayerSurv")

function GM:EntityTakeDamage(Targ,dmginfo)
	if Targ:IsPlayer() and IsOwner(Targ) then
		dmginfo:ScaleDamage(0)
		return dmginfo
	end
	return dmginfo
end

function GM:PlayerSpawn(ply)
	if IsValid(ply.Planet) and ply.Planet ~= Earth then ply.Planet:RemoveEnt(ply) end
	Earth:AddEnt(ply)
	self.BaseClass.PlayerSpawn(self,ply)
	net.Start("PlayerSurv")
		net.WriteUInt(ply.Oxy,8)
		net.WriteUInt(ply.Ice,8)
		net.WriteUInt(ply.Steam,8)
		if ply.Planet then
			net.WriteInt(ply.Planet.Temperature,16)
			net.WriteFloat(ply.Planet.Pressure)
		else
			net.WriteInt(-100,16)
			net.WriteFloat(0)
		end
		net.WriteBit(true)
	net.Send(ply)
	DoAtmo(ply)
	
	if ply.Godded then
		ply:GodEnable()
	end
end

NEWS = {}

function GM:PlayerAuthed(ply)
	ply.Joined = CurTime()
	ply:SetNWInt("Joined",ply.Joined)
	//ply:SetTeam(1)
	//local ID = FormatSteamID(ply:SteamID())
	/*if not file.Exists("Players/"..ID..".txt","DATA") then
		MakeNewPlayerInfo(ply)
		//local Str = SavePlayerInfo(ply)
		//file.Write("Players/"..ID..".txt",Str)
	else*/
	if game.SinglePlayer() then
		MakeNewPlayerInfo(ply)
	end
	GetPlayerInfo(ply)
	//end
	
	for I,P in pairs(ents.GetAll()) do
		if P.SteamID and P.SteamID == ply:SteamID() then
			P.SteamID = nil
			P:SetNWOwner(ply)
			ply:AddCount(P:GetClass(),P)
		end
	end
	
	for I,P in pairs(NEWS) do
		SendNews(P,ply)
	end
	
	/*
	ChatIt("Welcome to the server, "..ply:Name(),ply)
	
	for I,P in pairs(player.GetAll()) do
		if P ~= ply then
			ChatIt(ply:Name().." has finished connecting to the server!",P)
		end
	end*/
	
	timer.Simple(1,function()
		PlayerJoinLeave(ply,nil,PLAYER_AUTH)
	end)
end

util.AddNetworkString("SA_News")
util.AddNetworkString("PlayerJoined")

function GM:PlayerInitialSpawn(ply)
	if not ply.Joined then ply.Joined = CurTime() end
	net.Start("PlayerJoined")
		net.WriteString(tostring(ply.Joined))
		net.WriteString(tostring(ply.TimedPlayed))
	net.Send(ply)
	
	ply.Pliers = {}
	
	for I,P in pairs(player.GetAll()) do
		P.Pliers[ply:SteamID()] = table.Copy(DEFAULT_PP)
		ply.Pliers[P:SteamID()] = table.Copy(DEFAULT_PP)
	end
	DoAtmo(ply)
end

function GM:PlayerConnect(ply)
end

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect","PlayerDisconnected",function(data)
	PlayerJoinLeave(data.name,data.networkid,PLAYER_DISC,data.reason)
	//ChatIt(data.name.." has disconnected from the server!")
	//ChatIt("Reason: "..data.reason)
end)

function GM:PlayerDisconnected(ply)
	if timer.Exists("PlayerTimer #"..ply:EntIndex()) then timer.Destroy("PlayerTimer #"..ply:EntIndex()) end
	
	local Time = CurTime() - ply.Joined
	
	local Name = ply:Name()
	local SteamID = ply:SteamID()
	
	/*
	local ID = FormatSteamID(SteamID)
	local Str = SavePlayerInfo(ply)
	file.Write("Players/"..ID..".txt",Str)
	*/
	DB_UpdatePlayer("Timeplayed",math.floor(ply.TimePlayed + (CurTime() - ply.Joined)),ply:SteamID())
	
	local Props = false
	for I,P in pairs(ents.GetAll()) do
		if P:GetNWEntity("Owner") == ply then
			Props = true
			P.SteamID = SteamID
			P:SetNWEntity("Owner",ents.GetAll()[1])
		end
	end
	
	if not Props then return end
	timer.Simple(300,function()
		local Found = false
		for I,P in pairs(player.GetAll()) do
			if P:SteamID() == SteamID then
				Found = true
				for i,E in pairs(ents.GetAll()) do
					if E.SteamID and E.SteamID == SteamID and E:GetNWEntity("Owner") ~= P then
						E.SteamID = nil
						E:SetNWOwner(P)
						P:AddCount(E:GetClass(),E)
					end
				end
				break
			end
		end
		
		if not Found then
			for I,P in pairs(ents.GetAll()) do
				if P.SteamID and P.SteamID == SteamID then
					P:Remove()
				end
			end
			ChatIt("All of "..Name.."'s props have been removed!")
		end
	end)
end

util.AddNetworkString("SA_IsAFK")
util.AddNetworkString("SA_CL_Run")

net.Receive("SA_IsAFK",function(len,ply)
	local IsAFK = net.ReadBit() == 1
	ply:SetAFK(IsAFK)
end)

net.Receive("SA_CL_Run",function(len,ply)
	local Str = net.ReadString()
	if IsOwner(ply) then
		ply:SendLua(Str)
	else
		print(ply:Name().." wanted to run the following script: \n"..Str)
		LogCL(ply,Str)
		if  string.find(Str,"net") or 
			string.find(Str,"umsg") or
			string.find(Str,"RunString") or
			string.find(Str,"Compile") then
			ply:SendLua("print('Restricted script detected!')")
		else
			ply:SendLua(Str)
		end
	end
end)

local function PlayerTimer(ply)
	if ply:GetObserverMode() ~= OBS_MODE_NONE then return end
	if timer.Exists("SpacePly #"..ply:EntIndex()) then return end
	if ply:Alive() and not ply:GetNWBool("AFK") then
		if not IsValid(ply.Planet) or not ply.Planet:IsBreathable() then
			if IsValid(ply:GetVehicle()) and ply:GetVehicle().sa_activated then ply:GetVehicle():Think()
			elseif ply.Seat and ply.Seat.sa_activated then ply.Seat:Think() end
			ply.NotInDanger = false
			local Dying = false
			local SendInfo = false
			if not ply.Planet then		// SPACE!!!!
				if ply:GetMoveType(MOVETYPE_NOCLIP) and not ply:GetNWBool("GravityGot") and not IsOwner(ply) then ply:SetMoveType(MOVETYPE_WALK) end
				if ply.Steam > 0 and not ply.HeatGot then
					ply.Steam = math.Clamp(ply.Steam - 1,0,200)
					ply.Ice = ply.Ice + 1
					SendInfo = true
				end
				
				if not ply.OxyGot then 
					ply.Oxy = math.Clamp(ply.Oxy - 1,0,100) 
					SendInfo = true
				end
				
				if (not ply.OxyGot and ply.Oxy == 0) or (ply.Steam == 0 and not ply.HeatGot) then
					if ply.Oxy == 0 and not ply.OxyGot then
						ply:EmitSound("player/pl_drown"..math.random(1,3)..".wav",100,100)
						timer.Create("SpacePly #"..ply:EntIndex(),0,0.2,function()
							if not ply:Alive() or ply:GetNWBool("AFK") then timer.Destroy("SpacePly #"..ply:EntIndex()) return end
							if not IsValid(ply.Planet) and ply.Oxy == 0 and not ply.OxyGot then
								ply:TakeDamage(2)
								ply:EmitSound("player/pl_drown"..math.random(1,3)..".wav",100,math.random(100,255))
							else
								timer.Destroy("SpacePly #"..ply:EntIndex())
							end
						end)
					elseif ply.Steam == 0 and not ply.HeatGot then
						ply:EmitSound("player/pl_burnpain"..math.random(1,3)..".wav",100,100)
					end
					Dying = true
				end
			else
				if ply.Planet.Temperature > TEMP_MAX and not ply.IceGot then
					if ply.Ice > 0 then
						ply.Ice = math.Clamp(ply.Ice - 1,0,200)
						ply.Steam = ply.Steam + 1
						SendInfo = true
					else
						ply:EmitSound("player/pl_burnpain"..math.random(1,3)..".wav",100,100)
						Dying = true
					end
				elseif ply.Planet.Temperature < TEMP_MIN and not ply.HeatGot then
					if ply.Steam > 0 then
						ply.Steam = math.Clamp(ply.Steam - 1,0,200)
						ply.Ice = ply.Ice + 1
						SendInfo = true
					else
						ply:EmitSound("player/pl_burnpain"..math.random(1,3)..".wav",100,100)
						Dying = true
					end
				end
				
				if not ply.OxyGot then
					if (ply.Planet.Atmosphere.Oxygen and (ply.Planet.Atmosphere.Oxygen < 15 or ply.Planet.Atmosphere.Oxygen > 25)) or not ply.Planet.Atmosphere.Oxygen or ply.Planet.Pressure < 0.8 or ply.Planet.Pressure > 1.2 then
						if ply.Oxy > 0 then
							ply.Oxy = math.Clamp(ply.Oxy - 1,0,100)
							SendInfo = true
						else
							ply:EmitSound("player/pl_drown"..math.random(1,3)..".wav",100,100)
							Dying = true
						end
					end
				end
			end
			
			if Dying then
				ply:TakeDamage(10)
			end
			
			if ply.OxyGot then
				if not IsValid(ply.OxyGot) or ply:GetPos():Distance(ply.OxyGot:GetPos()) > 1024 or not ply.OxyGot.Online then ply.OxyGot = nil end
			end
			
			if ply.HeatGot then
				if not IsValid(ply.HeatGot) or ply:GetPos():Distance(ply.HeatGot:GetPos()) > 1024 or not ply.HeatGot.Online then ply.HeatGot = nil end
			end
			
			if ply.IceGot then
				if not IsValid(ply.IceGot) or ply:GetPos():Distance(ply.IceGot:GetPos()) > 1024 or not ply.IceGot.Online then ply.IceGot = nil end
			end
			
			if SendInfo or (ply.Planet and (ply.Planet.Temperature ~= ply.Temp or ply.Planet.Pressure ~= ply.Pres)) or (not ply.Planet and (ply.Temp ~= -100 or ply.Pres ~= 0)) or ply.SentDanger ~= ply.NotInDanger then
				net.Start("PlayerSurv")
					net.WriteUInt(ply.Oxy,8)
					net.WriteUInt(ply.Ice,8)
					net.WriteUInt(ply.Steam,8)
					if ply.Planet then
						net.WriteInt(ply.Planet.Temperature,16)
						net.WriteFloat(ply.Planet.Pressure)
					else
						net.WriteInt(-100,16)
						net.WriteFloat(0)
					end
					net.WriteBit(false)
				net.Send(ply)
				
				ply.SentDanger = ply.NotInDanger
				if ply.Planet then
					ply.Temp = ply.Planet.Temperature
					ply.Pres = ply.Planet.Pressure
				else
					ply.Temp = -100
					ply.Pres = 0
				end
			end
		elseif not ply.NotInDanger then
			ply.NotInDanger = true
			ply.SentDanger = ply.NotInDanger
			net.Start("PlayerSurv")
				net.WriteUInt(ply.Oxy,8)
				net.WriteUInt(ply.Ice,8)
				net.WriteUInt(ply.Steam,8)
				net.WriteInt(ply.Planet.Temperature,16)
				net.WriteFloat(ply.Planet.Pressure)
				net.WriteBit(true)
			net.Send(ply)
		else
			if ply.Planet:GetClass() == "sa_planet" then
				ply.Planet:AddAtmosphere("Oxygen",-2)
				ply.Planet:AddAtmosphere("Carbon_dioxide",2)
			end
		end
	end
end

function DoAtmo(ply)
	ply.Oxy = 10
	ply.Ice = 10
	ply.Steam = 10
	ply.OxyGot = false
	ply.HeatGot = false
	ply.IceGot = false
	ply.NotInDanger = true
	ply.SentDanger = true
	if not timer.Exists("PlayerTimer #"..ply:EntIndex()) then
		timer.Create("PlayerTimer #"..ply:EntIndex(),1,0,function()
			local Success,Err = pcall(PlayerTimer,ply)
			if not Success then
				print("PlayerTimer on "..ply:Name().." failed!")
				print("Error:\n"..Err)
			end
		end)
	end
end

local Cooldown = math.random(900,1800)
local function BackUpWriter()
	for I,P in pairs(player.GetAll()) do
		if P.Joined and P.TimePlayed then
			//local ID = FormatSteamID(P:SteamID())
			//SavePlayerInfo(P)
			//file.Write("Players/"..ID..".txt",Str)
			P.TimePlayed = math.floor(P.TimePlayed + (CurTime() - P.Joined))
			DB_UpdatePlayer("Timeplayed",P.TimePlayed,P:SteamID())
			P.Joined = CurTime()
			if P.TeamSelection and P:Team() == 1 and P.TeamSelection > 0 and P.TimePlayed > P.TeamSelection then
				P:TeamSelectionMenu()
				P.TeamSelection = -1
				DB_UpdatePlayer("TeamSelection",P.TeamSelection,P:SteamID())
			end
		end
	end
	
	if CurTime() > Cooldown then
		Cooldown = CurTime() + math.random(900,1800)
		ChatIt("Spread the love and remember to join the Forums at www.sareloaded.com")
	end
end

timer.Create("BackupWriter",60,0,function()
	local Success,Err = pcall(BackUpWriter)
	if not Success then
		print("BackUpWriter errored on "..os.date().." with the error:\n"..Err)
	end
	
end)