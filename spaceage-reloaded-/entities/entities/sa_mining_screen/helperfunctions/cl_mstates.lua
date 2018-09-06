
function ENT:Ship()
	net.Start("Terminal_RefreshTable")
		net.WriteEntity(self)
	net.SendToServer()
	if self.IsConnected then
		local Int = 0
		surface.SetFont("Futuristic")
		self:AddToBuffer(function() self:C_DrawText("Resources available for transmitting to Station",self.SizeX / 2,80,TEXT_ALIGN_CENTER) end)
		for I,P in pairs(self.FoundStorage) do
			if P[1] > 0 then
				self:AddToBuffer(function(I,Sto,Res) 
					local Str = Res..":     "..Sto[1].." / "..Sto[2]
					local W = surface.GetTextSize(Str)
					self:C_DrawBoxWithOutlinesAndText(20,120 + 60 * I,W + 40,48,Str) end,{Int,P,I})
				self:AddToBuffer(function(I) self:C_DrawBoxWithOutlinesAndText(self.SizeX - 180,120 + 60 * I,160,48,"Transmit") end,{Int})
				self:AddToBuffer(function(I,S,Am) if self:C_ClickedBox(self.SizeX - 180,120 + 60 * I,160,48) then 
					self:HowMuch(S,Am,function(A)
						self:Confirmation("Transmit "..S.." from Ship to Station?\nAmount: "..A,function() 
							self:ChangeState(TERMINAL_TRANSMIT) 
							self.Transmit = {S,A}
							self.TransmitDone = 0
							net.Start("Terminal_MiningTransmit")
								net.WriteEntity(self)
								net.WriteBit(true)
								net.WriteTable(self.Transmit)
							net.SendToServer()
						end,TERMINAL_SHIP)
					end,TERMINAL_SHIP)
				end end,{Int,I,P[1]})
				Int = Int + 1
			end
		end
	else
		surface.SetFont("Futuristic")
		local W = surface.GetTextSize("Try connecting it and then refreshing.") + 40
		self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - W / 2,160,W,100,"It seems your ship is not connected.") end,{})
		self:AddToBuffer(function() self:DrawText("Try connecting it and then refreshing.",self.SizeX / 2,220,TEXT_ALIGN_CENTER) end)
	end
end

function ENT:Station()
	if not self.PlayerStorage and self.PlayerStorage ~= false then
		net.Start("Terminal_MiningStorageTable")
			net.WriteEntity(self)
		net.SendToServer()
		surface.SetFont("Futuristic")
		local W = surface.GetTextSize("Please wait while we check up on your storages.") + 40
		self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - W / 2,160,W,60,"Please wait while we check up on your storages.") end,{})
	else
		local Mark = 0
		local Len = 0
		if self.PlayerStorage then
			for I,P in pairs(self.PlayerStorage) do
				if table.HasKey(MARKETABLE,I) then 
					Mark = Mark + 1 
				end
				Len = Len + 1 
			end
		end
		
		if not self.PlayerStorage or not next(self.PlayerStorage) or Mark >= Len then
			surface.SetFont("Futuristic")
			local W = surface.GetTextSize("It seems your storages don't have anything to transmit.") + 40
			self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - W / 2,160,W,100,"It seems your storages don't have anything to transmit.") end,{})
			self:AddToBuffer(function() self:DrawText("Try transmiting some resources from your ship.",self.SizeX / 2,220,TEXT_ALIGN_CENTER) end)
		else
			local Int = 0
			surface.SetFont("Futuristic")
			if self.IsConnected then
				self:AddToBuffer(function() self:C_DrawText("Resources available for transmitting to Ship",self.SizeX / 2,80,TEXT_ALIGN_CENTER) end)
			else
				self:AddToBuffer(function() self:C_DrawText("Resources in your Storage",self.SizeX / 2,80,TEXT_ALIGN_CENTER) end)
			end
			for I,P in pairs(self.PlayerStorage) do
				if P > 0 and not table.HasKey(MARKETABLE,I) then
					local Str = I..":     "..P
					local W = surface.GetTextSize(Str)
					self:AddToBuffer(function(I,Res,W) self:C_DrawBoxWithOutlinesAndText(20,120 + 60 * I,W + 40,48,Res) end,{Int,Str,W})
					if self.IsConnected then
						local Sto = self.FoundStorage[I]
						if Sto and Sto[2] - Sto[1] > 0 then
							local Available = math.min(P,Sto[2] - Sto[1])
							self:AddToBuffer(function(I) self:C_DrawBoxWithOutlinesAndText(self.SizeX - 180,120 + 60 * I,160,48,"Transmit") end,{Int})
							self:AddToBuffer(function(I,S,Am) if self:C_ClickedBox(self.SizeX - 180,120 + 60 * I,160,48) then 
								net.Start("Terminal_MiningStorageTable")
									net.WriteEntity(self)
								net.SendToServer()
								self:HowMuch(S,Am,function(A)
									self:Confirmation("Transmit "..S.." from Station to Ship?\nAmount: "..A,function() 
										self:ChangeState(TERMINAL_TRANSMIT) 
										self.Transmit = {S,A}
										self.TransmitDone = 0
										net.Start("Terminal_MiningTransmit")
											net.WriteEntity(self)
											net.WriteBit(false)
											net.WriteTable(self.Transmit)
										net.SendToServer()
									end,TERMINAL_STATION) 
								end,TERMINAL_STATION)
							end end,{Int,I,Available})
						end
					end
					Int = Int + 1
				end
			end
		end
	end
end

function ENT:M_AddTabs()
	self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{0,0,self.SizeX,60})
	self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{6,6,160,48,"Ship"})
	self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{172,6,160,48,"Station"})
	self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{338,6,320,48,"Refresh Storage"})
	self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{self.SizeX - 166,6,160,48,"Quit"})
	self:AddToBuffer(function(X,Y,W,H) if self:ClickedBox(X,Y,W,H) then self:ChangeState(TERMINAL_SHIP) end end,{6,6,160,48})
	self:AddToBuffer(function(X,Y,W,H) if self:ClickedBox(X,Y,W,H) then self:ChangeState(TERMINAL_STATION) end end,{172,6,160,48})
	self:AddToBuffer(function(X,Y,W,H) if self:ClickedBox(X,Y,W,H) then 
		if self.OldState == TERMINAL_SHIP then
			net.Start("Terminal_RefreshTable")
				net.WriteEntity(self)
			net.SendToServer()
		elseif self.OldState == TERMINAL_STATION then
			net.Start("Terminal_MiningStorageTable")
				net.WriteEntity(self)
			net.SendToServer()
		end
		end end,{338,6,320,48})
	self:AddToBuffer(function(X,Y,W,H) if self:ClickedBox(X,Y,W,H) then self:ChangeState(TERMINAL_EXITPRESSED) end end,{self.SizeX - 166,6,160,48})
end