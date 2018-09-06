include("shared.lua")

local function GetPosAng(Mdl,Pos,Ang,Ent)
	if not Ent.Func then
		local Func
		for I,P in pairs(DoshUpgds) do
			if P["Class"] == "Hats" and P["Var"] == Mdl then
				Func = P["Data"][1]
				break
			end
		end
		Ent.Func = Func
	end
	return Ent.Func(Pos,Ang,Ent)
end

local function GetAttachPosAng(Mdl,Pos,Ang,Ent)
	if not Ent.Func then
		local Func
		for I,P in pairs(DoshUpgds) do
			if P["Class"] == "Hats" and P["Var"] == Mdl then
				Func = P["Data"][2]
				break
			end
		end
		Ent.Func = Func
	end
	return Ent.Func(Pos,Ang,Ent)
end

function ENT:Draw()
	if self:GetOwner() == SelfPly then return end
	local ply = self:GetOwner()
	local Owner = ply
	if ply.Rag then Owner = ply.Rag elseif ply:Health() <= 0 then return end
	local BoneInd = Owner:LookupBone("ValveBiped.Bip01_Head1")
	if BoneInd then
		local Pos, Ang = Owner:GetBonePosition(BoneInd)
		if Pos then
			Pos,Ang = GetPosAng(self:GetModel(),Pos,Ang,self.Entity)
			self:SetPos(Pos)
			self:SetAngles(Ang)
			self:DrawModel()
			return
		end
	end

	local Attach = Owner:GetAttachment(Owner:LookupAttachment("eyes"))
	if not Attach then Attach = Owner:GetAttachment(Owner:LookupAttachment("head")) end
	if Attach then
		local Pos,Ang = GetAttachPosAng(self:GetModel(),Attach.Pos,Attach.Ang,self.Entity)
		self:SetPos(Pos)
		self:SetAngles(Ang)
		self:DrawModel()
	end
end