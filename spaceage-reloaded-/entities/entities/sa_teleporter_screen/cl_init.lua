include("shared.lua")

function ENT:PublicScreen()
	self:AddToBuffer(function() self:DrawBoxWithOutlinesAndText(20,20,self.SizeX - 40,self.SizeY - 100,"Teleport by pressing E") end)
	local Ents = ents.FindByClass("sa_teleporter_screen")
	table.RemoveByValue(Ents,self)
	local Names = {}
	for I,P in pairs(Ents) do
		if P:GetNWString("Name") ~= self:GetNWString("Name") and not table.HasValue(Names,P:GetNWString("Name")) then
			table.insert(Names,P:GetNWString("Name"))
			self:AddToBuffer(function(S,I) self:DrawBoxWithOutlinesAndText(80,60 + 70 * I,self.SizeX - 160,60,S) 
				if self:ClickedBox(80,60 + 70 * I,self.SizeX - 160,60) then
					net.Start("Terminal_Teleport")
						net.WriteString(S)
					net.SendToServer()
				end
			end,{P:GetNWString("Name"),I})
		end
	end
	if #Names < 2 then 
		self:AddToBufferDir(function()
			self:DrawBoxWithOutlinesAndText("Click this to refresh if the screen is empty",80,400,self.SizeX - 160,60)
			if self:ClickedBox(80,400,self.SizeX - 160,60) then
				self:ChangeState(TERMINAL_WELCOME)
			end
		end)
	end
end

function ENT:AddCheckStates()
end

function ENT:CheckCam()
	return false
end