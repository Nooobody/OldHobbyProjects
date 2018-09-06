local function Mapvote(um)
	if not LobbyPanel:IsVisible() then	
		ChatAnchor:SetVisible(true)
		LobbyPanel:SetVisible(true)
	end
	local MapAmount = um:ReadShort()
	local Maps = {}
	for I = 1,MapAmount do
		table.insert(Maps,um:ReadString())
	end
	local Timeleft = 30
	local VoteMenu = vgui.Create("DPanel",Screen)
	VoteMenu:SetSize(Screen:GetWide(),Screen:GetTall())
	VoteMenu:SetPos(0,0)
	VoteMenu.Paint = function(self)
		surface.SetDrawColor(20,20,20,255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		draw.DrawText("On what map would you like to vote on?","MenuLarge",self:GetWide() / 2,20,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		draw.DrawText("Time Left: "..Timeleft,"MenuLarge",self:GetWide() / 2,40,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	end
	timer.Create("CountingDown",1,Timeleft,function()
		Timeleft = Timeleft - 1
		if Timeleft <= 0 then
			RunConsoleCommand("Trappola_VotingforMap","TimeLeft")
			VoteMenu:Remove()
		end
	end)
	local VotesMenu = vgui.Create("DPanel",VoteMenu)
	VotesMenu:SetSize(VoteMenu:GetWide() - 120,40)
	VotesMenu:SetPos(60,80)
	VotesMenu.Paint = function(self)
	end
	local Votes = {}
	for Ind,Map in pairs(Maps) do
		Votes.Map = vgui.Create("DButton",VotesMenu)
		Votes.Map:SetSize(120,40)
		Votes.Map:SetPos(0 + 140 * (Ind - 1),0)
		Votes.Map:SetText(Map)
		Votes.Map.DoClick = function()
			RunConsoleCommand("Trappola_VotingforMap",Map)
		end
	end
	MapsShow = vgui.Create("DPanelList",VoteMenu)
	MapsShow:SetPos(60,140)
	MapsShow:SetSize(VoteMenu:GetWide() - 120,340)
	MapsShow:SetSpacing(0)
	MapsShow:EnableVerticalScrollbar(true)
	MapsShow:EnableHorizontal(false)
	MapsShow.Paint = function(self)
	end
end
usermessage.Hook("Map",Mapvote)

usermessage.Hook("UpdateMaps",function(um)
	if not MapsShow or not MapsShow:IsValid() then return end
	local txt = um:ReadString()
	local Maps = {}
	for I,P in pairs(string.Explode(",",txt)) do
		local Already = false
		for i,p in pairs(Maps) do
			if P == p[1] then
				Maps[i][2] = Maps[i][2] + 1
				Already = true
				break
			end
		end
		if not Already then
			table.insert(Maps,{P,1})
		end
	end
	MapsShow:Clear()
	for I,P in pairs(Maps) do
		if P[1] == "" then break end
		local Map = vgui.Create("DPanel")
		Map:SetSize(ScrW() - 120,20)
		local map,Num = P[1],P[2]
		Map.Paint = function(self)
			draw.DrawText(map..": "..Num,"MenuLarge",0,0,Color(255,255,255,255),TEXT_ALIGN_LEFT)
		end
		MapsShow:AddItem(Map)
	end
end)