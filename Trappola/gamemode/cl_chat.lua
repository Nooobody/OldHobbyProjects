local Chat
local TextEntry
local TextBtn
local TeamP

concommand.Add("Trappola_ChangeChat",function(ply,cmd,arg)
	local Vgui = vgui.Create("DPanel")
	Vgui:SetPos(0,0)
	Vgui:SetSize(ScrW(),ScrH())
	Vgui:MakePopup()
	Vgui.Paint = function(self)
		surface.SetDrawColor(200,200,200,100)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		draw.DrawText("Hold left mouse button to create a rectangle","MenuLarge",self:GetWide() / 2,100,Color(0,0,0,255),TEXT_ALIGN_CENTER)
		draw.DrawText("To define a new chatbox Position and Size.","MenuLarge",self:GetWide() / 2,120,Color(0,0,0,255),TEXT_ALIGN_CENTER)
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
		Chat:SetPos(self.MouseX,self.MouseY)
		Chat:SetSize(W,H - 20)
		ChatAnchor:SetSize(Chat:GetWide(),20)
		local X,Y = Chat:GetPos()
		ChatAnchor:SetPos(X,Y + Chat:GetTall())
		TextEntry:SetSize(ChatAnchor:GetWide() - 60,20)
		TextBtn:SetPos(ChatAnchor:GetWide() - 60,0)
		self:Remove()
		Chat:Rebuild()
		local X,Y = Chat:GetPos()
		file.Write("ChatPosSize.txt",X..","..Y..","..Chat:GetWide()..","..Chat:GetTall())
	end
end)

concommand.Add("Trappola_DefaultChat",function(ply,cmd,arg)
	Chat:SetSize(600,200)
	Chat:SetPos(60,ScrH() - 280)
	ChatAnchor:SetSize(Chat:GetWide(),20)
	local X,Y = Chat:GetPos()
	ChatAnchor:SetPos(X,Y + 200)
	TextEntry:SetSize(ChatAnchor:GetWide() - 60,20)
	TextBtn:SetPos(ChatAnchor:GetWide() - 60,0)
	Chat:Rebuild()
	local X,Y = Chat:GetPos()
	file.Write("ChatPosSize.txt",X..","..Y..",600,200")
end)

function CreateChat()
	if Chat and Chat:IsValid() then
		Chat:Remove()
	end
	if ChatAnchor and ChatAnchor:IsValid() then
		ChatAnchor:Remove()
	end
	Chat = vgui.Create("DPanelList")
	if not file.Exists("ChatPosSize.txt") then
		Chat:SetSize(600,200)
		Chat:SetPos(60,ScrH() - 280)
		local X,Y = Chat:GetPos()
		file.Write("ChatPosSize.txt",X..","..Y..",600,200")
	else
		local File = file.Read("ChatPosSize.txt")
		local Explode = string.Explode(",",File)
		local X,Y,W,H = Explode[1],Explode[2],Explode[3],Explode[4]
		Chat:SetSize(W,H)
		Chat:SetPos(X,Y)
	end
	Chat:SetSpacing(0)
	Chat:EnableVerticalScrollbar(true)
	Chat:EnableHorizontal(false)
	Chat.Paint = function(self)
		if LobbyPanel:IsVisible() or ChatAnchor:IsVisible() then
			surface.SetDrawColor(0,0,0,255)
			local Tall = 0
			for I,P in pairs(self:GetItems()) do
				Tall = Tall + P:GetTall()
			end
			if Tall > self:GetTall() then
				self.VBar:SetVisible(true)
			end
		else
			surface.SetDrawColor(0,0,0,0)
			self.VBar:SetVisible(false)
		end
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end
	ChatAnchor = vgui.Create("DFrame")
	ChatAnchor:SetSize(Chat:GetWide(),20)
	local X,Y = Chat:GetPos()
	ChatAnchor:SetPos(X,Y + Chat:GetTall())
	ChatAnchor:SetTitle("")
	ChatAnchor:ShowCloseButton(false)
	ChatAnchor:MakePopup()
	ChatAnchor.Paint = function()
	end
	TextEntry = vgui.Create("DTextEntry",ChatAnchor)
	TextEntry:SetPos(0,0)
	TextEntry:SetSize(ChatAnchor:GetWide() - 60,20)
	TextEntry:SetMultiline(false)
	TextEntry:RequestFocus()
	TextEntry.OnEnter = function(self)
		local Parent = self:GetParent()
		if not LobbyPanel:IsVisible() then
			Parent:SetVisible(false)
		end
		if self:GetValue() != "" then
			if self:GetValue() == "!Exit" and LobbyPanel:IsVisible() then
				AddText("!Exit")
				LobbyPanel:SetVisible(false)
				Parent:SetVisible(false)
			elseif self:GetValue() != "!Exit" then
				AddText(self:GetValue(),TeamP:IsVisible())
			end
			self:SetText("")
			if LobbyPanel:IsVisible() then
				self:RequestFocus()
			end
		end
		if TeamP:IsVisible() then
			TeamP:SetVisible(false)
			self:SetPos(0,0)
			self:SetSize(Parent:GetWide() - 60,20)
		end
	end
	TextEntry.OnKeyCodeTyped = function(self,code)
		if code == KEY_ENTER and !self:IsMultiline() and self:GetEnterAllowed() then
			self:FocusNext()
			self:OnEnter()
		elseif code == KEY_BACKSPACE and self:GetValue() == "" then
			self:OnEnter()
		end
	end
	TeamP = vgui.Create("DPanel",ChatAnchor)
	TeamP:SetSize(60,20)
	TeamP:SetPos(0,0)
	TeamP.Paint = function(self)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		draw.DrawText("Team","MenuLarge",30,2,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	end
	TeamP:SetVisible(false)
	TextBtn = vgui.Create("DButton",ChatAnchor)
	TextBtn:SetSize(60,20)
	TextBtn:SetPos(ChatAnchor:GetWide() - 60,0)
	TextBtn:SetText("")
	TextBtn.Paint = function(self)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		draw.DrawText("Chat","MenuLarge",30,2,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	end
	TextBtn.DoClick = TextEntry.OnEnter
end

function GM:OnPlayerChat(Ply,Text,BoolTeam,BoolDead)
	local IsPly = IsValid(Ply)
	local Team = 3
	local Name = "Console"
	if IsPly then
		Team = team.GetColor(Ply:Team())
		Name = Ply:Name()
	end
	local Time = 10
	local Tab = {}
	
	if BoolDead then
		table.insert(Tab,Color(188,143,143))
		table.insert(Tab,"*DEAD* ")
	end
	
	if BoolTeam then
		table.insert(Tab,Color(173,255,47))
		table.insert(Tab,"*TEAM* ")
	end
	
	if IsPly then
		table.insert(Tab,Team)
		table.insert(Tab,Name)
	else
		table.insert(Tab,Color(math.random(100,255),math.random(100,255),math.random(100,255)))
		table.insert(Tab,"Console")
	end
	
	table.insert(Tab,Color(245,245,255))
	table.insert(Tab,": "..Text)
	
	chat.AddText(unpack(Tab))
	/*
	T.Paint = function(self)
		if Height ~= 20 + (20 * math.floor(Start / (Chat:GetWide() - 14))) then
			self:SetSize(self:GetWide(),20 + (20 * math.floor(Start / (Chat:GetWide() - 14))))
		end
		if Time > 5 then
			Time = Time - 0.01
		elseif Time > 0.1 and Time <= 5 then
			Time = Time - 0.1
		else
			Time = 0
		end
		
		local A
		if Time > 5 then
			A = 255
		else
			A = 255 * (Time / 5)
		end
		
		if ChatAnchor:IsVisible() then
			A = 255
		end
		
		surface.SetFont("ChatFont")
		local txt = ""
		
		if BoolDead then
			surface.SetTextColor(188,143,143,A)
			surface.SetTextPos(5,0)
			surface.DrawText("*DEAD* ")
			txt = txt.."*DEAD* "
		end
		
		if BoolTeam then
			surface.SetTextColor(173,255,47,A)
			surface.SetTextPos(surface.GetTextSize(txt) + 5,0)
			surface.DrawText("*TEAM* ")
			txt = txt.."*TEAM* "
		end
		
		if IsPly then
			surface.SetTextColor(Team.r,Team.g,Team.b,A)
			surface.SetTextPos(surface.GetTextSize(txt) + 5,0)
			surface.DrawText(Name)
			txt = txt..Name
		else
			surface.SetTextColor(math.random(0,255),math.random(0,255),math.random(0,255),A)
			surface.SetTextPos(surface.GetTextSize(txt) + 5,0)
			surface.DrawText("Console")
			txt = txt.."Console"
		end
		
		surface.SetTextColor(248,248,255,A)
		surface.SetTextPos(surface.GetTextSize(txt) + 5,0)
		surface.DrawText(": ")
		txt = txt..": "
		local Expl = string.Explode(" ",Text)
		local h = 0
		local t = txt
		local H
		local Wide = Chat:GetWide() - 14
		for I,S in pairs(Expl) do
			t = t..S.." "
			if surface.GetTextSize(t) <= Wide then
				H = 0
			elseif surface.GetTextSize(t) > Wide * (h + 1) then
				H = 20 * (h + 1)
				txt = ""
				h = h + 1
			end
			surface.SetTextPos((surface.GetTextSize(txt) + 5) % Wide,H)
			surface.DrawText(S.." ")
			txt = txt..S.." "
		end
	end
	local Bottom = Chat.VBar:GetScroll() == Chat.VBar.CanvasSize
	Chat:AddItem(T)
	timer.Simple(0.01,function()
		if Bottom then
			Chat.VBar:SetScroll(Chat.VBar.CanvasSize)
		end
	end)
	*/
	if ChatSound:GetBool() then
		if Ply == SelfPly then
			SelfPly:EmitSound(Sound("ui/buttonclickrelease.wav"))
		else
			SelfPly:EmitSound(Sound("ui/buttonclick.wav"))
		end
	end
	return true
end

local OldAddText = chat.AddText

function chat.AddText(...)
	local Tab = {...}
	local T = vgui.Create("DPanel")
	local tx = ""
	for I,P in pairs(Tab) do
		if type(P) == "string" then
			for a,W in pairs(string.ToTable(P)) do
				tx = tx..W
			end
		end
	end
	local Clone = table.Copy(Tab)
	table.insert(Clone,1,Color(255,255,255,255))
	table.insert(Clone,2,os.date().." - ")
	OldAddText(unpack(Clone))
	surface.SetFont("Chatfont")
	local Wide = Chat:GetWide() - 20
	local txsize = surface.GetTextSize(tx)
	local Height = 20 + (20 * math.floor(txsize / Wide))
	T:SetSize(Wide,Height)
	local Time = 10
	T.Paint = function(self)
		if Height ~= 20 + (20 * math.floor(txsize / (self:GetParent():GetWide() - 14))) then
			self:SetSize(self:GetWide(),20 + (20 * math.floor(txsize / (self:GetParent():GetWide() - 14))))
		end
		
		if Wide ~= Chat:GetWide() - 20 then
			Wide = Chat:GetWide() - 20
		end
		
		if Time > 5 then
			Time = Time - 0.01
		elseif Time > 0.1 and Time <= 5 then
			Time = Time - 0.1
		else
			Time = 0
		end
		
		local A
		if Time > 5 then
			A = 255
		else
			A = 255 * (Time/5)
		end
		
		if ChatAnchor:IsVisible() then
			A = 255
		end
		
		surface.SetFont("Chatfont")
		local txt = ""
		local h = 0
		local t = txt
		for I,P in pairs(Tab) do
			if type(P) == "string" then
				for I,S in pairs(string.ToTable(P)) do
					t = t..S
					if surface.GetTextSize(t) <= Wide then
						H = 0
					elseif surface.GetTextSize(t) > Wide * (h + 1) then
						H = 20 * (h + 1)
						txt = ""
						h = h + 1
					end
					surface.SetTextPos((surface.GetTextSize(txt) + 5) % Wide,H)
					surface.DrawText(S.." ")
					txt = txt..S
				end
			elseif type(P) == "table" then
				surface.SetTextColor(P.r,P.g,P.b,A)
			end
		end
	end
	local Bottom = Chat.VBar:GetScroll() == Chat.VBar.CanvasSize
	Chat:AddItem(T)
	timer.Simple(0.01,function()
		if Bottom then
			Chat.VBar:SetScroll(Chat.VBar.CanvasSize)
		end
	end)
end

function GM:PlayerBindPress(ply,bind,pressed)
	if string.find(bind,"messagemode") and not string.find(bind,"messagemode2") and pressed then StartChat() return true end
	if string.find(bind,"messagemode2") and pressed then StartTeamChat() return true end
	if string.find(bind,"impulse 100") and pressed then 
		if GetGlobalBool("Lobby") then
			ply.Flash = not ply.Flash 
			SelfPly:EmitSound("buttons/lightswitch2.wav") 
			return true
		else
			if ply:Team() == 2 or ply:Team() == 3 or (ply:Team() == 1 and ply:Health() <= 0) then
				ply.Flash = not ply.Flash 
				SelfPly:EmitSound("buttons/lightswitch2.wav") 
				return true
			else
				return true
			end
		end
	end
end

function StartChat()
	ChatAnchor:SetVisible(true)
	TextEntry:RequestFocus()
end

function StartTeamChat()
	ChatAnchor:SetVisible(true)
	TextEntry:RequestFocus()
	TeamP:SetVisible(true)
	TextEntry:SetPos(60,ChatAnchor:GetTall() - 20)
	TextEntry:SetSize(ChatAnchor:GetWide() - 120,20)
end