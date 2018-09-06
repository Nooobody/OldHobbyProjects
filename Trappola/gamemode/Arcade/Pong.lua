local function Pong()
	Paused = false
	ArcadePlaying = false
	local P1Score = 0
	local P2Score = 0
	local XMov = 1
	local YMov = 1
	local Arena = vgui.Create("DPanel",g_MGMenu.List)
	Arena:SetSize(g_MGMenu.List:GetWide(),g_MGMenu.List:GetTall())
	Arena:SetPos(0,0)
	Arena.Paint = function(self)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		draw.DrawText("P1 score: "..P1Score,"DefaultLarge",20,0,Color(255,255,255,255),TEXT_ALIGN_LEFT)
		draw.DrawText("P2 score: "..P2Score,"DefaultLarge",self:GetWide() - 20,0,Color(255,255,255,255),TEXT_ALIGN_RIGHT)
		draw.DrawText("W or Up arrow to go up","DefaultLarge",20,350,Color(255,255,255,255),TEXT_ALIGN_LEFT)
		draw.DrawText("S or Down arrow to go down","DefaultLarge",20,370,Color(255,255,255,255),TEXT_ALIGN_LEFT)
		if Paused then
			draw.DrawText("PAUSED","HUDNumber",self:GetWide() / 2,60,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		end
	end
	local PlayArea = vgui.Create("DPanel",Arena)
	PlayArea:SetSize(Arena:GetWide() - 40,Arena:GetTall() - 80)
	PlayArea:SetPos(20,20)
	PlayArea.Paint = function(self)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall())
	end
	local P1 = vgui.Create("DPanel",PlayArea)
	P1:SetSize(5,60)
	P1:SetPos(10,PlayArea:GetTall() / 2 - 30)
	P1.Paint = function(self)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end
	local P2 = vgui.Create("DPanel",PlayArea)
	P2:SetSize(5,60)
	P2:SetPos(PlayArea:GetWide() - 20,PlayArea:GetTall() / 2 - 30)
	P2.Paint = function(self)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end
	local Start = vgui.Create("DButton",Arena)
	Start:SetSize(60,40)
	Start:SetPos(20,Arena:GetTall() - 50)
	Start:SetText("Start!")
	Start.DoClick = function(self)
		ArcadePlaying = true
		Start:SetVisible(false)
		Start.DoClick = function() end
		local Ball = vgui.Create("DPanel",PlayArea)
		Ball:SetSize(10,10)
		Ball:SetPos(PlayArea:GetWide() / 2 - 5,PlayArea:GetTall() / 2 - 5)
		Ball.Paint = function(self)
			draw.RoundedBox(6,0,0,self:GetWide(),self:GetTall(),Color(255,255,255,255))
		end
		local Time = 1
		local PongThink = function()
			if Paused then return end
			local X,Y = Ball:GetPos()
			X,Y = X + (XMov * math.floor(Time)),Y + YMov
			Ball:SetPos(X,Y)
			if (Y <= 0 and YMov < 0) or (Y + Ball:GetTall() >= PlayArea:GetTall() and YMov > 0) then
				SelfPly:EmitSound("buttons/blip1.wav")
				YMov = -YMov
			end
			local P1X,P1Y = P1:GetPos()
			local P2X,P2Y = P2:GetPos()
			if (X <= P1X + P1:GetWide() and Y + 5 >= P1Y and Y + 5 <= P1Y + P1:GetTall() and XMov < 0) or (X + Ball:GetWide() >= P2X and Y + 5 >= P2Y and Y + 5 <= P2Y + P2:GetTall() and XMov > 0) then
				Time = Time + 0.3
				SelfPly:EmitSound("buttons/blip1.wav")
				XMov = -XMov
			end
			if (input.IsKeyDown(KEY_W) or input.IsKeyDown(KEY_UP)) and P1Y >= 0 then
				P1:SetPos(P1X,P1Y - 1)
			elseif (input.IsKeyDown(KEY_S) or input.IsKeyDown(KEY_DOWN)) and P1Y + P1:GetTall() <= PlayArea:GetTall() then
				P1:SetPos(P1X,P1Y + 1)
			end
			if Y + 5 < P2Y + P2:GetTall() / 2 and P2Y >= 0 and XMov > 0 then
				P2:SetPos(P2X,P2Y - 1)
			elseif Y + 5 > P2Y + P2:GetTall() / 2 and P2Y + P2:GetTall() <= PlayArea:GetTall() and XMov > 0 then
				P2:SetPos(P2X,P2Y + 1)
			end
			if X < P1X and (Y + 5 < P1Y or Y + 5 > P1Y + P1:GetTall()) then
				P2Score = P2Score + 1
				Ball:SetPos(PlayArea:GetWide() / 2 - 5,math.random(0,PlayArea:GetTall() - 10))
				XMov = -XMov
				YMov = 1
				Time = 1
			elseif X > P2X + P2:GetWide() and (Y + 5 < P2Y or Y + 5 > P2Y + P2:GetTall()) then
				P1Score = P1Score + 1
				Ball:SetPos(PlayArea:GetWide() / 2 - 5,math.random(0,PlayArea:GetTall() - 10))
				XMov = -XMov
				YMov = 1
				Time = 1
			end
		end
		hook.Add("Think","Pong",PongThink)
	end
	
	function PauseGeemu()
		Paused = not Paused
	end
	
	local Pause = vgui.Create("DButton",Arena)
	Pause:SetSize(60,40)
	Pause:SetPos(20 + PlayArea:GetWide() - 140,Arena:GetTall() - 50)
	Pause:SetText("Pause")
	Pause.DoClick = PauseGeemu	
	
	local function ExitGeemu()
		ArcadePlaying = nil
		Paused = nil
		Arena:Remove()
		hook.Remove("Think","Pong")
	end
	
	local Exit = vgui.Create("DButton",Arena)
	Exit:SetSize(60,40)
	Exit:SetPos(20 + PlayArea:GetWide() - 60,Arena:GetTall() - 50)
	Exit:SetText("Exit")
	Exit.DoClick = ExitGeemu
end
table.insert(Geemu,{["Name"] = "Pong",["Function"] = Pong})