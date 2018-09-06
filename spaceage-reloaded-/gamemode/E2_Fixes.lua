
hook.Add( "InitPostEntity", "E2_Fixes", function()
	timer.Simple(1,function()
		AdvDupe.AdminSettings.ChangeDisallowedClass( "sa_plug", true, true )
		AdvDupe.AdminSettings.ChangeDisallowedClass( "sa_mining_rawtib_storage", true, true )
		E2Lib.replace_function("isFriend",function(owner,player)
			if owner == nil or not IsValid(player) then return false end
			if owner == player then return true end
			return player.Pliers[owner:SteamID()].ConstrainAble
		end)
		
		E2Lib.replace_function("getOwner",function(self,entity)
			if entity == nil then return end
			if entity == self.entity or entity == self.player then return self.player end
			local P = entity:GetNWEntity("Owner")
			if IsValid(P) and P:IsPlayer() then return P end
			
			if entity.GetPlayer then
				local ply = entity:GetPlayer()
				if IsValid(ply) then return ply end
			end

			local OnDieFunctions = entity.OnDieFunctions
			if OnDieFunctions then
				if OnDieFunctions.GetCountUpdate then
					if OnDieFunctions.GetCountUpdate.Args then
						if OnDieFunctions.GetCountUpdate.Args[1] then return OnDieFunctions.GetCountUpdate.Args[1] end
					end
				end
				if OnDieFunctions.undo1 then
					if OnDieFunctions.undo1.Args then
						if OnDieFunctions.undo1.Args[2] then return OnDieFunctions.undo1.Args[2] end
					end
				end
			end

			if entity.GetOwner then
				local ply = entity:GetOwner()
				if IsValid(ply) then return ply end
			end

			return nil
		end)
		
		local ValidSpawn = PropCore.ValidSpawn
		function PropCore.ValidSpawn()
			if self.player:GetResearch("PropCore_Unlock") == 1 then
				return ValidSpawn()
			end
			return false
		end

		local Forbidden = {
			"sa_tiberium_crystal",
			"sa_tiberium_tower",
			"sa_ice",
			"sa_ice_pump"
		}
		local ValidAction = PropCore.ValidAction
		function PropCore.ValidAction(self, entity, cmd)
			if ValidAction(self,entity,cmd) and not table.HasValue(Forbidden,entity) then
				if entity:GetClass() == "sa_mining_refinery" and entity.Pump then return false end
				return self.player:GetResearch("PropCore_Unlock") == 1
			end
			return false
		end
	end)
end)

if not Applied then
	Applied = true
	local EntsByModel = ents.FindByModel
	local EntsByClass = ents.FindByClass
	local EntsByClassParent = ents.FindByClassAndParent
	local EntsByName = ents.FindByName
	local EntsInSphere = ents.FindInSphere
	local EntsInBox = ents.FindInBox
	local EntsInCone = ents.FindInCone
	local EntsAll = ents.GetAll
	local EntsIndex = ents.GetByIndex
	local Ent = Entity
	TraceLine = util.TraceLine

	local Forbidden = {
		"sa_tiberium_crystal",
		"sa_tiberium_tower",
		"sa_ice",
		"sa_ice_pump"
	}

	function util.TraceLine(Data)
		local Tr = TraceLine(Data)
		if IsValid(Tr.Entity) then
			if table.HasValue(Forbidden,Tr.Entity:GetClass()) then 
				Tr.Entity = nil 
				Tr.Hit = nil
				Tr.HitPos = Data.endpos
			end
		end
		return Tr
	end
	
	function ents.FindByModel(...)
		local Ents = EntsByModel(...)
		if not Ents then return {} end
		local I = #Ents
		while I > 0 do
			if table.HasValue(Forbidden,Ents[I]:GetClass()) then
				table.remove(Ents,I)
			end
			I = I - 1
		end	
		return Ents
	end

	function ents.FindByClass(...)
		local Ents = EntsByClass(...)
		if not Ents then return {} end
		local I = #Ents
		while I > 0 do
			if table.HasValue(Forbidden,Ents[I]:GetClass()) then
				table.remove(Ents,I)
			end
			I = I - 1
		end	
		return Ents
	end

	function ents.FindByClassAndParent(...)
		local Ents = EntsByClassParent(...)
		if not Ents then return {} end
		local I = #Ents
		while I > 0 do
			if table.HasValue(Forbidden,Ents[I]:GetClass()) then
				table.remove(Ents,I)
			end
			I = I - 1
		end	
		return Ents
	end

	function ents.FindByName(...)
		local Ents = EntsByName(...)
		if not Ents then return {} end
		local I = #Ents
		while I > 0 do
			if table.HasValue(Forbidden,Ents[I]:GetClass()) then
				table.remove(Ents,I)
			end
			I = I - 1
		end	
		return Ents
	end

	function ents.FindInSphere(...)
		local Ents = EntsInSphere(...)
		if not Ents then return {} end
		local I = #Ents
		while I > 0 do
			if table.HasValue(Forbidden,Ents[I]:GetClass()) then
				table.remove(Ents,I)
			end
			I = I - 1
		end	
		return Ents
	end

	function ents.FindInBox(...)
		local Ents = EntsInBox(...)
		if not Ents then return {} end
		local I = #Ents
		while I > 0 do
			if table.HasValue(Forbidden,Ents[I]:GetClass()) then
				table.remove(Ents,I)
			end
			I = I - 1
		end	
		return Ents
	end

	function ents.FindInCone(...)
		local Ents = EntsInCone(...)
		if not Ents then return {} end
		local I = #Ents
		while I > 0 do
			if table.HasValue(Forbidden,Ents[I]:GetClass()) then
				table.remove(Ents,I)
			end
			I = I - 1
		end	
		return Ents
	end

	function ents.GetAll(...)
		local Ents = EntsAll(...)
		if not Ents then return {} end
		local I = #Ents
		while I > 0 do
			if table.HasValue(Forbidden,Ents[I]:GetClass()) then
				table.remove(Ents,I)
			end
			I = I - 1
		end	
		return Ents
	end

	function ents.GetByIndex(...)
		local Ent = EntsIndex(...)
		if IsValid(Ent) and table.HasValue(Forbidden,Ent:GetClass()) then
			Ent = nil
		end
		return Ent
	end
	
	function Entity(...)
		local En = Ent(...)
		if IsValid(En) and table.HasValue(Forbidden,En:GetClass()) then
			En = nil
		end
		return En
	end
end