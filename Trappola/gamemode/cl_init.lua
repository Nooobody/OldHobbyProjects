include("cl_mapvote.lua")
include("cl_lobby.lua")
include("cl_message.lua")
include("cl_scoreboard.lua")
include("models.lua")
include("cl_chat.lua")
include("cl_draw.lua")
include("cl_tut.lua")
include("shared.lua")
include("arcade/pong.lua")
include("arcade/alienattack.lua")
include("arcade/pacman.lua")

ChatSound = CreateClientConVar("ChatSound","1",false,false)

function GM:AddDeathNotice()
	return false
end

function GM:DrawDeathNotice()
	return false
end

function GM:HUDWeaponPickedUp()
	return false
end

function GM:HUDAmmoPickedUp()
	return false
end

function GM:HUDItemPickedUp()
	return false
end

function GM:StartChat()
	return true
end

function GM:FinishChat()
	return true
end

function GM:HUDShouldDraw(hud)
	if hud == "CHudHealth" or hud == "CHudBattery" or hud == "CHudChat" then
		return false
	end
	return true
end

function GetPlyStatus(ply)
	if GetGlobalBool("Lobby") then
		return "Spectating",Color(189,183,107,255)
	else
		local HP = ply:Health()
		if HP > 115 then
			return "Feeling inhumane!!",Color(0,150,255,255)
		elseif HP > 110 and HP <= 115 then
			return "Never felt better!",Color(0,255,255,255)
		elseif HP > 105 and HP <= 110 then
			return "In great shape!",Color(0,255,150,255)
		elseif HP > 100 and HP <= 105 then
			return "In good shape",Color(0,255,100,255)
		elseif HP == 100 then
			return "Not a scratch",Color(0,255,0,255)
		elseif HP >= 80 and HP < 100 then
			return "A pain in the arse",Color(50,255,0,255)
		elseif HP >= 60 and HP < 80 then
			return "Bruised",Color(150,255,0,255)
		elseif HP >= 40 and HP < 60 then
			return "Fractured rib",Color(255,255,0,255)
		elseif HP >= 20 and HP < 40 then
			return "Pierced Lung",Color(255,140,0,255)
		elseif HP > 0 and HP < 20 then
			return "Pushing daisies",Color(255,0,0,255)
		elseif HP <= 0 then
			return "R.I.P",Color(0,0,0,255)
		end
	end
end

function GM:KeyPress(ply,key)
	if ply:Team() == 2 and not GetGlobalBool("Lobby") then
		if key == IN_USE then
			if not Trapanel or not TrapShow then return end
			gui.EnableScreenClicker(true)
			if not Trapanel:IsVisible() then
				Trapanel:SetVisible(true)
			end
			if IsValidTrap(SelfPly:GetTrap()) and not TrapShow:IsVisible() then
				TrapShow:SetVisible(true)
			end
		elseif key == IN_ATTACK2 and string.Left(SelfPly:GetEyeTrace().Entity:GetClass(),5) ~= "trap_" then
			if #team.GetPlayers(1) > 0 then
				local x = 0
				hook.Add("PreDrawTranslucentRenderables","Rendering",function()
					x = x + 0.5
					for I,P in pairs(team.GetPlayers(1)) do
						if P:Health() > 0 then
							cam.Start3D2D(P:GetPos(),Angle(0,0,0),1)
								cam.IgnoreZ(true)
								surface.DrawCircle(0,0,x,Color(255,0,0,255 - x))
								cam.IgnoreZ(false)
							cam.End3D2D()
							cam.Start3D2D(P:GetPos(),Angle(90,0,0),1)
								cam.IgnoreZ(true)
								surface.SetDrawColor(255,0,0,255 - x)
								surface.DrawLine(0,0,-x,0)
								cam.IgnoreZ(false)
							cam.End3D2D()
						end
					end
				end)
				hook.Add("HUDPaint","NamePings",function()
					for I,P in pairs(team.GetPlayers(1)) do
						if P:Health() > 0 then
							local Pos = (P:GetPos() + Vector(0,0,80)):ToScreen()
							draw.DrawText(P:Name(),"MenuLarge",Pos.x,Pos.y,Color(255,255,255,255 - x),TEXT_ALIGN_CENTER)
						end
					end
				end)
				timer.Simple(1,function() 
					hook.Remove("PreDrawTranslucentRenderables","Rendering")
					hook.Remove("HUDPaint","NamePings")
				end)
			end
		end
	end
end

function GM:KeyRelease(ply,key)
	if not Trapanel or not TrapShow then return end
	if key == IN_USE and not GetGlobalBool("Lobby") and SelfPly:Team() == 2 then
		gui.EnableScreenClicker(false)
		Trapanel:SetVisible(false)
		TrapShow:SetVisible(false)
	end
end

local T
function GM:Think()
	SelfPly = LocalPlayer()
	if SelfPly.Flash and not GetGlobalBool("Lobby") and SelfPly:Team() == 1 and SelfPly:Health() > 0 then
		SelfPly.Flash = false
	end
	if SelfPly.Flash then
		local Light = DynamicLight(SelfPly:EntIndex())
		if Light then
			local Tr = SelfPly:GetEyeTraceNoCursor()
			local Dis = SelfPly:GetPos():Distance(Tr.HitPos)
			local Pos = SelfPly:GetPos() + SelfPly:EyeAngles():Forward() * Dis
			if Pos:Distance(SelfPly:GetPos()) > 500 then
				Pos = SelfPly:GetPos() + SelfPly:EyeAngles():Forward() * 500
			end
			if Tr.Hit then
				local Ang = Tr.HitNormal:Angle()
				Pos = Pos + Ang:Up() * 10
			end
			Light.Pos = Pos
			Light.r = 255
			Light.g = 255
			Light.b = 255
			Light.Brightness = 1
			Light.Size = 512
			Light.Decay = 512
			Light.DieTime = CurTime() + 1
			Light.Style = 0
		end
	end
	if SelfPly:Team() == 2 and not GetGlobalBool("Lobby") then
		for I,P in pairs(ents.FindByClass("trap_*")) do
			local Light = DynamicLight(P:EntIndex())
			if Light then
				Light.Pos = P:GetPos() + Vector(0,0,40)
				if P:GetOwner() == SelfPly then
					Light.r = SelfPly.FlareR
					Light.g = SelfPly.FlareG
					Light.b = SelfPly.FlareB
				else
					Light.r = P:GetOwner():GetNWInt("FlareR")
					Light.g = P:GetOwner():GetNWInt("FlareG")
					Light.b = P:GetOwner():GetNWInt("FlareB")
				end
				Light.Brightness = 1
				Light.Size = 512
				Light.Decay = 512
				Light.DieTime = CurTime() + 1
				Light.Style = 0
			end
		end
		local Tr = SelfPly:GetEyeTraceNoCursor()
		if Tr.Entity:IsValid() then
			if Ghost then
				Ghost:SetColor(255,255,255,0)
			end
			return
		end
		if not IsValidTrap(SelfPly:GetTrap()) then return end
		if not OldTrap then
			OldTrap = SelfPly:GetTrap()
			T = FindTrap(SelfPly:GetTrap())
		end
		if OldTrap ~= SelfPly:GetTrap() then
			OldTrap = SelfPly:GetTrap()
			T = FindTrap(SelfPly:GetTrap())
		end
		if not Ghost then
			Ghost = ents.Create("prop_physics")
			Ghost:Spawn()
			hook.Add("PreDrawTranslucentRenderables","TrapRange",function()
				if GetGlobalBool("Lobby") then return end
				if SelfPly:GetTrap() == "trap_fakeartifact" then return end
				local Radius = 100
				if SelfPly:GetTrap() == "trap_explosive" or SelfPly:GetTrap() == "trap_poison" then
					for I,P in pairs(Lvls) do
						if P["I"] == SelfPly:GetTrap().."_Radius" then
							Radius = GetData(SelfPly:GetTrap(),"Radius",P["lvl"])
						end
					end
				end
				local Tr = SelfPly:GetEyeTrace()
				if Tr.Entity and Tr.Entity:IsValid() then return end
				cam.Start3D2D(Tr.HitPos,Angle(0,0,0),1)
					surface.DrawCircle(0,0,Radius,Color(255,0,0,255))
				cam.End3D2D()
			end)
		end
		local t = SelfPly:GetTrap()
		if t == "trap_fakewall" or t == "trap_spike" then
			local lvl
			for I,P in pairs(Lvls) do
				if P["I"] == t.."_Model" then
					lvl = P["lvl"]
				end
			end
			local Mdl = GetData(t,"Model",lvl)
			Ghost:SetModel(Mdl)
		elseif Ghost:GetModel() ~= T["Model"] then
			Ghost:SetModel(T["Model"])
		end
		Ghost:SetColor(255,255,255,100)
		local Nor = Tr.HitNormal
		local Ang = Nor:Angle()
		local Min,Max = Ghost:WorldSpaceAABB()
		local Val = Max - Min
		Ghost:SetAngles(Angle(Ang.p + 90,0,0))
		Ghost:SetPos(Tr.HitPos + Ghost:GetAngles():Up() * (Val.z / 2))
	elseif SelfPly:Team() != 2 and Ghost then
		Ghost:Remove()
		Ghost = nil
		hook.Remove("PreDrawTranslucentRenderables","TrapRange")
	end
end

local SoundTries = 0
local function InitSounds()
	if not SelfPly or not SelfPly:IsValid() then timer.Simple(1,InitSounds) return end
	HeartBeat = CreateSound(SelfPly,"player/heartbeat1.wav")
	if not HeartBeat then
		HeartAllowed = false
	else 
		HeartAllowed = true 
	end
	Breath = CreateSound(SelfPly,"player/breathe1.wav")
	if not Breath then 
		BreathAllowed = false
	else 
		BreathAllowed = true 
		Breath:ChangeVolume(40)
	end
	if not BreathAllowed or not HeartAllowed and SoundTries < 10 then
		SoundTries = SoundTries + 1
		timer.Simple(5,InitSounds)
	end
end

function GM:Initialize()
	SelfPly = LocalPlayer()
	hook.Add("Think","StartingThink",function()
		if SelfPly and SelfPly:IsValid() then
			InitSounds()
			InitModels()
			for I,P in pairs(hook.GetTable()) do
				for i,A in pairs(P) do
					if string.find(string.lower(i),"postprocess") or string.find(string.lower(i),"render") or string.find(string.lower(i),"morph") or string.find(string.lower(i),"dof") or string.find(string.lower(i),"categories") or string.find(string.lower(i),"menus") then
						hook.Remove(I,i)
					end
				end
			end
			for i,P in pairs(GetAddonList()) do
				if P == "wire" then
					for h,H in pairs(hook.GetTable()) do
						for I,A in pairs(H) do					
							if string.find(string.lower(I),"wire") or string.find(string.lower(I),"egp") or string.find(string.lower(I),"e2") or string.find(string.lower(I),"zlib") or string.find(string.lower(I),"advdupe") or string.find(string.lower(I),"defaulttabs") then
								hook.Remove(h,I)
							end
						end
					end
				elseif P == "smartsnap" then
					for h,H in pairs(hook.GetTable()) do
						for I,A in pairs(H) do
							if string.find(string.lower(I),"smartsnap") then
								hook.Remove(h,I)
							end
						end
					end
				end
			end
			hook.Remove("Think","StartingThink")
			return
		end
	end)
	Joining = {}
	Deads = {}
	CreateLobby()
	CreateChat()
	SelectedTrap = ""
	TotalPlayers = 0
end

function GM:HUDDrawTargetID()
	return false
end

function GM:PlayerConnect(ply,ip)
end

function GM:PlayerAuthed(ply,steamid)
end

function CreateTraplayer()
	Trapanel = vgui.Create("DPanel")
	Trapanel:SetSize(ScrW() - 600,100)
	Trapanel:SetPos(300,ScrH() - 100)
	Trapanel.Paint = function(self)
		draw.RoundedBoxEx(20,0,0,self:GetWide(),self:GetTall(),Color(100,100,100,255),true,true,false,false)
		draw.RoundedBoxEx(20,10,10,self:GetWide() - 20,self:GetTall() - 10,Color(150,150,150,255),true,true,false,false)
	end
	Traplist = vgui.Create("DPanelList",Trapanel)
	Traplist:SetSize(Trapanel:GetWide() - 50,Trapanel:GetTall() - 25)
	Traplist:SetPos(25,25)
	Traplist:SetSpacing(4)
	Traplist:EnableVerticalScrollbar(false)
	Traplist:EnableHorizontal(true)
	local function CreateIcon(Trap,Name,Model,Info)
		local Icon = vgui.Create("SpawnIcon")
		Icon:SetIconSize(75)
		Icon:SetModel(Model)
		Icon:SetToolTip("Trap: "..Name.."\n"..Info)
		Icon.DoClick = function()
			if not TrapShow:IsVisible() then
				TrapShow:SetVisible(true)
			end
			if Trap ~= SelectedTrap then
				SelectedTrap = Trap
				TrapLabel:SetText("Selected trap: "..Name.."\n\n"..Info)
				TrapLabel:SizeToContents()
				TrapMdl:SetModel(Model)
				RunConsoleCommand("Trappola_NewTrap",Trap)
			end
		end
		Traplist:AddItem(Icon)
	end
	
	Tims = {}
	for I,T in pairs(Traps) do
		if T["Unlockable"] and Unlocks[I] == 1 then
			table.insert(Tims,T)
			CreateIcon(T["Trap"],T["Trap name"],T["Model"],T["Info"])
		elseif not T["Unlockable"] then
			table.insert(Tims,T)
			CreateIcon(T["Trap"],T["Trap name"],T["Model"],T["Info"])
		end
	end
	
	TrapShow = vgui.Create("DPanel")
	TrapShow:SetSize(200,300)
	TrapShow:SetPos(0,ScrH() - 300)
	TrapShow.Paint = function(self)
		draw.RoundedBoxEx(20,0,0,self:GetWide(),self:GetTall(),Color(100,100,100,255),false,true,false,false)
		draw.RoundedBoxEx(20,0,10,self:GetWide() - 10,self:GetTall() - 10,Color(75,75,75,255),false,true,false,false)
		if SelfPly:GetNWBool(SelectedTrap) or GetGlobalBool(SelectedTrap) then
			local Trp,I = FindTrap(SelectedTrap)
			local Time = GetData(SelectedTrap,"Cooldown",Cooldowns[I])
			local CurTim
			if Trp["PlayerLocalized"] then
				CurTim = Time - (CurTime() - SelfPly:GetNWInt(SelectedTrap.." Start"))
			else
				CurTim = Time - (CurTime() - GetGlobalInt(SelectedTrap.." Start"))
			end
			local Percent = math.Clamp(CurTim / Time,0,1)
			surface.SetDrawColor(125,125,125,125)
			local x,y = self:GetWide() / 2,self:GetTall() / 2
			for I = 180,180 + (360 * Percent),0.5 do
				surface.DrawLine(x,y,x + math.sin(math.rad(I)) * (y * math.sqrt(2)),y + math.cos(math.rad(I)) * (y * math.sqrt(2)))
			end
		else
			return
		end
	end
	TrapLabel = vgui.Create("DLabel",TrapShow)
	TrapLabel:SetPos(10,30)
	TrapLabel:SetText("")
	TrapMdl = vgui.Create("DModelPanel",TrapShow)
	TrapMdl:SetSize(180,180)
	TrapMdl:SetModel("")
	TrapMdl:SetPos(10,120)
	TrapMdl:SetLookAt(Vector(0,0,0))
	Trapanel:SetVisible(false)
	TrapShow:SetVisible(false)
end

function RemoveTraplayer()
	Trapanel:Remove()
	TrapShow:Remove()
	SelectedTrap = ""
	Unlocks = nil
	Cooldowns = nil
end

local function CreateDisableCD()
	local Pan = vgui.Create("DPanel")
	Pan:SetSize(500,100)
	Pan:SetPos(ScrW() / 2 - 250,300)
	Pan:MakePopup()
	Pan.Paint = function(self)
		if TutP and TutP:IsValid() and TutP:IsVisible() then self:SetVisible(false) return end
		if (not TutP or not TutP:IsValid() or not TutP:IsVisible()) and not self:IsVisible() then self:SetVisible(true) end 
		surface.SetDrawColor(0,0,0,100)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		draw.DrawText("Which trap do you want to have no cooldown?","MenuLarge",self:GetWide() / 2,20,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	end
	local Btns = {}
	for I,P in pairs(Traps) do
		if P["PlayerLocalized"] and Unlocks[I] == 1 then
			table.insert(Btns,P)
		end
	end
	for I,P in pairs(Btns) do
		local Btn = vgui.Create("DButton",Pan)
		Btn:SetSize(100,40)
		Btn:SetPos(20 + 120 * (I - 1),40)
		Btn:SetText(P["Trap name"])
		Btn.DoClick = function(self)
			self:GetParent():Remove()
			RunConsoleCommand("Trappola_DisableCooldown",P["Trap"])
		end
	end
	local Exit = vgui.Create("DButton",Pan)
	Exit:SetSize(300,20)
	Exit:SetPos(100,80)
	Exit:SetText("I don't want to use my cooldown token yet")
	Exit.DoClick = function(self)
		self:GetParent():Remove()
	end
end

usermessage.Hook("Respawn",function(um)
	local Pan = vgui.Create("DPanel")
	Pan:SetSize(300,80)
	Pan:SetPos(ScrW() / 2 - 150,300)
	Pan:MakePopup()
	Pan.Paint = function(self)
		surface.SetDrawColor(0,0,0,100)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		draw.DrawText("Do you want to use your respawn token?","MenuLarge",self:GetWide() / 2,20,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	end
	local Yes = vgui.Create("DButton",Pan)
	Yes:SetSize(60,20)
	Yes:SetPos(20,40)
	Yes:SetText("Yes")
	Yes.DoClick = function(self)
		self:GetParent():Remove()
		RunConsoleCommand("Trappola_Respawn")
	end
	local No = vgui.Create("DButton",Pan)
	No:SetSize(60,20)
	No:SetPos(Pan:GetWide() - 80,40)
	No:SetText("No")
	No.DoClick = function(self)
		self:GetParent():Remove()
	end
end)

usermessage.Hook("Lvls",function(um)
	lvls = string.ToTable(um:ReadString())
	Lvls = {}
	for I,P in pairs(lvls) do
		if I <= #TrapUpgrades then
			table.insert(Lvls,{["I"] = TrapUpgrades[I]["Trap"].."_"..TrapUpgrades[I]["Var"],["lvl"] = tonumber(P)})
		else
			local I = I - #TrapUpgrades
			table.insert(Lvls,{["I"] = ScavUpgrades[I]["Var"],["lvl"] = tonumber(P)})
		end
	end
	RebuildShop()
	for I,P in pairs(Lvls) do
		if P["I"] == "MaxHealth" then
			SelfPly.MaxHealth = GetData("Scavenger","MaxHealth",P["lvl"])
		end
	end
end)

usermessage.Hook("TrapUnlocks&Cooldowns",function(um)
	Unlocks = string.ToTable(um:ReadString())
	Unlocks[6] = tonumber(Unlocks[4])
	Unlocks[5] = tonumber(Unlocks[3])
	Unlocks[4] = tonumber(Unlocks[2])
	Unlocks[3] = tonumber(Unlocks[1])
	Unlocks[2] = 1
	Unlocks[1] = 1
	Cooldowns = string.ToTable(um:ReadString())
	Cooldowns[6] = tonumber(Cooldowns[6])
	Cooldowns[5] = tonumber(Cooldowns[5])
	Cooldowns[4] = tonumber(Cooldowns[4])
	Cooldowns[3] = tonumber(Cooldowns[3])
	Cooldowns[2] = tonumber(Cooldowns[2])
	Cooldowns[1] = tonumber(Cooldowns[1])
	if um:ReadBool() then
		CreateDisableCD()
	end
	CreateTraplayer()
end)

usermessage.Hook("Sound",function(um)
	local sound = Sound(um:ReadString())
	SelfPly:EmitSound(sound)
end)

usermessage.Hook("Death",function(um)
	local Ply,Team = um:ReadString(),um:ReadShort()
	local Atk,Atkteam = um:ReadString(),um:ReadShort()
	local Inflictor = um:ReadString()
	table.insert(Deads,{{Ply,Team},{Atk,Atkteam},Inflictor,CurTime() + 3})
end)

usermessage.Hook("TrapHere",function(um)
	local x,y,z = um:ReadShort(),um:ReadShort(),um:ReadShort()
	local Vec = Vector(x,y,z)
	local x = 0
	hook.Add("PreDrawTranslucentRenderables","TrapHere",function()
		x = math.Clamp(x + 0.5,0,150)
		cam.Start3D2D(Vec,Angle(0,0,0),1)
			cam.IgnoreZ(true)
			surface.DrawCircle(0,0,x,Color(255,0,0,255 - x * 1.5))
			cam.IgnoreZ(false)
		cam.End3D2D()
		if x == 150 then hook.Remove("PreDrawTranslucentRenderables","TrapHere") return end
	end)
end)

local Tex_Corner8 	= surface.GetTextureID( "gui/corner8" )
local Tex_Corner16 	= surface.GetTextureID( "gui/corner16" )
 
function draw.RoundedBoxEx( bordersize, x, y, w, h, color, a, b, c, d )
	x = math.Round( x )
	y = math.Round( y )
	w = math.Round( w )
	h = math.Round( h )
 
	surface.SetDrawColor( color.r, color.g, color.b, color.a )
 
	surface.DrawRect( x+bordersize, y, w-bordersize*2, h )
	surface.DrawRect( x, y+bordersize, bordersize, h-bordersize*2 )
	surface.DrawRect( x+w-bordersize, y+bordersize, bordersize, h-bordersize*2 )
 
	local tex = Tex_Corner8
	if ( bordersize > 8 ) then tex = Tex_Corner16 end
 
	surface.SetTexture( tex )
 
	if ( a ) then
		surface.DrawTexturedRectRotated( x + bordersize/2 , y + bordersize/2, bordersize, bordersize, 0 )
	else
		surface.DrawRect( x, y, bordersize, bordersize )
	end
 
	if ( b ) then
		surface.DrawTexturedRectRotated( x + w - bordersize/2 , y + bordersize/2, bordersize, bordersize, 270 )
	else
		surface.DrawRect( x + w - bordersize, y, bordersize, bordersize )
	end
 
	if ( c ) then
		surface.DrawTexturedRectRotated( x + bordersize/2 , y + h -bordersize/2, bordersize, bordersize, 90 )
	else
		surface.DrawRect( x, y + h - bordersize, bordersize, bordersize )
	end
 
	if ( d ) then
		surface.DrawTexturedRectRotated( x + w - bordersize/2 , y + h - bordersize/2, bordersize, bordersize, 180 )
	else
		surface.DrawRect( x + w - bordersize, y + h - bordersize, bordersize, bordersize )
	end
end