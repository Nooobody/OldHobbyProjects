
function ENT:FormatText(Str)
	if type(Str) == "string" then Str = tonumber(Str) end
	if Str >= math.pow(10,3) and Str < math.pow(10,6) then
		Str = tostring(math.floor(Str / math.pow(10,2)) / 10).." K"
	elseif Str >= math.pow(10,6) and Str < math.pow(10,9) then
		Str = tostring(math.floor(Str / math.pow(10,5)) / 10).." M"
	elseif Str >= math.pow(10,9) then
		Str = tostring(math.floor(Str / math.pow(10,8)) / 10).." B"
	end
	return Str		
end

function ENT:SplitText(Str,W)
	local Lines = {}
	local txt = ""
	local String = string.Split(Str," ")
	surface.SetFont("Futuristic")
	for I,P in pairs(String) do
		local S = surface.GetTextSize(txt..P.." ")
		if S > W then
			table.insert(Lines,txt)
			txt = ""
		elseif P == "\n" then
			table.insert(Lines,txt)
			txt = ""
		end
		
		if P ~= "\n" then
			txt = txt..P.." "
		end
		
		if I == #String then
			table.insert(Lines,txt)
		end
	end
	return Lines
end

function ENT:DrawPoly(Polys,Col)
	Col = Col or self.Outlines
	
	surface.SetDrawColor(Col)
	draw.NoTexture()
	surface.DrawPoly(Polys)
end

function ENT:DrawBoxWithOutlinesAndText(X,Y,W,H,Str,Col1,Col2)
	Col1 = Col1 or self.BG
	Col2 = Col2 or self.Outlines
	Str = Str or ""

	surface.SetDrawColor(Col2)
	surface.DrawRect(X,Y,W,H)
	surface.SetDrawColor(Col1)
	surface.DrawRect(X + 4,Y + 4,W - 8,H - 8)
	
	if self:CheckRenderBoxes(X,Y,W,H) then
		table.insert(self.RenderBoxes,{X,Y,W,H})
	end
	if Str == "" then return end
	self:DrawText(Str,X + W / 2,Y + 15,TEXT_ALIGN_CENTER,Col2)
end

function ENT:DrawText(Str,X,Y,Align,Col)
	if string.find(Str,"\n") then
		Str = string.Split(Str,"\n")
	end
	
	if type(Str) == "table" then
		for I,P in pairs(Str) do
			draw.DrawText(P,"Futuristic",X,Y + 20 * I,Col or self.Outlines,Align or TEXT_ALIGN_LEFT)
		end
	else
		draw.DrawText(Str,"Futuristic",X,Y,Col or self.Outlines,Align or TEXT_ALIGN_LEFT)
	end
end

function ENT:C_DrawBoxWithOutlinesAndText(X,Y,W,H,Str,Col1,Col2)
	Col1 = Col1 or self.BG
	Col2 = Col2 or self.Outlines
	Str = Str or ""
	
	
	if Y + H > self.SizeY - self.CamEndY then 
		local V = self.SizeY - (self.CamStartY + self.CamEndY) + ((Y + H + 20) - (self.SizeY - self.CamEndY)) 
		if V > self.CamSizeY then self.CamSizeY = V end
	end
	
	local y = Y
	Y = Y - self.CamY

	
	if Y < self.CamStartY or Y + H > self.SizeY - self.CamEndY then return end
	
	surface.SetDrawColor(Col2)
	surface.DrawRect(X,Y,W,H)
	surface.SetDrawColor(Col1)
	surface.DrawRect(X + 4,Y + 4,W - 8,H - 8)
	if self:CheckRenderBoxes(X,y,W,H) then
		table.insert(self.RenderBoxes,{X,y,W,H})
	end
	if Str == "" then return end
	self:C_DrawText(Str,X + W / 2,Y + 15,TEXT_ALIGN_CENTER,Col2,true)
end

function ENT:C_DrawText(Str,X,Y,Align,Col,IsRect)
	if not IsRect then
		if Y > self.SizeY - self.CamEndY then 
			local V = self.SizeY - (self.CamStartY + self.CamEndY) + ((Y + 20) - (self.SizeY - self.CamEndY)) 
			if V > self.CamSizeY then self.CamSizeY = V end
		end
		
		Y = Y - self.CamY
		if Y < self.CamStartY or Y > self.SizeY - self.CamEndY then return end
	end
	
	if string.find(Str,"\n") then
		Str = string.Split(Str,"\n")
	end
	
	if type(Str) == "table" then
		for I,P in pairs(Str) do
			draw.DrawText(Str,"Futuristic",X,Y + 20 * I,Col or self.Outlines,Align or TEXT_ALIGN_LEFT)
		end
	else
		draw.DrawText(Str,"Futuristic",X,Y,Col or self.Outlines,Align or TEXT_ALIGN_LEFT)
	end
	
	draw.DrawText(Str,"Futuristic",X,Y,Col or self.Outlines,Align or TEXT_ALIGN_LEFT)
end

function ENT:AddToBuffer(...)
	table.insert(self.B,{...})
end

function ENT:AddToBufferDir(...)
	table.insert(self.Buffer,{...})
end

local Tri = {{},{},{},{}}
Tri[1].x = 0
Tri[1].y = 0
Tri[2].x = 0.3
Tri[2].y = 0.6
Tri[3].x = 0.6
Tri[3].y = 0.3
Tri[4].x = 0
Tri[4].y = 0


function ENT:DrawCursor()
	if not LocalPlayer():GetEyeTrace().Entity or LocalPlayer():GetEyeTrace().Entity ~= self then return end
	if LocalPlayer():GetPos():Distance(self:GetPos()) > 100 then return end
	local X,Y = self:GetCursorPosition()
	if X < 0 or Y < 0 or X > self.SizeX or Y > self.SizeY then return end
	
	surface.SetTexture(0)
	surface.SetDrawColor(Color(0,0,0))
	local Curs = table.Copy(Tri)
	for I,P in pairs(Curs) do
		Curs[I].x = X + Curs[I].x * self.Mul
		Curs[I].y = Y + Curs[I].y * self.Mul
	end
	surface.DrawPoly(Curs)
	
	surface.SetDrawColor(Color(255,255,255))
	Curs = table.Copy(Tri)
	for I,P in pairs(Curs) do
		Curs[I].x = X + Curs[I].x * self.Mul + 0.6
		Curs[I].y = Y + Curs[I].y * self.Mul + 0.6
	end
	surface.DrawPoly(Curs)
end

function ENT:GetCursorPosition()
	local Min,Max = self:WorldSpaceAABB()
	local Off = Max - Min
	local Off2 = Max - self:GetPos()
	local Pos = self:WorldToLocal(LocalPlayer():GetEyeTrace().HitPos) - Vector(32,64,0)
	local X = Pos.y * -self.Mul
	local Y = Pos.x * -self.Mul
	//print(X..":"..Y)
	return X,Y
end

function ENT:CheckUse()
	self.TickClicked = false
	local E = LocalPlayer():KeyDown(IN_USE)
	if E and not self.Click and not self.SemiHolding then
		self.Click = true
	elseif E and self.Click then
		self.Click = false
		self.SemiHolding = true
		self.HoldCD = CurTime() + 0.8
	elseif not E and self.SemiHolding and not self.Released then
		self.HoldCD = 0
		self.Released = true
		self.Click = false
		self.SemiHolding = false
		self.Holding = false
	elseif not E and self.Released then
		self.Released = false
	end
	
	if E and self.SemiHolding and CurTime() > self.HoldCD then
		self.Holding = true
	end
end

function ENT:CheckClick()
	if self.Released then
		self.TickClicked = true
		return true
	end
	return false
end

function ENT:CheckRenderBoxes(X,Y,W,H)
	for I,P in pairs(self.RenderBoxes) do
		if P[1] == X and P[2] == Y and P[3] == W and P[4] == H then return false end
	end
	return true
end

function ENT:GetTopmostBox(X,Y)
	local I = #self.RenderBoxes
	while I > 0 do
		local Box = self.RenderBoxes[I]
		if X > Box[1] and X < Box[1] + Box[3] and Y > Box[2] and Y < Box[2] + Box[4] then
			return Box
		end
		I = I - 1
	end
	return nil
end

function ENT:IsCurrentBox(X,Y,W,H,IsCamera)
	if IsCamera then return true end
	local Box = self:GetTopmostBox(self:GetCursorPosition())
	if not Box then return false end
	return Box[1] == X and Box[2] == Y and Box[3] == W and Box[4] == H
end

function ENT:CursorInBox(X,Y,W,H,IsCamera)
	if LocalPlayer():GetPos():Distance(self:GetPos()) > 100 then return false end
	local x,y = self:GetCursorPosition()
	return x > X and x < X + W and y > Y and y < Y + H and self:IsCurrentBox(X,Y,W,H,IsCamera)
end

function ENT:HoldingBox(X,Y,W,H)
	if LocalPlayer():GetPos():Distance(self:GetPos()) > 100 then return false end
	local x,y = self:GetCursorPosition()
	return self:CursorInBox(X,Y,W,H) and (self.Click or self.Holding) and CurTime() > self.HoldCD
end

function ENT:C_HoldingBox(X,Y,W,H)
	if LocalPlayer():GetPos():Distance(self:GetPos()) > 100 then return false end
	local x,y = self:GetCursorPosition()
	if Y - self.CamY < self.CamStartY or Y + W - self.CamY > self.SizeY - self.CamEndY then return false end
	
	return self:CursorInBox(X,Y - self.CamY,W,H,true) and (self.Click or self.Holding) and CurTime() > self.HoldCD
end

function ENT:ClickedBox(X,Y,W,H)
	if LocalPlayer():GetPos():Distance(self:GetPos()) > 100 then return false end
	if self.TickClicked then return false end
	local x,y = self:GetCursorPosition()
	
	if self:CursorInBox(X,Y,W,H) then
		surface.SetTexture(surface.GetTextureID(self.Grad))
		surface.SetDrawColor(self.Outlines.r,self.Outlines.g,self.Outlines.b,15)
		surface.DrawTexturedRectRotated(X + W / 2,Y + H / 4,H / 2,W,90)
		surface.DrawTexturedRectRotated(X + W / 2,Y + (H / 4) * 3,H / 2,W,-90)
		return self:CheckClick()
	end
	return false
end

function ENT:C_ClickedBox(X,Y,W,H)
	if LocalPlayer():GetPos():Distance(self:GetPos()) > 100 then return false end
	if self.TickClicked then return false end
	local x,y = self:GetCursorPosition()
	if Y - self.CamY < self.CamStartY or Y + H - self.CamY > self.SizeY - self.CamEndY then return false end

	if self:CursorInBox(X,Y - self.CamY,W,H,true) then
		surface.SetTexture(surface.GetTextureID(self.Grad))
		surface.SetDrawColor(self.Outlines.r,self.Outlines.g,self.Outlines.b,15)
		surface.DrawTexturedRectRotated(X + W / 2,Y - self.CamY + H / 4,H / 2,W,90)
		surface.DrawTexturedRectRotated(X + W / 2,Y - self.CamY + (H / 4) * 3,H / 2,W,-90)
		return self:CheckClick()
	end
	return false
end

function ENT:StartCam()
	local Ang = self:LocalToWorldAngles(Angle(180,90,180))
	local Pos = self:LocalToWorld(Vector(32,64,0)) + self:GetAngles():Up() * 1
	cam.Start3D2D(Pos,Ang,1 / self.Mul)
end

function ENT:EndCam()
	cam.End3D2D()
end