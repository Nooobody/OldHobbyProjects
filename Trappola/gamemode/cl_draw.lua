local a = NULL
local b = NULL
local Pings = {}
local Flares = {}

function GM:HUDPaint()
	if not SelfPly or not SelfPly:IsValid() then return end
	if IsScavenger(SelfPly) then
		DrawHUD()
	elseif SelfPly:Team() == 2 and not GetGlobalBool("Lobby") then
		DrawTrapTimes()
	end
	if #Pings > 0 then
		DrawPings()
	end
	if #Flares > 0 then
		DrawFlares()
	end
	if #Deads > 0 then
		DrawDead()
	end
	if SelfPly:GetNWInt("Healing") > 0 then
		DrawHealing(SelfPly:GetNWInt("Healing"))
	end
	if SelfPly:Health() <= 40 and SelfPly:Health() > 0 and not GetGlobalBool("Lobby") then
		DrawSkull()
	end
	if (SelfPly:Health() <= 0 or GetGlobalBool("Lobby")) and SelfPly.BreathPlaying then
		Breath:Stop()
		SelfPly.BreathPlaying = false
	end
	if (SelfPly:Health() <= 0 or GetGlobalBool("Lobby") or SelfPly:Health() > 40) and SelfPly.HeartPlaying then
		HeartBeat:Stop()
		SelfPly.HeartPlaying = false
	end
	if SelfPly:GetNWBool("Poisoned") then
		DrawPoisoned()
	end
	local Ent = SelfPly:GetEyeTrace().Entity
	if not Ent or not Ent:IsValid() then return end
	if Ent:GetClass() == "player" then
		DrawPlayer(Ent)
	elseif Ent:GetClass() == "prop_ragdoll" and Ent:GetPos():Distance(SelfPly:GetPos()) < 250 then
		DrawRagdoll(Ent)
	elseif string.find(Ent:GetClass(),"artifact") and Ent:GetPos():Distance(SelfPly:GetPos()) < 250 then
		if Ent:GetClass() == "trap_fakeartifact" and SelfPly:Team() == 2 then
			DrawTrap(Ent)
		else
			if Ent:GetNWBool("Defused") then
				DrawTrap(Ent)
			else
				DrawArti(Ent)
			end
		end
	elseif SelfPly:Team() == 2 and string.Left(Ent:GetClass(),5) == "trap_" then
		DrawTrap(Ent)
	elseif SelfPly:Team() == 1 and string.Left(Ent:GetClass(),5) == "trap_" and Ent:GetNWBool("Defused") then
		DrawTrap(Ent)
	end
end

local Time = 0
function DrawHUD()
	local Stat,Col = GetPlyStatus(SelfPly)
	draw.RoundedBoxEx(8,0,ScrH() - 80,220,80,Color(100,100,100,200),false,true,false,false)
	surface.SetDrawColor(Col)
	surface.DrawLine(220,ScrH(),220,ScrH() - 73)
	surface.DrawLine(0,ScrH() - 80,212,ScrH() - 80)
	if not a:IsValid() then
		a = vgui.Create("DPanel")
		a:SetSize(8,8)
		a:SetPos(212,ScrH() - 80)
		a.Paint = function()
			if LobbyPanel:IsVisible() then return end
			if SelfPly:Team() ~= 1 then a:Remove() return end
			local Stat,Col = GetPlyStatus(SelfPly)
			surface.DrawCircle(0,8,8,Col)
		end
	end
	draw.DrawText("Status: ","MenuLarge",20,ScrH() - 60,Color(255,255,255,255),TEXT_ALIGN_LEFT)
	draw.DrawText(Stat,"MenuLarge",20 + surface.GetTextSize("Status: "),ScrH() - 60,Col,TEXT_ALIGN_LEFT)
	if GetGlobalBool("Lobby") or SelfPly:Health() <= 0 then return end
	if GetPlyArtStat(SelfPly) then
		draw.DrawText("Carrying an artifact.","MenuLarge",20,ScrH() - 40,Color(0,255,0,255),TEXT_ALIGN_LEFT)
	end
	if BreathAllowed then
		if SelfPly:KeyDown(IN_SPEED) and SelfPly:GetVelocity():Length() > 0 and SelfPly:GetRunSpeed() > SelfPly:GetWalkSpeed() then
			if timer.IsTimer("Rest") then timer.Remove("Rest") end
			Breath:Play()
			SelfPly.BreathPlaying = true
			Time = Time + 0.05
			Breath:ChangePitch(math.Clamp(80 + Time,80,155))
		elseif SelfPly:KeyReleased(IN_SPEED) then
			Breath:Play()
			SelfPly.BreathPlaying = true
			timer.Create("Rest",0.1,0,function()
				Time = Time - 1
				Breath:ChangePitch(math.Clamp(80 + Time,80,155))
				if math.Clamp(80 + Time,80,155) == 80 or GetGlobalBool("Lobby") then
					Breath:Stop()
					SelfPly.BreathPlaying = false
					Time = 0
					timer.Remove("Rest")
				end
			end)
		end
	end
end

function DrawPoisoned()
	if GetPlyArtStat(SelfPly) then
		draw.DrawText("Poisoned!","MenuLarge",20,ScrH() - 20,Color(50,205,50,255),TEXT_ALIGN_LEFT)
	else
		draw.DrawText("Poisoned!","MenuLarge",20,ScrH() - 40,Color(50,205,50,255),TEXT_ALIGN_LEFT)
	end
	if not Time or not TTime then
		Time = 1
		TTime = 50
	end
	if Time < TTime - 1 then
		Time = Time + (TTime - Time) / 20
	elseif Time > TTime + 1 then	
		Time = Time - (Time - TTime) / 20
	elseif Time >= TTime - 1 and TTime == 50 then
		Time = TTime
		TTime = 1
	elseif Time <= TTime + 1 and TTime == 1 then
		Time = TTime
		TTime = 50
	end
	local A = 150*(Time/50)
	surface.SetDrawColor(50,205,50,A)
	surface.DrawRect(0,0,ScrW(),ScrH())
	surface.SetDrawColor(200,200,200,A)
	surface.SetTexture(surface.GetTextureID("Toxic Byproduct"))
	surface.DrawTexturedRect(0,0,ScrW(),ScrH())
end

function DrawPlayer(ply)
	draw.DrawText(ply:GetName(),"TargetID",ScrW() / 2,ScrH() / 2 - 100,Color(235,235,235,255),TEXT_ALIGN_CENTER)
	local Text,Col = GetPlyStatus(ply)
	draw.DrawText(Text,"TargetID",ScrW() / 2,ScrH() / 2 - 80,Col,TEXT_ALIGN_CENTER)
	if ply:GetNWBool("Radar") then
		draw.DrawText("Scout","TargetID",ScrW() / 2,ScrH() / 2 - 60,Color(235,235,235,255),TEXT_ALIGN_CENTER)
	elseif ply:GetNWBool("Defuser") then
		draw.DrawText("Defuser","TargetID",ScrW() / 2,ScrH() / 2 - 60,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	end
	if GetPlyArtStat(ply) then
		local X = 60
		if ply:GetNWBool("Defuser") or ply:GetNWBool("Radar") then
			X = 40
		end
		draw.DrawText("Carrying an artifact.","TargetID",ScrW() / 2,ScrH() / 2 - X,Color(0,255,0,255),TEXT_ALIGN_CENTER)
	end
end

function DrawArti(art)
	draw.DrawText("An Artifact","TargetID",ScrW() / 2,ScrH() / 2 - 100,Color(235,235,235,255),TEXT_ALIGN_CENTER)
	if IsScavenger(SelfPly) then
		if GetPlyArtStat(SelfPly) then
			draw.DrawText("You can't pick this up yet!","TargetID",ScrW() / 2,ScrH() / 2 - 80,Color(235,235,235,255),TEXT_ALIGN_CENTER)
			draw.DrawText("Press E to ping this for other scavengers.","TargetID",ScrW() / 2,ScrH() / 2 - 60,Color(235,235,235,255),TEXT_ALIGN_CENTER)
		else
			draw.DrawText("Pick it up!","TargetID",ScrW() / 2,ScrH() / 2 - 80,Color(235,235,235,255),TEXT_ALIGN_CENTER)
		end
	end
end

function DrawTrap(Trap)
	local T = FindTrap(Trap:GetClass())
	draw.DrawText(T["Trap name"],"TargetID",ScrW() / 2,ScrH() / 2 - 100,Color(235,235,235,255),TEXT_ALIGN_CENTER)
	if Trap:GetOwner() == SelfPly and Trap:GetPos():Distance(SelfPly:GetPos()) <= 500 then
		if Trap:GetNWBool("BeingRemoved") then
			draw.DrawText("Removed in "..math.Round(Trap:GetNWInt("RemovalTime")*10)/10,"TargetID",ScrW() / 2,ScrH() / 2 - 80,Color(235,235,235,255),TEXT_ALIGN_CENTER)
		elseif Trap:GetNWBool("Defused") then
			draw.DrawText("Defused, cannot be removed","TargetID",ScrW() / 2,ScrH() / 2 - 80,Color(235,235,235,255),TEXT_ALIGN_CENTER)
		else
			draw.DrawText("Hold right mouse button to remove","TargetID",ScrW() / 2,ScrH() / 2 - 80,Color(235,235,235,255),TEXT_ALIGN_CENTER)
		end
	elseif Trap:GetOwner() ~= SelfPly then
		draw.DrawText("Owner: "..Trap:GetOwner():Name(),"TargetID",ScrW() / 2,ScrH() / 2 - 80,Color(235,235,235,255),TEXT_ALIGN_CENTER)
		if Trap:GetNWBool("Defused") then
			draw.DrawText("Defused","TargetID",ScrW() / 2,ScrH() / 2 - 60,Color(235,235,235,255),TEXT_ALIGN_CENTER)
		end
	end
end

function DrawTrapTimes()
	if GetGlobalBool("Lobby") then return end
	draw.RoundedBoxEx(8,0,ScrH() - 560,250,260,Color(0,0,0,100),false,true,false,true)
	for I,P in pairs(Tims) do
		if P["PlayerLocalized"] then
			if SelfPly:GetNWBool(P["Trap"]) then
				local Trp,A = FindTrap(P["Trap"])
				local Time = GetData(P["Trap"],"Cooldown",Cooldowns[A])
				local Time = Time - (CurTime() - SelfPly:GetNWInt(P["Trap"].." Start"))
				if Time > 60 then
					draw.DrawText(P["Trap name"]..": "..math.floor(Time / 60).." minutes and "..math.ceil(Time%60).." seconds","DefaultLarge",5,ScrH() - 580 + (40 * (I - 1)),Color(255,0,0,255),TEXT_ALIGN_LEFT)
				else
					draw.DrawText(P["Trap name"]..": "..math.ceil(Time).." seconds","DefaultLarge",5,ScrH() - 580 + (40 * (I - 1)),Color(255,0,0,255),TEXT_ALIGN_LEFT)
				end
			else
				draw.DrawText(P["Trap name"]..": READY","DefaultLarge",5,ScrH() - 580 + (40 * (I - 1)),Color(0,255,0,255),TEXT_ALIGN_LEFT)
			end
		else
			if GetGlobalBool(P["Trap"]) then
				local Trp,A = FindTrap(P["Trap"])
				local Time = GetData(P["Trap"],"Cooldown",Cooldowns[A])
				local Time = Time - (CurTime() - GetGlobalInt(P["Trap"].." Start"))
				if Time > 60 then
					draw.DrawText(P["Trap name"]..": "..math.floor(Time / 60).." minutes and "..math.ceil(Time%60).." seconds","DefaultLarge",5,ScrH() - 580 + (40 * (I - 1)),Color(255,0,0,255),TEXT_ALIGN_LEFT)
				else
					draw.DrawText(P["Trap name"]..": "..math.ceil(Time).." seconds","DefaultLarge",5,ScrH() - 580 + (40 * (I - 1)),Color(255,0,0,255),TEXT_ALIGN_LEFT)
				end
			else
				draw.DrawText(P["Trap name"]..": READY","DefaultLarge",5,ScrH() - 580 + (40 * (I - 1)),Color(0,255,0,255),TEXT_ALIGN_LEFT)
			end
		end
	end
end

function DrawHealing(Int)
	local Scl = 1 - (Int / 3)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawOutlinedRect(ScrW() / 2 - 100,100,200,40)
	surface.SetDrawColor(0,255,0,255)
	surface.DrawRect(ScrW() / 2 - 90,110,180 * Scl,20)
	draw.DrawText("Getting healed by "..SelfPly:GetNWString("Healer").."...","TargetID",ScrW() / 2,80,Color(255,255,255,255),TEXT_ALIGN_CENTER)
end

function DrawRagdoll(Rag)
	if not Rag.Found then
		for I,P in pairs(team.GetPlayers(1)) do
			if Rag:GetOwner() == P then
				Rag.Ply = P
				Rag.Found = true
				break
			end
		end
	end
	local Ply = Rag.Ply
	draw.DrawText(Ply:Name().."'s ragdoll","TargetID",ScrW() / 2,ScrH() / 2 - 80,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	if not IsScavenger(SelfPly) or GetGlobalBool("Lobby") or SelfPly:Health() <= 0 then return end
	if SelfPly:GetActiveWeapon():GetPrintName() ~= "Flare" then
		draw.DrawText("Switch to flare to see what's in the body.","TargetID",ScrW() / 2,ScrH() / 2 - 60,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	else
		local Medkit = Ply:GetNWBool("Medkit")
		local Radar = Ply:GetNWBool("Radar")
		local Defuser = Ply:GetNWBool("Defuser")
		if Medkit then
			if SelfPly:GetNWBool("Medkit") then
				draw.DrawText("Has a medkit","TargetID",ScrW() / 2,ScrH() / 2 - 60,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			else
				draw.DrawText("Has a medkit, Press left mouse button to pick it up.","TargetID",ScrW() / 2,ScrH() / 2 - 60,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			end
			if SelfPly:GetNWBool("Radar") or SelfPly:GetNWBool("Defuser") then
				if Radar then
					draw.DrawText("Has a radar","TargetID",ScrW() / 2,ScrH() / 2 - 40,Color(255,255,255,255),TEXT_ALIGN_CENTER)
				elseif Defuser then
					draw.DrawText("Has a defuser","TargetID",ScrW() / 2,ScrH() / 2 - 40,Color(255,255,255,255),TEXT_ALIGN_CENTER)
				end
			else
				if Radar then
					draw.DrawText("Has a radar, Press right mouse button to pick it up.","TargetID",ScrW() / 2,ScrH() / 2 - 40,Color(255,255,255,255),TEXT_ALIGN_CENTER)
				elseif Defuser then
					draw.DrawText("Has a defuser, Press right mouse button to pick it up.","TargetID",ScrW() / 2,ScrH() / 2 - 40,Color(255,255,255,255),TEXT_ALIGN_CENTER)
				end
			end
		else
			if SelfPly:GetNWBool("Radar") or SelfPly:GetNWBool("Defuser") then
				if Radar then
					draw.DrawText("Has a radar","TargetID",ScrW() / 2,ScrH() / 2 - 60,Color(255,255,255,255),TEXT_ALIGN_CENTER)
				elseif Defuser then
					draw.DrawText("Has a defuser","TargetID",ScrW() / 2,ScrH() / 2 - 60,Color(255,255,255,255),TEXT_ALIGN_CENTER)
				end
			else
				if Radar then
					draw.DrawText("Has a radar, Press right mouse button to pick it up.","TargetID",ScrW() / 2,ScrH() / 2 - 60,Color(255,255,255,255),TEXT_ALIGN_CENTER)
				elseif Defuser then
					draw.DrawText("Has a defuser, Press right mouse button to pick it up.","TargetID",ScrW() / 2,ScrH() / 2 - 60,Color(255,255,255,255),TEXT_ALIGN_CENTER)
				end
			end
		end
	end
end

usermessage.Hook("Ping",function(U)
	local ply = U:ReadString()
	local Ent = Entity(U:ReadShort())
	table.insert(Pings,{Ent,ply,60})
	local Num = Ent:EntIndex()
	timer.Create("Ping - "..Num,1,0,function(Num,Ent)
		local Tab
		local Int
		for I,P in pairs(Pings) do
			if P[1] == Ent then
				Tab = P
				Int = I
			end
		end
		Tab[3] = Tab[3] - 1
		if Tab[3] <= 0 then
			table.remove(Pings,Int)
			timer.Remove("Ping - "..Num)
			return
		end
		if Ent and not Ent:IsValid() then
			table.remove(Pings,Int)
			timer.Remove("Ping - "..Num)
			return
		end
	end,Num,Ent)
end)

function DrawPings()
	for I,P in pairs(Pings) do
		if P[1] and P[1]:IsValid() then
			local Vec = (P[1]:GetPos() + Vector(0,0,30)):ToScreen()
			local ply = P[2]
			local Time = P[3]
			draw.DrawText("An artifact pinged by "..ply,"TargetID",Vec.x,Vec.y,Color(200,200,200,255),TEXT_ALIGN_CENTER)
			draw.DrawText("This ping disappears in "..Time.." seconds.","TargetID",Vec.x,Vec.y - 20,Color(200,200,200,255),TEXT_ALIGN_CENTER)
		end
	end
end

function DrawDead()
	for I,P in pairs(Deads) do
		local Ply,Team = P[1][1],P[1][2]
		local Atk,Atkteam = P[2][1],P[2][2]
		local Trap = P[3]
		local Time = P[4] - CurTime()
		local x = ScrW() / 2
		local y
		local A = 255
		if Time >= 1 then
			y = 100 + (20 * (Time - 1)) + (20 * (I - 1))
		elseif Time > 0 and Time < 1 then
			y = 50 + (50 * Time) + (20 * (I - 1))
			A = 255 * Time
		elseif Time <= 0 then
			table.remove(Deads,I)
		end
		if Time <= 0 then return end
		if (Ply ~= Atk and Atk ~= "World") or SinglePlayer() then
			local txt = Ply.." was killed by "..Atk.." with "..Trap
			local X = x - surface.GetTextSize(txt) / 2
			local tx = ""
			for W,S in pairs(string.Explode(" ",txt)) do
				if W == 1 then
					local Col = team.GetColor(Team)
					draw.DrawText(Ply.." ","MenuLarge",X,y,Color(Col.r,Col.g,Col.b,A),TEXT_ALIGN_LEFT)
					tx = tx..Ply.." "
				elseif W == 5 then
					local Colo = team.GetColor(Atkteam)
					draw.DrawText(Atk.." ","MenuLarge",X + surface.GetTextSize(tx),y,Color(Colo.r,Colo.g,Colo.b,A),TEXT_ALIGN_LEFT)
					tx = tx..Atk.." "
				else
					draw.DrawText(S.." ","MenuLarge",X + surface.GetTextSize(tx),y,Color(255,255,255,A),TEXT_ALIGN_LEFT)
					tx = tx..S.." "
				end
			end
		elseif Atk == "World" and Atkteam == 0 then
			local txt = " was killed by "
			local Col = team.GetColor(Team)
			draw.DrawText(Ply,"MenuLarge",x - surface.GetTextSize(txt) / 2,y,Color(Col.r,Col.g,Col.b,A),TEXT_ALIGN_RIGHT)
			draw.DrawText(txt,"MenuLarge",x,y,Color(255,255,255,A),TEXT_ALIGN_CENTER)
			draw.DrawText(Atk,"MenuLarge",x + surface.GetTextSize(txt) / 2,y,Color(255,255,255,A),TEXT_ALIGN_LEFT)
		else
			local txt = Ply.." suicided"
			local Col = team.GetColor(Team)
			draw.DrawText(txt,"MenuLarge",x,y,Color(Col.r,Col.g,Col.b,A),TEXT_ALIGN_CENTER)
		end
	end
end

local hp = 0
local A = 0
function DrawSkull()
	if hp ~= SelfPly:Health() then
		hp = SelfPly:Health()
		A = 0
		Percent = 1 - hp/40
		TA = 200*Percent
		if HeartAllowed then
			HeartBeat:Play()
			HeartBeat:ChangePitch(math.Clamp(255 * Percent,80,255))
			SelfPly.HeartPlaying = true
		end
	end
	if TA == 200*Percent then
		if A < TA - 0.1 then
			A = A + (TA - A) / math.Clamp((20 * (hp / 40)),2,20)
		elseif A >= TA - 0.1 then
			A = TA
			TA = 0
		end
	elseif TA == 0 then
		if A > TA + 0.01 then
			A = A - (A - TA) / math.Clamp((20 * (hp / 40)),2,20)
		elseif A <= TA + 0.01 and hp <= 20 then
			A = 20
			TA = 200*Percent
		end
	end
	surface.SetDrawColor(255,255,255,A)
	surface.SetTexture(surface.GetTextureID("Skull"))
	local x,y = ScrW() / 2,ScrH() / 2
	surface.DrawTexturedRect(x - 128,y - 256,256,256)
end

function DrawFlares()
	if #Flares > 0 then
		for I,P in pairs(Flares) do
			local Ply = P[1]
			if not Ply or not Ply:IsValid() or not Ply:GetActiveWeapon() or Ply:GetActiveWeapon().PrintName ~= "Flare" then table.remove(Flares,I) end
			local E,R,G,B = P[2],P[3],P[4],P[5]
			local Light = DynamicLight(E)
			if Light then
				Light.Pos = Ply:EyePos() + Ply:GetAngles():Forward() * 10 + Vector(0,0,-20)
				Light.r = R
				Light.g = G
				Light.b = B
				Light.Brightness = 1
				Light.Size = 512
				Light.Decay = 512
				Light.DieTime = CurTime() + 1
				Light.Style = 0
			end
		end
	end
end

usermessage.Hook("flare",function(u)
	local P,E = u:ReadShort(),u:ReadLong()
	local Str = string.Explode(",",u:ReadString())
	local R,G,B = Str[1],Str[2],Str[3]
	if not R and not G and not B then R,G,B = 255,255,255 end 
	table.insert(Flares,{Entity(P),E,R,G,B})
end)