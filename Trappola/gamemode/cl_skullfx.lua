local D = NULL
local Percent
local TA
local A
local HP
hook.Add("Think","Skull",function()
	local SelfPly = LocalPlayer()
	if not HP then
		HP = SelfPly:Health()
	end
	if HP == SelfPly:Health() then return end
	HP = SelfPly:Health()
	if HP >= 40 then return end
	if HP > 0 and not D:IsValid() then
		D = vgui.Create("DPanel")
		D:SetSize(256,256)
		D:SetPos(ScrW() / 2 - D:GetWide() / 2,ScrH() / 2 - D:GetTall())
		local hp = SelfPly:Health()
		Percent = 1 - hp/40
		TA = 255*Percent
		A = 0
		D.Paint = function()
			if hp ~= SelfPly:Health() then
				hp = SelfPly:Health()
				A = 0
				if hp > 20 then
					Percent = 1 - hp/40
					TA = 255*Percent
				elseif hp <= 20 then
					Percent = 1 - hp/80
					TA = 255*Percent
				end
			end
			if TA == 255*Percent then
				if A < TA - 0.1 then
					A = A + (TA - A) / 20
				elseif A >= TA - 0.1 then
					A = TA
					TA = 0
				end
			elseif TA == 0 then
				if A > TA + 0.01 then
					A = A - (A - TA) / 20
				elseif A <= TA + 0.01 and hp <= 20 then
					A = 20
					TA = 255*Percent
				end
			end
			surface.SetDrawColor(255,255,255,A)
			surface.SetTexture(surface.GetTextureID("skull"))
			surface.DrawTexturedRect(0,0,256,256)
		end
	elseif HP <= 0 and D:IsValid() then
		D:Remove()
	end
end)