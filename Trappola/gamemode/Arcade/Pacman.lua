local function Pacman()
	local FrameLimiter = false
	local Val = 0
	hook.Add("Think","PacThink",function()
		if FrameLimiter then
			Val = Val + 1
			if Val > 1 then
				hook.Call("PacThink")
				Val = 0
			end
		else
			hook.Call("PacThink")
		end
	end)
	ArcadePlaying = false
	local Up,Right,Down,Left = 1,2,3,4
	local BlockTable = {}
	local Tab = {{{Right,Down,nil,nil,true},{Right,Left},			{Right,Left},			{Right,Down,Left},		{Right,Left},		{Right,Left},		{Right,Left},		{Right,Left},		{Down,Left},				{},							{},							{Right,Down},				{Right,Left},		{Right,Left},		{Right,Left},			{Right,Left},			{Right,Down,Left},			{Right,Left},		{Right,Left},			{Down,Left,nil,nil,true}},
				{{Up,Down},					{},						{},						{Up,Down},				{},					{},					{},					{},					{Up,Down},					{},							{},							{Up,Down},					{},					{},					{},						{},						{Up,Down},					{},					{},						{Up,Down}},
				{{Up,Down},					{},						{},						{Up,Down},				{},					{},					{},					{},					{Up,Down},					{},							{},							{Up,Down},					{},					{},					{},						{},						{Up,Down},					{},					{},						{Up,Down}},
				{{Up,Right,Down},			{Right,Left},			{Right,Left},			{Up,Right,Down,Left},	{Right,Left},		{Right,Down,Left},	{Right,Left},		{Right,Left},		{Up,Right,Left},			{Right,Left,nil,nil,nil,nil,true},{Right,Left,nil,nil,nil,nil,true},{Up,Right,Left},{Right,Left},		{Right,Left},		{Right,Down,Left},		{Right,Left},			{Up,Right,Down,Left},		{Right,Left},		{Right,Left},			{Up,Down,Left}},
				{{Up,Down},					{},						{},						{Up,Down},				{},					{Up,Down},			{},					{},					{},							{},							{},							{},							{},					{},					{Up,Down},				{},						{Up,Down},					{},					{},						{Up,Down}},
				{{Up,Right},				{Right,Down,Left},		{Right,Left},			{Up,Down,Left},			{},					{Up,Right,Down},	{Right,Left},		{Right,Left},		{Down,Left},				{},							{},							{Right,Down},				{Right,Left},		{Right,Left},		{Up,Down,Left},			{},						{Up,Right,Down},			{Right,Left},		{Right,Down,Left},		{Up,Left}},
				{{},						{Up,Down},				{},						{Up,Down},				{},					{Up,Down},			{},					{},					{Up,Down},					{},							{},							{Up,Down},					{},					{},					{Up,Down},				{},						{Up,Down},					{},					{Up,Down},				{}},
				{{},						{Up,Right},				{Right,Left},			{Up,Down,Left},			{},					{Up,Right,Down},	{Right,Left},		{Right,Down,Left},	{Up,Right,Left},			{Right,Left},				{Right,Left},				{Up,Right,Left},			{Right,Down,Left},	{Right,Left},		{Up,Down,Left},			{},						{Up,Right,Down},			{Right,Left},		{Up,Left},				{}},
				{{},						{},						{},						{Up,Down},				{},					{Up,Down},			{},					{Up,Down},			{},							{},							{},							{},							{Up,Down},			{},					{Up,Down},				{},						{Up,Down},					{},					{},						{}},
				{{Right,Down,Left},			{Right,Down,Left},		{Right,Down,Left},		{Up,Right,Down,Left},	{Right,Down,Left},	{Up,Down,Left},		{},					{Up,Down},			{},							{},							{},							{},							{Up,Down},			{},					{Up,Right,Down},		{Right,Down,Left},		{Up,Right,Down,Left},		{Right,Down,Left},	{Right,Down,Left},		{Right,Down,Left}},
				{{Up,Right,Left},			{Up,Right,Left},		{Up,Right,Left},		{Up,Right,Down,Left},	{Up,Right,Left},	{Up,Down,Left},		{},					{Up,Right},			{Right,Left,nil,nil,nil,true},{Right,Left,nil,nil,nil,true},{Right,Left,nil,nil,nil,true},{Right,Left,nil,nil,nil,true},{Up,Left},	{},					{Up,Right,Down},		{Up,Right,Left},		{Up,Right,Down,Left},		{Up,Right,Left},	{Up,Right,Left},		{Up,Right,Left}},
				{{},						{},						{},						{Up,Down},				{},					{Up,Down},			{},					{},					{},							{},							{},							{},							{},					{},					{Up,Down},				{},						{Up,Down},					{},					{},						{}},
				{{},						{},						{},						{Up,Down},				{},					{Up,Right,Down},	{Right,Left},		{Right,Left},		{Right,Left},				{Right,Left},				{Right,Left},				{Right,Left},				{Right,Left},		{Right,Left},		{Up,Down,Left},			{},						{Up,Down},					{},					{},						{}},
				{{},						{},						{},						{Up,Down},				{},					{Up,Down},			{},					{},					{},							{},							{},							{},							{},					{},					{Up,Down},				{},						{Up,Down},					{},					{},						{}},
				{{Right,Down},				{Right,Left},			{Right,Left},			{Up,Right,Left},		{Right,Down,Left},	{Up,Right,Left},	{Right,Left},		{Right,Left},		{Down,Left},				{},							{},							{Right,Down},				{Right,Left},		{Right,Left},		{Up,Right,Left},		{Right,Down,Left},		{Up,Right,Left},			{Right,Left},		{Right,Left},			{Down,Left}},
				{{Up,Down},					{},						{},						{},						{Up,Down},			{},					{},					{},					{Up,Right},					{Down,Left},				{Right,Down},				{Up,Left},					{},					{},					{},						{Up,Down},				{},							{},					{},						{Up,Down}},
				{{Up,Right},				{Down,Left},			{},						{},						{Up,Right,Down},	{Right,Left},		{Down,Left},		{},					{},							{Up,Down},					{Up,Down},					{},							{},					{Right,Down},		{Right,Left},			{Up,Down,Left},			{},							{},					{Right,Down},			{Up,Left}},
				{{Right,Down},				{Up,Right,Left},		{Right,Left},			{Right,Left},			{Up,Left},			{},					{Up,Right},			{Right,Left},		{Right,Down,Left},			{Up,Down,Left},				{Up,Right,Down},			{Right,Down,Left},			{Right,Left},		{Up,Left},			{},						{Up,Right},				{Right,Left},				{Right,Left},		{Up,Right,Left},		{Down,Left}},
				{{Up,Down},					{},						{},						{},						{},					{},					{},					{},					{Up,Down},					{Up,Right},					{Up,Left},					{Up,Down},					{},					{},					{},						{},						{},							{},					{},						{Up,Down}},
				{{Up,Right,nil,nil,true},		{Right,Left},			{Right,Left},			{Right,Left},			{Right,Left},		{Right,Left},		{Right,Left},		{Right,Left},		{Up,Right,Left},			{Right,Left},				{Right,Left},				{Up,Right,Left},			{Right,Left},		{Right,Left},		{Right,Left},			{Right,Left},			{Right,Left},				{Right,Left},		{Right,Left},			{Up,Left,nil,nil,true}}}
	table.insert(BlockTable,Tab)
	Tab = {{{},				{},									{},				{},					{},					{},				{},				{},						{},					{Up,Right,Down},				{Up,Down,Left},					{},					{},						{},				{},				{},				{},					{},				{},									{}},
				{{},				{Down,nil,nil,nil,true},			{},				{Right,Down},		{Right,Left},		{Right,Left},	{Right,Left},	{Right,Down,Left},		{Right,Left},		{Up,Right,Down,Left},			{Up,Right,Down,Left},			{Right,Left},		{Right,Down,Left},		{Right,Left},	{Right,Left},	{Right,Left},	{Down,Left},		{},				{Down,nil,nil,nil,true},			{}},
				{{},				{Up,Down},							{},				{Up,Down},			{},					{},				{},				{Up,Down},				{},					{Up,Right,Down},				{Up,Down,Left},					{},					{Up,Down},				{},				{},				{},				{Up,Down},			{},				{Up,Down},							{}},
				{{},				{Up,Right},							{Right,Left},	{Up,Right,Left},	{Right,Left},		{Right,Left},	{Right,Left},	{Up,Down,Left},			{},					{Up,Right,Down},				{Up,Down,Left},					{},					{Up,Right,Down},		{Right,Left},	{Right,Left},	{Right,Left},	{Up,Right,Left},	{Right,Left},	{Up,Left},							{}},
				{{},				{},									{},				{},					{},					{},				{},				{Up,Down},				{},					{Up,Right,Down},				{Up,Down,Left},					{},					{Up,Down},				{},				{},				{},				{},					{},				{},									{}},
				{{},				{Right,Down,nil,nil,nil,nil,true},	{Right,Left},	{Right,Left},		{Right,Left},		{Right,Left},	{Right,Left},	{Up,Right,Down,Left},	{Right,Down,Left},	{Up,Right,Down,Left},			{Up,Right,Down,Left},			{Right,Down,Left},	{Up,Right,Down,Left},	{Right,Left},	{Right,Left},	{Right,Left},	{Right,Left},		{Right,Left},	{Down,Left,nil,nil,nil,nil,true},	{}},
				{{},				{Up,Down},							{},				{},					{},					{},				{},				{Up,Right,Down},		{Up,Right,Left},	{Up,Right,Left},				{Up,Right,Left},				{Up,Right,Left},	{Up,Left},				{},				{},				{},				{},					{},				{Up,Down},							{}},
				{{},				{Up,Down},							{},				{Right,Down},		{Right,Left},		{Left},			{},				{Up,Down},				{},					{},								{},								{},					{},						{},				{Right},		{Right,Left},	{Down,Left},		{},				{Up,Down},							{}},
				{{},				{Up,Right,Down},					{Right,Left},	{Up,Down,Left},		{},					{},				{},				{Up,Down},				{},					{Right,Down,nil,nil,nil,true},	{Down,Left,nil,nil,nil,true},	{},					{Down},					{},				{},				{},				{Up,Right,Down},	{Right,Left},	{Up,Down,Left},						{}},
				{{Right,Down,Left},	{Up,Down,Left},						{},				{Up,Down},			{},					{Right,Down},	{Right,Left},	{Up,Right,Down,Left},	{Right,Down,Left},	{Up,Right,Down,Left},			{Up,Right,Down,Left},			{Right,Down,Left},	{Up,Right,Down,Left},	{Right,Left},	{Down,Left},	{},				{Up,Down},			{},				{Up,Right,Down},					{Right,Down,Left}},
				{{Up,Right,Left},	{Up,Down,Left},						{},				{Up,Right,Down},	{Right,Left},		{Up,Left},		{},				{Up,Right,Down},		{Up,Right,Left},	{Up,Right,Down,Left},			{Up,Right,Down,Left},			{Up,Right,Left},	{Up,Down,Left},			{},				{Up,Right},		{Right,Left},	{Up,Down,Left},		{},				{Up,Right,Down},					{Up,Right,Left}},
				{{},				{Up,Right,Down},					{Right,Left},	{Up,Down,Left},		{},					{},				{},				{Up},					{},					{Up,Right,nil,nil,nil,true},	{Up,Left,nil,nil,nil,true},		{},					{Up,Down},				{},				{},				{},				{Up,Right,Down},	{Right,Left},	{Up,Down,Left},						{}},
				{{},				{Up,Down},							{},				{Up,Right},			{Right,Left},		{Left},			{},				{},						{},					{},								{},								{},					{Up,Down},				{},				{Right},		{Right,Left},	{Up,Left},			{},				{Up,Down},							{}},
				{{},				{Up,Down},							{},				{},					{},					{},				{},				{Right,Down},			{Right,Down,Left},	{Right,Down,Left},				{Right,Down,Left},				{Right,Down,Left},	{Up,Down,Left},			{},				{},				{},				{},					{},				{Up,Down},							{}},
				{{},				{Up,Right,nil,nil,nil,nil,true},	{Right,Left},	{Right,Left},		{Right,Left},		{Right,Left},	{Right,Left},	{Up,Right,Down,Left},	{Up,Right,Left},	{Up,Right,Down,Left},			{Up,Right,Down,Left},			{Up,Right,Left},	{Up,Right,Down,Left},	{Right,Left},	{Right,Left},	{Right,Left},	{Right,Left},		{Right,Left},	{Up,Left,nil,nil,nil,nil,true},		{}},
				{{},				{},									{},				{},					{},					{},				{},				{Up,Down},				{},					{Up,Right,Down},				{Up,Down,Left},					{},					{Up,Down},				{},				{},				{},				{},					{},				{},									{}},
				{{},				{Right,Down},						{Right,Left},	{Right,Down,Left},	{Right,Left},		{Right,Left},	{Right,Left},	{Up,Down,Left},			{},					{Up,Right,Down},				{Up,Down,Left},					{},					{Up,Right,Down},		{Right,Left},	{Right,Left},	{Right,Left},	{Right,Down,Left},	{Right,Left},	{Down,Left},						{}},
				{{},				{Up,Down},							{},				{Up,Down},			{},					{},				{},				{Up,Down},				{},					{Up,Right,Down},				{Up,Down,Left},					{},					{Up,Down},				{},				{},				{},				{Up,Down},			{},				{Up,Down},							{}},
				{{},				{Up,nil,nil,nil,true},				{},				{Up,Right},			{Right,Left},		{Right,Left},	{Right,Left},	{Up,Right,Left},		{Right,Left},		{Up,Right,Down,Left},			{Up,Right,Down,Left},			{Right,Left},		{Up,Right,Left},		{Right,Left},	{Right,Left},	{Right,Left},	{Up,Left},			{},				{Up,nil,nil,nil,true},				{}},
				{{},				{},									{},				{},					{},					{},				{},				{},						{},					{Up,Right,Down},				{Up,Down,Left},					{},					{},						{},				{},				{},				{},					{},				{},									{}}}
	table.insert(BlockTable,Tab)
	Tab = nil
	Paused = false
	local Blocks = {}
	local AISpawn = {}
	local PacSpawn = {}
	local Score = 0
	local Balls = 0
	local GameOver = false
	local Win = false
	local Deletables = {}
	local PlayArea
	local Start
	local Arena = vgui.Create("DPanel",g_MGMenu.List)
	Arena:SetSize(g_MGMenu.List:GetWide(),g_MGMenu.List:GetTall())
	Arena.Paint = function(self)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,0,self:GetWide(),self:GetTall())
		draw.DrawText("Score: "..Score,"MenuLarge",self:GetWide() / 2 - 200,380,Color(255,255,255,255),TEXT_ALIGN_RIGHT)
		if GameOver then
			if Win then
				draw.DrawText("You win!","HUDNumber",self:GetWide() / 2,100,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			else
				draw.DrawText("You lost!","HUDNumber",self:GetWide() / 2,100,Color(255,255,255,255),TEXT_ALIGN_CENTER)
			end
		end
		if Paused then
			draw.DrawText("PAUSED","HUDNumber",self:GetWide() / 2,60,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		end
	end
	local Table = {}
	
	local function AddBlock(Dir,Paint)
		table.insert(Table,{["Directions"] = Dir,["Paint"] = Paint})
	end
	
	AddBlock({Up},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawOutlinedRect(0,-1,self:GetWide(),self:GetTall() + 1) end)
	AddBlock({Right},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawOutlinedRect(0,0,self:GetWide() + 1,self:GetTall()) end)
	AddBlock({Down},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawOutlinedRect(0,0,self:GetWide(),self:GetTall() + 1) end)
	AddBlock({Left},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawOutlinedRect(-1,0,self:GetWide() + 1,self:GetTall()) end)
	AddBlock({Up,Down},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawOutlinedRect(0,-1,self:GetWide(),self:GetTall() + 2) end)
	AddBlock({Right,Left},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawOutlinedRect(-1,0,self:GetWide() + 2,self:GetTall()) end)
	AddBlock({Up,Right},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawOutlinedRect(0,-1,self:GetWide() + 1,self:GetTall() + 1) surface.DrawOutlinedRect(self:GetWide() - 1,-1,2,2) end)
	AddBlock({Up,Left},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawOutlinedRect(-1,-1,self:GetWide() + 1,self:GetTall() + 1) surface.DrawOutlinedRect(-1,-1,2,2) end)
	AddBlock({Right,Down},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawOutlinedRect(0,0,self:GetWide() + 1,self:GetTall() + 1) surface.DrawOutlinedRect(self:GetWide() - 1,self:GetTall() - 1,2,2) end)
	AddBlock({Down,Left},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawOutlinedRect(-1,0,self:GetWide() + 1,self:GetTall() + 1) surface.DrawOutlinedRect(-1,self:GetTall() - 1,2,2) end)
	AddBlock({Up,Right,Down},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawLine(0,0,0,self:GetTall()) surface.DrawOutlinedRect(self:GetWide() - 1,-1,2,2) surface.DrawOutlinedRect(self:GetWide() - 1,self:GetTall() - 1,2,2) end)
	AddBlock({Right,Down,Left},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawLine(0,0,self:GetWide(),0) surface.DrawOutlinedRect(-1,self:GetTall() - 1,2,2) surface.DrawOutlinedRect(self:GetWide() - 1,self:GetTall() - 1,2,2) end)
	AddBlock({Up,Down,Left},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawLine(self:GetWide() - 1,0,self:GetWide() - 1,self:GetTall()) surface.DrawOutlinedRect(-1,-1,2,2) surface.DrawOutlinedRect(-1,self:GetTall() - 1,2,2) end)
	AddBlock({Up,Right,Left},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawLine(0,self:GetTall() - 1,self:GetWide(),self:GetTall() - 1) surface.DrawOutlinedRect(-1,-1,2,2) surface.DrawOutlinedRect(self:GetWide() - 1,-1,2,2) end)
	AddBlock({Up,Right,Down,Left},function(self) surface.SetDrawColor(0,0,255,255) surface.DrawOutlinedRect(-1,-1,2,2) surface.DrawOutlinedRect(self:GetWide() - 1,-1,2,2) surface.DrawOutlinedRect(self:GetWide() - 1,self:GetTall() - 1,2,2) surface.DrawOutlinedRect(-1,self:GetTall() - 1,2,2) end)
	
	local Pac = {}
	Pac.Init = function(self)
		self.Moving = false
		self.Direction = 0
		self.OldDir = Right
		self.SuperBallEnd = CurTime()
		hook.Add("PacThink","Pacman",function()
			self:PacThink(self)
		end)
	end
	Pac.PacThink = function(self)
		if GameOver or Paused then return end
		if self.SuperBall then
			self.SuperBallEnd = self.SuperBallEnd + 0.1
		end
		if self.SuperBallEnd >= 50 and self.SuperBall then
			self.SuperBall = false
		end
		if self.Transferring then
			local X,Y = self:GetPos()
			if self.Direction == Up and Y + self:GetTall() < self:GetParent():GetTall() then
				self.Transferring = false
			elseif self.Direction == Right and X > 0 then
				self.Transferring = false
			elseif self.Direction == Down and Y > 0 then
				self.Transferring = false
			elseif self.Direction == Left and X + self:GetWide() < self:GetParent():GetWide() then
				self.Transferring = false
			end
		end
		local function CheckBlock(self)
			local X,Y = self:GetPos()
			X,Y = X + self:GetWide() / 2,Y + self:GetWide() / 2
			for I,P in pairs(Blocks) do
				local x,y,w,h = P[2],P[3],20,20
				if X >= x + (w / 2) - 2 and X <= x + (w / 2) + 2 and Y >= y + (h / 2) - 2 and Y <= y + (h / 2) + 2 then
					return true,P[1]
				end
			end
			for I,P in pairs(Blocks) do
				local x,y,w,h = P[2],P[3],20,20
				if X >= x and X <= x + w and Y >= y and Y <= y + h then
					return false,P[1]
				end
			end
		end
		local Can,Block = CheckBlock(self)
		if Can then
			if Block.Ball then
				Block.Ball = nil
				Score = Score + 1
				Balls = Balls - 1
				if Balls == 0 then
					Win = true
					GameOver = true
					Start:SetVisible(true)
					ArcadePlaying = false
				end
			elseif Block.SuperBall then
				self.SuperBall = true
				self.SuperBallEnd = 0
				Block.SuperBall = nil
			end
			if not table.HasValue(Block.Directions,self.Direction) then
				self.Direction = 0
			end
		end
		if (input.IsKeyDown(KEY_W) or input.IsKeyDown(KEY_UP)) and Can then
			if Can then
				if table.HasValue(Block.Directions,Up) then
					self.Direction = Up
					if not self.Moving then self.Moving = true end
				else
					self.Direction = 0
				end
			else
				self.Direction = 0
			end
		elseif (input.IsKeyDown(KEY_D) or input.IsKeyDown(KEY_RIGHT)) and Can then
			if Can then
				if table.HasValue(Block.Directions,Right) then
					self.Direction = Right
					if not self.Moving then self.Moving = true end
				else
					self.Direction = 0
				end
			else
				self.Direction = 0
			end
		elseif (input.IsKeyDown(KEY_S) or input.IsKeyDown(KEY_DOWN)) and Can then
			if Can then
				if table.HasValue(Block.Directions,Down) then
					self.Direction = Down
					if not self.Moving then self.Moving = true end
				else
					self.Direction = 0
				end
			else
				self.Direction = 0
			end
		elseif (input.IsKeyDown(KEY_A) or input.IsKeyDown(KEY_LEFT)) and Can then
			if Can then
				if table.HasValue(Block.Directions,Left) then
					self.Direction = Left
					if not self.Moving then self.Moving = true end
				else
					self.Direction = 0
				end
			else
				self.Direction = 0
			end
		end
		if self.Direction ~= 0 and self.OldDir ~= self.Direction then
			self.OldDir = self.Direction
		end
		if self.Direction == 0 and self.Moving then
			self.Moving = false
		end
		if self.Direction > 0 then
			local X,Y = self:GetPos()
			if self.Direction == Up then
				self:SetPos(X,Y - 1)
			elseif self.Direction == Right then
				self:SetPos(X + 1,Y)
			elseif self.Direction == Down then
				self:SetPos(X,Y + 1)
			elseif self.Direction == Left then
				self:SetPos(X - 1,Y)
			end
			if self.Transferring then return end
			local X,Y = self:GetPos()
			if (X < 0 and self.Direction == Left) or (X + self:GetWide() > PlayArea:GetWide() and self.Direction == Right) or (Y < 0 and self.Direction == Up) or (Y + self:GetTall() > PlayArea:GetTall() and self.Direction == Down) then
				self.Transferring = true
				local PacClone = vgui.Create("DPanel",PlayArea)
				PacClone:SetPos(X,Y)
				PacClone:SetSize(self:GetWide(),self:GetTall())
				if self.Direction == Left then
					self:SetPos(X + 400,Y)
				elseif self.Direction == Right then
					self:SetPos(X - 400,Y)
				elseif self.Direction == Up then
					self:SetPos(X,Y + 400)
				elseif self.Direction == Down then
					self:SetPos(X,Y - 400)
				end
				PacClone.Dir = self.Direction
				PacClone.Paint = function(self)
					surface.SetTexture(surface.GetTextureID("stillpac"))
					surface.SetDrawColor(255,255,255,255)
					if self.Dir == Up then
						surface.DrawTexturedRectRotated(self:GetWide() / 2,self:GetTall() / 2,self:GetWide(),self:GetTall(),90)
					elseif self.Dir == Right then
						surface.DrawTexturedRectRotated(self:GetWide() / 2,self:GetTall() / 2,self:GetWide(),self:GetTall(),0)
					elseif self.Dir == Down then
						surface.DrawTexturedRectRotated(self:GetWide() / 2,self:GetTall() / 2,self:GetWide(),self:GetTall(),270)
					elseif self.Dir == Left then
						surface.DrawTexturedRectRotated(self:GetWide() / 2,self:GetTall() / 2,self:GetWide(),self:GetTall(),180)
					end
				end
				PacClone.Think = function(self)
					local X,Y = self:GetPos()
					if X + self:GetWide() < 0 or X > PlayArea:GetWide() or Y + self:GetTall() < 0 or Y > PlayArea:GetTall() then
						self:Remove()
					end
					if self.Dir == Up then
						self:SetPos(X,Y - 1)
					elseif self.Dir == Right then
						self:SetPos(X + 1,Y)
					elseif self.Dir == Down then
						self:SetPos(X,Y + 1)
					elseif self.Dir == Left then
						self:SetPos(X - 1,Y)
					end
					
				end
			end
		end
	end
	local Paccc = surface.GetTextureID("pacccman")
	local Still = surface.GetTextureID("stillpac")
	Pac.Paint = function(self)
		surface.SetDrawColor(255,255,255,255)
		if self.SuperBall then
			surface.SetDrawColor(math.random(100,255),math.random(100,255),math.random(100,255),255)
		end
		if self.Moving and not GameOver and not self.Transferring and not Paused then
			surface.SetTexture(Paccc)
		else
			surface.SetTexture(Still)
		end
		local Dir = self.Direction
		if Dir == 0 then Dir = self.OldDir end
		if Dir == Up then
			surface.DrawTexturedRectRotated(self:GetWide() / 2,self:GetTall() / 2,self:GetWide(),self:GetTall(),90)
		elseif Dir == Right then
			surface.DrawTexturedRect(0,0,self:GetWide(),self:GetTall())
		elseif Dir == Down then
			surface.DrawTexturedRectRotated(self:GetWide() / 2,self:GetTall() / 2,self:GetWide(),self:GetTall(),270)
		elseif Dir == Left then
			surface.DrawTexturedRectRotated(self:GetWide() / 2,self:GetTall() / 2,self:GetWide(),self:GetTall(),180)
		end
	end
	vgui.Register("PacmanPac",Pac,"DPanel")	
	PlayArea = vgui.Create("DPanel",Arena)
	PlayArea:SetSize(400,400)
	PlayArea:SetPos(Arena:GetWide() / 2 - 200,0)
	PlayArea.Paint = function() end
	local Food = surface.GetTextureID("Yellow_ball")
	local Tab = BlockTable[math.random(1,#BlockTable)]
	for I,P in pairs(Tab) do
		for a,b in pairs(P) do
			local X = a - 1
			local Y = I - 1
			local Pan = vgui.Create("DPanel",PlayArea)
			Pan:SetSize(20,20)
			Pan:SetPos(20 * X,20 * Y)
			Pan.Directions = b
			Pan.Paint = nil
			local X,Y = Pan:GetPos()
			table.insert(Blocks,{Pan,X,Y})
			for I,P in pairs(Table) do
				if b[1] == P["Directions"][1] and b[2] == P["Directions"][2] and b[3] == P["Directions"][3] and b[4] == P["Directions"][4] then
					if b[5] then
						Pan.Paint = function(self)
							P["Paint"](self)
							if self.SuperBall then
								surface.SetDrawColor(255,255,255,255)
								surface.SetTexture(Food)
								surface.DrawTexturedRect(3,3,14,14)
							end
						end
						Pan.SuperBall = true
					else
						Pan.Paint = function(self)
							P["Paint"](self)
							if self.Ball then
								surface.SetDrawColor(255,255,255,255)
								surface.SetTexture(Food)
								surface.DrawTexturedRect(6,6,8,8)
							end
						end
						Pan.Ball = true
					end
					break
				end
			end
		end
	end	
	Start = vgui.Create("DButton",Arena)
	Start:SetSize(60,40)
	Start:SetPos(Arena:GetWide() - 70,300)
	Start:SetText("Start")
	Start.DoClick = function(Self)
		ArcadePlaying = true
		Deletables = {}
		PacSpawn = {}
		AISpawn = {}
		Balls = 0
		Self:SetVisible(false)
		if GameOver then
			for I,P in pairs(Deletables) do
				P:Remove()
			end
			GameOver = false
			Win = false
			Score = 0
		end
		if PlayArea and PlayArea:IsValid() then
			PlayArea:Remove()
		end
		Blocks = {}
		PlayArea = vgui.Create("DPanel",Arena)
		PlayArea:SetSize(400,400)
		PlayArea:SetPos(Arena:GetWide() / 2 - 200,0)
		PlayArea.Paint = function() end
		local Food = surface.GetTextureID("Yellow_ball")
		local Num = math.random(1,#BlockTable)
		local Tab = BlockTable[Num]
		for I,P in pairs(Tab) do
			for a,b in pairs(P) do
				local X = a - 1
				local Y = I - 1
				local Pan = vgui.Create("DPanel",PlayArea)
				Pan:SetSize(20,20)
				Pan:SetPos(20 * X,20 * Y)
				Pan.Directions = {}
				Pan.Directions[1] = b[1]
				Pan.Directions[2] = b[2]
				Pan.Directions[3] = b[3]
				Pan.Directions[4] = b[4]
				Pan.Paint = nil
				Pan.NotFor = {}
				if b[7] then
					table.insert(PacSpawn,{X * 20,Y * 20})
				end
				if b[6] then
					table.insert(AISpawn,{X * 20,Y * 20})
				end
				local X,Y = Pan:GetPos()
				table.insert(Blocks,{Pan,X,Y})
				for I,P in pairs(Table) do
					if b[1] == P["Directions"][1] and b[2] == P["Directions"][2] and b[3] == P["Directions"][3] and b[4] == P["Directions"][4] then
						if b[5] then
							Pan.Paint = function(self)
								P["Paint"](self)
								if self.SuperBall then
									surface.SetDrawColor(255,255,255,255)
									surface.SetTexture(Food)
									surface.DrawTexturedRect(3,3,14,14)
								end
							end
							Pan.SuperBall = true
						else
							Pan.Paint = function(self)
								P["Paint"](self)
								if self.Ball then
									surface.SetDrawColor(255,255,255,255)
									surface.SetTexture(Food)
									surface.DrawTexturedRect(6,6,8,8)
								end
							end
							Pan.Ball = true
							Balls = Balls + 1
						end
						break
					end
				end
			end
		end	
		local Pac = vgui.Create("PacmanPac",PlayArea)
		local Pos = table.Random(PacSpawn)
		Pac:SetPos(Pos[1],Pos[2])
		Pac:SetSize(18,18)
		table.insert(Deletables,Pac)
		local I = 1
		local Ghost = {}
		Ghost.Init = function(self)
			timer.Simple(0,function()
				local X,Y = self:GetPos()
				X,Y = X + self:GetWide() / 2,Y + self:GetWide() / 2
				for I,P in pairs(Blocks) do
					local x,y,w,h = P[2],P[3],20,20
					if X >= x + (w / 2) - 2 and X <= x + (w / 2) + 2 and Y >= y + (h / 2) - 2 and Y <= y + (h / 2) + 2 then
						self.Direction = math.random(1,#P[1].Directions)
					end
				end
			end)
			hook.Add("PacThink","Ghost"..I,function()
				self:PacThink(self)
			end)
			I = I + 1
		end
		Ghost.PacThink = function(self)
			if not PlayArea:IsValid() then return end
			if Paused then return end
			local X,Y = self:GetPos()
			X,Y = X + self:GetWide() / 2,Y + self:GetTall() / 2
			local x,y = Pac:GetPos()
			x,y = x + Pac:GetWide() / 2,y + Pac:GetTall() / 2
			local Dist = math.sqrt(math.pow(X - x,2) + math.pow(Y - y,2))
			if Dist < 14 then
				if Pac.SuperBall and not self.Immunity then
					for I,P in pairs(Deletables) do
						if P == self then
							table.remove(Deletables,I)
							break
						end
					end
					self:Remove()
					Score = Score + 50
					timer.Simple(5,function() 
						local Ghost = vgui.Create("PacmanGhost",PlayArea)
						local Pos = table.Random(AISpawn)
						Ghost:SetPos(Pos[1],Pos[2])
						Ghost:SetSize(18,18)
						Ghost.Movement = math.random(1,2)
						Ghost.Immunity = true
						Ghost.R = math.random(100,255)
						Ghost.G = math.random(100,255)
						Ghost.B = math.random(100,255)
						table.insert(Deletables,Ghost)
					end)
				else
					GameOver = true
					ArcadePlaying = false
					Self:SetVisible(true)
				end
			end
			if not Pac.SuperBall and self.Immunity then
				self.Immunity = false
			end
			local function CheckBlock(self)
				local X,Y = self:GetPos()
				X,Y = X + self:GetWide() / 2,Y + self:GetWide() / 2
				for I,P in pairs(Blocks) do
					local x,y,w,h = P[2],P[3],20,20
					if X >= x + (w / 2) - 2 and X <= x + (w / 2) + 2 and Y >= y + (h / 2) - 2 and Y <= y + (h / 2) + 2 then
						return true,P[1]
					end
				end
				return false
			end
			local Can,Block = CheckBlock(self)
			if Can and not table.HasValue(Block.NotFor,self) then
				if not PlayArea or not PlayArea:IsValid() then return end
				table.insert(Block.NotFor,self)
				timer.Simple(0.1,function() 
					if not PlayArea or not PlayArea:IsValid() or not Block.NotFor then return end
					for I,P in pairs(Block.NotFor) do
						if P == self then
							table.remove(Block.NotFor,I)
							break
						end
					end
				end)
				local X,Y = self:GetPos()
				X,Y = X + self:GetWide() / 2,Y + self:GetTall() / 2
				local Not = 0
				if X >= 0 and X <= 25 then Not = Left end
				if X >= PlayArea:GetWide() - 25 and X <= PlayArea:GetWide() then Not = Right end
				if Y >= 0 and Y <= 25 then Not = Up end
				if Y >= PlayArea:GetTall() - 25 and Y <= PlayArea:GetTall() then Not = Down end
				local TurnBack = false
				for I,P in pairs(Block.Directions) do
					if (P == Not and Not ~= 0 and #Block.Directions == 2) or #Block.Directions == 1  then
						TurnBack = true
						break
					end
				end
				local Dirs = {}
				for I,P in pairs(Block.Directions) do
					if P ~= Not then
						if self.Direction == Up then
							if P ~= Down and not TurnBack then
								table.insert(Dirs,P)
							elseif TurnBack then
								table.insert(Dirs,P)
							end
						elseif self.Direction == Right then
							if P ~= Left and not TurnBack then
								table.insert(Dirs,P)
							elseif TurnBack then
								table.insert(Dirs,P)
							end
						elseif self.Direction == Down then
							if P ~= Up and not TurnBack then
								table.insert(Dirs,P)
							elseif TurnBack then
								table.insert(Dirs,P)
							end
						elseif self.Direction == Left then
							if P ~= Right and not TurnBack then
								table.insert(Dirs,P)
							elseif TurnBack then
								table.insert(Dirs,P)
							end
						end
					end
				end
				if not table.HasValue(Dirs,self.Direction) or #Dirs == math.random(2,3) then
					local X,Y = Pac:GetPos()
					X,Y = X + Pac:GetWide() / 2,Y + Pac:GetTall() / 2
					local x,y = self:GetPos()
					x,y = x + self:GetWide() / 2,y + self:GetTall() / 2
					if not Pac.SuperBall or self.Immunity then
						local Optimal
						if math.abs(Y - y) > math.abs(X - x) then
							if Y > y then
								Optimal = Down
							else
								Optimal = Up
							end
						else
							if X > x then
								Optimal = Right
							else
								Optimal = Left
							end
						end
						local IsOptimal = false
						for I,P in pairs(Dirs) do
							if P == Optimal then
								self.Direction = P
								IsOptimal = true
								break
							end
						end
						if not IsOptimal then
							if #Dirs > 1 then
								self.Direction = Dirs[math.random(1,#Dirs)]
							else
								self.Direction = Dirs[1]
							end
						end
					else
						local Optimal
						if math.abs(Y - y) < math.abs(X - x) then
							if Y < y then
								Optimal = Down
							else
								Optimal = Up
							end
						else
							if X < x then
								Optimal = Right
							else
								Optimal = Left
							end
						end
						local IsOptimal = false
						for I,P in pairs(Dirs) do
							if P == Optimal then
								self.Direction = P
								IsOptimal = true
								break
							end
						end
						if not IsOptimal then
							if #Dirs > 1 then
								self.Direction = Dirs[math.random(1,#Dirs)]
							else
								self.Direction = Dirs[1]
							end
						end
					end
				end
			end
			local X,Y = self:GetPos()
			if self.Direction == Up then
				self:SetPos(X,Y - 1)
			elseif self.Direction == Right then
				self:SetPos(X + 1,Y)
			elseif self.Direction == Down then
				self:SetPos(X,Y + 1)
			elseif self.Direction == Left then
				self:SetPos(X - 1,Y)
			end
		end
		local Textu = surface.GetTextureID("Pacman_Ghost")
		Ghost.Paint = function(self)
			if Pac.SuperBall and not self.Immunity then
				surface.SetDrawColor(50,50,200,255)
			else
				surface.SetDrawColor(self.R,self.G,self.B,255)
			end
			surface.SetTexture(Textu)
			surface.DrawTexturedRect(0,0,self:GetWide(),self:GetTall())
		end
		vgui.Register("PacmanGhost",Ghost,"DPanel")
		for I = 1,4 do
			local Ghost = vgui.Create("PacmanGhost",PlayArea)
			local Pos = table.Random(AISpawn)
			Ghost:SetPos(Pos[1],Pos[2])
			Ghost:SetSize(18,18)
			Ghost.R = math.random(100,255)
			Ghost.G = math.random(100,255)
			Ghost.B = math.random(100,255)
			table.insert(Deletables,Ghost)
		end
	end
	
	local FrameLimit = vgui.Create("DButton",Arena)
	FrameLimit:SetSize(120,40)
	FrameLimit:SetPos(Arena:GetWide() - 130,200)
	FrameLimit:SetText("Toggle Framelimiter")
	FrameLimit.DoClick = function() FrameLimiter = not FrameLimiter end
	
	function PauseGeemu()
		Paused = not Paused
	end
	
	local Pause = vgui.Create("DButton",Arena)
	Pause:SetSize(60,40)
	Pause:SetPos(Arena:GetWide() - 70,250)
	Pause:SetText("Pause")
	Pause.DoClick = PauseGeemu
	
	local function ExitGeemu()
		Paused = nil
		ArcadePlaying = nil
		Arena:Remove()
		hook.Remove("Think","PacThink")
	end
	
	local Exit = vgui.Create("DButton",Arena)
	Exit:SetSize(60,40)
	Exit:SetPos(Arena:GetWide() - 70,350)
	Exit:SetText("Exit")
	Exit.DoClick = ExitGeemu
end
table.insert(Geemu,{["Name"] = "Pacman",["Function"] = Pacman})