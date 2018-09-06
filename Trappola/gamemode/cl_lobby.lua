local Num1
local Num2
local Num3
usermessage.Hook("Lobby",function(um)
	local Num = um:ReadShort()
	if Num then
		TotalPlayers = Num
	end
	LobbyPanel:SetVisible(true)
	ChatAnchor:SetVisible(true)
end)

concommand.Add("Trappola_CloseLobby",function()
	RunConsoleCommand("Trappola_FlareColor",Num1:GetValue(),Num2:GetValue(),Num3:GetValue())
	SelfPly.FlareR = Num1:GetValue()
	SelfPly.FlareG = Num2:GetValue()
	SelfPly.FlareB = Num3:GetValue()
	LobbyPanel:SetVisible(false)
	ChatAnchor:SetVisible(false)
	AddText("!Exit")
end)

Geemu = {}
local Hats = {}
local MultiList = NULL
function CreateLobby()
	LobbyPanel = vgui.Create("DPanel")
	LobbyPanel:SetPos(0,0)
	LobbyPanel:SetSize(ScrW(),ScrH())
	LobbyPanel.Paint = function(self)
		surface.SetDrawColor(20,20,20,200)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end
	local PlayerPanel = vgui.Create("DPanel",LobbyPanel)
	PlayerPanel:SetSize(190,400)
	PlayerPanel:SetPos(60,60)
	PlayerPanel.Paint = function(self)
		local W,H = self:GetWide(),self:GetTall()
		draw.RoundedBoxEx(6,0,0,W,H,Color(0,0,0,255),true,true,true,true)
		local Ready = 0
		for I,P in pairs(player.GetAll()) do
			if P:GetNWBool("Ready") then
				Ready = Ready + 1
			end
		end
		local Num = #team.GetPlayers(1) + #team.GetPlayers(2)
		if GetGlobalBool("Lobby") then
			if Ready == Num and Ready >= 2 then
				draw.DrawText("Game starting in "..GetGlobalInt("Starting"),"MenuLarge",20,H - 30,Color(255,255,255,255),TEXT_ALIGN_LEFT)
			else
				draw.DrawText("Waiting for players...","MenuLarge",20,H - 30,Color(255,255,255,255),TEXT_ALIGN_LEFT)
			end
		else
			draw.DrawText("Game has started.","MenuLarge",20,H - 30,Color(255,255,255,255),TEXT_ALIGN_LEFT)
		end
		local function GetCol(ply)
			if GetGlobalBool("Lobby") then
				if ply:GetNWBool("Ready") then
					return Color(0,255,0,255)
				else
					return Color(255,0,0,255)
				end
			else
				return team.GetColor(ply:Team())
			end
		end
		local Draw = {}
		if #Joining > 0 then
			table.insert(Draw,{1,"Joining: "..#Joining,Color(255,255,255,255)})
			for I,P in pairs(Joining) do
				table.insert(Draw,{2,P,Color(0,0,255,255)})
			end
		end
		local Scavs = team.GetPlayers(1)
		if #Scavs > 0 then
			table.insert(Draw,{1,"Scavengers: "..#Scavs,Color(255,255,255,255)})
			for I,P in pairs(Scavs) do
				table.insert(Draw,{2,P:Name(),GetCol(P)})
			end
		end
		local Trappers = team.GetPlayers(2)
		if #Trappers > 0 then
			table.insert(Draw,{1,"Traplayers: "..#Trappers,Color(255,255,255,255)})
			for I,P in pairs(Trappers) do
				table.insert(Draw,{2,P:Name(),GetCol(P)})
			end
		end
		local Specs = team.GetPlayers(3)
		if #Specs > 0 then
			table.insert(Draw,{1,"Spectating: "..#Specs,Color(255,255,255,255)})
			for I,P in pairs(Specs) do
				table.insert(Draw,{2,P:Name(),team.GetColor(3)})
			end
		end
		
		for I,P in pairs(Draw) do
			local X,Name,Col = P[1],P[2],P[3]
			draw.DrawText(Name,"MenuLarge",10 + (X - 1) * 10,10 + 20 * (I - 1),Col,TEXT_ALIGN_LEFT)
		end
	end
	local ButtonPanel = vgui.Create("DPanel",LobbyPanel)
	ButtonPanel:SetSize(190,400)
	ButtonPanel:SetPos(ScrW() - 250,60)
	ButtonPanel.Paint = function(self)
		draw.RoundedBoxEx(6,0,0,self:GetWide(),self:GetTall(),Color(0,0,0,255),true,true,true,true)
	end
	
	local Button1 = vgui.Create("DButton",ButtonPanel)
	Button1:SetSize(100,40)
	Button1:SetPos(20,20)
	Button1:SetText("")
	Button1.Paint = function() end
	Button1.Paint = function(self)
		if not SelfPly or not SelfPly:IsValid() then return end
		if SelfPly:Team() == 3 or not GetGlobalBool("Lobby") then return end
		local W,H = self:GetWide(),self:GetTall()
		if SelfPly:GetNWBool("Ready") then
			surface.SetDrawColor(0,200,0,255)
			surface.DrawRect(0,0,W,H / 2)
			surface.SetDrawColor(0,150,0,255)
			surface.DrawRect(0,H / 2,W,H / 2)
		else
			surface.SetDrawColor(200,0,0,255)
			surface.DrawRect(0,0,W,H / 2)
			surface.SetDrawColor(150,0,0,255)
			surface.DrawRect(0,H / 2,W,H / 2)
		end
		surface.SetDrawColor(200,200,200,255)
		surface.DrawOutlinedRect(0,0,W,H)
		draw.DrawText("Ready","DefaultLarge",W / 2,H / 2 - 8,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	end
	Button1.DoClick = function()
		if SelfPly:Team() == 3 or not GetGlobalBool("Lobby") then return end
		RunConsoleCommand("Trappola_Ready")
	end
	local Button2 = vgui.Create("DButton",ButtonPanel)
	Button2:SetSize(100,40)
	Button2:SetPos(20,80)
	Button2:SetText("Exit")
	Button2.DoClick = function()
		RunConsoleCommand("Trappola_CloseLobby")
	end
	local Button3 = vgui.Create("DButton",ButtonPanel)
	Button3:SetSize(100,40)
	Button3:SetPos(20,140)
	Button3:SetText("Join Scavengers")
	Button3.Think = function(self)
		if not SelfPly or not SelfPly:IsValid() then return end
		if SelfPly:Team() ~= 3 then
			self:SetText("Join Spectators")
		else
			self:SetText("Join Scavengers")
		end
	end
	Button3.DoClick = function(self)
		if SelfPly:Team() ~= 3 then
			RunConsoleCommand("Trappola_Join_Spec")
		else
			RunConsoleCommand("Trappola_Join_Scav")
		end
	end
	local CheckPanel = vgui.Create("DPanel",ButtonPanel)
	CheckPanel:SetSize(150,120)
	CheckPanel:SetPos(20,260)
	CheckPanel.Paint = function(self)
		draw.RoundedBox(6,0,0,self:GetWide(),self:GetTall(),Color(100,100,100,255))
		draw.DrawText("ChatSounds","DefaultLarge",30,8,Color(255,255,255,255),TEXT_ALIGN_LEFT)
		draw.DrawText("Prefer Traplayer?","DefaultLarge",30,28,Color(255,255,255,255),TEXT_ALIGN_LEFT)
	end
	local Checkbox1 = vgui.Create("DCheckBox",CheckPanel)
	Checkbox1:SetPos(10,10)
	Checkbox1:SetText("")
	Checkbox1:SetConVar("ChatSound")
	Checkbox1:SetChecked(true)
	local Checkbox2 = vgui.Create("DCheckBox",CheckPanel)
	Checkbox2:SetPos(10,30)
	Checkbox2:SetText("")
	Checkbox2.OnChange = function(b)
		RunConsoleCommand("Trappola_PreferTrap",b)
	end
	function AddText(text,BoolT)
		if BoolT then
			RunConsoleCommand("say_team",text)
		else
			RunConsoleCommand("say",text)
		end
	end
	
	Screen = vgui.Create("DPanel",LobbyPanel)
	Screen:SetSize(ScrW() - 630,480)
	Screen:SetPos(ScrW() / 2 - Screen:GetWide() / 2,60)
	Screen.Paint = function(self)
		draw.RoundedBoxEx(6,0,0,self:GetWide(),400,Color(0,0,0,255),true,true,true,true)
	end
	Screens = {}
	function AddScreen(Pan,Name,BMySQL)
		table.insert(Screens,{["Panel"] = Pan,["Name"] = Name,["MySQL"] = BMySQL})
	end
	local Screen_Wlc = vgui.Create("DPanel",Screen)
	Screen_Wlc:SetSize(Screen:GetWide(),400)
	Screen_Wlc:SetPos(0,0)
	Screen_Wlc.Paint = function(self)
		draw.DrawText("TRAPPOLA","HUDNumber5",Screen_Wlc:GetWide() / 2,10,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	end
	local Screen_Wlc_Label = vgui.Create("DLabel",Screen_Wlc)
	Screen_Wlc_Label:SetSize(Screen_Wlc:GetWide() - 20,Screen_Wlc:GetTall() - 80)
	Screen_Wlc_Label:SetPos(10,60)
	Screen_Wlc_Label:SetWrap(true)
	Screen_Wlc_Label:SetFont("Trebuchet20")
	Screen_Wlc.Think = function(self)
		if not self:IsVisible() then return end
		local Txt = [[
		Server Name: ]]..GetHostName()..[[
		
		Server IP: 89.238.160.40:27015
		Players: ]]..TotalPlayers..[[ / ]]..MaxPlayers()..[[
		
		Map: ]]..game.GetMap()..[[
		
		Password: TestingUnderway
		Phase: Late Alpha
		
		Aim of Trappola: A team of scavengers must find artifacts in various locations while an invisible team of cosmic horrors lay traps to stop them.
		
		When the round starts, you can use F2 to get a quick text tutorial on how to play Trappola.
		Press F1 to come back to Lobby, after exiting it.
		You can type !print in chat to see all the chatcommands available to you.
		
		That should do for a quick explanation, hope you have fun!]]
		Screen_Wlc_Label:SetText(Txt)
	end
	AddScreen(Screen_Wlc,"Welcome",false)
	Screen_Stats = vgui.Create("DPanel",Screen)
	Screen_Stats:SetSize(Screen:GetWide(),400)
	Screen_Stats:SetPos(0,0)
	Screen_Stats:SetVisible(false)
	Screen_Stats.Paint = function(self)
	end
	AddScreen(Screen_Shop,"Shop",true)
	AddScreen(Screen_Stats,"Stats",true)
	Screen_Settings = vgui.Create("DPanel",Screen)
	Screen_Settings:SetSize(Screen:GetWide(),400)
	Screen_Settings:SetPos(0,0)
	Screen_Settings:SetVisible(false)
	Screen_Settings.Paint = function()
	end
	AddScreen(Screen_Settings,"Settings",false)
	ModelShow = vgui.Create("DModelPanel",Screen_Settings)
	ModelShow:SetSize(200,200)
	ModelShow:SetPos(20,200)
	local ListView = vgui.Create("DListView",Screen_Settings)
	ListView:SetSize(200,180)
	ListView:SetPos(20,20)
	ListView:AddColumn("Models")
	ListView.OnClickLine = function(self,line)
		for I,P in pairs(PlayerModels) do
			if P[1] == line:GetValue(1) then
				ModelShow:SetModel(P[2])
				if P[2] ~= LocalPlayer():GetNWString("PlayerModel") then
					RunConsoleCommand("Trappola_SaveModel",P[2])
				end
			end
		end
	end
	function UpdateMdls()
		ListView:Clear()
		DefaultModels()
		for I,P in pairs(Mdls) do
			table.insert(PlayerModels,1,{P["Name"],P["Model"]})
		end
		if SinglePlayer() or SelfPly:SteamID() == "STEAM_0:1:22097575" then
			table.insert(PlayerModels,1,{"Miku","models/player/miku.mdl"})
		end
		for I,P in pairs(PlayerModels) do
			ListView:AddLine(P[1])
		end
	end
	local function Tim()
		if not SelfPly or not SelfPly:IsValid() or not Mdls then timer.Simple(5,Tim) return end
		local Mdl = LocalPlayer():GetNWString("PlayerModel") or "models/player/kleiner.mdl"
		ModelShow:SetModel(Mdl)
		UpdateMdls()
	end
	timer.Simple(10,Tim)
	local ColorCircle = vgui.Create("DColorCircle",Screen_Settings)
	ColorCircle:SetSize(150,150)
	ColorCircle:SetPos(Screen_Settings:GetWide() - 170,20)
	Num1 = vgui.Create("DNumSlider",Screen_Settings)
	Num1:SetWide(150)
	Num1:SetPos(Screen_Settings:GetWide() - 330,40)
	Num1:SetText("Red")
	Num1:SetMinMax(0,255)
	Num1:SetDecimals(0)
	Num1.Think = function(self)
		if Num2:GetValue() < 50 and Num3:GetValue() < 50 then
			self:SetMin(100)
		else
			self:SetMin(0)
		end
	end
	Num2 = vgui.Create("DNumSlider",Screen_Settings)
	Num2:SetWide(150)
	Num2:SetPos(Screen_Settings:GetWide() - 330,80)
	Num2:SetText("Green")
	Num2:SetMinMax(0,255)
	Num2:SetDecimals(0)
	Num2.Think = function(self)
		if Num1:GetValue() < 50 and Num3:GetValue() < 50 then
			self:SetMin(100)
		else
			self:SetMin(0)
		end
	end
	Num3 = vgui.Create("DNumSlider",Screen_Settings)
	Num3:SetWide(150)
	Num3:SetPos(Screen_Settings:GetWide() - 330,120)
	Num3:SetText("Blue")
	Num3:SetMinMax(0,255)
	Num3:SetDecimals(0)
	Num3.Think = function(self)
		if Num2:GetValue() < 50 and Num1:GetValue() < 50 then
			self:SetMin(100)
		else
			self:SetMin(0)
		end
	end
	local Colo = ColorCircle:GetRGB()
	ColorCircle.PaintOver = function(self)
		if Colo ~= self:GetRGB() then
			Colo = self:GetRGB()
			Num1:SetValue(Colo.r)
			Num2:SetValue(Colo.g)
			Num3:SetValue(Colo.b)
		end
	end
	local Labl = vgui.Create("DLabel",Screen_Settings)
	Labl:SetPos(Screen_Settings:GetWide() - 300,210)
	Labl:SetSize(280,60)
	Labl:SetWrap(true)
	Labl:SetText([[This here sets the color for your flare. A flare is a thing that's given to each scavenger at the start of a round.
	With it, they light the place around them. This is their only light, as flashlights are disabled.]])
	local ColorP = vgui.Create("DPanel",Screen_Settings)
	ColorP:SetSize(280,20)
	ColorP:SetPos(Screen_Settings:GetWide() - 300,180)
	ColorP.Paint = function(self)
		surface.SetDrawColor(Num1:GetValue(),Num2:GetValue(),Num3:GetValue(),255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end
	local Button4 = vgui.Create("DButton",Screen_Settings)
	Button4:SetSize(150,40)
	Button4:SetPos(Screen_Settings:GetWide() - 170,280)
	Button4:SetText("Change chatbox pos/size")
	Button4.DoClick = function()
		RunConsoleCommand("Trappola_ChangeChat")
	end
	local Button5 = vgui.Create("DButton",Screen_Settings)
	Button5:SetText("Reset chatbox position")
	Button5:SetSize(150,40)
	Button5:SetPos(Screen_Settings:GetWide() - 170,340)
	Button5.DoClick = function()
		RunConsoleCommand("Trappola_DefaultChat")
	end
	if #Hats > 0 then
		MultiList = vgui.Create("DMultiChoice",Screen_Settings)
		MultiList:SetSize(150,20)
		MultiList:SetPos(Screen_Settings:GetWide() - 340,280)
		for I,P in pairs(Hats) do
			MultiList:AddChoice(P["Name"])
		end
		MultiList.OnSelect = function(self,ind,str,data)
			local Hat
			for I,P in pairs(Hats) do
				if str == P["Name"] then
					Hat = P["Model"]
					break
				end
			end
			RunConsoleCommand("Trappola_Hat",Hat,str)
		end
	end
	local SearchP = vgui.Create("DPanel",Screen_Stats)
	SearchP:SetSize(Screen_Stats:GetWide(),40)
	SearchP:SetPos(0,0)
	SearchP.Paint = function(self)
		draw.DrawText("Search","MenuLarge",30,13,Color(255,255,255,255),TEXT_ALIGN_LEFT)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
	end
	local Bar = vgui.Create("DPanel",SearchP)
	Bar:SetSize(200,20)
	Bar:SetPos(100,10)
	Bar:SetCursor("beam")
	Bar.Paint = function(self)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end
	Bar.OnMousePressed = function(self)
		local F = vgui.Create("DFrame")
		F:SetSize(200,20)
		local X,Y = Screen:GetPos()
		F:SetPos(X + 100,Y + 10)
		F:ShowCloseButton(false)
		F:SetTitle("")
		F:MakePopup()
		F.Paint = function()
		end
		local SearchBar = vgui.Create("DTextEntry",F)
		SearchBar:SetSize(200,20)
		SearchBar:SetPos(0,0)
		SearchBar:SetText("")
		SearchBar:SetEditable(true)
		SearchBar:SetMultiline(false)
		SearchBar:SetEnterAllowed(true)
		SearchBar:SetUpdateOnType(false)
		SearchBar:RequestFocus()
		SearchBar.OnEnter = function(self)
			if StatP and StatP:IsValid() then
				StatP:Remove()
			end
			local txt = self:GetValue()
			RunConsoleCommand("Trappola_Search",txt)
			F:Remove()
			StatP = vgui.Create("DPanel",Screen_Stats)
			StatP:SetSize(Screen_Stats:GetWide(),358)
			StatP:SetPos(0,42)
			StatP.Paint = function(self)
				draw.DrawText("Please wait, fetching data...","HUDNumber5",self:GetWide() / 2,20,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			end
		end
		SearchBar.OnLoseFocus = function(self)
			self:GetParent():Remove()
		end
	end
	Screen_Arcade = vgui.Create("DPanel",Screen)
	Screen_Arcade:SetSize(Screen:GetWide(),400)
	Screen_Arcade:SetPos(0,0)
	Screen_Arcade:SetVisible(false)
	Screen_Arcade.Paint = function(self)
	end
	local List = vgui.Create("DPanelList",Screen_Arcade)
	List:SetSize(Screen_Arcade:GetWide() - 20,380)
	List:SetPos(10,10)
	List:EnableVerticalScrollbar(true)
	List:EnableHorizontal(true)
	List:SetSpacing(2)
	List.Paint = function(self)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end
	for I,P in pairs(Geemu) do
		local Panel = vgui.Create("DPanel")
		Panel:SetSize(100,100)
		Panel.Paint = function(self)
			draw.RoundedBox(6,0,0,self:GetWide(),self:GetTall(),Color(100,100,100,255))
			draw.DrawText(P["Name"],"MenuLarge",self:GetWide() / 2,20,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		end
		local Btn = vgui.Create("DButton",Panel)
		Btn:SetSize(100,40)
		Btn:SetPos(0,60)
		Btn:SetText("Play!")
		Btn.DoClick = P["Function"]
		List:AddItem(Panel)
	end
	AddScreen(Screen_Arcade,"Arcade",false)
	local NoConnection = vgui.Create("DPanel",Screen)
	NoConnection:SetSize(Screen:GetWide(),400)
	NoConnection:SetPos(0,0)
	NoConnection.Paint = function(self)
		draw.DrawText("No connection to the MySQL has been made.","HUDNumber",self:GetWide() / 2,20,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		draw.DrawText("Please try again later.","HUDNumber",self:GetWide() / 2,80,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		draw.DrawText("If the connection hasn't restored in a minute, please contact the server owner.","DefaultLarge",self:GetWide() / 2,200,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	end
	NoConnection:SetVisible(false)
	local ScreenBtns = vgui.Create("DPanel",Screen)
	ScreenBtns:SetSize(Screen:GetWide(),80)
	ScreenBtns:SetPos(0,400)
	ScreenBtns.Paint = function(self)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		surface.SetDrawColor(255,255,255,255)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
	end
	local Wide = ScreenBtns:GetWide() - 40
	local Wide = Wide / #Screens
	local function AddBtn(I,Pan,Name,MySQL)
		local ScreenBtns_Btn = vgui.Create("DButton",ScreenBtns)
		ScreenBtns_Btn:SetSize(Wide - 20,40)
		ScreenBtns_Btn:SetPos(20 + (Wide * (I - 1)),20)
		ScreenBtns_Btn:SetText(Name)
		ScreenBtns_Btn.DoClick = function(self)
			local Pan = Pan
			if not Pan then
				for I,P in pairs(Screens) do
					if P["Name"] == Name then
						Pan = P["Panel"]
					end
				end
			end
			if not Pan or not Pan:IsValid() then return end
			if not Pan:IsVisible() then
				if MySQL and (not GetGlobalBool("MySQL") or not SelfPly:GetNWBool("MySQL")) then
					NoConnection:SetVisible(true)
					for a,b in pairs(Screens) do
						if b["Panel"] and b["Panel"]:IsValid() then
							if b["Panel"]:IsVisible() then
								b["Panel"]:SetVisible(false)
							end
						end
					end
				else
					Pan:SetVisible(true)
					for a,b in pairs(Screens) do
						if b["Panel"] and b["Panel"]:IsValid() then
							if b["Panel"] ~= Pan and b["Panel"]:IsVisible() then
								b["Panel"]:SetVisible(false)
							end
						end
					end
					if NoConnection:IsVisible() then
						NoConnection:SetVisible(false)
					end
				end
			end
		end
	end
	for I,P in pairs(Screens) do
		AddBtn(I,P["Panel"],P["Name"],P["MySQL"])
	end
end

usermessage.Hook("SearchResult",function(um)
	if StatP and StatP:IsValid() then
		StatP:Remove()
	end
	local Bool = um:ReadBool()
	if Bool then
		local Name,Model = um:ReadString(),um:ReadString()
		local Expl,FakeArti,Poison,Harpoon,Fakewall,Spike = um:ReadShort(),um:ReadShort(),um:ReadShort(),um:ReadShort(),um:ReadShort(),um:ReadShort()
		local TotalExp,Exp,Kills,Scores,Defusings,Pinged,Triggered = um:ReadLong(),um:ReadShort(),um:ReadShort(),um:ReadShort(),um:ReadShort(),um:ReadShort(),um:ReadShort()
		StatP = vgui.Create("DPanel",Screen_Stats)
		StatP:SetSize(Screen_Stats:GetWide(),358)
		StatP:SetPos(0,42)
		local Tabl = {}
		if Expl > 0 then table.insert(Tabl,{"Explosive",Expl}) end
		if FakeArti > 0 then table.insert(Tabl,{"Fake artifact",FakeArti}) end
		if Poison > 0 then table.insert(Tabl,{"Poison",Poison}) end
		if Harpoon > 0 then table.insert(Tabl,{"Harpoon",Harpoon}) end
		if Fakewall > 0 then table.insert(Tabl,{"Fakewall",Fakewall}) end
		if Spike > 0 then table.insert(Tabl,{"Spike",Spike}) end
		local Max = Expl + FakeArti + Poison + Harpoon + Fakewall + Spike
		for I,P in pairs(Tabl) do
			Tabl[I][3] = Tabl[I][2] / Max
		end
		StatP.Paint = function(self)
			draw.DrawText(Name,"HUDNumber5",self:GetWide() / 2,20,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			draw.DrawText("Total experience: "..TotalExp,"DefaultLarge",20,80,Color(255,255,255,255),TEXT_ALIGN_LEFT)
			draw.DrawText("Experience: "..Exp,"DefaultLarge",20,100,Color(255,255,255,255),TEXT_ALIGN_LEFT)
			draw.DrawText("Scores: "..Scores,"DefaultLarge",20,120,Color(255,255,255,255),TEXT_ALIGN_LEFT)
			draw.DrawText("Kills: "..Kills,"DefaultLarge",20,140,Color(255,255,255,255),TEXT_ALIGN_LEFT)
			draw.DrawText("Defusings: "..Defusings,"DefaultLarge",160,100,Color(255,255,255,255),TEXT_ALIGN_LEFT)
			draw.DrawText("Pinged artifacts: "..Pinged,"DefaultLarge",160,120,Color(255,255,255,255),TEXT_ALIGN_LEFT)
			draw.DrawText("Triggered traps: "..Triggered,"DefaultLarge",160,140,Color(255,255,255,255),TEXT_ALIGN_LEFT)
			if Max > 0 then
				draw.DrawText("Trap usage in %","DefaultLarge",150,180,Color(255,255,255,255),TEXT_ALIGN_CENTER)
				for I,P in pairs(Tabl) do
					draw.DrawText(P[1],"DefaultLarge",20,200 + 20 * (I - 1),Color(255,255,255,255),TEXT_ALIGN_LEFT)
					surface.SetDrawColor(255,255,255,255)
					surface.DrawOutlinedRect(100,200 + 20 * (I - 1),100,20)
					surface.SetDrawColor(0,255,0,255)
					surface.DrawRect(100,200 + 20 * (I - 1),100 * P[3],20)
					draw.DrawText((math.Round((P[3] * 1000)) / 10).."% ("..P[2]..")","DefaultLarge",210,200 + 20 * (I - 1),Color(255,255,255,255),TEXT_ALIGN_LEFT)
				end
			end
		end
		local Mdl = vgui.Create("DModelPanel",StatP)
		Mdl:SetSize(240,240)
		Mdl:SetPos(StatP:GetWide() - 260,100)
		Mdl:SetModel(Model)
	else
		StatP = vgui.Create("DPanel",Screen_Stats)
		StatP:SetSize(Screen_Stats:GetWide(),358)
		StatP:SetPos(0,42)
		StatP.Paint = function(self)
			draw.DrawText("Player not found!","HUDNumber5",self:GetWide() / 2,20,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		end
	end
end)

usermessage.Hook("FlareColors",function(u)
	local R,G,B = u:ReadShort(),u:ReadShort(),u:ReadShort()
	Num1:SetValue(R)
	Num2:SetValue(G)
	Num3:SetValue(B)
end)


local function BuildDosh()
	Shop_Dosh = vgui.Create("DPropertySheet")
	local Classes = {"Models","Tokens","Hats"}
	for I,P in pairs(Classes) do
		local Dosh = vgui.Create("DPanel")
		Dosh:SetSize(Screen:GetWide(),400)
		Dosh.Paint = function(self)
			surface.SetDrawColor(120,120,120,255)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
			draw.DrawText("You have "..SelfPly:GetDosh().." Dosh","Trebuchet24",10,300,Color(255,255,255,255),TEXT_ALIGN_LEFT)
		end
		local DoshShop = vgui.Create("DPanelList",Dosh)
		DoshShop:SetSize(Dosh:GetWide(),300)
		DoshShop:SetPos(0,0)
		DoshShop:EnableHorizontal(true)
		DoshShop:EnableVerticalScrollbar(true)
		DoshShop:SetSpacing(2)
		DoshShop.Paint = function(self)
			surface.SetDrawColor(0,0,0,255)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
		for i,U in pairs(DoshUpgs) do
			if P == U["Class"] then
				local Lvl
				for I,P in pairs(DoshUps) do
					if I == i then
						Lvl = tonumber(P)
					end
				end
				local Cost = U["Cost"]
				local Panel = vgui.Create("DPanel")
				if P == "Models" or P == "Hats" then
					Panel:SetSize(200,290)
				else
					Panel:SetSize(200,180)
				end
				Panel.Paint = function(self)
					surface.SetDrawColor(0,0,0,255)
					surface.DrawRect(0,0,self:GetWide(),self:GetTall())
					draw.RoundedBoxEx(8,10,10,self:GetWide() - 20,self:GetTall() - 20,Color(100,100,100,255),true,true,false,false)
					draw.DrawText(U["Name"],"MenuLarge",100,10,Color(255,255,255,255),TEXT_ALIGN_CENTER)
					draw.DrawText("Cost: "..Cost.." Dosh","DefaultLarge",self:GetWide() / 2,self:GetTall() - 60,Color(255,255,255,255),TEXT_ALIGN_CENTER)
					if P == "Models" or P == "Hats" then
						if Lvl == 0 then
							local Lvl
							for I,P in pairs(DoshUps) do
								if I == i then
									Lvl = tonumber(P)
								end
							end
							if Lvl == 1 then
								draw.DrawText("Already bought!","Trebuchet24",100,250,Color(255,255,255,255),TEXT_ALIGN_CENTER)
							end
						else
							draw.DrawText("Already bought!","Trebuchet24",100,250,Color(255,255,255,255),TEXT_ALIGN_CENTER)
						end
					end
				end
				if P == "Models" or P == "Hats" then
					local Mdl = vgui.Create("DModelPanel",Panel)
					Mdl:SetSize(200,200)
					Mdl:SetPos(0,30)
					Mdl:SetModel(U["Var"])
					if P == "Hats" then
						Mdl:SetLookAt(Vector(0,0,0))
					end
				else
					local Lbl = vgui.Create("DLabel",Panel)
					Lbl:SetSize(160,110)
					Lbl:SetPos(20,30)
					Lbl:SetWrap(true)
					Lbl:SetText(U["Desc"].."\n\nYou have: "..Lvl)
					Lbl.Paint = function(self)
						local Lvl
						for I,P in pairs(DoshUps) do
							if I == i then
								Lvl = tonumber(P)
							end
						end
						self:SetText(U["Desc"].."\n\nYou have: "..Lvl)
					end
				end
				if (Lvl == 0 and P == "Models") or P ~= "Models" then
					local Btn = vgui.Create("DButton",Panel)
					Btn:SetSize(180,40)
					if P == "Models" or P == "Hats" then
						Btn:SetPos(10,250)
					else
						Btn:SetPos(10,140)
					end
					Btn:SetText("Buy")
					local OldPaint = Btn.Paint
					Btn.Paint = function(self)
						if P == "Models" or P == "Hats" then
							local Lvl
							for I,P in pairs(DoshUps) do
								if I == i then
									Lvl = tonumber(P)
								end
							end
							if Lvl == 1 then
								self.DoClick = function() end
								self.Paint = function() end
								self:SetText("")
								return
							end
						end
						if not GetGlobalBool("Lobby") then return end
						OldPaint(self)
					end
					Btn.DoClick = function(self)
						if not GetGlobalBool("Lobby") then return end
						local Dosh = SelfPly:GetDosh()
						if Dosh >= Cost then
							RunConsoleCommand("Trappola_Dosh",U["Class"].."_"..U["Name"])
						else
							self:SetText("Not enough Dosh.")
							timer.Simple(1,function() self:SetText("Buy") end)
						end
					end
				end
				DoshShop:AddItem(Panel)
			end
		end
		Shop_Dosh:AddSheet(P,Dosh,"gui/silkicons/user",false,false,"Dosh")
	end
	local HowToBuy = vgui.Create("DPanel")
	HowToBuy:SetSize(Screen:GetWide(),Screen:GetTall())
	HowToBuy.Paint = function(self)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end
	local HowToBuy_Label = vgui.Create("DLabel",HowToBuy)
	HowToBuy_Label:SetFont("MenuLarge")
	HowToBuy_Label:SetPos(0,0)
	HowToBuy_Label:SetSize(HowToBuy:GetWide(),200)
	HowToBuy_Label:SetText([[In order to get Dosh, you need to pay the server owner, Nooobody, some real dosh.
	Here are the prices:
		2 euros / $2.86 = 10 Dosh
		5 euros / $7.16 = 30 Dosh
		10 euros / $14.32 = 75 Dosh
		
	To do this, you need to message Nooobody on steam, or on the server if you see him, and tell him that you want to buy dosh.
	All payments will be done through paypal.
	This transaction only works oneway, so you can't convert dosh into real dosh.
	
	Ordering a playermodel that's not in the shop will cost you 10 dosh.
	]])
	HowToBuy_Label:SetWrap(true)
	Shop_Dosh:AddSheet("How to get dosh",HowToBuy,"gui/silkicons/exclamation",false,false,"Dosh")
	Screen_Shop_Sheet:AddSheet("Dosh",Shop_Dosh,"gui/silkicons/user",false,false,"Dosh")
end

function RebuildShop()
	for I,P in pairs(Screens) do
		if P["Name"] == "Shop" then
			table.remove(Screens,I)
		end
	end
	local WasVisible = false
	if Screen_Shop and Screen_Shop:IsValid() then
		if Screen_Shop:IsVisible() then
			WasVisible = true
		end
		Screen_Shop:Remove()
	end
	Screen_Shop = vgui.Create("DPanel",Screen)
	Screen_Shop:SetSize(Screen:GetWide(),400)
	Screen_Shop:SetPos(0,0)
	Screen_Shop:SetVisible(false)
	Screen_Shop.Paint = function(self)
	end
	AddScreen(Screen_Shop,"Shop",true)
	Screen_Shop_Sheet = vgui.Create("DPropertySheet",Screen_Shop)
	Screen_Shop_Sheet:SetSize(Screen_Shop:GetWide(),Screen_Shop:GetTall() - 10)
	Screen_Shop_Sheet:SetPos(0,10)
	local Shop_Trap = vgui.Create("DPropertySheet")
	for I,P in pairs(Traps) do
		if P["Trap"] ~= "trap_fakeartifact" then
			local TrapShop = vgui.Create("DPanelList")
			TrapShop:EnableHorizontal(true)
			TrapShop:EnableVerticalScrollbar(true)
			TrapShop.Paint = function(self)
				surface.SetDrawColor(0,0,0,255)
				surface.DrawRect(0,0,self:GetWide(),self:GetTall())
			end
			local function AddUpg(U,Lvl,Upg)
				local Panel = vgui.Create("DPanel")
				Panel:SetSize(200,200)
				Panel.Paint = function(self)
					surface.SetDrawColor(0,0,0,255)
					surface.DrawRect(0,0,self:GetWide(),self:GetTall())
					draw.RoundedBoxEx(8,10,10,self:GetWide() - 20,self:GetTall() - 20,Color(100,100,100,255),true,true,false,false)
					if U["Var"] == "Unlock" then
						draw.DrawText(U["Var"],"Trebuchet24",100,15,Color(255,255,255,255),TEXT_ALIGN_CENTER)
					else
						draw.DrawText(U["Var"].." - Level "..Lvl,"MenuLarge",100,15,Color(255,255,255,255),TEXT_ALIGN_CENTER)
					end
					if Lvl >= U["Maxlvl"] then
						draw.DrawText("Max level!","Trebuchet24",100,150,Color(255,255,255,255),TEXT_ALIGN_CENTER)
					end
				end
				local Lbl = vgui.Create("DLabel",Panel)
				Lbl:SetPos(15,40)
				Lbl:SetSize(170,100)
				Lbl:SetFont("DefaultLarge")
				Lbl:SetWrap(true)
				Lbl:SetText(U["Description"])
				if Lvl < U["Maxlvl"] then
					local Cost = U["Cost"] + U["CostInc"] * math.Clamp(Lvl - 1,0,6)
					Lbl:SetText(U["Description"].."\n\nCost: "..Cost.." Exp\nYou have: "..SelfPly:GetExp())
					local OldExp = SelfPly:GetExp()
					local OldPaint = Lbl.Paint
					Lbl.Paint = function(self)
						if OldExp ~= SelfPly:GetExp() then
							OldExp = SelfPly:GetExp()
							self:SetText(U["Description"].."\n\nCost: "..Cost.." Exp\nYou have: "..SelfPly:GetExp())
						end
						OldPaint(self)
					end
					local Btn = vgui.Create("DButton",Panel)
					Btn:SetSize(180,40)
					Btn:SetPos(10,150)
					Btn:SetText("Upgrade")
					local OldPaint = Btn.Paint
					Btn.Paint = function(self)
						if not GetGlobalBool("Lobby") then return end
						OldPaint(self)
					end
					Btn.DoClick = function(self)
						if not GetGlobalBool("Lobby") then return end
						local Exp = SelfPly:GetExp()
						if Exp >= Cost then
							RunConsoleCommand("Trappola_Upgrade",Upg)
						else
							self:SetText("Not enough Exp")
							timer.Simple(1,function() self:SetText("Upgrade") end)
						end
					end
				end
				TrapShop:AddItem(Panel)
			end
			
			for i,U in pairs(TrapUpgrades) do
				if P["Trap"] == U["Trap"] then
					local Lvl
					local Upg
					local Bought = 0
					for I,P in pairs(Lvls) do
						if P["I"] == U["Trap"].."_Unlock" then
							Bought = P["lvl"]
						end
						if P["I"] == U["Trap"].."_"..U["Var"] then
							Lvl = P["lvl"]
							Upg = P["I"]
						end
					end
					if U["Trap"] == "trap_explosive" then
						AddUpg(U,Lvl,Upg)
					elseif U["Var"] == "Unlock" and Bought == 0 then
						AddUpg(U,Lvl,Upg)
					elseif U["Var"] ~= "Unlock" and Bought == 1 then
						AddUpg(U,Lvl,Upg)
					end
				end
			end
			Shop_Trap[P["Trap"]] = Shop_Trap:AddSheet(P["Trap name"],TrapShop,"gui/silkicons/wrench",false,false,"Upgrades for "..P["Trap name"])
		end
	end
	local Shop_Scav = vgui.Create("DPropertySheet")
	local Classes = {"Scavenger","Defuser","Scout"}
	for I,P in pairs(Classes) do
		local ScavShop = vgui.Create("DPanelList")
		ScavShop:EnableHorizontal(true)
		ScavShop:EnableVerticalScrollbar(true)
		ScavShop.Paint = function(self)
			surface.SetDrawColor(0,0,0,255)
			surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		end
		for i,U in pairs(ScavUpgrades) do
			if P == U["Class"] then
				local Lvl
				local Upgd
				for I,P in pairs(Lvls) do
					if P["I"] == U["Var"] then
						Lvl = P["lvl"]
						Upgd = P["I"]
					end
				end
				local Panel = vgui.Create("DPanel")
				Panel:SetSize(200,200)
				Panel.Paint = function(self)
					surface.SetDrawColor(0,0,0,255)
					surface.DrawRect(0,0,self:GetWide(),self:GetTall())
					draw.RoundedBoxEx(8,10,10,self:GetWide() - 20,self:GetTall() - 20,Color(100,100,100,255),true,true,false,false)
					draw.DrawText(U["Var"].." - Level "..Lvl,"MenuLarge",100,15,Color(255,255,255,255),TEXT_ALIGN_CENTER)
					if Lvl >= U["Maxlvl"] then
						draw.DrawText("Max level!","Trebuchet24",100,150,Color(255,255,255,255),TEXT_ALIGN_CENTER)
					end
				end
				local Lbl = vgui.Create("DLabel",Panel)
				Lbl:SetPos(15,40)
				Lbl:SetSize(170,100)
				Lbl:SetFont("DefaultLarge")
				Lbl:SetWrap(true)
				Lbl:SetText(U["Description"])
				if Lvl < U["Maxlvl"] then
					local Cost = U["Cost"] + U["CostInc"] * math.Clamp(Lvl - 1,0,6)
					Lbl:SetText(U["Description"].."\n\nCost: "..Cost.." Exp\nYou have: "..SelfPly:GetExp())
					local OldExp = SelfPly:GetExp()
					local OldPaint = Lbl.Paint
					Lbl.Paint = function(self)
						if OldExp ~= SelfPly:GetExp() then
							OldExp = SelfPly:GetExp()
							self:SetText(U["Description"].."\n\nCost: "..Cost.." Exp\nYou have: "..SelfPly:GetExp())
						end
						OldPaint(self)
					end
					local Btn = vgui.Create("DButton",Panel)
					Btn:SetSize(180,40)
					Btn:SetPos(10,150)
					Btn:SetText("Upgrade")
					local OldPaint = Btn.Paint
					Btn.Paint = function(self)
						if not GetGlobalBool("Lobby") then return end
						OldPaint(self)
					end
					Btn.DoClick = function(self)
						if not GetGlobalBool("Lobby") then return end
						local Exp = SelfPly:GetExp()
						if Exp >= Cost then
							RunConsoleCommand("Trappola_Upgrade",Upgd)
						else
							self:SetText("Not enough Exp")
							timer.Simple(1,function() self:SetText("Upgrade") end)
						end
					end
				end
				ScavShop:AddItem(Panel)
			end
		end
		Shop_Scav[P] = Shop_Scav:AddSheet(P,ScavShop,"gui/silkicons/wrench",false,false,"Upgrades for "..P)
	end
	Screen_Shop_Sheet.Trap = Screen_Shop_Sheet:AddSheet("Trap upgrades",Shop_Trap,"gui/silkicons/user",false,false,"Upgrades for traps")
	Screen_Shop_Sheet.Scavenger = Screen_Shop_Sheet:AddSheet("Scav upgrades",Shop_Scav,"gui/silkicons/user",false,false,"Upgrades for scavengers")
	if WasVisible then
		Screen_Shop:SetVisible(true)
	end
	if not DoshUps then return end
	BuildDosh()
end

usermessage.Hook("Dosh",function(um)
	DoshUps = string.ToTable(um:ReadString())
	Mdls = {}
	Hats = {}
	for I,P in pairs(DoshUpgs) do
		if tonumber(DoshUps[I]) > 0 and P["Class"] == "Models" then
			table.insert(Mdls,{["Name"] = P["Name"],["Model"] = P["Var"]})
		elseif tonumber(DoshUps[I]) > 0 and P["Class"] == "Hats" then
			table.insert(Hats,{["Name"] = P["Name"],["Model"] = P["Var"]})
		end
	end
	if #Hats > 0 then
		if MultiList:IsValid() then MultiList:Remove() end
		MultiList = vgui.Create("DMultiChoice",Screen_Settings)
		MultiList:SetSize(150,20)
		MultiList:SetPos(Screen_Settings:GetWide() - 340,280)
		for I,P in pairs(Hats) do
			MultiList:AddChoice(P["Name"])
		end
		MultiList.OnSelect = function(self)
			RunConsoleCommand("Trappola_Hat",P["Model"],P["Name"])
		end
	end
	UpdateMdls()
	if not Shop_Dosh and Screen_Shop_Sheet then BuildDosh() end
end)