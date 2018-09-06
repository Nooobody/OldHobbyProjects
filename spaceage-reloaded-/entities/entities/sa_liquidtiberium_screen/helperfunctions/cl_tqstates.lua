
local Verts = {
	{x = 0,y = 200},
	{x = 100,y = 100},
	{x = 700,y = 100},
	{x = 800,y = 200},
	{x = 700,y = 300},
	{x = 100,y = 300}
}
local SVerts = {
	{x = 10,y = 200},
	{x = 100,y = 110},
	{x = 700,y = 110},
	{x = 790,y = 200},
	{x = 700,y = 290},
	{x = 100,y = 290}
}
local Tri1 = {
	{x = 10,y = 200},
	{x = 100,y = 110},
	{x = 100,y = 290}
}
local Tri2 = {
	{x = 700,y = 110},
	{x = 790,y = 200},
	{x = 700,y = 290}
}

for I,P in pairs(Verts) do
	P.x = P.x + 150
	P.y = P.y + 200
	SVerts[I].x = SVerts[I].x + 150
	SVerts[I].y = SVerts[I].y + 200
end

for I,P in pairs(Tri1) do
	Tri1[I].x = Tri1[I].x + 150
	Tri1[I].y = Tri1[I].y + 200
	Tri2[I].x = Tri2[I].x + 150
	Tri2[I].y = Tri2[I].y + 200
end

function ENT:HandleLoader()
	self:AddVertTabs()
	self:AddToBuffer(function() 
		local Str = self:GetNWString("Loader_Status") or ""
		self:DrawText("Loader Status: "..Str,136,6)
	end)
	self:AddToBuffer(function()
		self:DrawText("Refinery Status:",136,60)
		self:DrawText("Unprocessed tiberium: "..self.Tib_Ref[1],150,90)
		self:DrawText("Processed tiberium: "..self.Tib_Ref[2],150,120)
	end)
	if self.Connected then
		surface.SetFont("Futuristic")

		self:AddToBuffer(function(Sto) 
			local Str = Sto[1].." / "..Sto[2]
			self:DrawText(Str,self.SizeX / 2,200,TEXT_ALIGN_CENTER) end,{self.FoundStorage})
		local Pols = table.Copy(Verts)
		local SPols = table.Copy(SVerts)
		local Tr1,Tr2 = table.Copy(Tri1),table.Copy(Tri2)
		self:AddToBuffer(function(Ver) self:DrawPoly(Ver) end,{Pols})
		self:AddToBuffer(function(Ver) 
			if not self.Int then 
				self.Int = 0
				self.IsUp = true
			end
			local Col = Color(20,200 + self.Int,20)
			self:DrawPoly(Ver,Col)
			if self.IsUp then self.Int = self.Int + 1 else self.Int = self.Int - 1 end
			if self.Int > 55 or self.Int < 0 then self.IsUp = not self.IsUp end
		end,{SPols})
		self:AddToBuffer(function(Tri1,Tri2,Sto) 
			local Per = Sto[1] / Sto[2]
			if Per < 1 then self:DrawPoly(Tr2,Color(0,0,0)) end
			if Per > 0 then
				surface.SetDrawColor(0,0,0)
				surface.DrawRect(math.ceil(Tr1[2].x + 600 * Per),Tr1[2].y,math.ceil(600 - (600 * Per)),180)
			else
				surface.SetDrawColor(0,0,0)
				surface.DrawRect(Tr1[2].x,Tr1[2].y,600,180)
				self:DrawPoly(Tr1,Color(0,0,0))
			end
		end,{Tr1,Tr2,self.FoundStorage})
	else
		surface.SetFont("Futuristic")
		local W = surface.GetTextSize("It seems your storage is not connected.") + 40
		self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - W / 2,160,W,100,"It seems your storage is not connected.") end,{})
		self:AddToBuffer(function() self:DrawText("No storage detected in loader.",self.SizeX / 2,220,TEXT_ALIGN_CENTER) end)
	end
end

function ENT:AddVertTabs()
	self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(0,0,130,self.SizeY) end)
	self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(6,6,118,48,"Open") end)
	self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(6,60,118,48,"Close") end)
	self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(6,114,118,48,"Load") end)
	self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(6,168,118,48,"Unload") end)
	self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(6,222,118,48,"Transmit") end)
	self:AddToBuffer(function() if self:ClickedBox(6,6,118,48) then
			local Str = self:GetNWString("Loader_Status")
			if Str == "Moving" then
				self:ErrorPanel("Failed to open!","Loader is moving!",TERMINAL_LIQREFINERY)
				return
			end
			if Str ~= "Closed" then
				self:ErrorPanel("Failed to open!","Loader not closed!",TERMINAL_LIQREFINERY)
				return
			end
			net.Start("Terminal_Loader_Open")
				net.WriteEntity(self)
			net.SendToServer()
		end
	end)
	self:AddToBuffer(function() if self:ClickedBox(6,60,118,48) then
			local Str = self:GetNWString("Loader_Status")
			if Str == "Moving" then
				self:ErrorPanel("Failed to close!","Loader is moving!",TERMINAL_LIQREFINERY)
				return
			end
			if Str ~= "Open" then
				self:ErrorPanel("Failed to close!","Loader not open and empty!",TERMINAL_LIQREFINERY)
				return
			end
			net.Start("Terminal_Loader_Close")
				net.WriteEntity(self)
			net.SendToServer()
		end
	end)
	self:AddToBuffer(function() if self:ClickedBox(6,114,118,48) then
			local Str = self:GetNWString("Loader_Status")
			if Str == "Moving" then
				self:ErrorPanel("Failed to load!","Loader is moving!",TERMINAL_LIQREFINERY)
				return
			end
			if Str ~= "Open" then
				self:ErrorPanel("Failed to load!","Loader not open!",TERMINAL_LIQREFINERY)
				return
			end
			net.Start("Terminal_Loader_Load")
				net.WriteEntity(self)
			net.SendToServer()
			self:ChangeState(TERMINAL_LIQREFINERY)
		end	
	end)
	self:AddToBuffer(function() if self:ClickedBox(6,168,118,48) then
			local Str = self:GetNWString("Loader_Status")
			if Str == "Moving" then
				self:ErrorPanel("Failed to unload!","Loader is moving!",TERMINAL_LIQREFINERY)
				return
			end
			if not self.Connected and Str == "Loaded" then
				net.Start("Terminal_Loader_Unload")
					net.WriteEntity(self)
				net.SendToServer()
				self:ChangeState(TERMINAL_LIQREFINERY)
				return
			elseif not self.Connected and Str ~= "Loaded" then
				self:ErrorPanel("Failed to unload!","No storage connected!",TERMINAL_LIQREFINERY)
				return
			end
			net.Start("Terminal_Loader_Unload")
				net.WriteEntity(self)
			net.SendToServer()
			self:ChangeState(TERMINAL_LIQREFINERY)
		end
	end)
	self:AddToBuffer(function() if self:ClickedBox(6,222,118,48) then
			if self.Tib_Ref[2] == 0 then
				self:ErrorPanel("Failed to transmit!","No processed tiberium left!",TERMINAL_LIQREFINERY)
				return
			end
			if not self.Connected then
				self:ErrorPanel("Failed to transmit!","No connected storage!",TERMINAL_LIQREFINERY)
				return
			end
			net.Start("Terminal_LiqTibTransmit")
				net.WriteEntity(self)
			net.SendToServer()
			self:ChangeState(TERMINAL_LIQREFINERY)
		end
	end)
	self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{self.SizeX - 166,6,160,48,"Quit"})
	self:AddToBuffer(function(X,Y,W,H) if self:ClickedBox(X,Y,W,H) then self:ChangeState(TERMINAL_EXITPRESSED) end end,{self.SizeX - 166,6,160,48})
end