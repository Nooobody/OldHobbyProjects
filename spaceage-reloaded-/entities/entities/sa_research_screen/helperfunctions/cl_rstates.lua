
function ENT:Research()
	if self.PlyResearch then
		self.CamStartY = 100
		local Cat = {"Laser","Drill","Ice","Storage","Tech","Resource"}
		if not self.Cat then self.Cat = "Laser" end
		
		for I,P in pairs(Cat) do
			self:AddToBuffer(function(I,S) self:DrawBoxWithOutlinesAndText(6 + 156 * (I - 1),66,150,48,S) end,{I,P})
			self:AddToBuffer(function(I,S) 
				if self:ClickedBox(6 + 156 * (I - 1),66,150,48) then 
					self.Cat = S 
					self.CamY = 0
					self:ChangeState(TERMINAL_RESEARCH) 
				end 
			end,{I,P})
		end
		
		local Int = 0
		local y = 140
		for I,P in pairs(self.PlyResearch) do
			local R = GetResearch(I)
			if R then
				if R.Category == self.Cat and P < R.Levels then
					local Lines = self:SplitText(R.Desc,554)
					local W,H = surface.GetTextSize(Lines[1])
					local Y = 40 + (H + 2) * #Lines
					self:AddToBuffer(function(H,Y) self:C_DrawBoxWithOutlinesAndText(20,H,600,Y) end,{y,Y})
					self:AddToBuffer(function(Y,S) self:C_DrawText(S,26,Y) end,{y + 6,string.Replace(I,"_"," ")})
					self:AddToBuffer(function(Y,S)  
						for L,P in pairs(S) do	
							local W,H = surface.GetTextSize(P)
							self:C_DrawText(P,26,Y + H * (L - 1)) 
						end
					end,{y + 40,Lines})
					self:AddToBuffer(function(Y) self:C_DrawBoxWithOutlinesAndText(self.SizeX - 210,Y,200,60) end,{y})
					self:AddToBuffer(function(Y,L,Max) self:C_DrawText(L.." / "..Max,self.SizeX - 20,Y,TEXT_ALIGN_RIGHT) end,{y + 4,P,R.Levels})
					local Cost = R.InitialCost + R.CostMulPer * P
					if R.CostMulPer == 0 then
						Cost = R.Costs[P + 1]
					end
					self:AddToBuffer(function(Y,S) self:C_DrawText("Cost: "..S,self.SizeX - 200,Y) end,{y + 26,self:FormatText(Cost)})
					
					if LocalPlayer():GetNWInt("Money") >= Cost then
						self:AddToBuffer(function(Y) self:C_DrawBoxWithOutlinesAndText(640,Y,self.SizeX - (640 + 220),60) end,{y})
						local Str = "Upg."
						if P == 0 then Str = "Buy" end
						self:AddToBuffer(function(Y,S) self:C_DrawText(S,655,Y) end,{y + 20,Str})
						self:AddToBuffer(function(Y,Name,Level,Res)
							if self:C_ClickedBox(640,Y,self.SizeX - (640 + 220),60) or self:C_HoldingBox(640,Y,self.SizeX - (640 + 220),60) then
								self.HoldCD = CurTime() + 0.05
								local C = Res.InitialCost + Res.CostMulPer * P
								if Res.CostMulPer == 0 then
									C = Res.Costs[P + 1]
									if Res.PreReqs then
										local Ned,lv = next(Res.PreReqs[Level + 1])
										if not self.PlyResearch[Ned] or self.PlyResearch[Ned] < lv then
											self:ErrorPanel("Failed to upgrade tech!","Prerequisites missing,\n"..Ned..": "..lv,TERMINAL_RESEARCH)
											return
										end
									end
								end
								
								if LocalPlayer():GetNWInt("Money") < C then
									self:ErrorPanel("Failed to upgrade tech!","Not enough money",TERMINAL_RESEARCH)
									return
								end
								
								net.Start("Terminal_UpgradeResearch")
									net.WriteEntity(self)
									net.WriteString(Name)
								net.SendToServer()
								self.PlyResearch[Name] = Level + 1
								self:ChangeState(TERMINAL_RESEARCH)
							end
						end,{y,I,P,R})
					end
					
					y = y + Y + 20
				end
				Int = Int + 1
			end
		end
	else
		self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - 400,200,800,100,"Please wait while we load your research") end)
	end
end

function ENT:Refine()
	if not self.PlayerStorage and self.PlayerStorage ~= false then
		timer.Simple(1,function()
				net.Start("Terminal_ResearchStorageTable")
					net.WriteEntity(self)
				net.SendToServer()
			end)
		surface.SetFont("Futuristic")
		local W = surface.GetTextSize("Please wait while we check up on your storages.") + 40
		self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - W / 2,160,W,60,"Please wait while we check up on your storages.") end,{})
	else
		local IsRef = false
		if self.PlayerStorage then
			for I,P in pairs(self.PlayerStorage) do
				if table.HasKey(REFINE_MATERIALS,I) then IsRef = true break end
			end
		end
		
		if not self.PlayerStorage or not next(self.PlayerStorage) or not IsRef then
			timer.Simple(1,function()
				net.Start("Terminal_ResearchStorageTable")
					net.WriteEntity(self)
				net.SendToServer()
			end)
			surface.SetFont("Futuristic")
			local W = surface.GetTextSize("Try transmiting some resources from your ship.") + 40
			self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - W / 2,160,W,100,"It seems you don't have anything to refine.") end,{})
			self:AddToBuffer(function() self:DrawText("Try transmiting some resources from your ship.",self.SizeX / 2,220,TEXT_ALIGN_CENTER) end)
		else
			local Int = 0
			surface.SetFont("Futuristic")
			self:AddToBuffer(function() self:DrawText("Resources available for refinement",self.SizeX / 2,80,TEXT_ALIGN_CENTER) end)
			for I,P in pairs(self.PlayerStorage) do
				if P > 0 and table.HasKey(REFINE_MATERIALS,I) then
					local Str = I..":     "..math.floor(P)
					local W = surface.GetTextSize(Str)
					self:AddToBuffer(function(I,Res,W) self:C_DrawBoxWithOutlinesAndText(20,120 + 60 * I,W + 40,48,Res) end,{Int,Str,W})
					self:AddToBuffer(function(I) self:C_DrawBoxWithOutlinesAndText(self.SizeX - 180,120 + 60 * I,160,48,"Refine") end,{Int})
					self:AddToBuffer(function(I,S) if self:C_ClickedBox(self.SizeX - 180,120 + 60 * I,160,48) then 
						self:Confirmation("Refining "..S,function() 
							net.Start("Terminal_Refine")
								net.WriteEntity(self)
								net.WriteString(S)
							net.SendToServer()
							
							local Str = "You refined "..S.."\nResources you received:\n"
							for I,P in pairs(REFINE_MATERIALS[S]) do
								if not self.PlayerStorage[I] then self.PlayerStorage[I] = 0 end
								self.PlayerStorage[I] = self.PlayerStorage[I] + P * self.PlayerStorage[S]
								Str = Str..I..": "..self:FormatText(P * self.PlayerStorage[S]).."\n"
							end

							self.PlayerStorage[S] = nil
							self:OkayPanel(Str,TERMINAL_REFINE)
						end,TERMINAL_REFINE) 
					end end,{Int,I})
					Int = Int + 1
				end
			end
		end
	end
end

function ENT:Market()
	if not self.PlayerStorage and self.PlayerStorage ~= false  then
		timer.Simple(1,function()
				net.Start("Terminal_ResearchStorageTable")
					net.WriteEntity(self)
				net.SendToServer()
			end)
		surface.SetFont("Futuristic")
		local W = surface.GetTextSize("Please wait while we check up on your storages.") + 40
		self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - W / 2,160,W,60,"Please wait while we check up on your storages.") end,{})
	else
	
		local IsRef = false
		if self.PlayerStorage then
			for I,P in pairs(self.PlayerStorage) do
				if table.HasKey(MARKETABLE,I) then IsRef = true break end
			end
		end
		
		if not self.PlayerStorage or not next(self.PlayerStorage) or not IsRef then
			timer.Simple(1,function()
				net.Start("Terminal_ResearchStorageTable")
					net.WriteEntity(self)
				net.SendToServer()
			end)
			surface.SetFont("Futuristic")
			local W = surface.GetTextSize("It seems you don't have anything for the market.") + 40
			self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - W / 2,160,W,100,"It seems you don't have anything for the market.") end,{})
			self:AddToBuffer(function() self:DrawText("Try refining some ore.",self.SizeX / 2,220,TEXT_ALIGN_CENTER) end)
		else
			local Int = 0
			surface.SetFont("Futuristic")
			self:AddToBuffer(function() self:C_DrawText("Resources available for the market",20,80,TEXT_ALIGN_LEFT) end)
			for I,P in pairs(self.PlayerStorage) do
				if P > 0 and table.HasKey(MARKETABLE,I) then
					local Str = I..":     "..math.floor(P)
					local W = surface.GetTextSize(Str)
					self:AddToBuffer(function(I,Res,W) self:C_DrawBoxWithOutlinesAndText(20,140 + 60 * I,W + 40,48,Res) end,{Int,Str,W})
					self:AddToBuffer(function(I) self:C_DrawBoxWithOutlinesAndText(self.SizeX - 180,140 + 60 * I,160,48,"Sell") end,{Int})
					self:AddToBuffer(function(I,S) if self:C_ClickedBox(self.SizeX - 180,140 + 60 * I,160,48) then 
						self:Confirmation("Selling "..S,function() 
							if self.PlayerStorage[S] > 0 then
								local Str = "You sold: "..S.."\nYou received "..self:FormatText(MARKETABLE[S] * self.PlayerStorage[S]).." credits"
								
								net.Start("Terminal_Market")
									net.WriteEntity(self)
									net.WriteString(S)
								net.SendToServer()
								
								self.PlayerStorage[S] = nil
								self:OkayPanel(Str,TERMINAL_MARKET)
							else
								self:ErrorPanel("Operation failed","None of that in storage",TERMINAL_MARKET)
							end
						end,TERMINAL_MARKET) 
					end end,{Int,I})
					Int = Int + 1
				end
			end
			self:AddToBuffer(function() self:C_DrawBoxWithOutlinesAndText(self.SizeX - 220,70,200,48,"Sell All") end)
			self:AddToBuffer(function() 
				if self:C_ClickedBox(self.SizeX - 220,70,200,48) then
					self:Confirmation("Selling Everything",function()
						local Str = "You sold everything!\nYou received "
						local Credits = 0
						for I,P in pairs(self.PlayerStorage) do
							if table.HasKey(MARKETABLE,I) then
								Credits = Credits + MARKETABLE[I] * P
								self.PlayerStorage[I] = nil
							end
						end
						net.Start("Terminal_MarketAll")
							net.WriteEntity(self)
						net.SendToServer()
						Str = Str..self:FormatText(Credits).." credits"
						self:OkayPanel(Str,TERMINAL_MARKET)
					end,TERMINAL_MARKET)
				end
			end)
		end
	end
end

function ENT:R_AddTabs()
	self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{0,0,self.SizeX,60})
	self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{6,6,180,48,"Research"})
	self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{192,6,160,48,"Refine"})
	self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{358,6,160,48,"Market"})
	self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{self.SizeX - 166,6,160,48,"Quit"})
	self:AddToBuffer(function(X,Y,W,H) if self:ClickedBox(X,Y,W,H) then self:ChangeState(TERMINAL_RESEARCH) end end,{6,6,180,48})
	self:AddToBuffer(function(X,Y,W,H) if self:ClickedBox(X,Y,W,H) then self:ChangeState(TERMINAL_REFINE) end end,{192,6,160,48})
	self:AddToBuffer(function(X,Y,W,H) if self:ClickedBox(X,Y,W,H) then self:ChangeState(TERMINAL_MARKET) end end,{358,6,160,48})
	self:AddToBuffer(function(X,Y,W,H) if self:ClickedBox(X,Y,W,H) then self:ChangeState(TERMINAL_EXITPRESSED) end end,{self.SizeX - 166,6,160,48})
	self:AddToBuffer(function() self:DrawText("Money: "..self:FormatText(LocalPlayer():GetNWInt("Money")),530,20) end)
end