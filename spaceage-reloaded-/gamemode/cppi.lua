
local Ent = FindMetaTable("Entity")

function Ent:CPPISetOwner(ply)
	if not ply:IsPlayer() then return false end 
	self:SetNWOwner(ply)
	return true
end

function Ent:CPPISetOwnerUID(uid)
	return CPPI.CPPI_NOTIMPLEMENTED
end

function Ent:CPPICanTool(ply,mode)
	if not ply:IsPlayer() then return false end
	return CanSomethingDo(ply,self,"ConstrainAble")
end

function Ent:CPPICanPhysgun(ply)
	if not ply:IsPlayer() then return false end
	return CanSomethingDo(ply,self,"PhysGunAble")
end

function Ent:CPPICanPickup(ply)
	if not ply:IsPlayer() then return false end
	return CanSomethingDo(ply,self,"PhysGunAble")
end

function Ent:CPPICanPunt(ply)
	if not ply:IsPlayer() then return false end
	return CanSomethingDo(ply,self,"PhysGunAble")
end