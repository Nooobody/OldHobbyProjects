
local PANEL = {}

function PANEL:Init()
	self.Button.Paint = function(self,w,h)
		draw.DrawTransBox(0,0,w,h,team.GetColor(LocalPlayer():Team()))
		
		if self.Depressed then
			surface.SetDrawColor(60,60,60)
			surface.DrawRect(3,3,w - 6,h - 6)
		elseif self.Hovered then
			surface.SetDrawColor(100,100,100)
			surface.DrawRect(3,3,w - 6,h - 6)
		end
		
		if self:GetChecked() then
			draw.DrawCross(5,5,w - 10,h - 10)
		end
	end
end

function PANEL:PerformLayout()
	local x = self.m_iIndent or 0
	self.Button:SetSize(30,30)
	self.Button:SetPos(x,0)
	
	if self.Label then
		self.Label:SizeToContents()
		self.Label:SetPos(x + 38,8)
	end
end

vgui.Register("SA_CheckBox",PANEL,"DCheckBoxLabel")