include("shared.lua")

function ENT:Think()
	self:SetNextClientThink(CurTime() + 1)
	if LocalPlayer():GetEyeTrace().Entity == self and LocalPlayer():EyePos():Distance(self:GetPos()) < 256 then
		net.Start("SA_LSProbeLooked")
		net.SendToServer()
	end
	
	return true
end

net.Receive("SA_LSProbeLookedReceive",function(len)
	local Ent = net.ReadEntity()
	Ent.Data = net.ReadString()
end)

function ENT:Draw()
	self:DrawModel()
	self:BeforeTooltip()
	if self.Data and LocalPlayer():GetEyeTrace().Entity == self and LocalPlayer():EyePos():Distance(self:GetPos()) < 256 then
		//AddWorldTip(nil,self.Data,nil,self:GetPos(),self)
		surface.SetFont("Trebuchet24")
		local Lines = string.Split(self.ScreenName.."\n"..self.Data,"\n")
		local T,Y = 0
		for I,P in pairs(Lines) do
			if T < surface.GetTextSize(Lines[I]) then T,Y = surface.GetTextSize(Lines[I]) end
		end
		local W,H = 20 + T,(4 + Y) * #Lines
		
		local Min,Max = self:WorldSpaceAABB()
		Pos = Min + (Max - Min) / 2
		local Distance = Pos:Distance(LocalPlayer():GetPos())
		local A
		
		if Distance > 200 and Distance < 256 then
			local Distance = 1 - ((Distance - 200) / 56)
			A = 255 * Distance
		elseif Distance > 250 then
			A = 0
		else
			A = 255
		end
		
		if A <= 0 then return end
		
		local ScrnPos = Pos:ToScreen()
		table.insert(SA_TOOLTIPS,{ScrnPos.x,ScrnPos.y,W,H,Lines,A,Y})
	end
end