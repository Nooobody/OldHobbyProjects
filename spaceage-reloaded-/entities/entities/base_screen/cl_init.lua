include("shared.lua")
include("helperfunctions/cl_helper.lua")
include("helperfunctions/cl_states.lua")

TERMINAL_EXIT = -2
TERMINAL_IDLE = -1
TERMINAL_WELCOME = 0
TERMINAL_EXITPRESSED = 2

function ENT:ChangeState(S)
	if self.State == S then return end
	self.RenderBoxes = {}
	self.StateChanged = CurTime()
	if S ~= self.OldState then
		self.CamY = 0
		self.CamSizeY = 0
		self.CamStartY = 60
		self.CamEndY = 60
	end
	self.OldState = self.State
	self.State = S
end

function ENT:AddTabs()
end

function ENT:PublicScreen()
end

function ENT:AddCheckStates()
end

function ENT:CheckCam()
end

function ENT:CheckState()
	self.B = {}
	if self.State == TERMINAL_EXIT then
		self.Ply = nil
		self:SetNWEntity("Using",nil)
		net.Start("Terminal_PlayerLeft")
			net.WriteEntity(self)
			net.WriteEntity(LocalPlayer())
		net.SendToServer()
	elseif self.State == TERMINAL_WELCOME then
		if self.StartState then
			return self:ChangeState(self.StartState)
		end
		if self.RestrictedToOne then
			self:AddTabs()
			self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{self.SizeX / 2 - 200,100,400,100,"Welcome, "..LocalPlayer():GetName()})
		else
			self:PublicScreen()
		end
	elseif self.State == TERMINAL_EXITPRESSED then
		self:Finish()
		timer.Simple(3,function() self:ChangeState(TERMINAL_EXIT) end)
	end
	
	self:AddCheckStates()
	
	if self:CheckCam() then
		self:AddToBuffer(function() 
			if self.CamSizeY > self.SizeY - (self.CamStartY + self.CamEndY) then
				if self.CamY < self.CamSizeY - (self.SizeY - (self.CamStartY + self.CamEndY)) and self:CursorInBox(0,self.SizeY - (self.CamEndY + 40),self.SizeX,40,true) then 
					self.CamY = self.CamY + 1
				elseif self.CamY > 0 and self:CursorInBox(0,self.CamStartY,self.SizeX,40,true) then
					self.CamY = self.CamY - 1
				end
			end
		end)
	end
	
	if #self.B >= 0 and self.State >= 0 then self.Buffer = self.B end
	
	self.B = {}
	self:ChangeState(TERMINAL_IDLE)
end

function ENT:Initialize()
	self.Buffer = {}
	self.RenderBoxes = {}
	self.Using = false
	self.OldState = -1
	self.State = 0
	self.KeyD = 0
	self.StateChanged = 0
	self.Ply = nil
	self.PlyTeam = LocalPlayer():Team()
	
	self.Mul = 10
	
	self.HoldCD = 0
	self.Click = false
	self.SemiHolding = false
	self.Holding = false
	self.Released = false
	
	self.SizeX = 96 * self.Mul - 4
	self.SizeY = 64 * self.Mul - 4
	
	self.CamY =	0
	self.CamStartY = 60
	self.CamEndY = 60
	self.CamSizeY = self.SizeY - 120
	
	self.BG = Color(0,0,0)
	self.Outlines = LocalPlayer():GetFact().Col
	self.Grad = "gui/gradient"
	
	self:MoreInit()
end

function ENT:MoreInit()
end

function ENT:Draw()
	self:DrawModel()
	if LocalPlayer():Team() ~= self.PlyTeam then
		self.PlyTeam = LocalPlayer():Team()
		self.Outlines = LocalPlayer():GetFact().Col
	end
	if LocalPlayer():GetPos():Distance(self:GetPos()) > 1000 then return end
	if self.RestrictedToOne then
		local Ply = self:GetNWEntity("Using")
		if not self.Ply then
			if IsValid(Ply) and Ply:IsPlayer() and LocalPlayer() ~= Ply then 
				self:StartCam()
					surface.SetDrawColor(self.BG)
					surface.DrawRect(0,0,self.SizeX,self.SizeY)
					draw.DrawText("Wait for your turn!","Futuristic",480,250,self.Outlines,TEXT_ALIGN_CENTER)
				self:EndCam()
				return 
			elseif not IsValid(Ply) then
				self:StartCam()
					surface.SetDrawColor(self.BG)
					surface.DrawRect(0,0,self.SizeX,self.SizeY)
					self:DrawBoxWithOutlinesAndText(50,250,self.SizeX - 100,100,"Press E to begin!")
				self:EndCam()
				return
			elseif IsValid(Ply) and LocalPlayer() == Ply then
				self.Ply = Ply
				self.State = 0
			end
		elseif self.Ply ~= Ply and self.Ply == LocalPlayer() then
			self.Ply = nil
			self.State = 0
		end
	elseif not IsValid(self.Ply) then
		self.Ply = LocalPlayer()
	end

	if not IsValid(self.Ply) then return end
	self:CheckUse()
	
	self:StartCam()
		surface.SetDrawColor(self.BG)
		surface.DrawRect(0,0,self.SizeX,self.SizeY)
		self:CheckState()
		for I,P in pairs(self.Buffer) do
			P[1](unpack(P[2] or {}))
		end
		
		if not self.Ply or self.OldState == 2 then
			self:EndCam()
			return
		end
		self:DrawBoxWithOutlinesAndText(0,self.SizeY - 60,self.SizeX,60)
		draw.DrawText("Player: "..self.Ply:GetName(),"Futuristic",20,self.SizeY - 40,self.Outlines,TEXT_ALIGN_LEFT)
		local Time = math.floor(CurTime() - self:GetNWInt("Started"))
		if Time > 60 then
			local Sec = Time
			Time = math.floor(Sec / 60)..":"..(Sec % 60)
			if Sec % 60 < 10 then
				Time = math.floor(Sec / 60)..":0"..(Sec % 60)
			end
		end
		draw.DrawText("Time: "..Time,"Futuristic",self.SizeX - 20,self.SizeY - 40,self.Outlines,TEXT_ALIGN_RIGHT)
		self:DrawCursor()
	self:EndCam()
end