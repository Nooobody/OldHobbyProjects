P = vgui.Create("DPanel")
P:SetSize(600,500)
P:SetPos(ScrW() / 2 - P:GetWide() / 2,200)
A = 0
P.Paint = function(self)
	if not self:IsVisible() then return end
	local W,H = self:GetWide(),self:GetTall()
	surface.SetDrawColor(0,0,0,A)
	surface.DrawRect(0,0,W,H)
	surface.SetDrawColor(100,100,100,A)
	surface.DrawOutlinedRect(0,0,W,H)
	if #team.GetPlayers(3) > 0 then
		surface.DrawLine(W / 2,0,W / 2,H - 100)
		surface.DrawLine(0,H - 100,W,H - 100)
		draw.DrawText("Spectators","HUDNumber",W / 2,H - 100,Color(255,255,255,A),TEXT_ALIGN_CENTER)
		local txt = ""
		surface.SetFont("MenuLarge")
		for I,P in pairs(team.GetPlayers(3)) do
			draw.DrawText(P:Name()..", ","MenuLarge",10 + surface.GetTextSize(txt),H - 60,Color(255,255,255,A),TEXT_ALIGN_LEFT)
			txt = txt..P:Name()..", "
		end
	else
		surface.DrawLine(W / 2,0,W / 2,H)
	end
	local Col1,Col2 = team.GetColor(1),team.GetColor(2)
	draw.DrawText("Scavengers","HUDNumber",W / 4,0,Color(Col1.r,Col1.g,Col1.b,A),TEXT_ALIGN_CENTER)
	draw.DrawText("Ping","MenuLarge",240,50,Color(Col1.r,Col1.g,Col1.b,A),TEXT_ALIGN_RIGHT)
	draw.DrawText("Name","MenuLarge",10,50,Color(Col1.r,Col1.g,Col1.b,A),TEXT_ALIGN_LEFT)
	draw.DrawText("Score","MenuLarge",290,50,Color(Col1.r,Col1.g,Col1.b,A),TEXT_ALIGN_RIGHT)
	draw.DrawText("Traplayers","HUDNumber",W - (W / 4),0,Color(Col2.r,Col2.g,Col2.b,A),TEXT_ALIGN_CENTER)
	draw.DrawText("Ping","MenuLarge",310,50,Color(Col2.r,Col2.g,Col2.b,A),TEXT_ALIGN_LEFT)
	draw.DrawText("Name","MenuLarge",W - (W / 4),50,Color(Col2.r,Col2.g,Col2.b,A),TEXT_ALIGN_CENTER)
	draw.DrawText("Kills","MenuLarge",590,50,Color(Col2.r,Col2.g,Col2.b,A),TEXT_ALIGN_RIGHT)
	surface.SetDrawColor(100,100,100,A)
	surface.DrawLine(0,70,W,70)
	if not GetGlobalBool("Lobby") then
		surface.SetDrawColor(100,100,100,A)
		surface.DrawLine(0,H - 20,W,H - 20)
		local Time
		if GetGlobalBool("OverTime") then
			Time = GetGlobalInt("ExtraTime")
		else
			Time = GetGlobalInt("Time")
		end
		draw.DrawText("Time left: "..math.floor(Time / 60)..":"..Time % 60,"MenuLarge",10,H - 20,Color(255,255,255,A),TEXT_ALIGN_LEFT)
		if GetGlobalBool("OverTime") then
			draw.DrawText("OverTime!","MenuLarge",130,H - 20,Color(255,255,255,A),TEXT_ALIGN_LEFT)
		end
		draw.DrawText("Artifacts returned: "..(math.Round((GetGlobalInt("Arties") / GetGlobalInt("MaxArties")) * 1000) / 10).."%","MenuLarge",W - 10,H - 20,Color(255,255,255,A),TEXT_ALIGN_RIGHT)
	end
end
P:SetVisible(false)

local AList = vgui.Create("DPanelList",P)
AList:SetSize(280,320)
AList:SetPos(10,70)
AList.Init = function(Self)
	local function AddPly(P)
		local Pan = vgui.Create("DPanel")
		Pan:SetSize(280,20)
		Pan.Paint = function(self)
			if not P or not P:IsValid() then return end
			local Col1 = team.GetColor(1)
			local Name = P:Name()
			surface.SetFont("MenuLarge")
			if surface.GetTextSize(Name) > 160 then
				local Letter = surface.GetTextSize(string.Left(Name,1))
				local Difference = math.Round((surface.GetTextSize(Name) / Letter) - (160 / Letter))
				Name = string.Left(Name,string.len(Name) - Difference)
			end
			if P:Health() > 0 then
				draw.DrawText(Name,"MenuLarge",0,0,Color(Col1.r,Col1.g,Col1.b,A),TEXT_ALIGN_LEFT)
			else
				draw.DrawText(Name,"MenuLarge",0,0,Color(100,100,100,A),TEXT_ALIGN_LEFT)
			end
			draw.DrawText(tostring(P:Ping()),"MenuLarge",self:GetWide() - 50,0,Color(Col1.r,Col1.g,Col1.b,A),TEXT_ALIGN_RIGHT)
			draw.DrawText(tostring(P:Frags()),"MenuLarge",self:GetWide(),0,Color(Col1.r,Col1.g,Col1.b,A),TEXT_ALIGN_RIGHT)
			if P:GetNWBool("Medkit") then
				surface.SetTexture(surface.GetTextureID("Medkit"))
				surface.SetDrawColor(255,255,255,A)
				surface.DrawTexturedRect(180,0,20,20)
			end
		end
		Self:AddItem(Pan)
	end
	for I,P in pairs(team.GetPlayers(1)) do
		AddPly(P)
	end
end
local T1 = team.GetPlayers(1)
AList.Think = function(Self)
	if T1 ~= team.GetPlayers(1) then
		T1 = team.GetPlayers(1)
		Self:Clear()
		Self:Init(Self)
	end
end
AList.Paint = function() end

local BList = vgui.Create("DPanelList",P)
BList:SetSize(280,320)
BList:SetPos(310,70)
BList.Init = function(Self)
	local function AddPly(P)
		local Pan = vgui.Create("DPanel")
		Pan:SetSize(270,20)
		Pan.Paint = function(self)
			if not P or not P:IsValid() then return end
			local Col2 = team.GetColor(2)
			draw.DrawText(P:Name(),"MenuLarge",self:GetWide() / 2,0,Color(Col2.r,Col2.g,Col2.b,A),TEXT_ALIGN_CENTER)
			draw.DrawText(tostring(P:Ping()),"MenuLarge",0,0,Color(Col2.r,Col2.g,Col2.b,A),TEXT_ALIGN_LEFT)
			draw.DrawText(tostring(P:Frags()),"MenuLarge",self:GetWide(),0,Color(Col2.r,Col2.g,Col2.b,A),TEXT_ALIGN_RIGHT)
		end
		Self:AddItem(Pan)
	end
	for I,P in pairs(team.GetPlayers(2)) do
		AddPly(P)
	end
end
local T2 = team.GetPlayers(2)
BList.Think = function(Self)
	if T2 ~= team.GetPlayers(2) then
		T2 = team.GetPlayers(2)
		Self:Clear()
		Self:Init(Self)
	end
end
BList.Paint = function() end

function GM:ScoreboardShow()
	local Time = 1
	hook.Add("HUDPaint","FadeIn",function()
		if not P:IsVisible() then
			P:SetVisible(true)
		end
		Time = Time - 0.02
		A = 255 * (1 - Time)
		if A > 250 then
			A = 255
			hook.Remove("HUDPaint","FadeIn")
		end
	end)
end

function GM:ScoreboardHide()
	local Time = 1
	hook.Add("HUDPaint","FadeOut",function()
		Time = Time - 0.02
		A = 255 * Time
		if A < 5 then
			A = 0
			P:SetVisible(false)
			hook.Remove("HUDPaint","FadeOut")
		end
	end)
end

usermessage.Hook("RoundEnd",function(um)
	if SelfPly:Team() == 2 then
		RemoveTraplayer()
	end
	Ragdolls = {}
	local P3 = vgui.Create("DPanel")
	P3:SetSize(600,500)
	P3:SetPos(ScrW() / 2 - P3:GetWide() / 2,100)
	P3.Paint = function(self)
		draw.RoundedBox(8,0,0,self:GetWide(),self:GetTall(),Color(0,0,0,255))
		local Dead = {}
		for I,P in pairs(team.GetPlayers(1)) do
			if P:Health() <= 0 then
				table.insert(Dead,P)
			end	
		end
		surface.SetFont("HUDNumber")
		if #team.GetPlayers(1) == #Dead or GetGlobalInt("Arties") < GetGlobalInt("MaxArties") or (GetGlobalInt("Time") <= 0 and GetGlobalInt("ExtraTime") <= 0) then
			local Txt = "Traplayers win!"
			draw.RoundedBox(8,180,20,surface.GetTextSize(Txt),40,Color(255,0,0,255))
			draw.DrawText(Txt,"HUDNumber",self:GetWide() / 2,20,team.GetColor(2),TEXT_ALIGN_CENTER)
		else
			local Txt = "Scavengers win!"
			draw.RoundedBox(8,180,20,surface.GetTextSize(Txt),40,Color(0,255,0,255))
			draw.DrawText(Txt,"HUDNumber",self:GetWide() / 2,20,team.GetColor(1),TEXT_ALIGN_CENTER)
		end
	end
	local Show = vgui.Create("DPanelList",P3)
	Show:SetPos(30,90)
	Show:SetSize(P3:GetWide() - 60,P3:GetTall() - 120)
	Show:SetSpacing(10)
	Show:EnableVerticalScrollbar(false)
	Show:EnableHorizontal(false)
	Show.Paint = function(self)
		surface.SetDrawColor(150,150,150,255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end
	local Copy = table.Copy(RoundEndFuncs)
	for I = 1,4 do
		local Num = math.random(1,#Copy)
		local Text,Team = Copy[Num]()
		if Text == "" and #Copy > 1 then
			table.remove(Copy,Num)
			Num = math.random(1,#Copy)
			Text,Team = Copy[Num]()
		end
		if Text == "" and #Copy > 1 then
			table.remove(Copy,Num)
			Num = math.random(1,#Copy)
			Text,Team = Copy[Num]()
		end
		if Text == "" and #Copy > 1 then
			table.remove(Copy,Num)
			Num = math.random(1,#Copy)
			Text,Team = Copy[Num]()
		end
		local Color = team.GetColor(Team)
		local Lab = vgui.Create("DPanel")
		local Height
		if surface.GetTextSize(Text) > Show:GetWide() and surface.GetTextSize(Text) < Show:GetWide() * 2 then
			Height = 40
		elseif surface.GetTextSize(Text) > Show:GetWide() * 2 then
			Height = 60
		else
			Height = 20
		end
		Lab:SetSize(Show:GetWide(),Height)
		Lab.Paint = function()
			local h = 0
			local txt = ""
			surface.SetFont("MenuLarge")
			surface.SetTextColor(Color)
			for I,S in pairs(string.Explode(" ",Text)) do
				local H
				local t = txt..S.." "
				if surface.GetTextSize(t) > Show:GetWide() and surface.GetTextSize(t) < Show:GetWide() * 2 then
					H = 20
				elseif surface.GetTextSize(t) > Show:GetWide() * 2 then
					H = 40
				else
					H = 0
				end
				if surface.GetTextSize(txt) < Show:GetWide() and H > 0 then
					txt = ""
					h = 1
				elseif surface.GetTextSize(txt) > Show:GetWide() and surface.GetTextSize(txt) < Show:GetWide() * 2 and H > 20 then
					txt = ""
					h = 2
				end
				if H == 0 and h > 0 then
					H = 20*h
				end
				surface.SetTextPos((surface.GetTextSize(txt) + 5) % Show:GetWide(),H)
				surface.DrawText(S.." ")
				txt = txt..S.." "
			end
		end
		Show:AddItem(Lab)
		table.remove(Copy,Num)
	end
	local Labl = vgui.Create("DPanel")
	Labl:SetSize(60,20)
	Labl.Paint = function(self)
		draw.DrawText("You gained "..SelfPly:GetNWInt("ExpGain").." experience that round.","MenuLarge",0,0,Color(255,255,255,255),TEXT_ALIGN_LEFT)
	end
	Show:AddItem(Labl)
	local Btn = vgui.Create("DButton")
	Btn:SetSize(60,40)
	Btn:SetText("Vote for mapchange")
	Btn.DoClick = function()
		RunConsoleCommand("say","!rtv")
	end
	Show:AddItem(Btn)
	local Btn = vgui.Create("DButton")
	Btn:SetSize(60,40)
	Btn:SetText("Exit")
	Btn.DoClick = function()
		RoundEnd = false
		gui.EnableScreenClicker(false)
		P3:Remove()
	end
	Show:AddItem(Btn)
	gui.EnableScreenClicker(true)
end)

RoundEndFuncs = {}

local function InsertFunc(func)
	table.insert(RoundEndFuncs,func)
end

InsertFunc(function()
	local Teeam = team.GetPlayers(2)
	if not Teeam[1] then return "",3 end
	table.sort(Teeam,function(a,b) return a:Frags() > b:Frags() end)
	if Teeam[1]:Frags() <= 0 then return "",3 end
	return "The traplayer with the highest kills is "..Teeam[1]:Name()..". ("..Teeam[1]:Frags()..")",2
end)

InsertFunc(function()
	local Teeam = team.GetPlayers(1)
	if not Teeam[1] then return "",3 end
	table.sort(Teeam,function(a,b) return a:Frags() > b:Frags() end)
	return Teeam[1]:Name().." brought the most artifacts that round. ("..Teeam[1]:Frags()..")",1
end)

InsertFunc(function()
	local Teeam = team.GetPlayers(1)
	if not Teeam[1] then return "",3 end
	for I,P in pairs(Teeam) do
		if P:Health() > 0 then
			Teeam[I] = nil
			table.remove(Teeam,I)
		end
	end
	if not Teeam[1] then return "",3 end
	table.sort(Teeam,function(a,b) return a:GetNWInt("DeathTime") < b:GetNWInt("DeathTime") end)
	local Time = math.Round(Teeam[1]:GetNWInt("DeathTime") - GetGlobalInt("RoundStart"))
	if Time <= 0 then return "",3 end
	if Time < 60 then
		return Teeam[1]:Name().." died only "..Time.." seconds into the game.",1
	else
		return "The first one to go was "..Teeam[1]:Name().." when it was "..math.floor(Time/60).." minutes and "..(Time%60).." seconds from the start of the round.",1
	end
end)

InsertFunc(function()
	local Teeam = team.GetPlayers(2)
	if not Teeam[1] then return "",3 end
	local Num = math.random(1,#Teeam)
	local Ply = Teeam[Num]
	return "Traplayer \""..Ply:Name().."\" spawned "..Ply:GetNWInt("TrapsSpawned").." traps and removed "..Ply:GetNWInt("TrapsRemoved").." traps that round.",2
end)

InsertFunc(function()
	local Teeam = team.GetPlayers(1)
	if not Teeam[1] then return "",3 end
	table.sort(Teeam,function(a,b) return a:GetNWInt("DamageTaken") > b:GetNWInt("DamageTaken") end)
	if Teeam[1]:GetNWInt("DamageTaken") <= 0 then return "",3 end
	return "Scavenger with the most damage taken was "..Teeam[1]:Name()..". ("..math.Round(Teeam[1]:GetNWInt("DamageTaken"))..")",1
end)

InsertFunc(function()
	local Teeam = team.GetPlayers(1)
	if not Teeam[1] then return "",3 end
	local Num = math.random(1,#Teeam)
	local Ply = Teeam[Num]
	return "Scavenger \""..Ply:Name().."\" jumped "..Ply:GetNWInt("Jumped").." times that round.",1
end)

InsertFunc(function()
	local Teeam = team.GetPlayers(1)
	if not Teeam[1] then return "",3 end
	local Num = math.random(1,#Teeam)
	local Ply = Teeam[Num]
	local Dist = math.Round(Ply:GetNWInt("DistanceTravelled") / 100)
	return "Scavenger \""..Ply:Name().."\" travelled "..Dist.." meters that round.",1
end)

InsertFunc(function()
	local Teeam = team.GetPlayers(1)
	if not Teeam[1] then return "",3 end
	table.sort(Teeam,function(a,b) return a:GetNWInt("Triggered") > b:GetNWInt("Triggered") end)
	if Teeam[1]:GetNWInt("Triggered") <= 0 then return "",3 end
	local Ply = Teeam[1]
	return "Scavenger \""..Ply:Name().."\" triggered the most traps. ("..Ply:GetNWInt("Triggered")..")",1
end)

InsertFunc(function()
	local Teeam = team.GetPlayers(1)
	if not Teeam[1] then return "",3 end
	table.sort(Teeam,function(a,b) return a:GetNWInt("Pinged") > b:GetNWInt("Pinged") end)
	if Teeam[1]:GetNWInt("Pinged") <= 0 then return "",3 end
	local ply = Teeam[1]
	return "Scavenger \""..ply:Name().."\" pinged the most artifacts. ("..ply:GetNWInt("Pinged")..")",1
end)

InsertFunc(function()
	local Teeam = team.GetPlayers(1)
	if not Teeam[1] then return "",3 end
	table.sort(Teeam,function(a,b) return a:GetNWInt("Defused") > b:GetNWInt("Defused") end)
	if Teeam[1]:GetNWInt("Defused") <= 0 then return "",3 end
	return "Scavenger with the defuser, defused "..Teeam[1]:GetNWInt("Defused").." traps.",1
end)

InsertFunc(function()
	local Time = math.Round(CurTime() - GetGlobalInt("RoundStart"))
	if Time > 60 then
		return "That round lasted for "..math.Round(Time / 60).." minutes and "..(Time%60).." seconds.",3
	else
		return "that round lasted only "..Time.." seconds.",3
	end
end)