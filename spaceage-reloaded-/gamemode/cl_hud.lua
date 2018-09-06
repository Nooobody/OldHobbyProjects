
function WelcomeBox()
	local Wi,He = ScrW(),ScrH()
	local Text = Material("VGUI/LogoTxt.png","unlitgeneric")
	local BG = Material("VGUI/Logo_NewBG.png","unlitgeneric")
	SA_WelcomeBox = vgui.Create("DPanel")
	local W,H = math.max(Wi - 400,1200),He - 100
	SA_WelcomeBox:SetSize(W,H)
	SA_WelcomeBox:Center()
	SA_WelcomeBox:MakePopup()
	local Outlines = Color(239,235,237)
	SA_WelcomeBox.Paint = function(self,w,h)
		surface.SetDrawColor(255,255,255)
		surface.SetMaterial(BG)
		local SizX = 1539
		local SizY = 1050
		local TimesX = math.ceil(w / SizX)
		local TimesY = math.ceil(h / SizX)
		for I = 0,TimesX * TimesY - 1,1 do
			local X = (I % TimesX) * SizX + 3
			local Y = math.floor(I / TimesX) * SizY + 3
			surface.DrawTexturedRect(X,Y,SizX,SizY)
		end
		surface.SetDrawColor(Outlines)
		surface.DrawOutlinedRect(0,0,w,h)
		surface.DrawOutlinedRect(1,1,w - 2,h - 2)
		surface.DrawOutlinedRect(2,2,w - 4,h - 4)
		
		surface.SetDrawColor(255,255,255)
		surface.SetMaterial(Text)
		surface.DrawTexturedRect(200,3,w - 400,200)
		
		if w < 1300 then
			draw.DrawText("What is this Server?","Lucida",w / 2,220,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("This server is based on an old SpaceBuild3 gamemode called 'SpaceAge',","Lucida",w / 2,260,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("which was unfortunately disbanded.","Lucida",w / 2,286,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("But this server is not based on SB3, instead, it's all custom.","Lucida",w / 2,312,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("What is SpaceBuild3?","Lucida",w / 2,360,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("SpaceBuild3 is/was a gamemode that allowed players to create resource distribution and","Lucida",w / 2,400,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("lifesupport systems. However, this server is not built on top of SB3.","Lucida",w / 2,426,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("It's all customly built by the developer.","Lucida",w / 2,452,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("Addons?","Lucida",w / 2,500,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("All the required addons are downloaded through workshop, but the models are from SBEP.","Lucida",w / 2,540,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("SBEP isn't on the Workshop however, so I've compiled a collection of the models","Lucida",w / 2,566,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("into a single dropbox link. It does have a couple of custom models aswell.","Lucida",w / 2,592,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("Join our forums too! Found at, ","Lucida",w / 2,668,Outlines,TEXT_ALIGN_CENTER)
		else
			draw.DrawText("What is this Server?","Lucida",w / 2,220,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("This server is based on an old SpaceBuild3 gamemode called 'SpaceAge', which was unfortunately disbanded.","Lucida",w / 2,260,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("But this server is not based on SB3, instead, it's all custom.","Lucida",w / 2,286,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("What is Spacebuild3?","Lucida",w / 2,340,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("SpaceBuild3 is/was a gamemode that allowed players to create resource distribution and lifesupport.","Lucida",w / 2,380,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("However, this server is not built on top of SB3. It's all customly built by the developer.","Lucida",w / 2,406,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("Addons?","Lucida",w / 2,460,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("All the required addons are downloaded through workshop, but the models are from SBEP.","Lucida",w / 2,500,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("SBEP isn't on the Workshop however, so I've compiled a collection of the models into a single dropbox link.","Lucida",w / 2,526,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("It does have a couple of custom models aswell.","Lucida",w / 2,552,Outlines,TEXT_ALIGN_CENTER)
			draw.DrawText("Join our forums too! Found at, ","Lucida",w / 2,668,Outlines,TEXT_ALIGN_CENTER)
		end
	end
	local Link = vgui.Create("RichText",SA_WelcomeBox)
	local Str = "https://www.dropbox.com/s/pvgajpt7y5l93oh/SBEP_Collection.7z"
	surface.SetFont("Lucida")
	local TextW = surface.GetTextSize(Str) + 20
	local Hei = 580
	if W < 1300 then Hei = 660 end
	Link:SetPos(W / 2 - TextW / 2 + 10,Hei)
	Link:SetSize(TextW,24)
	Link:SetVerticalScrollbarEnabled(false)
	Link:SetFGColor(Outlines)
	local Pnt = Link.Paint
	Link.Paint = function(self)
		self.m_FontName = "Lucida"
		self:SetFontInternal("Lucida")
		self.Paint = Pnt
	end
	Link:InsertClickableTextStart(Str)
	Link:AppendText(Str)
	Link:InsertClickableTextEnd()
	local ForumLink = vgui.Create("RichText",SA_WelcomeBox)
	Str = "www.sareloaded.com"
	surface.SetFont("Lucida")
	local TextW = surface.GetTextSize(Str) + 20
	Hei = 700
	if W < 1300 then Hei = 740 end
	ForumLink:SetPos(W / 2 - TextW / 2 + 10,Hei)
	ForumLink:SetSize(TextW,24)
	ForumLink:SetVerticalScrollbarEnabled(false)
	ForumLink:SetFGColor(Outlines)
	local Pnt = ForumLink.Paint
	ForumLink.Paint = function(self)
		self.m_FontName = "Lucida"
		self:SetFontInternal("Lucida")
		self.Paint = Pnt
	end
	ForumLink:InsertClickableTextStart(Str)
	ForumLink:AppendText(Str)
	ForumLink:InsertClickableTextEnd()
	local Btn = vgui.Create("DButton",SA_WelcomeBox)
	Btn:SetSize(100,40)
	Btn:SetPos(W - 120,H - 60)
	Btn:SetText("Okay")
	Btn.DoClick = function(self) self:GetParent():Remove() end
end

local function CreateScoreboard()
	local W,H = ScrW(),ScrH()
	local Text = Material("VGUI/LogoTxt.png","unlitgeneric")
	local BG = Material("VGUI/Logo_NewBG.png","unlitgeneric")

	SA_Scoreboard = vgui.Create("DPanel")
	SA_Scoreboard:SetSize(math.max(W - 900,1000),H - 100)
	SA_Scoreboard:Center()
	SA_Scoreboard:SetVisible(false)
	local Outlines = Color(239,235,237)
	SA_Scoreboard.Paint = function(self,w,h)
		surface.SetDrawColor(255,255,255)
		surface.SetMaterial(BG)
		//surface.DrawTexturedRect(0,0,w,h)
		
		local SizX = 1539
		local SizY = 1050
		local TimesX = math.ceil(w / SizX)
		local TimesY = math.ceil(h / SizX)
		for I = 0,TimesX * TimesY - 1,1 do
			local X = (I % TimesX) * SizX + 3
			local Y = math.floor(I / TimesX) * SizY + 3
			surface.DrawTexturedRect(X,Y,SizX,SizY)
		end/*
		surface.SetDrawColor(Outlines)
		surface.DrawLine(w - 3,0,w - 3,h)
		surface.DrawLine(0,h - 3,w,h - 3)
		surface.DrawLine(w - 2,0,w - 2,h)
		surface.DrawLine(0,h - 2,w,h - 2)
		surface.DrawLine(w - 1,0,w - 1,h)
		surface.DrawLine(0,h - 1,w,h - 1)*/
		draw.DrawTransBox(0,0,w,h,Outlines)
		
		surface.SetDrawColor(255,255,255)
		surface.SetMaterial(Text)
		surface.DrawTexturedRect(3,3,w - 6,200)
		
		draw.DrawText("Score","Default",640,206,Outlines,TEXT_ALIGN_RIGHT)
		draw.DrawText("Ping","Default",w - 50,206,Outlines,TEXT_ALIGN_RIGHT)
		local Off = 45
		local Plies = player.GetAll()
		local function Comp(a,b)
			if a:GetScore() == b:GetScore() then return a:Name() > b:Name()
			else return a:GetScore() > b:GetScore() end
		end
		table.sort(Plies,Comp)
		for I,P in pairs(Plies) do
			local Fac = P:GetFact()
			local Col = Fac.Col
			local Name = P:Name()
			if P:Team() == 0 then Name = "Connecting..." end
			surface.SetDrawColor(Col)
			surface.DrawOutlinedRect(18,220 + Off * (I - 1),w - 36,40)
			if Fac.Icon then
				surface.SetDrawColor(255,255,255,255)
				surface.SetMaterial(Fac.Icon)
				surface.DrawTexturedRect(28,225 + Off * (I - 1),30,30)
			end
			draw.DrawText(Name,"Lucida",74,228 + Off * (I - 1),Outlines,TEXT_ALIGN_LEFT)
			if P:GetPrivilege() > 0 then
				local Priv
				if P:GetPrivilege() >= PRIV_OWNER then
					Priv = PRIVs[PRIV_OWNER]
				elseif P:GetPrivilege() >= PRIV_ADMIN then
					Priv = PRIVs[PRIV_ADMIN]
				elseif P:GetPrivilege() >= PRIV_MOD then
					Priv = PRIVs[PRIV_MOD]
				end
				draw.DrawText(Priv.Name,"Lucida",400,228 + Off * (I - 1),Priv.Color,TEXT_ALIGN_CENTER)
			end
			if P:Team() ~= 0 then
				draw.DrawText(string.Comma(P:GetScore()),"Lucida",740,228 + Off * (I - 1),Outlines,TEXT_ALIGN_RIGHT)
				draw.DrawText(P:Ping(),"Lucida",w - 50,228 + Off * (I - 1),Outlines,TEXT_ALIGN_RIGHT)
				if P:GetNWBool("AFK") then
					draw.DrawText("AFK","Lucida",w - 150,228 + Off * (I - 1),Color(255,255,0),TEXT_ALIGN_CENTER)
				end
			end
		end
		return true
	end
end

function GM:ScoreboardShow()
	if not SA_Scoreboard or not SA_Scoreboard:IsValid() then CreateScoreboard() end
	SA_Scoreboard:SetVisible(true)
end

function GM:ScoreboardHide()
	SA_Scoreboard:SetVisible(false)
end

function GM:HUDDrawTargetID()
	return false
end

local Cooldown = 0
local Clicker = false
local OldNews

function GetNewsTicker(Off)
	if CurTime() < Cooldown then 
		if IsValid(SA_TICKER) then 
			SA_TICKER:SetPos(SA_TICKER:GetPos(),46 + Off) 
			if not SA_TICKER:IsVisible() then
				SA_TICKER:SetVisible(true)
			end
		end
		return 
	end
	Cooldown = CurTime() + 0.01
	if not IsValid(SA_TICKER) then
		local News = table.Random(SA_NEWS) or "Welcome to SpaceAge - Reloaded!"
		if #SA_NEWS > 1 then
			while News == OldNews do
				News = table.Random(SA_NEWS)
			end
		end
		OldNews = News
		surface.SetFont("LucidaSmall")
		local W
		if type(News) == "table" then W = surface.GetTextSize(News[1]) + 20
		elseif type(News) == "string" then W = surface.GetTextSize(News) + 20 end
		SA_TICKER = vgui.Create("DPanel")
		SA_TICKER:SetPos(ScrW(),46 + Off)
		SA_TICKER:SetSize(W,30)
		if type(News) == "string" then
			SA_TICKER.Paint = function(self,w,y)
				draw.DrawText(News,"LucidaSmall",w / 2,0,Color(255,255,255),TEXT_ALIGN_CENTER)
			end
			Clicker = false
		else
			SA_TICKER.Paint = function(self,w,y)
			end
			local Text = vgui.Create("RichText",SA_TICKER)
			Text:Dock(LEFT)
			Text:SetSize(W,30)
			Text:SetVerticalScrollbarEnabled(false)
			Text:SetFGColor(Color(255,255,255))
			local Pnt = Text.Paint
			Text.Paint = function(self)
				self.m_FontName = "LucidaSmall"
				self:SetFontInternal("LucidaSmall")
				self.Paint = Pnt
			end
			Text:InsertClickableTextStart(News[2])
			Text:AppendText(News[1])
			Text:InsertClickableTextEnd()
			Clicker = true
		end
	end
	if not SA_TICKER:IsVisible() then
		SA_TICKER:SetVisible(true)
	end
	local X = SA_TICKER:GetPos()
	SA_TICKER:SetPos(X - 1,46 + Off)
	if not SA_TICKER.Stopped and X + SA_TICKER:GetSize() / 2 <= ScrW() / 2 then
		SA_TICKER.Stopped = true
		Cooldown = CurTime() + 5
	elseif X + SA_TICKER:GetSize() < 0 then
		SA_TICKER:Remove()
		Cooldown = CurTime() + 5
	end
end

local function AddZero(Num)
	if Num < 10 then
		return "0"..Num
	end
	return Num
end

local SoundAllow = true
local S_Warning = Sound("alarms/klaxon1.wav")

function DrawTopBar()
	if LocalPlayer().ContextMenuOpen and not input.IsKeyDown(KEY_C) then LocalPlayer().ContextMenuOpen = false end
	local Off = 0
	local Rest = GetGlobalInt("RestartTimer")
	local RestartOff = 0
	if Rest > 0 then
		RestartOff = 30
	end
	if LocalPlayer().ContextMenuOpen then
		Off = 30
		if ShowTopBar and Clicker and IsValid(SA_TICKER) then
			draw.DrawText("Open chat to enable link clicking!","LucidaSmall",SA_TICKER:GetPos() + SA_TICKER:GetSize() / 2,100,Color(255,255,255),TEXT_ALIGN_CENTER)
		end
	end
	
	if not ShowTopBar then
		if Rest > 0 then
			surface.SetDrawColor(0,0,0,200)
			surface.DrawRect(0,0,ScrW(),RestartOff + Off)
			draw.DrawText("The server is restarting in "..Rest.." seconds!","Lucida",ScrW() / 2,10 + Off,Color(255,50,50),TEXT_ALIGN_CENTER)
		end
		
		if input.IsMouseDown(MOUSE_LEFT) and gui.MouseY() > Off + RestartOff and gui.MouseY() < Off + RestartOff + 3 then
			ShowTopBar = true
		end
		
		surface.SetDrawColor(team.GetColor(LocalPlayer():Team()))
		surface.DrawRect(0,Off + RestartOff,ScrW(),3)
		
		if IsValid(SA_TICKER) and SA_TICKER:IsVisible() then
			SA_TICKER:SetVisible(false)
		end
		return
	end
	if input.IsMouseDown(MOUSE_LEFT) and gui.MouseY() > 70 + Off + RestartOff and gui.MouseY() < 70 + Off + RestartOff + 3 then
		ShowTopBar = false
	end
	local W,H = ScrW(),ScrH()
	surface.SetDrawColor(0,0,0,200)
	surface.DrawRect(0,0,W,70 + Off + RestartOff)
	surface.SetDrawColor(LocalPlayer():GetFact().Col)
	surface.DrawRect(0,70 + Off + RestartOff,W,3)
	draw.DrawText("Name: "..LocalPlayer():Name(),"Lucida",20,6 + Off,Color(255,255,255),TEXT_ALIGN_LEFT)
	draw.DrawText("Faction: "..LocalPlayer():GetFact().Name,"Lucida",400,6 + Off,Color(255,255,255),TEXT_ALIGN_LEFT)
	local XP = 800
	local ALIGN = TEXT_ALIGN_LEFT
	if ScrW() < 1300 then XP = W - 400 ALIGN = TEXT_ALIGN_RIGHT end
	draw.DrawText("Credits: "..string.Comma(LocalPlayer():GetMoney()),"Lucida",XP,6 + Off,Color(255,255,255),ALIGN)
	local Time = math.floor(LocalPlayer():GetNWInt("TimePlayed") + (CurTime() - LocalPlayer():GetNWInt("Joined")))
	local Str = ""
	if Time >= 3600 then
		Str = math.floor(Time / 3600)..":"..AddZero(math.floor(Time / 60) % 60)..":"..AddZero(Time % 60)
	elseif Time >= 60 then
		Str = math.floor(Time / 60)..":"..AddZero(Time % 60)
	else
		Str = Time
	end
	draw.DrawText("Time Played: "..Str,"Lucida",W - 20,6 + Off,Color(255,255,255),TEXT_ALIGN_RIGHT)
	GetNewsTicker(Off)
	if Rest > 0 then
		draw.DrawText("The server is restarting in "..Rest.." seconds!","Lucida",ScrW() / 2,80 + Off,Color(255,50,50),TEXT_ALIGN_CENTER)		
		if (Rest % 60 == 0 or Rest < 20) and SoundAllow then
			LocalPlayer():EmitSound(S_Warning)
			SoundAllow = false
			timer.Simple(2,function() SoundAllow = true end)
		end
	end
end

function DrawTarget(Tr)
	local ScW,ScH = ScrW(),ScrH()
	if Tr.Entity:IsPlayer() then
		local Name = Tr.Entity:Name()
		draw.DrawText(Name,"TargetID",ScW / 2,ScH - 380,Color(200,200,0,200),TEXT_ALIGN_CENTER)
		draw.DrawText(Tr.Entity:Health(),"TargetID",ScW / 2,ScH - 360,Color(200,200,0,200),TEXT_ALIGN_CENTER)
	else
		if Tr.Entity:GetClass() == "prop_ragdoll" and Tr.Entity:GetNWString("Name") ~= "" then
			draw.DrawText(Tr.Entity:GetNWString("Name"),"TargetID",ScW / 2,ScH - 380,Color(200,200,0,200),TEXT_ALIGN_CENTER)
		elseif Tr.Entity:GetNWEntity("Owner") then
			local Name = ""
			if Tr.Entity:GetNWEntity("Owner"):IsPlayer() and IsValid(Tr.Entity:GetNWEntity("Owner")) then
				Name = Tr.Entity:GetNWEntity("Owner"):Name()
			else
				Name = "World"
			end
			local Str = "Owner: "..Name
			surface.SetFont("TargetID")
			local W = surface.GetTextSize(Str)
			draw.RoundedBox(6,ScW / 2 - W / 2 - 5,ScH - 320,W + 10,20,Color(0,0,0,100))
			draw.DrawText(Str,"TargetID",ScW / 2,ScH - 320,Color(200,200,0,200),TEXT_ALIGN_CENTER)
		end
	end
end

function DrawAtmo()
	if not LocalPlayer().Oxy then
		LocalPlayer().Oxy = 5
		LocalPlayer().Ice = 5
		LocalPlayer().Steam = 5
		LocalPlayer().Pressure = 100
		LocalPlayer().Temperature = 0
		LocalPlayer().NotDanger = true
		return
	end

	if not LocalPlayer().O then
		LocalPlayer().O = LocalPlayer().Oxy
		LocalPlayer().I = LocalPlayer().Ice
		LocalPlayer().S = LocalPlayer().Steam
		LocalPlayer().P = LocalPlayer().Pressure
		LocalPlayer().T = LocalPlayer().Temperature
	end

	local W,H = ScrW(),ScrH()
	
	local BarWide = 240
	local BarHeight = 20
	local BarPadding = 6
	
	local X,Y = W / 2 - (BarWide + 40) / 2,H - 300
	draw.RoundedBox(4,X,Y,BarWide + 120,BarHeight * 5 + BarPadding * 4 + 40,Color(0,0,0,200))
	
	local Y1,Y2,Y3,Y4,Y5 = Y + 20,
						   Y + 20 + BarHeight + BarPadding,
						   Y + 20 + BarHeight * 2 + BarPadding * 2,
						   Y + 20 + BarHeight * 3 + BarPadding * 3,
						   Y + 20 + BarHeight * 4 + BarPadding * 4
	
	local I,O,S,P,T = LocalPlayer().I,LocalPlayer().O,LocalPlayer().S,LocalPlayer().P,LocalPlayer().T
	local Ice,Oxy,Stm,Pre,Tmp = LocalPlayer().Ice,LocalPlayer().Oxy,LocalPlayer().Steam,LocalPlayer().Pressure,LocalPlayer().Temperature
	
	if I ~= Ice then
		I = Lerp(0.1,I,Ice)
		LocalPlayer().I = I
	end
	
	if O ~= Oxy then
		O = Lerp(0.1,O,Oxy)
		LocalPlayer().O = O
	end
	
	if S ~= Stm then
		S = Lerp(0.1,S,Stm)
		LocalPlayer().S = S
	end
	
	if P ~= Pre then
		P = Lerp(0.1,P,Pre)
		LocalPlayer().P = P
	end
	
	if T ~= Tmp then
		T = Lerp(0.1,T,math.Clamp(Tmp,-100,2500))
		LocalPlayer().T = T
	end
	
	local IP,OP,SP,PP,TP = I / 200,O / 100,S / 200,P - 1,T / 2600
	
	surface.SetMaterial(Material("gui/gradient"))
	
	-- Temperature
	local Star = 100 / 2600
	local Safe = 60 / 2600
	surface.SetDrawColor(0,255,0)
	surface.DrawTexturedRectRotated(X + 20 + BarWide * Star + (BarWide * Safe) / 2,Y1 + BarHeight / 4,BarHeight / 2,BarWide * Safe,90)
	surface.DrawTexturedRectRotated(X + 20 + BarWide * Star + (BarWide * Safe) / 2,Y1 + (BarHeight / 4) * 3,BarHeight / 2,BarWide * Safe,-90)
	surface.SetDrawColor(0,0,255)
	surface.DrawTexturedRectRotated(X + 20 + (BarWide * Star) / 2,Y1 + BarHeight / 4,BarHeight / 2,BarWide * Star,90)
	surface.DrawTexturedRectRotated(X + 20 + (BarWide * Star) / 2,Y1 + (BarHeight / 4) * 3,BarHeight / 2,BarWide * Star,-90)
	surface.SetDrawColor(255,0,0)
	surface.DrawTexturedRectRotated(X + 20 + BarWide * (Star + Safe) + (BarWide * (1 - (Safe + Star))) / 2,Y1 + BarHeight / 4,BarHeight / 2,BarWide * (1 - (Safe + Star)),90)
	surface.DrawTexturedRectRotated(X + 20 + BarWide * (Star + Safe) + (BarWide * (1 - (Safe + Star))) / 2,Y1 + (BarHeight / 4) * 3,BarHeight / 2,BarWide * (1 - (Safe + Star)),-90)

	surface.SetDrawColor(222,222,222)
	local A = X + 20 + BarWide * (TP + Star)
	surface.DrawRect(A - 1,Y1 - 2,2,BarHeight + 4)
	
	draw.DrawText("Temperature","Default",X + 20 + BarWide / 2,Y1,Color(255,255,255),TEXT_ALIGN_CENTER)
	draw.DrawText(Tmp,"Lucida",X + 20 + BarWide + 4,Y1,Color(255,255,255),TEXT_ALIGN_LEFT)
	
	-- Pressure
	surface.SetDrawColor(0,255,0)
	surface.DrawTexturedRectRotated(X + 20 + BarWide / 2,Y2 + BarHeight / 4,BarHeight / 2,BarWide * 0.2,90)
	surface.DrawTexturedRectRotated(X + 20 + BarWide / 2,Y2 + (BarHeight / 4) * 3,BarHeight / 2,BarWide * 0.2,-90)
	surface.SetDrawColor(255,0,0)
	surface.DrawTexturedRectRotated(X + 20 + (BarWide * 0.4) / 2,Y2 + BarHeight / 4,BarHeight / 2,BarWide * 0.4,90)
	surface.DrawTexturedRectRotated(X + 20 + (BarWide * 0.4) / 2,Y2 + (BarHeight / 4) * 3,BarHeight / 2,BarWide * 0.4,-90)
	surface.DrawTexturedRectRotated(X + 20 + (BarWide * 0.6) + (BarWide * 0.4) / 2,Y2 + BarHeight / 4,BarHeight / 2,BarWide * 0.4,90)
	surface.DrawTexturedRectRotated(X + 20 + (BarWide * 0.6) + (BarWide * 0.4) / 2,Y2 + (BarHeight / 4) * 3,BarHeight / 2,BarWide * 0.4,-90)

	surface.SetDrawColor(222,222,222)
	A = X + 20 + BarWide / 2 + (BarWide / 2) * PP
	surface.DrawRect(A - 1,Y2 - 2,2,BarHeight + 4)
	
	draw.DrawText("Pressure","Default",X + 20 + BarWide / 2,Y2,Color(255,255,255),TEXT_ALIGN_CENTER)
	draw.DrawText(Pre,"Lucida",X + 20 + BarWide + 4,Y2,Color(255,255,255),TEXT_ALIGN_LEFT)
	
	-- Oxygen
	surface.SetDrawColor(150,150,150)

	surface.DrawTexturedRectRotated(X + 20 + (BarWide * OP) / 2,Y3 + BarHeight / 4,BarHeight / 2,BarWide * OP,90)
	surface.DrawTexturedRectRotated(X + 20 + (BarWide * OP) / 2,Y3 + (BarHeight / 4) * 3,BarHeight / 2,BarWide * OP,-90)
	
	draw.DrawText("Oxygen","Default",X + 20 + BarWide / 2,Y3,Color(255,255,255),TEXT_ALIGN_CENTER)
	draw.DrawText(Oxy,"Lucida",X + 20 + BarWide + 4,Y3,Color(255,255,255),TEXT_ALIGN_LEFT)
	
	-- Steam
	surface.SetDrawColor(100,100,100)

	surface.DrawTexturedRectRotated(X + 20 + (BarWide * SP) / 2,Y4 + BarHeight / 4,BarHeight / 2,BarWide * SP,90)
	surface.DrawTexturedRectRotated(X + 20 + (BarWide * SP) / 2,Y4 + (BarHeight / 4) * 3,BarHeight / 2,BarWide * SP,-90)
	
	draw.DrawText("Steam","Default",X + 20 + BarWide / 2,Y4,Color(255,255,255),TEXT_ALIGN_CENTER)
	draw.DrawText(Stm,"Lucida",X + 20 + BarWide + 4,Y4,Color(255,255,255),TEXT_ALIGN_LEFT)
	
	-- Ice
	surface.SetDrawColor(0,0,255)

	surface.DrawTexturedRectRotated(X + 20 + (BarWide * IP) / 2,Y5 + BarHeight / 4,BarHeight / 2,BarWide * IP,90)
	surface.DrawTexturedRectRotated(X + 20 + (BarWide * IP) / 2,Y5 + (BarHeight / 4) * 3,BarHeight / 2,BarWide * IP,-90)
	
	draw.DrawText("Ice","Default",X + 20 + BarWide / 2,Y5,Color(255,255,255),TEXT_ALIGN_CENTER)
	draw.DrawText(Ice,"Lucida",X + 20 + BarWide + 4,Y5,Color(255,255,255),TEXT_ALIGN_LEFT)
	
	
	surface.SetDrawColor(255,255,255,255)
	surface.DrawOutlinedRect(X + 20,Y1,BarWide,BarHeight)
	surface.DrawOutlinedRect(X + 20,Y2,BarWide,BarHeight)
	surface.DrawOutlinedRect(X + 20,Y3,BarWide,BarHeight)
	surface.DrawOutlinedRect(X + 20,Y4,BarWide,BarHeight)
	surface.DrawOutlinedRect(X + 20,Y5,BarWide,BarHeight)
end

function DrawHP()
	if not LocalPlayer().Hp then LocalPlayer().Hp = 100 end
	local HP = LocalPlayer().Hp
	HP = math.min(100,(HP == LocalPlayer():Health() and HP) or Lerp(0.1,HP,LocalPlayer():Health()))
	LocalPlayer().Hp = HP
	
	local barBorder = 3

	local YLength = 300
	local BarWidth = 20

	local XPlace = 10
	local barYPlace = 10
	
	local HPPer = HP / 100

	local Tallness = ScrH() - YLength - barYPlace - barBorder

	local XPlace = BarWidth - (XPlace + barBorder)

	draw.RoundedBox(4,XPlace - barBorder,Tallness - barBorder,BarWidth + barBorder * 2,YLength + barBorder * 2,Color(0,0,0,255))

	draw.RoundedBox(0,XPlace,Tallness,BarWidth,YLength,Color(100,100,100,255))

	draw.RoundedBox(0,XPlace,(Tallness + YLength) - (YLength * HPPer),BarWidth,YLength * HPPer,Color(0,100,220,200))

	-- Armor
	local bordersize
	local Arm = LocalPlayer():Armor()
	if Arm > 0 then
		local ArmPer = math.Min(Arm / 255,1)
		local armorColor = Color(0,255,100,255)
		local bordersize = 3

		draw.RoundedBox(0,XPlace,Tallness + YLength - bordersize,BarWidth,bordersize,armorColor)
		draw.RoundedBox(0,XPlace,(Tallness + YLength) - (YLength * ArmPer),bordersize,YLength * ArmPer,armorColor)
		draw.RoundedBox(0,XPlace + BarWidth - bordersize,(Tallness + YLength) - (YLength * ArmPer),bordersize,YLength * ArmPer,armorColor)
		if Arm == 255 then
			draw.RoundedBox(0,XPlace,Tallness,BarWidth,bordersize,armorColor)
		end
	end

	surface.SetDrawColor(0,0,0,230)
	surface.SetMaterial(Material("gui/gradient"))

	surface.DrawTexturedRectRotated(XPlace + (BarWidth / 2),Tallness + (YLength / 2),BarWidth,YLength,180)
	surface.DrawTexturedRectRotated(XPlace + (BarWidth / 2),Tallness + (YLength / 2),BarWidth,YLength,0)

	surface.SetFont("HudHintTextLarge")
	local w, h = surface.GetTextSize(math.Round(LocalPlayer():Health()))

	local YPlace = 0
	if (Tallness + YLength) - (YLength * HPPer) < Tallness + YLength then
		YPlace = (Tallness + YLength) - (YLength * HPPer) + 6
	else
		YPlace = Tallness + YLength - (h + YLength / 100)
	end

	draw.DrawText(math.Max(0,math.Round(LocalPlayer():Health())),"HudHintTextLarge",XPlace + BarWidth / 2 - 1,YPlace,Color(255,255,255,225),1)
end