
DEFAULT_PP = {
		Muted = false,
		PhysGunAble = false,
		ConstrainAble = false,
		UseAble = false
	}

if CLIENT then
	
	function ShowPP()
		if not IsValid(PPMenu) then DrawPP() end
		PPMenu:SetSelected(0)
		
		for I,P in pairs(PPMenu.Btns) do
			P:Remove()
		end
		PPMenu.Btns = {}
		
		local I = 1
		for _,P in pairs(player.GetAll()) do
			if P != LocalPlayer() then
				local Btn = vgui.Create("SA_Button",PPMenu.List)
				Btn:SetSize(120,26)
				Btn:SetPos(0,30 * (I - 1))
				Btn:SetText(P:Name())
				Btn:SetValue(P)
				Btn:SetMenuParent(PPMenu)
				Btn.Ind = table.insert(PPMenu.Btns,Btn)
				I = I + 1
			end
		end
		if PPMenu:IsVisible() then return
		else PPMenu:SetVisible(true) end
	end
	
	function DrawPP()
		local function SavePP()
			local Frnds = {}
			local Tab = {}
			for I,P in pairs(LocalPlayer().Pliers) do
				for _,ply in pairs(player.GetAll()) do
					if ply:SteamID() == I then
						Tab[ply:EntIndex()] = P
						if P.ConstrainAble then
							table.insert(Frnds,ply)
						end
					end
				end
			end			
			net.Start("SA_PPPUpdate")
				net.WriteTable(Tab)
			net.SendToServer()
			gamemode.Call("CPPIFriendsChanged",LocalPlayer(),Frnds)
		end
		
		local function SetAll(mode,B)
			if not LocalPlayer().AllPP then LocalPlayer().AllPP = {} end
			LocalPlayer().AllPP[mode] = B
			local T = {}
			for I,P in pairs(player.GetAll()) do
				if P ~= LocalPlayer() then
					LocalPlayer().Pliers[P:SteamID()][mode] = B
					if mode == "Muted" then
						P:SetMuted(B)
					elseif mode == "ConstrainAble" then
						table.insert(T,P)
					end
				end
			end
			SavePP()
		end
		
		local W,H = 500,300
		local SW,SH = ScrW(),ScrH()
		PPMenu = vgui.Create("DFrame")
		PPMenu:SetTitle("")
		PPMenu.SetTitle = function(self,tit)
			self.Title = tit
		end
		PPMenu:SetTitle("Player Prop Protection")
		PPMenu:SetDraggable(false)
		PPMenu:SetSize(W,H)
		PPMenu:Center()
		PPMenu:MakePopup()
		PPMenu:ShowCloseButton(false)
		PPMenu.UpdateValues = function(self)
			if not IsValid(self.PlayerSelected) then 
				self.Mute:SetChecked(false)
				self.Phys:SetChecked(false)
				self.Constr:SetChecked(false)
				self.Use:SetChecked(false)
				return 
			end
			local Ply = self.PlayerSelected
			if not LocalPlayer().Pliers[Ply:SteamID()] then LocalPlayer().Pliers[Ply:SteamID()] = table.Copy(DEFAULT_PP) end
			self.Mute:SetChecked(LocalPlayer().Pliers[Ply:SteamID()].Muted)
			self.Phys:SetChecked(LocalPlayer().Pliers[Ply:SteamID()].PhysGunAble)
			self.Constr:SetChecked(LocalPlayer().Pliers[Ply:SteamID()].ConstrainAble)
			self.Use:SetChecked(LocalPlayer().Pliers[Ply:SteamID()].UseAble)
		end
		PPMenu.Close = function(self)
			self:SetVisible(false)
		end
		PPMenu.Paint = function(self,w,h)
			local Col = team.GetColor(LocalPlayer():Team())
			draw.DrawBox(0,0,w,h,Col)
			draw.DrawBox(10,30,140,h - 90,Col)
			draw.DrawText("Affects everyone: ","DermaDefaultBold",20,40,Col,TEXT_ALIGN_LEFT)
			draw.DrawBox(160,30,140,h - 90,Col)
			draw.DrawBox(w - 190,30,180,h - 90,Col)
			local Str = (self.PlayerSelected and self.PlayerSelected:Name()) or "None"
			draw.DrawText("Affects: "..Str,"DermaDefaultBold",w - 176,40,Col,TEXT_ALIGN_LEFT)
			draw.DrawText(self.Title,"Futuristic",10,0,Col,TEXT_ALIGN_LEFT)
			draw.DrawText("You can also use F2 when aiming at entities","LucidaSmall",w / 2,h - 50,Color(255,255,255),TEXT_ALIGN_CENTER)
			draw.DrawText("to enable all players to Use it.","LucidaSmall",w / 2,h - 30,Color(255,255,255),TEXT_ALIGN_CENTER)
		end
		PPMenu.Btns = {}
		PPMenu.SetSelected = function(self,Int)
			local Old = self.Selected or 0
			self.Selected = Int
			if self.Selected == 0 then
				if Old > 0 then
					self.Btns[Old].Selected = false
				end
				self.PlayerSelected = nil
				self:UpdateValues()
			else
				if Old > 0 then
					self.Btns[Old].Selected = false
				end
				self.PlayerSelected = self.Btns[self.Selected]:GetValue()
				self:UpdateValues()
			end
		end
		PPMenu.GetSelected = function(self)
			return self.Selected
		end
		
		local Close = vgui.Create("DButton",PPMenu)
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
			self:GetParent():SetVisible(false)
		end
		
		local Scrl = vgui.Create("DScrollPanel",PPMenu)
		Scrl:SetSize(134,H - 96)
		Scrl:SetPos(163,33)
		
		//local Arr = {"Test","Test2","Test3","Test4","Test5","Test6","Test7","Test8"}
		
		for I,P in pairs(player.GetAll()) do
			if P != LocalPlayer() then
				local Btn = vgui.Create("SA_Button",Scrl)
				Btn:SetSize(120,26)
				Btn:SetPos(0,30 * (I - 1))
				Btn:SetText(P:Name())
				Btn:SetValue(P)
				Btn:SetMenuParent(PPMenu)
				Btn.Ind = table.insert(PPMenu.Btns,Btn)
			end
		end
		
		local Mute = vgui.Create("SA_CheckBox",PPMenu)
		Mute:SetPos(330,60)
		Mute:SetText("Mute?")
		Mute:SetValue(false)
		Mute:SizeToContents()
		Mute.OnChange = function(self,Bol)
			if not IsValid(self:GetParent().PlayerSelected) then return end
			LocalPlayer().Pliers[self:GetParent().PlayerSelected:SteamID()].Muted = Bol
			self:GetParent().PlayerSelected:SetMuted(Bol)
			SavePP()
		end
		
		local Phys = vgui.Create("SA_CheckBox",PPMenu)
		Phys:SetPos(330,105)
		Phys:SetText("Can physgun props?")
		Phys:SetValue(false)
		Phys:SizeToContents()
		Phys.OnChange = function(self,Bol)
			if not IsValid(self:GetParent().PlayerSelected) then return end
			LocalPlayer().Pliers[self:GetParent().PlayerSelected:SteamID()].PhysGunAble = self:GetChecked()
			SavePP()
		end
		
		local Constr = vgui.Create("SA_CheckBox",PPMenu)
		Constr:SetPos(330,150)
		Constr:SetText("Can constraint props?")
		Constr:SetValue(false)
		Constr:SizeToContents()
		Constr.OnChange = function(self,Bol)
			if not IsValid(self:GetParent().PlayerSelected) then return end
			LocalPlayer().Pliers[self:GetParent().PlayerSelected:SteamID()].ConstrainAble = self:GetChecked()
			SavePP()
		end
		
		local Use = vgui.Create("SA_CheckBox",PPMenu)
		Use:SetPos(330,195)
		Use:SetText("Can do Use?")
		Use:SetValue(false)
		Use:SizeToContents()
		Use.OnChange = function(self,Bol)
			if not IsValid(self:GetParent().PlayerSelected) then return end
			LocalPlayer().Pliers[self:GetParent().PlayerSelected:SteamID()].UseAble = self:GetChecked()
			SavePP()
		end
		
		local A_Mute = vgui.Create("SA_CheckBox",PPMenu)
		A_Mute:SetPos(20,60)
		A_Mute:SetText("Mute?")
		A_Mute:SetValue(false)
		A_Mute:SizeToContents()
		A_Mute.OnChange = function(self,Bol)
			SetAll("Muted",Bol)
		end
		
		local A_Phys = vgui.Create("SA_CheckBox",PPMenu)
		A_Phys:SetPos(20,105)
		A_Phys:SetText("Physgun props?")
		A_Phys:SetValue(false)
		A_Phys:SizeToContents()
		A_Phys.OnChange = function(self,Bol)
			SetAll("PhysGunAble",Bol)
		end
		
		local A_Constr = vgui.Create("SA_CheckBox",PPMenu)
		A_Constr:SetPos(20,150)
		A_Constr:SetText("Constraint props?")
		A_Constr:SetValue(false)
		A_Constr:SizeToContents()
		A_Constr.OnChange = function(self,Bol)
			SetAll("ConstrainAble",Bol)
		end
		
		local A_Use = vgui.Create("SA_CheckBox",PPMenu)
		A_Use:SetPos(20,195)
		A_Use:SetText("Do Use?")
		A_Use:SetValue(false)
		A_Use:SizeToContents()
		A_Use.OnChange = function(self,Bol)
			SetAll("UseAble",Bol)
		end
		
		PPMenu.List = Scrl
		PPMenu.Mute = Mute
		PPMenu.Phys = Phys
		PPMenu.Constr = Constr
		PPMenu.Use = Use
		PPMenu.A_Mute = A_Mute
		PPMenu.A_Phys = A_Phys
		PPMenu.A_Constr = A_Constr
		PPMenu.A_Use = A_Use
		PPMenu:SetSelected(0)
	end

else
	
	util.AddNetworkString("SA_PPPUpdate")
	
	net.Receive("SA_PPPUpdate",function(len,ply)
		local Ply = net.ReadTable()
		
		local Frnds = {}
		for I,P in pairs(Ply) do
			local Pl = Entity(I)
			if IsValid(Pl) and Pl:IsPlayer() then
				ply.Pliers[Pl:SteamID()] = P
				if P.ConstrainAble then
					table.insert(Frnds,Pl)
				end
			end
		end
		gamemode.Call("CPPIFriendsChanged",ply,Frnds)
	end)
	
	function GM:ShowHelp(ply)
		ply:SendLua("ShowPP()")
	end
	
	function GM:ShowTeam(ply)
		local Ent = ply:GetEyeTrace().Entity
		if not IsValid(Ent) or Ent:GetNWEntity("Owner") ~= ply then return end
		Ent.UseAllowed = not Ent.UseAllowed
		if Ent.UseAllowed then
			ply:SendLua("notification.AddLegacy('You have allowed Use on "..tostring(Ent).."!',NOTIFY_GENERIC,4)")
		else
			ply:SendLua("notification.AddLegacy('You have disabled Use on "..tostring(Ent).."!',NOTIFY_GENERIC,4)")
		end
	end

end