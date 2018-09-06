
local function CreateTeamBox(NumberOfSwitches)
	local TeamMenu = vgui.Create("DPanel")
	TeamMenu:SetSize(ScrW() - 200,ScrH() - 200)
	TeamMenu:Center()
	TeamMenu:MakePopup()
	TeamMenu.Paint = function(self,w,h)
		draw.DrawBox(0,0,w,h,team.GetColor(LocalPlayer():Team()))
	end
	local W,H = TeamMenu:GetSize()
	
	local Close = vgui.Create("DButton",TeamMenu)
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
		net.Start("SA_TeamSelected")
			net.WriteUInt(1,4)
		net.SendToServer()
		self:GetParent():Remove()
	end
	
	local Font = "TeamMenuFont"
	local TextFont = "Lucida"
	local TitleY = 40
	surface.SetFont(Font)
	local SizeX = surface.GetTextSize("The Corporation")
	
	if SizeX > (W - 80) / 4 - 40 then
		Font = "TeamMenuFontSmall"
		TextFont = "LucidaSmall"
		TitleY = 20
	end
	
	local Ind = 0
	for I,P in pairs(FACTIONS) do
		if P.Num > 1 then
			local TeamPanel = vgui.Create("DPanel",TeamMenu)
			local w = (W - 80) / 4
			TeamPanel:SetSize(w - 20,H - 100)
			TeamPanel:SetPos(40 + w * Ind,40)
			if P.Icon then
				TeamPanel.Icon = P.Icon
			end
			TeamPanel.Paint = function(self,w,h)
				draw.DrawBox(0,0,w,h,P.Col)
				if self.Depressed then
					surface.SetDrawColor(P.Col.r,P.Col.g,P.Col.b,20)
					surface.DrawRect(3,3,w - 6,h - 6)
				elseif self.Hovered then
					surface.SetDrawColor(P.Col.r,P.Col.g,P.Col.b,50)
					surface.DrawRect(3,3,w - 6,h - 6)
				end
				draw.DrawText(P.Name,Font,w / 2,TitleY,P.Col,TEXT_ALIGN_CENTER)
				if self.Icon then
					surface.SetMaterial(self.Icon)
					surface.SetDrawColor(255,255,255,255)
					surface.DrawTexturedRect(50,TitleY + 40,w - 100,w - 100)
				end
			end
			TeamPanel.OnCursorEntered = function(self)
				self.Hovered = true
			end
			TeamPanel.OnCursorExited = function(self)
				self.Hovered = false
				self.Depressed = false
			end
			TeamPanel.OnMousePressed = function(self)
				self.Depressed = true
			end
			TeamPanel.OnMouseReleased = function(self)
				if self.Hovered then self:DoClick() end
				self.Depressed = false
			end
			TeamPanel.DoClick = function(self)
				self:GetParent():Remove()
				if LocalPlayer():GetMoney() >= NumberOfSwitches * math.pow(2,20) then
					net.Start("SA_TeamSelected")
						net.WriteUInt(P.Num,4)
					net.SendToServer()
				else
					local Box = vgui.Create("DPanel")
					Box:SetSize(800,200)
					Box:Center()
					Box:MakePopup()
					Box.Paint = function(self,w,h)
						draw.DrawBox(0,0,w,h,Color(255,255,255))
						draw.DrawText("I'm sorry, but you don't have the credits for that!","Lucida",w / 2,40,Color(255,255,255),TEXT_ALIGN_CENTER)
						draw.DrawText("You need atleast "..NumberOfSwitches * math.pow(2,20).." credits.","Lucida",w / 2,80,Color(255,255,255),TEXT_ALIGN_CENTER)
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
					local Btn = vgui.Create("DButton",Box)
					Btn:SetSize(60,40)
					Btn:SetPos(W / 2 - 30,120)
					Btn:SetText("Okay...")
					Btn.DoClick = function(self)
						self:GetParent():Remove()
					end
				end
			end
			Ind = Ind + 1
			local Wi,He = TeamPanel:GetSize()
			local Text = vgui.Create("RichText",TeamPanel)
			Text:SetSize(Wi - 40,He / 2)
			Text:SetPos(20,He / 2 + 10)
			local Pnt = Text.Paint
			Text.Paint = function(self)
				self.m_FontName = TextFont
				self:SetFontInternal(TextFont)
				self.Paint = Pnt
			end
			Text:AppendText(P.Desc)
		end
	end
	
	local Free = vgui.Create("DButton",TeamMenu)
	Free:SetSize(W - 100,40)
	Free:SetPos(50,H - 50)
	Free:SetText("Or you can choose to be left alone as a freelancer, no bonuses apply")
	Free.DoClick = function(self)
		net.Start("SA_TeamSelected")
			net.WriteUInt(1,4)
		net.SendToServer()
		self:GetParent():Remove()
	end
		
	local Hidden = vgui.Create("DPanel")
	Hidden:SetSize(ScrW(),ScrH())
	Hidden:SetPos(0,0)
	Hidden:MakePopup()
	if NumberOfSwitches == 0 then
		Hidden.Paint = function(self,w,h)
			surface.SetDrawColor(0,0,0,245)
			surface.DrawRect(0,0,w,h)
			draw.DrawText("You have been chosen from the masses for the Freelancer Education program.","Lucida",w / 2,200,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			draw.DrawText("You will be given a choice for 4 different factions, that you can choose from. You can choose to remain as a Freelancer aswell.","Lucida",w / 2,240,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		end
	else
		Hidden.Paint = function(self,w,h)
			surface.SetDrawColor(0,0,0,245)
			surface.DrawRect(0,0,w,h)
			draw.DrawText("You're here again? Guess you weren't that satisfied in your old Faction.","Lucida",w / 2,200,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			draw.DrawText("After your first Faction though, you need to pay up some credits to get into a Faction again!","Lucida",w / 2,240,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			draw.DrawText("The amount you need is "..NumberOfSwitches * math.pow(2,20).." credits!","Lucida",w / 2,280,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		end
	end
	local Btn = vgui.Create("DButton",Hidden)
	Btn:SetSize(60,60)
	Btn:SetPos(ScrW() / 2 - 30,320)
	Btn:SetText("Okay")
	Btn.DoClick = function(self)
		self:GetParent():Remove()
	end
end

net.Receive("SA_TeamSelection",function(len)
	CreateTeamBox(net.ReadUInt(8))
end)