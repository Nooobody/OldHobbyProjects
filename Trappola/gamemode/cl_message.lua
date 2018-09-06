usermessage.Hook("Message",function(um)
	local txt = um:ReadString()
	local ply = um:ReadString()
	local Team = um:ReadShort()
	local b = um:ReadBool()
	if not b then
		chat.AddText(Color(255,215,0,255),"{SYSTEM} ",Color(255,127,80,255),txt)
	else
		chat.AddText(Color(255,215,0,255),"{ADMIN} ",team.GetColor(Team),ply,Color(255,127,80,255),": "..txt)
	end
end)

local a = NULL
usermessage.Hook("Shout",function(um)
	local txt = um:ReadString()
	local UnderLines = um:ReadShort()
	local Lines
	if UnderLines and UnderLines > 0 then
		Lines = {}
		for I = 1,UnderLines do
			local text = um:ReadString()
			table.insert(Lines,text)
		end
	end
	if a:IsValid() then a:Remove() end
	a = vgui.Create("DPanel")
	surface.SetFont("HUDNumber")
	a:SetSize(surface.GetTextSize(txt) + 10,200)
	a:SetPos(ScrW() / 2 - a:GetWide() / 2,200)
	local V = 255
	a.Paint = function(self)
		V = V - 0.5
		local T = V/255
		draw.DrawText(txt,"HUDNumber",self:GetWide() / 2,0,Color(255,255,255,255 * T),TEXT_ALIGN_CENTER)
		if Lines and #Lines > 0 then
			for I,L in pairs(Lines) do
				draw.DrawText(L,"MenuLarge",self:GetWide() / 2,40 + 20*(I-1),Color(255,255,255,255 * T),TEXT_ALIGN_CENTER)
			end
		end
		if V <= 0 then
			a:Remove()
		end
	end
end)

usermessage.Hook("Disconnected",function(um)
	chat.AddText(Color(189,183,107),"Player "..um:ReadString().." has left the server.")
	local Num = um:ReadShort()
	if Num then
		TotalPlayers = Num
	end
end)

usermessage.Hook("Joining",function(um)
	local B,BS,S = um:ReadBool(),um:ReadBool(),um:ReadString()
	local Num = um:ReadShort()
	if B then
		table.insert(Joining,S)
		if BS then
			chat.AddText(Color(189,183,107),"Player "..S.." has joined the server.")
		end
	else
		for I,P in pairs(Joining) do
			if S == P then
				table.remove(Joining,I)
				break
			end
		end
	end
	if Num then
		TotalPlayers = Num
	end
end)

usermessage.Hook("Auth",function(um)
	local S = um:ReadString()
	for I,P in pairs(Joining) do
		if P == S then
			Joining[I] = nil
		end
	end
	chat.AddText(Color(189,183,107),"Player "..S.." has finished joining the server.")
end)