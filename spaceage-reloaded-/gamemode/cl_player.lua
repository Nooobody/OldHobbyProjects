
net.Receive("PlayerJoined",function(len)
	LocalPlayer().Joined = tonumber(net.ReadString())
	LocalPlayer().TimePlayed = tonumber(net.ReadString())
end)

concommand.Add("sa_runcl",function(ply,cmd,arg,str)
	net.Start("SA_CL_Run")
		net.WriteString(str)
	net.SendToServer()
end)

function GM:PlayerDisconnected(ply)
end

function GM:PlayerConnect(ply)
end

function CheckPlayerActivity()
	if not LocalPlayer().OldCursor then
		local X,Y = input.GetCursorPos()
		LocalPlayer().OldCursor = {X,Y}
	end
	
	if #LocalPlayer().AFKKeys > 0 then
		LocalPlayer().AFKKeys = {}
		local X,Y = input.GetCursorPos()
		LocalPlayer().OldCursor = {X,Y}
		return false
	end
	
	local X,Y = input.GetCursorPos()
	if X ~= LocalPlayer().OldCursor[1] or Y ~= LocalPlayer().OldCursor[2] then
		LocalPlayer().OldCursor = {X,Y}
		return false
	end
	return true
end

net.Receive("BetaTester",function(len)
	local Is500k = net.ReadBit() == 1
	local Box = vgui.Create("DPanel")
	Box:SetSize(900,200)
	Box:Center()
	Box:MakePopup()
	Box.Paint = function(self,w,h)
		draw.DrawBox(0,0,w,h,Color(60,60,240))
		draw.DrawText("Thank you for playing in the beta! We hope you have enjoyed your stay on the server.","LucidaSmall",w / 2,20,Color(255,255,255),TEXT_ALIGN_CENTER)
		draw.DrawText("We've now decided to take off our beta status, as it seems the gamemode is mostly stable right now.","LucidaSmall",w / 2,50,Color(255,255,255),TEXT_ALIGN_CENTER)
		draw.DrawText("More info can be found on the forums! We hope you keep enjoying the server, and good luck in your travels!","LucidaSmall",w / 2,80,Color(255,255,255),TEXT_ALIGN_CENTER)
		if Is500k then
			draw.DrawText("You've been given 500k for your lost score and credits.","LucidaSmall",w / 2,120,Color(255,255,255),TEXT_ALIGN_CENTER)
		else
			draw.DrawText("You've been given 100k for your lost score and credits.","LucidaSmall",w / 2,120,Color(255,255,255),TEXT_ALIGN_CENTER)
		end
	end
	
	local W,H = Box:GetSize()
	local Close = vgui.Create("DButton",Box)
	Close:SetSize(20,20)
	Close:SetPos(W - 28,6)
	Close:SetText("")
	Close.Paint = function(self,w,h)
		if self.Hovered then
			draw.DrawCross(4,4,w - 8,h - 8,Color(255,255,255))
		elseif self.Depressed then
			draw.DrawCross(4,4,w - 8,h - 8,Color(150,150,150))
		else
			draw.DrawCross(4,4,w - 8,h - 8,Color(200,200,200))
		end
	end
	Close.DoClick = function(self)
		self:GetParent():Remove()
	end
	
	local Close2 = vgui.Create("DButton",Box)
	Close2:SetSize(120,20)
	Close2:SetPos(W / 2 - 60,H - 40)
	Close2:SetText("Okay!")
	Close2.DoClick = function(self)
		self:GetParent():Remove()
	end
end)

net.Receive("SA_News",function(len)
	local S = net.ReadBit() == 1
	if not S then
		local Str = net.ReadString()
		table.insert(SA_NEWS,Str)
	else
		local Str = net.ReadString()
		local Link = net.ReadString()
		table.insert(SA_NEWS,{Str,Link})
	end
end)

local SuggestionBox
concommand.Add("SA_Suggestion",function(ply)
	if IsValid(SuggestionBox) then return end
	local SW,SH = ScrW(),ScrH()
	local W,H = 600,300
	
	SuggestionBox = vgui.Create("DFrame")
	SuggestionBox:SetSize(W,H)
	SuggestionBox:Center()
	SuggestionBox:MakePopup()
	SuggestionBox:SetTitle("")
	SuggestionBox:ShowCloseButton(false)
	SuggestionBox.Paint = function(self,w,h)
		draw.DrawBox(0,0,w,h,team.GetColor(LocalPlayer():Team()))
		draw.DrawText("Put out any suggestions, opinions, comments, hatemails, anything.","LucidaSmall",10,10,Color(255,255,255),TEXT_ALIGN_LEFT)
	end
	
	local Close = vgui.Create("DButton",SuggestionBox)
	Close:SetSize(20,20)
	Close:SetPos(W - 28,6)
	Close:SetText("")
	Close.Paint = function(self,w,h)
		if self.Hovered then
			draw.DrawCross(4,4,w - 8,h - 8,Color(255,255,255))
		elseif self.Depressed then
			draw.DrawCross(4,4,w - 8,h - 8,Color(150,150,150))
		else
			draw.DrawCross(4,4,w - 8,h - 8,Color(200,200,200))
		end
	end
	Close.DoClick = function(self)
		self:GetParent():Remove()
	end
	
	local Text = vgui.Create("DTextEntry",SuggestionBox)
	Text:SetSize(W - 80,H - 60)
	Text:SetPos(20,40)
	Text:SetMultiline(true)
	Text:AllowInput(true)
	
	local Send = vgui.Create("DButton",SuggestionBox)
	Send:SetSize(40,20)
	Send:SetPos(W - 50,H - 30)
	Send:SetText("Send")
	Send.DoClick = function(self)
		net.Start("SA_Suggestion")
			net.WriteString(Text:GetValue())
		net.SendToServer()
		self:GetParent():Remove()
	end
end)