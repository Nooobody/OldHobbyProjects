TOOL.Mode 		= "sa_rd_link"
TOOL.Tab 		= "SA"
TOOL.Category 	= "RD"
TOOL.Name		= "Link Tool"
TOOL.Command	= nil
TOOL.ConfigName	= ""

if CLIENT then
	language.Add( "tool.sa_rd_link.name", "Link Tool" )
	language.Add( "tool.sa_rd_link.desc", "Left-Click to select RD objects. Right-click to link to a node. Reload to erase all links on an object." )
	language.Add( "tool.sa_rd_link.0", "Left Click: Link Devices. Reload: Unlink Device from All." )
	language.Add( "tool.sa_rd_link.1", "Left Click: Link/Unlink Devices. Reload: Unlink Device from All. Right-Click on a Node." )
end

function TOOL:LeftClick(trace)
	if !trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	
	E = trace.Entity
	if not E.sa_ent and not E:IsVehicle() then return end
	if not CanSomethingDo(self:GetOwner(),E,"ConstrainAble") then return false end
	
	self:SetObject(self:NumObjects() + 1,E,trace.HitPos,trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone ), trace.PhysicsBone, trace.HitNormal)
	E:SetColor(Color(0,200,0))

	self:SetStage(1)
	return true
end

function TOOL:RightClick(trace)
	if !trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	
	E = trace.Entity
	if not E.Class or (E.Class ~= "LS" and E.Class ~= "RD") then return end
	
	if E.SubClass == "Node" then
		local Ents = {}
		for I = 1,self:NumObjects() do
			local DontUpdate = true
			if I == self:NumObjects() then DontUpdate = false end
			local e = self:GetEnt(I)
			if e:IsVehicle() then
				E:Link(e,DontUpdate)
			elseif not table.HasValue(Ents,e) and e ~= E then
				table.insert(Ents,e)
				table.insert(Ents,E)
				E:Link(e,DontUpdate)
			end
			e:SetColor(Color(255,255,255))
		end
	else
		return false
	end
	
	self:ClearObjects()
	self:SetStage(0)
	
	return true
end

function TOOL:Holster()
	for I = 1,self:NumObjects() do
		local Ent = self:GetEnt(I)
		if IsValid(Ent) then self:GetEnt(I):SetColor(Color(255,255,255)) end
	end
	self:ClearObjects()
end

function TOOL:Reload(trace)
	if !trace.HitPos then return false end
	if trace.Entity:IsPlayer() then return false end
	if CLIENT then return true end
	
	E = trace.Entity
	if not E.sa_ent and not E:IsVehicle() then return end
	if not CanSomethingDo(self:GetOwner(),E,"ConstrainAble") then return false end
	
	for I = 1,#E.Links do
		E:Unlink(E.Links[1])
	end
	return true
end

function TOOL.BuildCPanel(Panel)
end

