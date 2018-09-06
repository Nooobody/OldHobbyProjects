
function ENT:Begin()
	self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{50,250,self.SizeX - 100,100,"Press E to begin!"})
	self:AddToBuffer(function() if self:ClickedBox(0,0,self.SizeX,self.SizeY) then self:ChangeState(1) end end,{})
end

function ENT:Finish()
	self:AddToBuffer(function(X,Y,W,H,Str) self:DrawBoxWithOutlinesAndText(X,Y,W,H,Str) end,{50,250,self.SizeX - 100,100,"Thank you for doing business with us!"})
end

function ENT:HowMuch(Res,Amount,Callback,Return)
	self:AddToBufferDir(function(R,A) self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - 400,200,800,160,"How much would you like to transmit "..R.."?\nAmount available: "..A) end,{Res,Amount})
	self:AddToBufferDir(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - 380,300,120,48,"All") end)
	self:AddToBufferDir(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - 240,300,120,48,"Half") end)
	self:AddToBufferDir(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - 100,300,160,48,"Quarter") end)
	self:AddToBufferDir(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 + 240,300,140,48,"Cancel") end)
	self:AddToBufferDir(function(CB,A) if self:ClickedBox(self.SizeX / 2 - 380,300,120,48) then
			CB(A)
		end end,{Callback,Amount})
	self:AddToBufferDir(function(CB,A) if self:ClickedBox(self.SizeX / 2 - 240,300,120,48) then
			CB(math.Round(A / 2))
		end end,{Callback,Amount})
	self:AddToBufferDir(function(CB,A) if self:ClickedBox(self.SizeX / 2 - 100,300,160,48) then 
			CB(math.Round(A / 4))
		end end,{Callback,Amount})
	self:AddToBufferDir(function(Ret) if self:ClickedBox(self.SizeX / 2 + 240,300,140,48) then 
			self:ChangeState(Ret)
		end end,{Return})
end

function ENT:Transmitting(Res,FromStationQM)
	self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - 200,200,400,60) end)
	if FromStationQM then
		self:AddToBuffer(function(R) self:DrawText("Transmitting "..R[1].." from Station to Ship...",self.SizeX / 2,160,TEXT_ALIGN_CENTER) end,{Res})
	else
		self:AddToBuffer(function(R) self:DrawText("Transmitting "..R[1].." from Ship to Station...",self.SizeX / 2,160,TEXT_ALIGN_CENTER) end,{Res})
	end
	self:AddToBuffer(surface.SetDrawColor,{0,0,255})
	self:AddToBuffer(function() surface.DrawRect(self.SizeX / 2 - 196,204,392 * self.TransmitDone,52) end)
	self:AddToBuffer(function() self:DrawText("Amount Left: "..math.Round(self.Transmit[2] * (1 - self.TransmitDone)),self.SizeX / 2,220,TEXT_ALIGN_CENTER,Color(255,255,0)) end)
end

function ENT:ErrorPanel(Str,Res,Ret)
	surface.SetFont("Futuristic")
	local Wide1 = surface.GetTextSize(Str) + 40
	local Wide2 = surface.GetTextSize("Reason: "..Res) + 40
	local Wi = Wide1
	if Wide2 > Wide1 then Wi = Wide2 end
	self:AddToBufferDir(function(S,W) self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - W / 2,200,W,200,S) end,{Str,Wi})
	self:AddToBufferDir(function(R) self:DrawText("Reason: "..R,self.SizeX / 2,260,TEXT_ALIGN_CENTER) end,{Res})
	self:AddToBufferDir(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - 100,340,200,48,"Okay") end)
	self:AddToBufferDir(function(R) if self:ClickedBox(self.SizeX / 2 - 100,340,200,48) then
							self:ChangeState(R)
						end end,{Ret})
end

function ENT:OkayPanel(Str,Ret)
	surface.SetFont("Futuristic")
	local W = surface.GetTextSize(Str) + 40
	local H = 100
	if string.find(Str,"\n") then 
		local w = 0
		local S = string.Split(Str,"\n")
		for I,P in pairs(S) do
			local x = surface.GetTextSize(P) + 40
			if x > w then w = x end
		end
		W = w
		H = #S * 20 + 120
	end
	self:AddToBufferDir(function(S,w,h) self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - w / 2,200,w,h,S) end,{Str,W,H})
	self:AddToBufferDir(function(h) self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - 100,200 + h - 60,200,48,"Okay") end,{H})
	self:AddToBufferDir(function(R,h) if self:ClickedBox(self.SizeX / 2 - 100,200 + h - 60,200,48) then
							self:ChangeState(R)
						end end,{Ret,H})
end

function ENT:Confirmation(Str,Callback,Return)
	surface.SetFont("Futuristic")
	local W = math.max(surface.GetTextSize(Str) + 40,400)
	self:AddToBufferDir(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - W / 2,100,W,200,"Are you sure?") end)
	self:AddToBufferDir(function(S) self:DrawText(S,self.SizeX / 2,140,TEXT_ALIGN_CENTER) end,{Str})
	self:AddToBufferDir(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 - (W / 2 - 20),240,160,48,"Confirm") end)
	self:AddToBufferDir(function() self:DrawBoxWithOutlinesAndText(self.SizeX / 2 + (W / 2 - 180),240,160,48,"Cancel") end)
	self:AddToBufferDir(function(CB) if self:ClickedBox(self.SizeX / 2 - (W / 2 - 20),240,160,48) then CB() end end,{Callback})
	self:AddToBufferDir(function(RET) if self:ClickedBox(self.SizeX / 2 + (W / 2 - 180),240,160,48) then self:ChangeState(RET) end end,{Return})
end