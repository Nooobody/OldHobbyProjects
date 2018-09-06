	
E2Lib.RegisterExtension("spaceage",true)
__e2setcost(1)
e2function number entity:credits()
	if not IsValid(this) then return 0 end
	if this:IsPlayer() then return this:GetMoney() else return 0 end
end

e2function number entity:score()
	if not IsValid(this) then return 0 end
	if this:IsPlayer() then return this:GetScore() else return 0 end
end

e2function number entity:privilege()
	if not IsValid(this) then return 0 end
	if this:IsPlayer() then return this:GetPrivilege() else return 0 end
end

e2function number entity:isAFK()
	if not IsValid(this) then return 0 end
	if this:IsPlayer() then return this:GetNWBool("AFK") else return 0 end
end

e2function void entity:link(entity E)
	if not IsValid(this) or not IsValid(E) or this:IsWorld() or E:IsWorld() then return end
	if not this.sa_ent or not E.sa_ent then return end
	
	this:Link(E)
end

e2function array entity:getLinked()
	if not IsValid(this) or this:IsWorld() then return end
	if not this.sa_ent or not this.Class or not this.SubClass then return end

	return this:UpdateLinks()
end

e2function number entity:getStorage(string str)
	if not IsValid(this) or this:IsWorld() then return end
	if not this.sa_ent then return end
	if not next(this.Storage) then return end
	if not table.HasValue(Resources,str) then return end
	local Stor = this:UpdateStorage()
	return Stor[str][1]
end

e2function number entity:getStorageMax(string str)
	if not IsValid(this) or this:IsWorld() then return end
	if not this.sa_ent then return end
	if not next(this.Storage) then return end
	if not table.HasValue(Resources,str) then return end
	local Stor = this:UpdateStorage()
	return Stor[str][2]
end

e2function number entity:isOccupied()
	if not IsValid(this) or this:IsWorld() then return end
	if not this.sa_ent then return end
	if this.Class ~= "RD" or this.SubClass ~= "Port" then return end
	if this.Connected then
		return 1
	else
		return 0
	end
end

e2function void entity:unPlug()
	if not IsValid(this) or this:IsWorld() then return end
	if not this.sa_ent then return end
	if this.Class ~= "RD" or this.SubClass ~= "Port" then return end
	this:Unplug()
end

e2function array spawnPlugs(vector Vec1,angle Ang1,vector Vec2,angle Ang2)
	if not Vec1 or not Ang1 or not Vec2 or not Ang2 then return end
	local Ply = self.player
	
	if not Ply:CheckLimit("sa_plug") then return {} end
	
	if type(Vec1) == "table" then
		Vec1 = Vector(Vec1[1],Vec1[2],Vec1[3])
	end
	
	if type(Vec2) == "table" then
		Vec2 = Vector(Vec2[1],Vec2[2],Vec2[3])
	end
	
	Ang1 = Angle(Ang1[1],Ang1[2],Ang1[3])
	Ang2 = Angle(Ang2[1],Ang2[2],Ang2[3])
	
	local Ent1 = MakePlugs(Ply,Vec1,Ang1,false)
	local Ent2 = MakePlugs(Ply,Vec2,Ang2,false)
	
	local Rope
	if Ply:GetResearch("Socket_Plasma_Fiber") > 0 then
		Ent1:SetMaterial("models/props_lab/xencrystal_sheet")
		Ent2:SetMaterial("models/props_lab/xencrystal_sheet")
		Rope = constraint.Rope(Ent1,Ent2,0,0,Vector(12,.115219,-0.085065,-0.158239),Vector(12.115219,-0.085065,-0.158239),500,0,0,10,"cable/hydra",false)
		Ent1.Plasma = true 
		Ent2.Plasma = true
	elseif Ply:GetResearch("Socket_Optic_Fiber") > 0 then
		Ent1:SetMaterial("models/debug/debugwhite")
		Ent2:SetMaterial("models/debug/debugwhite")
		Rope = constraint.Rope(Ent1,Ent2,0,0,Vector(12.115219,-0.085065,-0.158239),Vector(12.115219,-0.085065,-0.158239),500,0,0,6,"cable/physbeam",false)
		Ent1.Golden = true
		Ent2.Golden = true
	else
		Rope = constraint.Rope(Ent1,Ent2,0,0,Vector(12.115219,-0.085065,-0.158239),Vector(12.115219,-0.085065,-0.158239),500,0,0,1,"cable/cable",false)
	end
	
	Ent1:DeleteOnRemove(Ent2)
	Ent2:DeleteOnRemove(Ent1)
	
	Ent1:DeleteOnRemove(Rope)
	Ent2:DeleteOnRemove(Rope)
	
	Ent1.LinkPlug = Ent2
	Ent2.LinkPlug = Ent1
	
	undo.Create("Plugs")
		undo.AddEntity(Ent1)
		undo.AddEntity(Ent2)
		undo.SetPlayer(Ply)
	undo.Finish()
	
	Ply:AddCount("sa_plug",Ent1)
	Ply:AddCount("sa_plug",Ent2)
	
	Ply:AddCleanup("sa_plug",Ent1)
	Ply:AddCleanup("sa_plug",Ent2)
	
	return {Ent1,Ent2}
end