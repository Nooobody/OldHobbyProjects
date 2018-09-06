
net.Receive("SA_Message",function(len)
	local txt = net.ReadString()
	local b = net.ReadInt(4)
	if b == C_CHAT then
		chat.AddText(Color(255,215,0,255),"{SYSTEM} ",Color(127,230,80,255),txt)
	elseif b == C_PRINT then
		chat.AddText(Color(255,215,0,255),txt)
	elseif b == C_ADMIN then
		local ply = net.ReadString()
		local Team = net.ReadInt(4)
		chat.AddText(Color(255,215,0,255),"{STAFF} ",team.GetColor(Team),ply,Color(127,230,80,255),": "..txt)
	elseif b == C_SHOUT then
		if SA_a and SA_a:IsValid() then SA_a:Remove() end
		local Lines = {txt}
		if string.find(txt,"\n") then
			Lines = string.Split(txt,"\n")
		end
		SA_a = vgui.Create("DPanel")
		surface.SetFont("DermaLarge")
		SA_a:SetSize(surface.GetTextSize(txt) + 10,200)
		SA_a:SetPos(ScrW() / 2 - SA_a:GetWide() / 2,200)
		SA_a.V = 255
		SA_a.Paint = function(self)
			self.V = self.V - 0.2
			local T = self.V / 255
			for I,P in pairs(Lines) do
				draw.DrawText(P,"DermaLarge",self:GetWide() / 2,40 * (I - 1),Color(255,255,255,255 * T),TEXT_ALIGN_CENTER)
			end
			
			if self.V <= 0 then
				SA_a:Remove()
			end
		end
	end
end)

net.Receive("SA_PlayerJoinLeave",function(len)
	local Name = net.ReadString()
	local Team = team.GetColor(net.ReadInt(4))
	local Type = net.ReadInt(4)
	
	if Type == PLAYER_JOIN then
		chat.AddText(Color(127,230,80,255),"### ",Team,Name,Color(127,230,80,255)," has started connecting!")
	elseif Type == PLAYER_AUTH then
		if IsValid(LocalPlayer()) and Name == LocalPlayer():Name() then
			chat.AddText(Color(127,230,80,255),"### ",Color(127,230,80,255),"Welcome, to SpaceAge - Reloaded, ",Team,Name)
		else
			chat.AddText(Color(127,230,80,255),"### ",Team,Name,Color(127,230,80,255)," has finished connecting!")
		end
	elseif Type == PLAYER_DISC then
		chat.AddText(Color(127,230,80,255),"### ",Team,Name,Color(127,230,80,255)," has disconnected!")
		chat.AddText(Color(127,230,80,255),"### ",Color(127,230,80,255),"Reason: "..net.ReadString())
	end
end)

CHAT = {}

function GM:OnPlayerChat(Ply,Text,BoolTeam,BoolDead)
	local IsPly = IsValid(Ply)
	local Team = 3
	local Name = "Console"
	local Tab = {}
	
	if IsPly then
		local P = tonumber(Ply:GetPrivilege())
		if P > tonumber(PRIV_USER) then
			local Pr = PRIVs[P]
			if not Pr then
				if P >= PRIV_OWNER then Pr = PRIVs[PRIV_OWNER]
				elseif P >= PRIV_ADMIN then Pr = PRIVs[PRIV_ADMIN]
				elseif P >= PRIV_MOD then Pr = PRIVs[PRIV_MOD] end
			end
			table.insert(Tab,Pr.Color)
			table.insert(Tab,"["..Pr.Tag.."] ")
		end	
		Team = team.GetColor(Ply:Team())
		Name = Ply:Name()
		if Ply:GetNWString("Nick") ~= "" then
			Name = Name.." \""..Ply:GetNWString("Nick").."\""
		end
	end
	
	if BoolDead then
		table.insert(Tab,Color(188,143,143))
		table.insert(Tab,"*DEAD* ")
	end
	
	if BoolTeam then
		table.insert(Tab,Color(173,255,47))
		table.insert(Tab,"*TEAM* ")
	end
	
	if IsPly then
		table.insert(Tab,Ply:GetFact().Col)
		table.insert(Tab,Name)
	else
		table.insert(Tab,Color(math.random(100,255),math.random(100,255),math.random(100,255)))
		table.insert(Tab,"Console")
	end
	
	table.insert(Tab,Color(245,245,255))
	table.insert(Tab,": "..Text)
	
	chat.AddText(unpack(Tab))
	if not IsValid(LocalPlayer()) then return true end
	if CHAT.Muted then return true end
	if Ply == LocalPlayer() then
		LocalPlayer():EmitSound(Sound("ui/buttonclickrelease.wav"))
	else
		LocalPlayer():EmitSound(Sound("ui/buttonclick.wav"))
	end
	return true
end

local LogInd = 0

function SaveChat()
	CHAT.BG = CHAT.BG or Color(0,0,0,100)
	CHAT.Border = CHAT.Border or Color(255,255,255,255)
	local Str = "X="..CHAT.X.."\r\n"
	Str = Str.."Y="..CHAT.Y.."\r\n"
	Str = Str.."W="..CHAT.W.."\r\n"
	Str = Str.."H="..CHAT.H.."\r\n"
	local B = 0
	if CHAT.Muted then B = 1 end
	Str = Str.."Muted="..B.."\r\n"
	local b = 0
	if CHAT.Toggle then b = 1 end
	Str = Str.."Toggle="..b.."\r\n"
	Str = Str.."BG="..CHAT.BG.r..","..CHAT.BG.g..","..CHAT.BG.b..","..CHAT.BG.a.."\r\n"
	Str = Str.."Border="..CHAT.Border.r..","..CHAT.Border.g..","..CHAT.Border.b..","..CHAT.Border.a
	file.Write("ChatSettings.txt",Str)
end

function LoadChat()
	if not file.Exists("ChatSettings.txt","DATA") then return end
	local Str = file.Read("ChatSettings.txt")
	local Lines = string.Split(Str,"\r\n")
	for I,P in pairs(Lines) do
		local L = string.Split(P,"=")
		if L[1] == "X" or L[1] == "Y" or L[1] == "W" or L[1] == "H" then
			CHAT[L[1]] = tonumber(L[2])
		elseif L[1] == "Muted" or L[1] == "Toggle" then
			CHAT[L[1]] = tonumber(L[2]) == 1
		elseif L[1] == "BG" or L[1] == "Border" then
			local Col = string.Split(L[2],",")
			CHAT[L[1]] = Color(Col[1],Col[2],Col[3],Col[4])
		end
	end
end

concommand.Add("SA_ChangeChat",function(ply,cmd,arg)
	local Vgui = vgui.Create("DPanel")
	Vgui:SetPos(0,0)
	Vgui:SetSize(ScrW(),ScrH())
	Vgui:MakePopup()
	Vgui.Paint = function(self)
		surface.SetDrawColor(200,200,200,80)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		draw.DrawText("Hold left mouse button to create a rectangle","Futuristic",self:GetWide() / 2,100,Color(0,0,0,255),TEXT_ALIGN_CENTER)
		draw.DrawText("To define a new chatbox Position and Size.","Futuristic",self:GetWide() / 2,120,Color(0,0,0,255),TEXT_ALIGN_CENTER)
		if self.MouseX and self.MouseY then
			surface.SetDrawColor(0,0,0,255)
			surface.DrawRect(self.MouseX,self.MouseY,gui.MouseX() - self.MouseX,gui.MouseY() - self.MouseY)
		end
	end
	Vgui.OnMousePressed = function(self)
		self.MouseX,self.MouseY = gui.MouseX(),gui.MouseY()
	end
	Vgui.OnMouseReleased = function(self)
		local W,H = math.Clamp(gui.MouseX() - self.MouseX,200,2000),math.Clamp(gui.MouseY() - self.MouseY,40,2000)
		CHAT.X = self.MouseX
		CHAT.Y = self.MouseY
		CHAT.W = W
		CHAT.H = H
		SaveChat()
		self:Remove()
		Chat:Remove()
		ChatAnchor:Remove()
		CreateChat()
		LogInd = 0
		AddOldChat(true)/*
		Chat:SetPos(self.MouseX,self.MouseY)
		Chat:SetSize(W,H - 20)
		ChatText:SetSize(Chat:GetSize())
		ChatAnchor:SetSize(Chat:GetWide(),20)
		local X,Y = Chat:GetPos()
		ChatAnchor:SetPos(X,Y + Chat:GetTall())
		TextEntry:SetSize(ChatAnchor:GetWide() - 60,20)
		TextBtn:SetPos(ChatAnchor:GetWide() - 60,0)
		local X,Y = Chat:GetPos()*/
	end
end)

concommand.Add("SA_DefaultChat",function(ply,cmd,arg)
	CHAT.X = 60
	CHAT.Y = ScrH() - 280
	CHAT.W = 600
	CHAT.H = 200
	SaveChat()
	Chat:Remove()
	ChatAnchor:Remove()
	CreateChat()
	LogInd = 0
	AddOldChat(true)/*
	Chat:SetSize(600,200)
	Chat:SetPos(60,ScrH() - 280)
	ChatText:SetSize(Chat:GetSize())
	ChatAnchor:SetSize(Chat:GetWide(),20)
	local X,Y = Chat:GetPos()
	ChatAnchor:SetPos(X,Y + 200)
	TextEntry:SetSize(ChatAnchor:GetWide() - 60,20)
	TextBtn:SetPos(ChatAnchor:GetWide() - 60,0)
	local X,Y = Chat:GetPos()*/
end)

function SaveChatColors()
	local Col1 = BG_COLOR or Color(0,0,0,200)
	local Col2 = BORDER_COLOR or team.GetColor(LocalPlayer():Team())
	CHAT.BG = Col1
	CHAT.Border = Col2
	SaveChat()
end

LoadChat()
local ClientLog = {}
local Ind = 0

function CreateChat()
	if file.Exists("ChatPosSize.txt","DATA") then
		local File = file.Read("ChatPosSize.txt","DATA")
		local Explode = string.Explode(",",File)
		local X,Y,W,H = Explode[1],Explode[2],Explode[3],Explode[4]
		CHAT.X = X
		CHAT.Y = Y
		CHAT.W = W
		CHAT.H = H
		SaveChat()
		file.Delete("ChatPosSize.txt")
	end
	
	if file.Exists("ChatColors.txt","DATA") then
		local Str = file.Read("ChatColors.txt","DATA")
		local Lines = string.Split(Str," ")
		local BG = string.Split(Lines[1],",")
		BG_COLOR = Color(BG[1],BG[2],BG[3],BG[4])
		local Border = string.Split(Lines[2],",")
		BORDER_COLOR = Color(Border[1],Border[2],Border[3],Border[4])
		CHAT.BG = BG_COLOR
		CHAT.Border = BORDER_COLOR
		SaveChat()
		file.Delete("ChatColors.txt")
	end
	
	if file.Exists("ChatToggle.txt","DATA") then
		local Str = file.Read("ChatToggle.txt","DATA")
		local Num = tonumber(Str) == 1
		CHAT.Toggle = Num
		SaveChat()
		file.Delete("ChatToggle.txt")
	end
	
	if Chat and Chat:IsValid() then
		Chat:Remove()
	end
	if ChatAnchor and ChatAnchor:IsValid() then
		ChatAnchor:Remove()
	end
	Chat = vgui.Create("DPanel")
	if not file.Exists("ChatSettings.txt","DATA") then
		CHAT.W = 600
		CHAT.H = 200
		CHAT.Muted = false
		CHAT.X = 60
		CHAT.Y = ScrH() - 280
		CHAT.BG = Color(0,0,0)
		CHAT.Border = Color(255,255,255)
		CHAT.Toggle = false
		Chat:SetSize(600,200)
		Chat:SetPos(60,ScrH() - 280)
		BG_COLOR = CHAT.BG
		BORDER_COLOR = CHAT.Border
		SaveChat()
	else
		Chat:SetSize(CHAT.W,CHAT.H)
		Chat:SetPos(CHAT.X,CHAT.Y)
		BG_COLOR = CHAT.BG or Color(0,0,0)
		BORDER_COLOR = CHAT.Border or Color(255,255,255)
		DefaultChatEnabled = CHAT.Toggle
	end
	Chat.Paint = function(self,w,h)
		if IsValid(ChatAnchor) and ChatAnchor:IsVisible() then
			local Col = BORDER_COLOR
			surface.SetDrawColor(BG_COLOR or Color(0,0,0,200))
			surface.DrawRect(0,0,w,h)
			draw.DrawTransBox(0,0,w,h,Col)
			draw.DrawTransBox(20,20,w - 40,Chat:GetTall() - 70,Col)
			draw.DrawTransBox(20,h - 30,w - 40,20,Col)
		end
	end
	ChatText = vgui.Create("RichText",Chat)
	ChatText:SetPos(20,20)
	ChatText:SetSize(Chat:GetWide() - 40,Chat:GetTall() - 70)
	ChatText:SetFGColor(Color(255,255,255))
	ChatText:SetVerticalScrollbarEnabled(false)
	local Pnt = ChatText.Paint
	ChatText.Paint = function(self)
		self.m_FontName = "ChatFont"
		self:SetFontInternal("ChatFont")
		self.Paint = Pnt
	end
	ChatAnchor = vgui.Create("DFrame")
	ChatAnchor:SetSize(Chat:GetWide() - 40,20)
	local X,Y = Chat:GetPos()
	ChatAnchor:SetPos(X + 20,Y + Chat:GetTall() - 30)
	ChatAnchor:SetTitle("")
	ChatAnchor:ShowCloseButton(false)
	ChatAnchor:MakePopup()
	ChatAnchor.Paint = function()
	end
	ChatAnchor:SetVisible(false)
	TextEntry = vgui.Create("DTextEntry",ChatAnchor)
	TextEntry:SetPos(2,0)
	TextEntry:SetSize(ChatAnchor:GetWide() - 60,20)
	TextEntry:SetMultiline(false)
	TextEntry:RequestFocus()
	TextEntry:SetDrawBackground(false)
	TextEntry:SetDrawBorder(false)
	TextEntry:SetTextColor(Color(255,255,255))
	TextEntry.OnEnter = function(self)
		local Parent = self:GetParent()
		ChatText:ResetAllFades(false,true,0)
		Parent:SetVisible(false)
		ChatText:SetVerticalScrollbarEnabled(false)
		Ind = 0
		if self:GetValue() != "" then
			local Str = self:GetValue()
			string.Replace(Str,"'","\"")
			AddText(self:GetValue(),TeamP:IsVisible())
			self:SetText("")
		end
		if TeamP:IsVisible() then
			TeamP:SetVisible(false)
			self:SetPos(0,0)
			self:SetSize(Parent:GetWide() - 60,20)
		end
	end
	TextEntry.OnTextChanged = function(self,Panel)
		if string.len(self:GetValue()) > 124 then
			self:SetText(string.sub(self:GetValue(),0,124))
			self:SetCaretPos(124)
		end
	end
	TextEntry.OnKeyCodeTyped = function(self,code)
		if code == KEY_ESCAPE then
			self:SetText("")
			self:OnEnter()
		elseif code == KEY_ENTER then
			self:FocusNext()
			self:OnEnter()
		elseif code == KEY_BACKSPACE and self:GetValue() == "" then
			self:OnEnter()
		elseif code == KEY_UP then
			Ind = Ind - 1
			if Ind < 0 then Ind = #ClientLog end
			if Ind == 0 then self:SetText("")
			else self:SetText(ClientLog[Ind]) end
			self:SetCaretPos(string.len(self:GetValue()))
		elseif code == KEY_DOWN then
			Ind = Ind + 1
			if Ind > #ClientLog then Ind = 0 end
			if Ind == 0 then self:SetText("")
			else self:SetText(ClientLog[Ind]) end
			self:SetCaretPos(string.len(self:GetValue()))
		end
	end
	TextEntry.OnLoseFocus = function(self)
		if self:GetValue() == "" then
			self:OnEnter()
		end
	end
	TeamP = vgui.Create("DPanel",ChatAnchor)
	TeamP:SetSize(60,20)
	TeamP:SetPos(0,2)
	TeamP.Paint = function(self)
		draw.DrawText("Team","LucidaSmall",30,2,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	end
	TeamP:SetVisible(false)
	TextBtn = vgui.Create("DButton",ChatAnchor)
	TextBtn:SetSize(60,20)
	TextBtn:SetPos(ChatAnchor:GetWide() - 60,0)
	TextBtn:SetText("")
	TextBtn.Paint = function(self)
		draw.DrawText("Chat","LucidaSmall",30,2,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	end
	TextBtn.DoClick = TextEntry.OnEnter
end

local ChatLog = {}
	
local Chat_Color = 1
local Chat_ColorEnd = 2
local Chat_Link = 3
local Chat_Text = 4
local Hex = {["0"] = 0,["1"] = 1,["2"] = 2,["3"] = 3,["4"] = 4,["5"] = 5,["6"] = 6,["7"] = 7,["8"] = 8,["9"] = 9,["a"] = 10,["b"] = 11,["c"] = 12,["d"] = 13,["e"] = 14,["f"] = 15}

local function ParseString(Str,Tab)
	Tab = Tab or {}
	if string.find(Str,"[#",nil,true) then
		local Num = string.find(Str,"[#",nil,true)
		if Str[Num + 5] == "]" or Str[Num + 8] == "]" then
			local Col = Color(255,255,255)
			local End
			if Str[Num + 5] == "]" then
				local S = string.sub(Str,Num + 2,Num + 4)
				Col.r = Hex[string.lower(S[1])] * 16
				Col.g = Hex[string.lower(S[2])] * 16
				Col.b = Hex[string.lower(S[3])] * 16
				End = 6
			else
				local S = string.sub(Str,Num + 2,Num + 7)
				Col.r = Hex[string.lower(S[2])] * 16 + Hex[string.lower(S[1])]
				Col.g = Hex[string.lower(S[4])] * 16 + Hex[string.lower(S[3])]
				Col.b = Hex[string.lower(S[6])] * 16 + Hex[string.lower(S[5])]
				End = 9
			end
			local Str1
			local Str2
			if Num > 1 then
				Str1 = string.sub(Str,0,Num - 1)
				Str2 = string.sub(Str,Num + End)
				Tab = ParseString(Str1,Tab)
			else
				Str2 = string.sub(Str,End)
			end
			table.insert(Tab,{ID = Chat_Color,Col = Col})
			return ParseString(Str2,Tab)
		end
	end
	
	if string.find(Str,"[/#]",nil,true) then
		local Num = string.find(Str,"[/#]",nil,true)
		local Str1
		local Str2
		if Num > 1 then
			Str1 = string.sub(Str,0,Num - 1)
			Str2 = string.sub(Str,Num + 4)
			Tab = ParseString(Str1,Tab)
		else
			Str2 = string.sub(Str,5)
		end
		table.insert(Tab,{ID = Chat_ColorEnd})
		return ParseString(Str2,Tab)
	end
	
	if string.find(string.lower(Str),"http://",nil,true) or string.find(string.lower(Str),"www.",nil,true) then
		local Split = string.Split(Str," ")
		local Whole
		for I,P in pairs(Split) do
			if string.StartWith(string.lower(P),"http://") or string.StartWith(string.lower(P),"www.") then
				Whole = P
				break
			end
		end
		if Whole then
			local Num = string.find(string.lower(Str),"http://",nil,true) or string.find(string.lower(Str),"www.",nil,true)
			local End = Num + string.len(Whole)
			local Str1
			local Str2
			if Num > 1 then
				Str1 = string.sub(Str,0,Num - 1)
				Str2 = string.sub(Str,End)
				Tab = ParseString(Str1,Tab)
			else
				Str2 = string.sub(Str,End)
			end
			table.insert(Tab,{ID = Chat_Link,Text = Whole})
			return ParseString(Str2,Tab)
		end
	end
	
	table.insert(Tab,{ID = Chat_Text,Text = Str})
	return Tab
end
	
function AddOldChat(Positioned)
	local Num
	if DefaultChatEnabled then Num = 0 else Num = 1 end
	CHAT.Toggle = DefaultChatEnabled
	SaveChat()
	if DefaultChatEnabled then 
		LogInd = #ChatLog
		return 
	end
	for I,Tab in pairs(ChatLog) do
		if I >= LogInd then
			for I,P in pairs(Tab) do
				if type(P) == "string" then
					local Parsed = ParseString(P)
					for Ind,T in pairs(Parsed) do
						if T.ID == Chat_Color then
							ChatText:InsertColorChange(T.Col.r,T.Col.g,T.Col.b,255)
							ChatText:InsertFade(12,3)
						elseif T.ID == Chat_ColorEnd then
							ChatText:InsertColorChange(255,255,255,255)
							ChatText:InsertFade(12,3)
						elseif T.ID == Chat_Link then
							ChatText:InsertClickableTextStart(T.Text)
							ChatText:AppendText(T.Text)
							ChatText:InsertClickableTextEnd()
						elseif T.ID == Chat_Text then
							ChatText:AppendText(T.Text)
						end
					end
				elseif type(P) == "table" then
					LastColor = P
					ChatText:InsertColorChange(P.r,P.g,P.b,P.a or 255)
					ChatText:InsertFade(12,3)
				elseif type(P) == "Player" then
					local Col = team.GetColor(P:Team())
					LastColor = Col
					ChatText:InsertColorChange(Col.r,Col.g,Col.b,Col.a or 255)
					ChatText:InsertFade(12,3)
					ChatText:AppendText(P:Name())
				end
			end
			ChatText:AppendText("\n")
		end
	end
	LogInd = #ChatLog
	if Positioned then return end
	chat.AddText(Color(255,215,0,255),"You can use !chat command to get further info on using this chatbox!")
end

if not AlreadyLoaded then
	local OldAddText = chat.AddText
	AlreadyLoaded = true
	function chat.AddText(...)
		local Tab = {...}
		OldAddText(unpack(Tab))
		table.insert(ChatLog,Tab)
		if not DefaultChatEnabled then
			for I,P in pairs(Tab) do
				if type(P) == "string" then
					local Parsed = ParseString(P)
					for Ind,T in pairs(Parsed) do
						if T.ID == Chat_Color then
							ChatText:InsertColorChange(T.Col.r,T.Col.g,T.Col.b,255)
							ChatText:InsertFade(12,3)
						elseif T.ID == Chat_ColorEnd then
							ChatText:InsertColorChange(255,255,255,255)
							ChatText:InsertFade(12,3)
						elseif T.ID == Chat_Link then
							ChatText:InsertClickableTextStart(T.Text)
							ChatText:AppendText(T.Text)
							ChatText:InsertClickableTextEnd()
						elseif T.ID == Chat_Text then
							ChatText:AppendText(T.Text)
						end
					end
				elseif type(P) == "table" then
					LastColor = P
					ChatText:InsertColorChange(P.r,P.g,P.b,P.a or 255)
					ChatText:InsertFade(12,3)
				elseif type(P) == "Player" then
					local Col = team.GetColor(P:Team())
					LastColor = Col
					ChatText:InsertColorChange(Col.r,Col.g,Col.b,Col.a or 255)
					ChatText:InsertFade(12,3)
					ChatText:AppendText(P:Name())
				end
			end
			ChatText:AppendText("\n")
		end
	end
end

concommand.Add("ResetChat",function()
	chat.AddText = OldAddText
end)

function AddText(Str,IsTeam)
	table.insert(ClientLog,Str)
	if IsTeam then
		RunConsoleCommand("say_team",Str)
	else
		RunConsoleCommand("say",Str)
	end
end

function StartChat()
	if DefaultChatEnabled or not IsValid(ChatText) then return end
	ChatText:SetVerticalScrollbarEnabled(true)
	ChatText:ResetAllFades(true,false,0)
	ChatAnchor:SetVisible(true)
	TextEntry:RequestFocus()
end

function StartTeamChat()
	if DefaultChatEnabled or not IsValid(ChatText) then return end
	ChatText:SetVerticalScrollbarEnabled(true)
	ChatText:ResetAllFades(true,false,0)
	ChatAnchor:SetVisible(true)
	TextEntry:RequestFocus()
	TeamP:SetVisible(true)
	TextEntry:SetPos(60,ChatAnchor:GetTall() - 20)
	TextEntry:SetSize(ChatAnchor:GetWide() - 120,20)
end