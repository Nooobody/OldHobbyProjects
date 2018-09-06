
local PANEL = {}

function PANEL:SetText(txt)
	self.Txt = txt
end

function PANEL:SetValue(Val)
	self.Value = Val
end

function PANEL:Paint(w,h)
	local Col = team.GetColor(self:GetValue():Team())
	local BG
	if self.Selected then
		BG = Color(200,200,200)
	elseif self.Depressed then
		BG = Color(50,50,50)
	elseif self.Hovered then
		BG = Color(100,100,100)
	end
	
	draw.DrawTransBox(2,2,w - 4,h - 4,Col)
	if BG then
		surface.SetDrawColor(BG)
		surface.DrawRect(5,5,w - 10,h - 10)
	end
	draw.DrawText(self.Txt,"DermaDefaultBold",6,4,Col,TEXT_ALIGN_LEFT)
end

function PANEL:GetValue()
	return self.Value
end

function PANEL:SetMenuParent(Pan)
	self.Parent = Pan
end

function PANEL:GetMenuParent()
	return self.Parent
end

function PANEL:DoClick()
	if self.Selected then
		self.Selected = false
		self.Parent:SetSelected(0)
	else
		self.Selected = true
		self.Parent:SetSelected(self.Ind)
	end
end

function PANEL:OnMousePressed()
	self.Depressed = true
end

function PANEL:OnMouseReleased()
	self.Depressed = false
	if self.Hovered then self:DoClick() end
end

function PANEL:OnCursorEntered(x,y)
	self.Hovered = true
end

function PANEL:OnCursorExited()
	self.Hovered = false
end

vgui.Register("SA_Button",PANEL,"DPanel")