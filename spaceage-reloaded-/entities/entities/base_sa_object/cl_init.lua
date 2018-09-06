include("shared.lua")

SA_TOOLTIPS = {}

hook.Add("HUDPaint","SA_Tooltips",function()
	for I,P in pairs(SA_TOOLTIPS) do
		local X,Y,W,H,Lines,A,TY = P[1],P[2],P[3],P[4],P[5],P[6],P[7]
		draw.RoundedBox(10,X - W / 2,Y - H / 2,W,H,Color(0,0,0,A))
		draw.RoundedBox(8,X + 5 - W / 2,Y + 5 - H / 2,W - 10,H - 10,Color(255,255,255,A))
		for I,P in pairs(Lines) do
			draw.DrawText(P,"Trebuchet24",X,Y - H / 2 + 10 + (TY + 6) * (I - 1),Color(0,0,0,255),TEXT_ALIGN_CENTER)
		end
	end
	SA_TOOLTIPS = {}
end)

concommand.Add("sa_tooltipreset",function(ply,cmd,args,fullstr)
	local Ent
	if #args == 0 then
		Ent = ply:GetEyeTrace().Entity
	else
		Ent = Entity(args[1])
	end
	
	Ent.Nodes = nil
	Ent.Temperature = nil
	Ent.Percent = nil
	Ent.Coverage = nil
	Ent.Port = nil
	Ent.Status = nil
	Ent.Data = nil
	Ent.CheckFor = nil
end)

function ENT:Draw()
	self:DrawModel()
	self:BeforeTooltip()
	if self.Data and LocalPlayer():GetEyeTrace().Entity == self and LocalPlayer():EyePos():Distance(self:GetPos()) < 256 then
		//AddWorldTip(nil,self.Data,nil,self:GetPos(),self)
		surface.SetFont("Trebuchet24")
		local Lines = self:GetData()
		local T,Y = 0
		for I,P in pairs(Lines) do
			if T < surface.GetTextSize(Lines[I]) then T,Y = surface.GetTextSize(Lines[I]) end
		end
		local W,H = 20 + T,(10 + Y) * #Lines
		
		local Min,Max = self:WorldSpaceAABB()
		Pos = Min + (Max - Min) / 2
		local Distance = Pos:Distance(LocalPlayer():GetPos())
		local A
		
		if Distance > 200 and Distance < 256 then
			local Distance = 1 - ((Distance - 200) / 56)
			A = 255 * Distance
		elseif Distance > 250 then
			A = 0
		else
			A = 255
		end
		
		if A <= 0 then return end
		
		local ScrnPos = Pos:ToScreen()
		table.insert(SA_TOOLTIPS,{ScrnPos.x,ScrnPos.y,W,H,Lines,A,Y})
	end
end

function ENT:GetData()
	local T = {}
	if self:GetNWString("ScreenName") ~= "" then
		table.insert(T,self:GetNWString("ScreenName"))
	else
		table.insert(T,self.ScreenName)
	end
	if self.Nodes and #self.Nodes > 0 then
		for I,P in pairs(self.Nodes) do
			table.insert(T,"Connected to Node #"..P)
		end
	end
	
	if self.Temperature and self.Temperature > 0 then
		table.insert(T,"Temperature: "..self.Temperature)
	end
	
	if self.Port then
		table.insert(T,"Status: "..PORT_STATUS[self.Port])
		if self.ConnectedPort then
			table.insert(T,"Connected to Socket #"..self.ConnectedPort)
		end
	end
	
	if self.Status ~= nil then
		local Stat = self.Status
		if self.Status ~= self:GetNWBool("Online") then
			Stat = self:GetNWBool("Online")
		end
		if Stat then
			table.insert(T,"Status: Online")
		else
			table.insert(T,"Status: Offline")
		end
	end
	
	if self.Coverage and self.Status then
		table.insert(T,"Coverage: "..self.Coverage.."%")
	end
	
	if self.Percent and self.Status then
		table.insert(T,"Cycle: "..self.Percent.."%")
	end
	
	if self.Data.Storage then
		for I,P in pairs(self.Data.Storage) do
			table.insert(T,I..": "..P[1].." / "..P[2])
		end
	end
	
	if self:GetClass() == "sa_generator_water" or self:GetClass() == "sa_generator_hydro" then
		local Wat = {[0] = "Not in water",[1] = "Slightly in water, go deeper!",[2] = "Majorly in water, still deeper!",[3] = "Completely submerged"}
		table.insert(T,Wat[self:WaterLevel()])
	elseif self:WaterLevel() > 0 then
		table.insert(T,"Submerged! Get it up!")
	end
	
	if self.Data.Outputs and next(self.Data.Outputs) then
		table.insert(T,"###OUTPUTS###")
		for I,P in pairs(self.Data.Outputs) do
			table.insert(T,I..": "..P[1].." / "..P[2])
		end
	end
	
	if self.Data.Inputs and next(self.Data.Inputs) then
		table.insert(T,"###INPUTS###")
		for I,P in pairs(self.Data.Inputs) do
			table.insert(T,I..": "..P[1].." / "..P[2])
		end
	end
	
	if self.Data.Node and next(self.Data.Node) then
		table.insert(T,"Resources on this network:")
		for I,P in pairs(self.Data.Node) do
			table.insert(T,I..": "..P[1].." / "..P[2])
		end
	end
	
	return T
end

function ENT:BeforeTooltip()
end

function ENT:Think()
	self:SetNextClientThink(CurTime() + (self.NextThnk or 0.5))
	
	if LocalPlayer():GetEyeTrace().Entity == self and LocalPlayer():EyePos():Distance(self:GetPos()) < 256 then
		net.Start("SA_ObjectLooked")
		net.SendToServer()
	end
	
	return true
end

function ENT:OnRemove()
	self.Data = nil
	self.CheckFor = nil
	self.Temperature = nil
	self.Percent = nil
	self.Coverage = nil
	self.Status = nil
	self.Nodes = nil
	self.Port = nil
	self.ConnectedPort = nil
end

net.Receive("SA_ObjectLookedReceive",function(len)
	local Ent = net.ReadEntity()
	if not IsValid(Ent) then return end
	//print(tostring(Ent).."'s Info")
	//print("Packet Size: "..len.." bits")
	if not Ent.Data then
		Ent.Data = {}
		Ent.CheckFor = {}
	end
	
	local B = net.ReadUInt(4)
	while B > 0 do
		if B == S_TEMPERATURE then
			Ent.Temperature = math.floor(net.ReadFloat() * 100) / 100
			if not table.HasValue(Ent.CheckFor,S_TEMPERATURE) then table.insert(Ent.CheckFor,S_TEMPERATURE) end
		elseif B == S_PERCENT then
			Ent.Percent = net.ReadUInt(8)
			if not table.HasValue(Ent.CheckFor,S_PERCENT) then table.insert(Ent.CheckFor,S_PERCENT) end
		elseif B == S_COVERAGE then
			Ent.Coverage = net.ReadUInt(8)
			if not table.HasValue(Ent.CheckFor,S_COVERAGE) then table.insert(Ent.CheckFor,S_COVERAGE) end
		elseif B == S_STATUS then
			Ent.Status = net.ReadBit() == 1
			if not table.HasValue(Ent.CheckFor,S_STATUS) then table.insert(Ent.CheckFor,S_STATUS) end
		elseif B == S_NODE then
			Ent.Nodes = {}
			local Size = net.ReadUInt(4)
			if Size > 0 then 
				for I = 1,Size do
					local Int = net.ReadUInt(16)
					if Int > 0 then table.insert(Ent.Nodes,Int) end
				end
			end
			if not table.HasValue(Ent.CheckFor,S_NODE) then table.insert(Ent.CheckFor,S_NODE) end
		elseif B == S_STORAGE then
			if not Ent.Data.Storage then Ent.Data.Storage = {} end
			while net.ReadBit() == 1 do
				local Res = net.ReadUInt(8)
				local Val = net.ReadUInt(32)
				local Max = net.ReadUInt(32)
				if Res > 0 then
					Ent.Data.Storage[Resources[Res]] = {Val,Max}
				end
			end
			if not table.HasValue(Ent.CheckFor,S_STORAGE) then table.insert(Ent.CheckFor,S_STORAGE) end
		elseif B == S_PORT then
			Ent.Port = net.ReadUInt(4)
			if not table.HasValue(Ent.CheckFor,S_PORT) then table.insert(Ent.CheckFor,S_PORT) end
		elseif B == S_CONNECTEDPORT then
			Ent.ConnectedPort = net.ReadUInt(16)
			if Ent.ConnectedPort == 0 then Ent.ConnectedPort = nil end
			if not table.HasValue(Ent.CheckFor,S_CONNECTEDPORT) then table.insert(Ent.CheckFor,S_CONNECTEDPORT) end
		elseif B == S_INPUTS then
			if not Ent.Data.Inputs then Ent.Data.Inputs = {} end
			while net.ReadBit() == 1 do
				local Res = net.ReadUInt(8)
				local Val = 0
				local Max = 0
				if net.ReadBit() == 1 then
					Val = net.ReadUInt(32)
					Max = net.ReadUInt(32)
				end
				Ent.Data.Inputs[Resources[Res]] = {Val,Max}
			end
			if not table.HasValue(Ent.CheckFor,S_INPUTS) then table.insert(Ent.CheckFor,S_INPUTS) end
		elseif B == S_OUTPUTS then
			if not Ent.Data.Outputs then Ent.Data.Outputs = {} end
			while net.ReadBit() == 1 do
				local Res = net.ReadUInt(8)
				local Val = 0
				local Max = 0
				if net.ReadBit() == 1 then
					Val = net.ReadUInt(32)
					Max = net.ReadUInt(32)
				end
				Ent.Data.Outputs[Resources[Res]] = {Val,Max}
			end
			if not table.HasValue(Ent.CheckFor,S_OUTPUTS) then table.insert(Ent.CheckFor,S_OUTPUTS) end
		elseif B == S_NODERESOURCE then
			if not Ent.Data.Node then Ent.Data.Node = {} end
			local I = 0
			while net.ReadBit() == 1 do
				I = I + 1
				local Res = net.ReadUInt(8)
				local Val = net.ReadUInt(32)
				local Max = net.ReadUInt(32)
				if Max == 0 then
					Ent.Data.Node[Resources[Res]] = nil
				else
					//print(Res)
					//print(Val)
					//print(Max)
					Ent.Data.Node[Resources[Res]] = {Val,Max}
				end
			end
			if I == 0 then Ent.Data.Node = {} end
			if not table.HasValue(Ent.CheckFor,S_NODERESOURCE) then table.insert(Ent.CheckFor,S_NODERESOURCE) end
		end		
		//print("State: "..B)
		B = net.ReadUInt(4)
	end
	
	net.Start("SA_ObjectLookedConfirm")
		net.WriteEntity(Ent)
		for I,P in pairs(Ent.CheckFor) do
			net.WriteBit(true)
			net.WriteUInt(P,4)
		end
		net.WriteBit(false)
	net.SendToServer()
end)

net.Receive("SA_ObjectLookedUpdate",function(len)
	local Ent = net.ReadEntity()
	if not IsValid(Ent) then return end
	if not Ent.CheckFor then
		net.Start("SA_ObjectLookedConfirm")
			net.WriteEntity(Ent)
			net.WriteBit(false)
		net.SendToServer()
		return
	end
	//Queue = {}
	//PrintTable(Ent.CheckFor)
	local B = net.ReadUInt(4,true)
	local V = 0
	while B > 0 do
		if B == S_TEMPERATURE and table.HasValue(Ent.CheckFor,S_TEMPERATURE) then
			Ent.Temperature = math.floor(net.ReadFloat() * 100) / 100
			//print("Temperature: "..Ent.Temperature)
			V = Ent.Temperature
		elseif B == S_PERCENT and table.HasValue(Ent.CheckFor,S_PERCENT) then
			Ent.Percent = net.ReadUInt(8)
			V = Ent.Percent
		elseif B == S_COVERAGE and table.HasValue(Ent.CheckFor,S_COVERAGE) then
			Ent.Coverage = net.ReadUInt(8)
			V = Ent.Coverage
		elseif B == S_STATUS and table.HasValue(Ent.CheckFor,S_STATUS) then
			Ent.Status = net.ReadBit() == 1
			V = Ent.Status
		elseif B == S_NODE and table.HasValue(Ent.CheckFor,S_NODE) then
			local Size = net.ReadUInt(4)
			for I = 1,Size do
				local Int = net.ReadUInt(16)
				if Int > 0 then table.insert(Ent.Nodes,net.ReadUInt(16)) end
			end
			V = Ent.Nodes
		elseif B == S_STORAGE and table.HasValue(Ent.CheckFor,S_STORAGE) then
			if not Ent.Data.Storage then Ent.Data.Storage = {} end
			while net.ReadBit() == 1 do
				local Res = net.ReadUInt(8)
				local Val = net.ReadUInt(32)
				//print("Resource Name: "..Res)
				//print("Resource Value: "..Val)
				if not Ent.Data.Storage[Resources[Res]] then
					net.Start("SA_ObjectLookedConfirm")
						net.WriteEntity(Ent)
						for I,P in pairs(Ent.CheckFor) do
							net.WriteBit(true)
							net.WriteUInt(P,4)
						end
						net.WriteBit(false)
					net.SendToServer()
					return false
				end
				Ent.Data.Storage[Resources[Res]][1] = Val
			end
			V = Ent.Data.Storage
		elseif B == S_PORT and table.HasValue(Ent.CheckFor,S_PORT) then
			Ent.Port = net.ReadUInt(4)
			V = Ent.Port
		elseif B == S_CONNECTEDPORT and table.HasValue(Ent.CheckFor,S_CONNECTEDPORT) then
			Ent.ConnectedPort = net.ReadUInt(16)
			V = Ent.ConnectedPort
			if Ent.ConnectedPort == 0 then Ent.ConnectedPort = nil end
		elseif B == S_INPUTS and table.HasValue(Ent.CheckFor,S_INPUTS) then
			local IB = net.ReadBit() == 1
			while IB do
				local Res = net.ReadUInt(8)
				local Val = 0
				if net.ReadBit() == 1 then
					Val = net.ReadUInt(32)
				end
				Ent.Data.Inputs[Resources[Res]][1] = Val
				IB = net.ReadBit() == 1
			end
			V = Ent.Data.Inputs
		elseif B == S_OUTPUTS and table.HasValue(Ent.CheckFor,S_OUTPUTS) then
			local OB = net.ReadBit() == 1
			while OB do
				local Res = net.ReadUInt(8)
				//print("Resource Name: "..Res)
				local Val = 0
				if net.ReadBit() == 1 then
					Val = net.ReadUInt(32)
				end
				//print("Resource value: "..Val)
				Ent.Data.Outputs[Resources[Res]][1] = Val
				OB = net.ReadBit() == 1
			end
			V = Ent.Data.Outputs
		elseif B == S_NODERESOURCE and table.HasValue(Ent.CheckFor,S_NODERESOURCE) then
			local Size = net.ReadUInt(4)
			//print("Size: "..Size)
			for I = 1,Size do
				local Res = net.ReadUInt(8)
				local Val = net.ReadUInt(32)
				//print("Resource Name: "..Res)
				//print("Resource Value: "..Val)
				if not Ent.Data.Node[Resources[Res]] then Ent.Data.Node[Resources[Res]] = {0,0} end
				Ent.Data.Node[Resources[Res]][1] = Val
			end
			V = Ent.Data.Node
		end		
		/*print("Updated state: "..B)
		if type(V) == "table" then
			print("Table: ")
			PrintTable(V)
		else
			print("Value: "..tostring(V))
		end*/
		B = net.ReadUInt(4,true)
	end
	
	//PrintTable(Queue)
end)