local MetaPly = FindMetaTable("Player")

local CheckLimit = MetaPly.CheckLimit
local ThisAndThat = {}
function MetaPly:CheckLimit(str)
	if SA_Limits[str] then
		if  str == "sa_mining_laser" or 
			str == "sa_mining_drill" or
			str == "sa_mining_icelaser" or
			str == "sa_mining_refinery" or
			str == "sa_mining_liquidtib_storage" then
			return self:CheckLimit("sa_mining")
		elseif  str == "sa_mining_rawore_storage" or
				str == "sa_mining_rawtib_storage" or
				str == "sa_mining_rawice_storage" or
				str == "sa_mining_refinedice_storage" then
			return self:CheckLimit("sa_mining_storage")
		end
		if string.Split(str,"_")[1] ~= "sa" then
			if ThisAndThat[str] then
				return self:CheckLimit(ThisAndThat[str])
			else
				if str == "ning" or str == "ning_storage" then
					if str == "ning" then
						ThisAndThat[str] = "sa_mining"
						return self:CheckLimit("sa_mining")
					else
						ThisAndThat[str] = "sa_mining_storage"
						return self:CheckLimit("sa_mining_storage")
					end
				else
					for I,P in pairs(SA_Limits) do
						if string.find(I.."s",str) and I ~= str and P == SA_Limits[str] then
							ThisAndThat[str] = I
							return self:CheckLimit(I)
						end
					end
				end
			end
		end
		if self:GetCount(str) >= SA_Limits[str] then self:LimitHit(str) return false end
		return true
	else
		return CheckLimit(self,str)
	end
end

function MetaPly:AddCount(str,ent)
	if not IsValid(ent) then return end
	if string.Split(str,"_")[1] == "sa" then
		if str == "sa_mining_laser" or str == "sa_mining_drill" or str == "sa_mining_liquidtib_storage" or str == "sa_mining_icelaser" then return self:AddCount("sa_mining",ent) end
		if str == "sa_mining_rawtib_storage" or str == "sa_mining_rawore_storage" or str == "sa_mining_rawice_storage" then return self:AddCount("sa_mining_storage",ent) end
	end
	if SA_Limits[str] and ent:GetClass() ~= str and str ~= "sa_mining" and str ~= "sa_mining_storage" then return self:AddCount(ent:GetClass(),ent) end

	local key = self:UniqueID()
	g_SBoxObjects[key] = g_SBoxObjects[key] or {}
	g_SBoxObjects[key][str] = g_SBoxObjects[key][str] or {}

	local tab = g_SBoxObjects[key][str]

	if table.HasValue(tab,ent) then return end
	
	table.insert(tab,ent)

	-- Update count (for client)
	self:GetCount(str)

	ent:CallOnRemove("GetCountUpdate",function(ent,ply,str) ply:GetCount(str,1) end,self,str)
end

function MetaPly:ChatPrint(str)
	net.Start("SA_Message")
		net.WriteString(str)
		net.WriteInt(C_PRINT,4)
	net.Send(self)
end

local PrintMsg = MetaPly.PrintMessage
function MetaPly:PrintMessage(type,str)
	if type == HUD_PRINTTALK then
		net.Start("SA_Message")
			net.WriteString(str)
			net.WriteInt(C_PRINT,4)
		net.Send(self)
	else
		PrintMsg(self,type,str)
	end
end

function GM:PlayerSpawnEffect(ply,mdl)
	return IsOwner(ply)
end

function GM:PlayerSpawnNPC(ply,npc,wep)
	return IsOwner(ply)
end

function GM:PlayerSpawnRagdoll(ply,mdl)
	return IsOwner(ply)
end

function GM:PlayerSpawnSENT(ply,class)
	return IsOwner(ply)
end

function GM:PlayerSpawnSWEP(ply,wep,info)
	return IsOwner(ply)
end

function GM:CanDrive(ply,ent)
	return false
end

function GM:PlayerUse(ply,ent)
	if ent.UseAllowed then return true end
	return CanSomethingDo(ply,ent,"UseAble")
end

function GM:OnPhysgunFreeze(wep,phys,ent,ply)
	self.BaseClass:OnPhysgunFreeze(wep,phys,ent,ply)
	return CanSomethingDo(ply,ent,"PhysGunAble")
end

function GM:CanPlayerUnfreeze(ply,ent,phys)
	return CanSomethingDo(ply,ent,"PhysGunAble")
end

function GM:OnPhysgunReload(s,ply)
	local ent = ply:GetEyeTrace().Entity
	if ent and not CanSomethingDo(ply,ent,"PhysGunAble") then return false end
	ply:PhysgunUnfreeze()
end

function GM:CanTool(ply,tr,tool)
	if tr.HitWorld then return true end
	local ent = tr.Entity
	if not ent then return true end
	return CanSomethingDo(ply,ent,"ConstrainAble")
end

function GM:GravGunPickupAllowed(ply,ent)
	return CanSomethingDo(ply,ent,"PhysGunAble")
end

function GM:GravGunOnPickedUp(ply,ent)
	if ent:GetClass() == "sa_plug" then ent.PlayerHolding = true end
end

function GM:GravGunOnDropped(ply,ent)
	if ent:GetClass() == "sa_plug" then ent.PlayerHolding = false end
end

function GM:PlayerSpawnedProp(ply,mdl,ent)	// Blacklist phx bombs
	ent:SetNWOwner(ply)
end

function GM:PlayerSpawnedVehicle(ply,ent)
	if ent:GetClass() == "prop_vehicle_airboat" or ent:GetClass() == "prop_vehicle_jeep" then
		ent:Remove()
		return
	end
	ent:SetNWOwner(ply)
end

function GM:PlayerSpawnedNPC(ply,ent)
	ent:SetNWOwner(ply)
end

function GM:PlayerSpawnedRagdoll(ply,model,ent)
	ent:SetNWOwner(ply)
end

function GM:PlayerSpawnedSENT(ply,ent)
	ent:SetNWOwner(ply)
end

function GM:OnEntityCreated(ent)
	if not IsValid(ent) then return end
	timer.Simple(0.01,function()
		if not IsValid(ent) then return end
		if IsValid(ent:GetOwner()) and ent:GetOwner():IsPlayer() then ent:SetNWOwner(ent:GetOwner())
		elseif ent.GetPlayer and IsValid(ent:GetPlayer()) then ent:SetNWOwner(ent:GetPlayer()) end
	end)
end

function constraint.GetAllConstrainedEntities(ent,ResultTable)

	local ResultTable = ResultTable or {}

	if  not IsValid(ent) then return end
	if ResultTable[ent:EntIndex()] then return end

	ResultTable[ent:EntIndex()] = ent

	local ConTable = constraint.GetTable(ent)

	for k,con in ipairs(ConTable) do

		for EntNum,Ent in pairs(con.Entity) do
			if Ent.Entity:GetNWEntity("Owner") == ent:GetNWEntity("Owner") then
				constraint.GetAllConstrainedEntities(Ent.Entity,ResultTable)
			elseif Ent.Entity:GetNWEntity("Owner"):IsPlayer() then
				if CanSomethingDo(ent:GetNWEntity("Owner"),Ent.Entity,"ConstrainAble") then
					constraint.GetAllConstrainedEntities(Ent.Entity,ResultTable)
				end
			end
		end

	end

	return ResultTable

end

function constraint.CanConstrain(Ent,Bone)
	if not Ent then return false end
	if not isnumber(Bone) then return false end
	if not Ent:IsWorld() and not Ent:IsValid() then return false end
	if not Ent:GetPhysicsObjectNum(Bone) or not Ent:GetPhysicsObjectNum(Bone):IsValid()	then return false end
	//if game.SinglePlayer() then return true end
	if Ent:IsWorld() then return true end
	
	local Ply	
	for I=1,8 do
		if not debug.getinfo(I) then break end
		local Name,Val = debug.getlocal(I,1)
		if Name == "self" and type(Val) == "table" then
			if Val.GetSWEP then Ply = Val:GetSWEP():GetOwner() break end
			if Val.GetOwner then Ply = Val:GetOwner() break end
			if Val.GetPlayer then Ply = Val:GetPlayer() break end
			if Val.GetNWEntity then Ply = Val:GetNWEntity("Owner") break end
		end
	end
	
	
	if not Ply or not Ply:IsPlayer() then return true end
	if Ent:GetNWEntity("Owner"):IsWorld() then return false end
	if Ent:GetNWEntity("Owner") == Ply then return true end
	if not IsValid(Ent:GetNWEntity("Owner")) then Ent:SetNWOwner(Ply) return true end
	
	return CanSomethingDo(Ply,Ent,"ConstrainAble")
end

function cleanup.CC_AdminCleanup(pl,cmd,args)
	for I,P in pairs(ents.GetAll()) do
		if IsValid(P:GetNWEntity("Owner")) and not P:GetNWEntity("Owner"):IsWorld() then P:Remove() end
	end
end

function cleanup.CC_Cleanup(pl,cmd,args)
	for I,P in pairs(ents.GetAll()) do
		if IsValid(P:GetNWEntity("Owner")) and P:GetNWEntity("Owner") == pl then P:Remove() end
	end
end

local OldCleanup = game.CleanUpMap
function game.CleanUpMap(DontClient,Filters)
	OldCleanup(DontClient,table.Add(Filters,{
		"sa_terminal_screen",
		"sa_asteroid",
		"sa_port",
		"sa_planet"
	}))
end