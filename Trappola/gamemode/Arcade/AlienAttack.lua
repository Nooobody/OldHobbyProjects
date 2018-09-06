local function AlienAttack()
	Paused = false
	ArcadePlaying = false
	local Score = 0
	local Highscore = 0
	local Lives = 3
	local Movement = 2
	local ShootUpg = 0.2
	local GameOver = false
	local Message = ""
	local Aliens = {}
	local Bullet = {}
	Bullet.Init = function()
	end
	Bullet.Paint = function(self)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
	end
	Bullet.Think = function(self)
		if Paused then return end
		local X,Y = self:GetPos()
		local Y = Y - 1
		self:SetPos(X,Y)
		if Y < 0 then self:Remove() end
		for I,P in pairs(Aliens) do
			local x,y = P:GetPos()
			if X < x + P:GetWide() and X > x and Y < y + P:GetTall() and Y > y then
				P:Hit(P)
				self:Remove()
			end
		end
	end
	vgui.Register("Bullet",Bullet,"DPanel")
	local Alien = {}
	Alien.Init = function(self)
		table.insert(Aliens,self)
		self.CanMove = true
	end
	Alien.Think = function(self)
		if Paused then return end
		if self.CanMove then
			self.CanMove = false
			timer.Simple(1 - math.floor(Score / 100) / 10,function() if self and self:IsValid() then self.CanMove = true end end)
			local X,Y = self:GetPos()
			self:SetPos(X,Y + 10)
			if Y + 1 > self:GetParent():GetTall() then self:Win(self) end
		end
	end
	local AlienTex = surface.GetTextureID("Alien")
	Alien.Paint = function(self)
		surface.SetTexture(AlienTex)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(0,0,self:GetWide(),self:GetTall())
	end
	Alien.Win = function(self)
		Lives = Lives - 1
		if Lives > 0 then
			Message = "An alien has got past you and snatched one of your lives!"
			timer.Simple(3,function() Message = "" end)
		elseif Lives <= 0 and not GameOver then
			Highscore = Score
			Score = 2000
			GameOver = true
			ArcadePlaying = false
		end
		self:Die(self)
	end
	Alien.Die = function(self)
		self:Remove()
		for I,P in pairs(Aliens) do
			if self == P then
				table.remove(Aliens,I)
			end
		end
	end
	Alien.Hit = function(self)
		Score = Score + 1
		if Score%100 == 0 then
			Lives = Lives + 1
			Message = "You have gained an extra life through your success!"
			timer.Simple(3,function() Message = "" end)
		end
		if Score%350 == 0 then
			Movement = Movement + 1
			Message = "As a tribute to your success, you have gained a faster board!"
			timer.Simple(3,function() Message = "" end)
		end
		if Score%450 == 0 then
			ShootUpg = ShootUpg - 0.075
			Message = "As a tribute to your success, you have gained a faster gun!"
			timer.Simple(3,function() Message = "" end)
		end
		self:Die(self)
	end
	vgui.Register("Alien",Alien,"DPanel")
	local HeartTex = surface.GetTextureID("Heart")
	local Arena = vgui.Create("DPanel",g_MGMenu.List)
	local Start = vgui.Create("DButton",Arena)
	Arena:SetSize(g_MGMenu.List:GetWide(),g_MGMenu.List:GetTall())
	Arena:SetPos(0,0)
	Arena.Paint = function(self)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		if GameOver then
			draw.DrawText("You lost!","HUDNumber",self:GetWide() / 2,100,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			draw.DrawText("Your score: "..Highscore,"DefaultLarge",self:GetWide() / 2,180,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			Start:SetVisible(true)
		else
			if Paused then
				draw.DrawText("PAUSED","HUDNumber",self:GetWide() / 2,60,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			end
			draw.DrawText("Score: "..Score,"DefaultLarge",10,370,Color(255,255,255,255),TEXT_ALIGN_LEFT)
			draw.DrawText(Message,"DefaultLarge",Arena:GetWide() - 100,360,Color(255,255,255,255),TEXT_ALIGN_RIGHT)
			for I = 1,Lives do
				surface.SetTexture(HeartTex)
				surface.SetDrawColor(255,255,255,255)
				surface.DrawTexturedRect(100 + (34 * (I - 1)),350,32,32)
			end
		end
	end
	local Board = vgui.Create("DPanel",Arena)
	Board:SetSize(30,10)
	Board:SetPos(Arena:GetWide() / 2 - Board:GetWide() / 2,330)
	local CanShoot = true
	Board.Think = function(self)
		if Paused then return end
		if GameOver then return end
		local X,Y = self:GetPos()
		if (input.IsKeyDown(KEY_A) or input.IsKeyDown(KEY_LEFT)) and X >= 10 then
			self:SetPos(X - Movement,Y)
		elseif (input.IsKeyDown(KEY_D) or input.IsKeyDown(KEY_RIGHT)) and X + self:GetWide() <= Arena:GetWide() - 10 then
			self:SetPos(X + Movement,Y)
		end
		if input.IsKeyDown(KEY_SPACE) and CanShoot then
			CanShoot = false
			timer.Simple(ShootUpg,function() CanShoot = true end)
			local Bullet = vgui.Create("Bullet",Arena)
			Bullet:SetPos(X + Board:GetWide() / 2,Y)
			Bullet:SetSize(1,1)
		end
	end
	Board.Paint = function(self)
		draw.RoundedBox(10,0,2,self:GetWide(),self:GetTall() - 2,Color(255,0,0,255))
		surface.SetDrawColor(255,0,0,255)
		surface.DrawLine(self:GetWide() / 2,0,self:GetWide() / 2,2)
	end
	Start:SetSize(60,40)
	Start:SetPos(10,Arena:GetTall() - 50)
	Start:SetText("Start")
	Start.DoClick = function(self)
		self:SetVisible(false)
		ArcadePlaying = true
		local CanSpawn = true
		if GameOver then
			GameOver = false
			Highscore = 0
			Score = 0
			Lives = 3
			for I,P in pairs(Aliens) do
				P:Remove()
			end
			Aliens = {}
		end
		Message = "A and D (or left/right arrows) to move, Space to shoot."
		hook.Add("Think","Alien Attack",function()
			if Paused then return end
			if CanSpawn then
				CanSpawn = false
				timer.Simple(1 - math.floor(Score / 150) / 10,function() CanSpawn = true end)
				local Alien = vgui.Create("Alien",Arena)
				Alien:SetPos(math.random(10,Arena:GetWide() - 30),math.random(-50,-20))
				Alien:SetSize(32,32)
			end
		end)
	end
	
	function PauseGeemu()
		Paused = not Paused
	end
	
	local Pause = vgui.Create("DButton",Arena)
	Pause:SetSize(60,20)
	Pause:SetPos(Arena:GetWide() / 2 - 30,380)
	Pause:SetText("Pause")
	local Old = Pause.Paint
	Pause.Paint = function(self)
		if not Start:IsVisible() then
			Old(self)
		end
	end
	Pause.DoClick = PauseGeemu
	
	local function ExitGeemu()
		Paused = nil
		ArcadePlaying = nil
		Arena:Remove()
		hook.Remove("Think","Alien Attack")
	end
	
	local Exit = vgui.Create("DButton",Arena)
	Exit:SetSize(60,40)
	Exit:SetPos(Arena:GetWide() - 70,350)
	Exit:SetText("Exit")
	Exit.DoClick = ExitGeemu
end

table.insert(Geemu,{["Name"] = "Alien Attack",["Function"] = AlienAttack})