
local Verts = {
	{x = 0,y = 200},
	{x = 20,y = 220},
	{x = 20,y = 380},
	{x = 0,y = 400},
	{x = -20,y = 380},
	{x = -20,y = 220}
}
local SVerts = {
	{x = 0,y = 210},
	{x = 10,y = 220},
	{x = 10,y = 380},
	{x = 0,y = 390},
	{x = -10,y = 380},
	{x = -10,y = 220}
}
local Tri1 = {
	{x = 0,y = 210},
	{x = 10,y = 220},
	{x = -10,y = 220}
}
local Tri2 = {
	{x = 0,y = 390},
	{x = 10,y = 380},
	{x = -10,y = 380}
}

for I,P in pairs(Verts) do
	P.x = P.x + 300
	P.y = P.y + 100
	SVerts[I].x = SVerts[I].x + 300
	SVerts[I].y = SVerts[I].y + 100
end

for I,P in pairs(Tri1) do
	Tri1[I].x = Tri1[I].x + 300
	Tri1[I].y = Tri1[I].y + 100
	Tri2[I].x = Tri2[I].x + 300
	Tri2[I].y = Tri2[I].y + 100
end

function ENT:SendTiberium()
	if self.Connected then
		surface.SetFont("Futuristic")
		self:AddToBuffer(function() self:C_DrawText("Tiberium available for transmitting",self.SizeX / 2,80,TEXT_ALIGN_CENTER) end)
		
		for I,P in pairs(self.FoundStorage) do
			if P[1] > 0 then
				local PosX = 20 + ((self.SizeX - 40) / 2) * (I - 1)
				self:AddToBuffer(function(X,Int)
					self:DrawBoxWithOutlinesAndText(X,120,(self.SizeX - 60) / 2,self.SizeY - 200,"Storage #"..Int)
				end,{PosX,P[3]})
				self:AddToBuffer(function(X,Sto) 
					local Str = Sto[1].." / "..Sto[2]
					local W = surface.GetTextSize(Str)
					self:DrawText(Str,X,200,TEXT_ALIGN_CENTER) end,{PosX + self.SizeX / 4 - 20,P})
				if (I == 1 and self.Transmit1) or (I == 2 and self.Transmit2) then
					self:AddToBuffer(function(X) self:DrawText("Transmitting...",X + 40,300,TEXT_ALIGN_LEFT) end,{PosX})
				else
					self:AddToBuffer(function(X) self:DrawBoxWithOutlinesAndText(X + 40,300,160,48,"Transmit") end,{PosX})
					self:AddToBuffer(function(X,Am,Int) if self:C_ClickedBox(X + 40,300,160,48) then 						
						if Int == 1 then self.Transmit1 = true
						else self.Transmit2 = true end
						net.Start("Terminal_TibTransmit")
							net.WriteEntity(self)
							net.WriteInt(Int,4)
						net.SendToServer()
						self:ChangeState(TERMINAL_REFINERY)
					end end,{PosX,P[1],P[3]})
				end
				local Pols = table.Copy(Verts)
				local SPols = table.Copy(SVerts)
				local Tr1,Tr2 = table.Copy(Tri1),table.Copy(Tri2)
				for I,P in pairs(Pols) do
					P.x = P.x + PosX
					SPols[I].x = SPols[I].x + PosX
				end
				for I,P in pairs(Tr1) do
					Tr1[I].x = Tr1[I].x + PosX
					Tr2[I].x = Tr2[I].x + PosX
				end
				self:AddToBuffer(function(Ver) self:DrawPoly(Ver) end,{Pols})
				self:AddToBuffer(function(Ver,Tri1,Tri2,Max,Green,Blue) 
					if Blue == 0 then
						self:DrawPoly(Ver,Color(0,255,0))
						return
					elseif Green == 0 then
						self:DrawPoly(Ver,Color(0,0,255))
						return
					end
					self:DrawPoly(Ver,Color(0,255,0))
					local Per = (Green + Blue) / Max
					local BluePer = Blue / Max
					
					if Per == 1 then
						self:DrawPoly(Tri1,Color(0,0,255))
					end
					
					surface.SetDrawColor(0,0,255)
					surface.DrawRect(Tri1[3].x,Tri1[3].y + 160 * (1 - Per),20,160 * BluePer)
				end,{SPols,Tr1,Tr2,P[2],P[4],P[5]})
				self:AddToBuffer(function(Tri1,Tri2,Sto) 
					local Per = Sto[1] / Sto[2]
					if Per < 1 and Per > 0 then
						self:DrawPoly(Tri1,Color(0,0,0))
						surface.SetDrawColor(0,0,0)
						surface.DrawRect(Tri1[3].x,Tri1[3].y,20,160 * (1 - Per))
					end
					if Per == 0 then self:DrawPoly(Tri2,Color(0,0,0)) end
				end,{Tr1,Tr2,P})
			end
		end
	else
		surface.SetFont("Futuristic")
		local W = surface.GetTextSize("Put your storages into the holder and then try refreshing.") + 40
		self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - W / 2,160,W,100,"It seems your storages are not connected.") end,{})
		self:AddToBuffer(function() self:DrawText("Put your storages into the holder and then try refreshing.",self.SizeX / 2,220,TEXT_ALIGN_CENTER) end)
	end
end

function ENT:T_AddTabs()
	self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(0,0,self.SizeX,60) end)
	self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(6,6,180,48,"Refinery") end)
	self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(192,6,320,48,"Refresh Storage") end)
	self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{self.SizeX - 166,6,160,48,"Quit"})
	self:AddToBuffer(function(X,Y,W,H) if self:ClickedBox(X,Y,W,H) then self:ChangeState(TERMINAL_REFINERY) end end,{6,6,180,48})
	self:AddToBuffer(function() 
		if self:ClickedBox(192,6,320,48) then 
			net.Start("Terminal_RefreshTable")
				net.WriteEntity(self)
			net.SendToServer()
		end 
	end)
	self:AddToBuffer(function(X,Y,W,H) if self:ClickedBox(X,Y,W,H) then self:ChangeState(TERMINAL_EXITPRESSED) end end,{self.SizeX - 166,6,160,48})
end