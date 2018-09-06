local Meta = FindMetaTable("Player")

function Meta:AddFatigue(Int)
	self.Fatigue = math.Clamp(self.Fatigue + Int,0,self.Endurance)
end
	
function Meta:SetFatigue(Int)
	self.Fatigue = Int
end

function Meta:FatigueCheck()
	local ply = self
	if not ply.OldFat then
		ply.OldFat = ply:GetFatigue()
	end
	local Fat = ply:GetFatigue()
	if ply.OldFat ~= Fat then
		ply.OldFat = Fat
		if ply.Fatigued then
			if Fat <= self.Endurance / 2 then
				ply:SetRunSpeed(200)
				ply:SetWalkSpeed(200)
			elseif Fat > self.Endurance / 2 then
				ply:SetRunSpeed(200 * 0.75)
				ply:SetWalkSpeed(200 * 0.75)
			end
		else
			if Fat <= self.Endurance / 2 then
				ply:SetRunSpeed(400)
				ply:SetWalkSpeed(200)
			elseif Fat > self.Endurance / 2 then
				ply:SetRunSpeed(400 * 0.75)
				ply:SetWalkSpeed(200 * 0.75)
			end
		end
	end
end

function Meta:MovementCheck()
	if not self or not self:IsValid() then return end
	local P = self
	if (P:KeyDown(IN_FORWARD) or P:KeyDown(IN_BACK) or P:KeyDown(IN_MOVELEFT) or P:KeyDown(IN_MOVERIGHT)) and not timer.IsTimer("DistanceCheck - "..P:Name()) then
		timer.Remove("FatigueDecrease - "..P:Name())
		timer.Create("DistanceCheck - "..P:Name(),0.1,0,function(Name)
			if GetGlobalBool("Lobby") or not P or not P:IsValid() or P:Health() <= 0 then timer.Remove("DistanceCheck - "..Name) return end
			if not P.OldPos then
				P.OldPos = P:GetPos()
			end
			if P.OldPos ~= P:GetPos() then
				P.DistTraveld = P.DistTraveld + P:GetPos():Distance(P.OldPos)*2.54
				P.OldPos = P:GetPos()
			end
			if P:KeyDown(IN_SPEED) and P:GetRunSpeed() > P:GetWalkSpeed() and not P.Fatigued then
				P:AddFatigue(0.1)
				if P:KeyPressed(IN_JUMP) then
					P:AddFatigue(2)
				end
				if P:GetFatigue() >= P.Endurance then
					P:SetRunSpeed(P:GetWalkSpeed())
					P.Fatigued = true
				end
			else
				if P:GetFatigue() > 0 then
					P.Fatigued = true
				end
				P:AddFatigue(P.FatigueDrain)
				if P:KeyPressed(IN_JUMP) then
					P:AddFatigue(2)
				end
				if P:GetFatigue() > 0 and P:GetRunSpeed() > P:GetWalkSpeed() then
					P:SetRunSpeed(P:GetWalkSpeed())
				elseif P:GetFatigue() <= 0 and P:GetRunSpeed() == P:GetWalkSpeed() then
					P:SetRunSpeed(400)
					P.Fatigued = false
				end
			end
		end,P:Name())
	elseif not P:KeyDown(IN_FORWARD) and not P:KeyDown(IN_BACK) and not P:KeyDown(IN_MOVELEFT) and not P:KeyDown(IN_MOVERIGHT) and not timer.IsTimer("FatigueDecrease - "..P:Name()) then
		timer.Remove("DistanceCheck - "..P:Name())
		timer.Create("FatigueDecrease - "..P:Name(),0.1,0,function(Name)
			if GetGlobalBool("Lobby") or not P or not P:IsValid() or P:Health() <= 0 then timer.Remove("FatigueDecrease - "..Name) return end
			P:AddFatigue(-0.5)
		end,P:Name())
	end
end

function GM:CanPlayerSuicide(ply)
	if ply:Team() ~= 1 then
		return false
	end
	return true
end

function GM:PlayerNoClip()
	return false
end

function GM:PlayerInitialSpawn(ply)
	umsg.Start("Lobby",ply)
		local Tab = gatekeeper.GetNumClients()
		umsg.Short(Tab.total)
	umsg.End()
	ply:SetTeam(3)
	ply:Spectate(6)
	ply:SetNWBool("InLobby",true)
	ply:SetNWBool("Ready",false)
	ply:SetFatigue(0)
	ply:SetTrap("")
	ply.PreferTrap = false
	ply.FirstTime3 = true
	ply.FirstTime4 = true
	for I,P in pairs(Joining) do
		if P == ply:Name() then
			Joining[I] = nil
		end
	end
	local People = RecipientFilter()
	for I,P in pairs(player.GetAll()) do
		if P ~= ply then
			People:AddPlayer(P)
		end
	end
	umsg.Start("Auth",People)
		umsg.String(ply:Name())
	umsg.End()
	if timer.IsTimer("Checking for "..ply:Name()) then
		timer.Remove("Checking for "..ply:Name())
	end
	if #Joining > 0 then
		for I,P in pairs(Joining) do
			umsg.Start("Joining",ply)
				umsg.Bool(true)
				umsg.Bool(false)
				umsg.String(P)
				local Tab = gatekeeper.GetNumClients()
				umsg.Short(Tab.total)
			umsg.End()
		end
	end
end

function GM:PlayerConnect(ply,ip)
	if not DB then
		DB_Connect()
	end
	local function Stuph()
		if DB:status() ~= 0 then
			DB_Connect()
			timer.Simple(1,Stuph)
		else
			DB_SelectIDs()
		end
	end
	timer.Simple(1,Stuph)
	if table.HasValue(Joining,ply) then return end
	table.insert(Joining,ply)
	umsg.Start("Joining")
		umsg.Bool(true)
		umsg.Bool(true)
		umsg.String(ply)
		local Tab = gatekeeper.GetNumClients()
		umsg.Short(Tab.total)
	umsg.End()
	timer.Create("Checking for "..ply,1,0,function()
		if gatekeeper.GetNumClients().spawning < #Joining then
			for I,P in pairs(Joining) do 
				if P == ply then 
					table.remove(Joining,I)
					umsg.Start("Joining")
						umsg.Bool(false)
						umsg.Bool(false)
						umsg.String(P)
						local Tab = gatekeeper.GetNumClients()
						umsg.Short(Tab.total)
					umsg.End()
					timer.Remove("Checking for "..ply)
				end 
			end
		end
	end)
end

function GM:PlayerAuthed(ply,steamid)
	if SinglePlayer() then ply:SetPrivilege(2) end
	ply:SetNWBool("MySQL",false)
	local Reason,Time = CheckBan(steamid,ply:IPAddress(),ply:Name())
	if Time then
		ChatIt(ply:Name().." is banned from the server.")
		gatekeeper.Drop(ply:UserID(),Format("You are banned because %s! Your ban ends in %s minutes.",Reason,Time))
		return
	end
	if not IDs then table.insert(IDQueue,{ply,steamid}) DB_SelectIDs() return end
	local ID = Ply_Check(steamid)
	if ID then
		ply:SetPrivilege(tonumber(ID.Privilege))
		ply:SetNWString("PlayerModel",ID.Model)
		ply:SetExp(tonumber(ID.Experience))
		umsg.Start("FlareColors",ply)
			umsg.Short(tonumber(ID.FlareR))
			umsg.Short(tonumber(ID.FlareG))
			umsg.Short(tonumber(ID.FlareB))
		umsg.End()
		if ID.Name == "" or ID.Name ~= ply:Name() then
			DB_UpdateStrPly(steamid,"Name",ply:Name())
		end
	else
		DB_CreatePly(steamid,ply:Name())
		ply.FirstTime1 = true
		ply.FirstTime2 = true
		ply:SetPrivilege(0)
		ply:SetNWString("PlayerModel","models/player/kleiner.mdl")
		ply:SetExp(0)
		umsg.Start("FlareColors",ply)
			umsg.Short(255)
			umsg.Short(255)
			umsg.Short(255)
		umsg.End()
	end
end

function GM:PlayerSpawn(ply)
	if ply.Hat then ply.Hat:Remove() end
	ply:SetNWBool("Poisoned",false)
	if GetGlobalBool("Lobby") then
		ply:Spectate(6)
		ply:Give("weapon_crowbar")
	else
		ply:StripWeapons()
		ply:StripAmmo()
		if ply:Team() == 2 or ply:Team() == 3 then
			ply:Spectate(OBS_MODE_ROAMING)
		elseif IsScavenger(ply) then
			if ply.Rag then
				ply.Rag:Remove()
				ply.Rag = nil
			end
			ply:UnSpectate()
			ply:SetRunSpeed(400)
			ply:SetWalkSpeed(200)
			ply:SetJumpPower(150)
			ply:SetFatigue(0)
			ply:SetHealth(ply.MaxHealth)
			ply:SetNWBool("Arti",false)
			ply:SetNWBool("FakeArti",false)
			if ply:IsBot() then
				ply:SetModel("models/player/kleiner.mdl")
				ply:SetHealth(100)
				ply:SetNWBool("Medkit",true)
				local Hat = ents.Create("Base_hat")
				local Name = ply:EntIndex()
				Hat:SetOwner(ply)
				Hat:SetParent(ply)
				Hat:Spawn()
				local Hats = {}
				for I,P in pairs(DoshUpgs) do
					if P["Class"] == "Hats" then
						table.insert(Hats,P["Var"])
					end
				end
				Hat.Mdl = table.Random(Hats)
				Hat:Activate()
				if Hat.Mdl == "models/Gibs/HGIBS.mdl" then
					local Att = ply:GetAttachment(ply:LookupAttachment("eyes"))
					local Ang = Att.Ang
					local Temp = Ang.r
					Ang.r = Ang.p + 180
					Ang.p = ((Temp - 90) * - 1) - 10
					Hat:SetAngles(Ang)
					local Pos = Att.Pos
					Hat:SetPos(Pos)
				end
				ply.Hat = Hat
				Hats = nil
			else
				ply:SetModel(ply:GetNWString("PlayerModel"))
				ply:Give("Flare")
				ply:Give("MedKit")
				ply:SetNWBool("Medkit",true)
				local Hat = Ply_Select(ply:SteamID(),"LastUsedHat")
				if Hat or ply.HatName then
					if not (ply.HatName and Hat ~= ply.HatName) then
						ply.HatName = Hat
						for I,P in pairs(DoshUpgs) do
							if P["Class"] == "Hats" and P["Name"] == Hat then
								ply.HatMdl = P["Var"]
							end
						end
					end
					if ply.HatName and Ply_SelectDosh(ply:SteamID(),"Hats_"..ply.HatName) > 0 then
						local Hat = ents.Create("Base_hat")
						Hat:SetOwner(ply)
						Hat:SetParent(ply)
						Hat:Spawn()
						Hat.Mdl = ply.HatMdl
						Hat:Activate()
						if HatName == "Skull" then
							local Att = ply:GetAttachment(ply:LookupAttachment("eyes"))
							local Ang = Att.Ang
							local Temp = Ang.r
							Ang.r = Ang.p + 180
							Ang.p = ((Temp - 90) * - 1) - 10
							Hat:SetAngles(Ang)
							local Pos = Att.Pos
							Hat:SetPos(Pos)
						end
						ply.Hat = Hat
					end
				end
			end
			if ply.Radar then
				ply:Give("TrapRadar")
			end
			if ply.Defuser then
				ply:Give("TrapDefuser")
			end
			if SinglePlayer() then
				ply:Give("TrapRadar")
				ply:Give("TrapDefuser")
				ply:Give("MedKit")
			end
		end
	end
end

local function SendDeath(ply,atk,inf)
	umsg.Start("Death")
		umsg.String(ply:Name())
		umsg.Short(ply:Team())
		if atk:IsPlayer() then
			umsg.String(atk:Name())
			umsg.Short(atk:Team())
			if atk == inf then
				umsg.String("Fake artifact")
			else
				local Trap = FindTrap(inf:GetClass())
				umsg.String(Trap["Trap name"])
			end
		else
			umsg.String("World")
			umsg.Short(0)
		end
	umsg.End()
end

function GM:PlayerDeath(ply, inf, Killer)
	if ply:Team() != 1 or GetGlobalBool("Lobby") then ply:Spectate(OBS_MODE_ROAMING) return end
	SendDeath(ply,Killer,inf)
	if ply:GetNWBool("Arti") then
		local Prop = ents.Create("Artifact")
		Prop:SetPos(ply:GetPos() + Vector(0,0,20))
		Prop:Spawn()
		ply:SetNWBool("Arti",false)
		if ply.ArtiPinger then
			ply.ArtiPinger = nil
		end
	elseif ply:GetNWBool("FakeArti") then
		local Prop = ents.Create("trap_fakeartifact")
		Prop:SetPos(ply:GetPos() + Vector(0,0,20))
		Prop:Spawn()
		ply:SetNWBool("FakeArti",false)
	end
	ply:SetNWInt("DamageTaken",ply.DamageTaken)
	ply:SetNWInt("DeathTime",CurTime())
	if Killer:IsPlayer() and Killer ~= ply and Killer:Team() == 2 then
		Killer:AddExp(100)
		DB_UpdateAddIndPly(Killer:SteamID(),"Kills",1)
	elseif Killer == ply then
		local ExpGain = ply:GetExp() - ply.OldExp
		ExpGain = ExpGain * 0.75
		ply:AddExp(-ExpGain)
	end
	DB_UpdateAddIndPly(ply:SteamID(),"Deaths",1)
	ply:StripWeapons()
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(ply.Rag)
	timer.Simple(2,function()
		ply:Spectate(OBS_MODE_ROAMING)
	end)
	if Ply_SelectDosh(ply:SteamID(),"Tokens_Respawn") > 0 then
		local Plies = team.GetPlayers(1)
		local Dead = 0
		for I,P in pairs(Plies) do
			if P:Health() <= 0 then
				Dead = Dead + 1
			end
		end
		if Dead < #Plies then
			umsg.Start("Respawn",ply)
				umsg.Bool(true)
			umsg.End()
		end
	end
end

function GM:DoPlayerDeath( ply, attacker, dmginfo )
	local Rag = ents.Create("prop_ragdoll")
	Rag:SetModel(ply:GetModel())
	Rag:SetPos(ply:GetPos())
	Rag:SetAngles(ply:GetAngles())
	Rag:Spawn()
	Rag:Activate()
	local num = Rag:GetPhysicsObjectCount() - 1
	local Vel = ply:GetVelocity()
	for I = 1,num do
		local Bone = Rag:GetPhysicsObjectNum(I)
		if ValidEntity(Bone) then
            local BonePos,BoneAng = ply:GetBonePosition(Rag:TranslatePhysBoneToBone(I))
            if BonePos and BoneAng then
               Bone:SetPos(BonePos)
               Bone:SetAngle(BoneAng)
            end
			Bone:SetVelocity(Vel)
		end
	end
	Rag:SetOwner(ply)
	ply.Rag = Rag
	ply:AddDeaths( 1 )
	if attacker:IsValid() and attacker:IsPlayer() then
		if attacker ~= ply then
			attacker:AddFrags( 1 )
		end
	end
end

function GM:PlayerDeathThink(ply)
end

function GM:PlayerDisconnected(ply)
	Ply_Remove(ply:SteamID())
	if ply.Rag then
		ply.Rag:Remove()
	end
	local Name = ply:Name()
	timer.Simple(0,function()
		umsg.Start("Disconnected")
			umsg.String(Name)
			local Tab = gatekeeper.GetNumClients()
			umsg.Short(Tab.total)
		umsg.End()
	end)
	for I,P in pairs(Ready) do
		if P == ply then
			table.remove(Ready,I)
			break
		end
	end
	if Owner == ply then
		Owner = nil
	end
end