
util.AddNetworkString("SA_ObjectLooked")
util.AddNetworkString("SA_ObjectLookedReceive")
util.AddNetworkString("SA_ObjectLookedUpdate")
util.AddNetworkString("SA_ObjectLookedConfirm")

local function State(Sta,Str)
	//print("State: "..Str)
	net.WriteUInt(Sta,4)
end
/*
local Queue = {}

local NWUI = net.WriteUInt
function net.WriteUInt(Val,Bits,State)
	local Str = "Value"
	if State then Str = "State" end
	table.insert(Queue,{Val,Bits,Str,debug.traceback()})
	NWUI(Val,Bits)
end

local NWB = net.WriteBit
function net.WriteBit(Val)
	table.insert(Queue,{Val,debug.traceback()})
	NWB(Val)
end

local NWF = net.WriteFloat
function net.WriteFloat(Val)
	table.insert(Queue,Val)
	NWF(Val)
end
*/
local Tab = {"Status","Temperature","Nodes","Storage","Port","ConnectedPort","NodeResource","Inputs","Outputs"}
net.Receive("SA_ObjectLookedConfirm",function(len,ply)
	local Ent = net.ReadEntity()
	if not Ent.SentData or not Ent.SentData[ply:EntIndex()] then return end
	local T = {}
	while net.ReadBit() == 1 do
		table.insert(T,Tab[net.ReadUInt(4)])
	end
	
	if #T == 0 then 
		Ent.SentData[ply:EntIndex()].NeedsUpdate = true
		return
	end
	
	local Checks = true
	for I,P in pairs(Ent.SentData[ply:EntIndex()]) do
		if table.HasValue(Tab,I) and not table.HasValue(T,I) then Checks = false end
	end
	
	if not Checks then
		Ent.SentData[ply:EntIndex()].NeedsUpdate = true
	end
end)


function ENT:SendResData(ply,name,data)
	local ty = S_ENTDATA[name]
	local Spl = string.Split(ty.type,"_")
	if ty.type[1] == "A" then
		if ty.type[2] == "Node" then
			if not self.SentData[ply:EntIndex()][ty.name] then self.SentData[ply:EntIndex()][ty.name] = {} end
			if #self.SentData[ply:EntIndex()][ty.name] ~= #data or self.SentData[ply:EntIndex()][ty.name] ~= data then
				self.SentData[ply:EntIndex()][ty.name] = data
				State(name)
				net.WriteUInt(#data,4)
				for I,P in pairs(data) do
					net.WriteUInt(P:EntIndex(),16)
				end
			end
		elseif ty.type[2] == "NodeRes" then
			local Stor = {}
			for I,P in pairs(data) do
				if next(P.Storage) then
					for i,p in pairs(P.Storage) do
						if not Stor[i] then Stor[i] = {0,0} end
						Stor[i][1] = Stor[i][1] + p
						Stor[i][2] = Stor[i][2] + P.StorageMax[i]
					end
				end
			end
			
			if not self.SentData[ply:EntIndex()][ty.name] then self.SentData[ply:EntIndex()][ty.name] = {} end
			if #self.SentData[ply:EntIndex()][ty.name] ~= #Stor or self.SentData[ply:EntIndex()][ty.name] ~= Stor then
				State(name)
				for I,P in pairs(self.SentData[ply:EntIndex()][ty.name]) do
					if not table.HasKey(Stor,I) then
						self.SentData[ply:EntIndex()][ty.name][I] = nil
						net.WriteBit(true)
						net.WriteUInt(table.KeyFromValue(Resources,I),8)
						net.WriteUInt(0,32)
						net.WriteUInt(0,32)
					end
				end
				
				for I,P in pairs(Stor) do
					if not self.SentData[ply:EntIndex()][ty.name][I] or
					   self.SentData[ply:EntIndex()][ty.name][I][1] ~= P[1] or 
					   self.SentData[ply:EntIndex()][ty.name][I][2] ~= P[2] then
						self.SentData[ply:EntIndex()][ty.name][I] = P
						net.WriteBit(true)
						net.WriteUInt(table.KeyFromValue(Resources,I),8)
						net.WriteUInt(P[1],32)
						net.WriteUInt(P[2],32)
					end
				end
				
				net.WriteBit(false)
			end
		elseif ty.type[2] == "Res" then
			State(name)
			for I,P in pairs(self.SentData[ply:EntIndex()][ty.name]) do
				if not table.HasKey(data,I) then
					self.SentData[ply:EntIndex()][ty.name][I] = nil
					net.WriteBit(true)
					net.WriteUInt(table.KeyFromValue(Resources,I),8)
					net.WriteBit(false)
				end
			end
			
			for I,P in pairs(data) do
				if not self.SentData[ply:EntIndex()][ty.name][I] or 
				   self.SentData[ply:EntIndex()][ty.name][I][1] ~= data.[I][1] or 
				   self.SentData[ply:EntIndex()][ty.name][I][2] ~= data.[I][2] then
					self.SentData[ply:EntIndex()][ty.name][I] = data[I]
					net.WriteBit(true)
					net.WriteUInt(table.KeyFromValue(Resources,I),8)
					net.WriteBit(true)
					net.WriteUInt(data[I][1],32)
					net.WriteUInt(data[I][2],32)
				end
			end
			net.WriteBit(false)
		end
	else
		if self.SentData[ply:EntIndex()][ty.name] ~= data then
			self.SentData[ply:EntIndex()][ty.name] = data
			State(name)
			if ty.type == "Bit" then			
				net.WriteBit(data)
			elseif ty.type == "Float" then
				net.WriteFloat(data)
			elseif Spl[1] == "UInt" then
				net.WriteUInt(data,Spl[2])
			end
		end
	end
end

net.Receive("SA_ObjectLooked",function(len,ply)
	local Ent = ply:GetEyeTrace().Entity
	if not IsValid(Ent) or not Ent.sa_ent or Ent.SpawnCD > CurTime() or Ent:GetClass() == "sa_atmosphere_probe" then return end
	
	if not Ent.SentData[ply:EntIndex()] or Ent.SentData[ply:EntIndex()].NeedsUpdate then
		//print(tostring(Ent).."'s info has been updated!")
		net.Start("SA_ObjectLookedReceive")
			net.WriteEntity(Ent)
			if not Ent.SentData[ply:EntIndex()] then Ent.SentData[ply:EntIndex()] = {} end
			
			if Ent.Coolant then
				Ent:SendResData(ply,S_TEMPERATURE,Ent.Temperature)
				/*if Ent.SentData[ply:EntIndex()].Temperature ~= Ent.Temperature then
					State(S_TEMPERATURE,"Temperature")
					net.WriteFloat(Ent.Temperature)
					Ent.SentData[ply:EntIndex()].Temperature = Ent.Temperature
				end*/
			end
			
			if Ent.Coverage then
				Ent:SendResData(ply,S_COVERAGE,math.Round(Ent.Coverage * 100))
				/*if Ent.SentData[ply:EntIndex()].Coverage ~= Ent.Coverage then
					State(S_COVERAGE,"Coverage")
					net.WriteUInt(math.Round(Ent.Coverage * 100),8)
					Ent.SentData[ply:EntIndex()].Coverage = Ent.Coverage
				end*/
			end
			
			if Ent.SubClass == "Port" then
				SendResData(ply,S_PORT,Ent.Status)
				/*
				if Ent.SentData[ply:EntIndex()].Port ~= Ent.Status then
					State(S_PORT,"Port")
					net.WriteUInt(Ent.Status,4)
					Ent.SentData[ply:EntIndex()].Port = Ent.Status
				end*/
				if Ent.ConnectedSocket then
					SendResData(ply,S_CONNECTEDPORT,Ent.ConnectedSocket:EntIndex())
				else
					SendResData(ply,S_CONNECTEDPORT,0)
				end
				/*
				if Ent.ConnectedSocket and Ent.SentData[ply:EntIndex()].ConnectedPort ~= Ent.ConnectedSocket:EntIndex() then
					State(S_CONNECTEDPORT,"ConnectedPort Update")
					net.WriteUInt(Ent.ConnectedSocket:EntIndex(),16)
					Ent.SentData[ply:EntIndex()].ConnectedPort = Ent.ConnectedSocket:EntIndex()
				elseif not Ent.ConnectedSocket and Ent.SentData[ply:EntIndex()].ConnectedPort ~= 0 then
					State(S_CONNECTEDPORT,"ConnectedPort Zeroed")
					net.WriteUInt(0,16)
					Ent.SentData[ply:EntIndex()].ConnectedPort = 0
				end*/
			end
			
			if next(Ent.ROutputs) or next(Ent.RInputs) or Ent.Class == "LS" then
				SendResData(ply,S_STATUS,Ent.Online)
			end
			
			if next(Ent.ROutputs) or Ent.Class == "LS" then
				if Ent.StoredLinks.Outputs then
					local Stor = {}
					for I,P in pairs(Ent.StoredLinks.Outputs) do
						if not Stor[I] then Stor[I] = {0,0} end
						if IsValid(P[1]) then
							local S = P[1]:UpdateStorage()
							Stor[I][1] = Stor[I][1] + S[1]
							Stor[I][2] = Stor[I][2] + S[2]
						else
							Stor[I][1] = 0
							Stor[I][1] = 0
						end
					end
					
					SendResData(ply,S_OUTPUTS,Stor)
				end
			end
			/*if next(Ent.ROutputs) or next(Ent.RInputs) or Ent.Class == "LS" then
				
				if (not Ent.SentData[ply:EntIndex()].Status or Ent.SentData[ply:EntIndex()].Status ~= Ent.Online) and Ent.SubClass ~= "Port" then
					State(S_STATUS,"Status")
					net.WriteBit(Ent.Online)
					Ent.SentData[ply:EntIndex()].Status = Ent.Online
				end
				State(S_OUTPUTS,"Outputs")
				if not Ent.SentData[ply:EntIndex()].Outputs then Ent.SentData[ply:EntIndex()].Outputs = {} end
				if not Ent.SentData[ply:EntIndex()].Inputs then Ent.SentData[ply:EntIndex()].Inputs = {} end
				local I,N = next(Ent.StoredLinks.Outputs)
				if I and #N > 0 then
					for I,P in pairs(Ent.StoredLinks.Outputs) do
						if #P > 0 then
							local Stor = P[1]:UpdateStorage()
							//print("Stor: ")
							//PrintTable(Stor)
							if Stor[1] then
								net.WriteBit(true)
								net.WriteUInt(table.KeyFromValue(Resources,I),8,"Resource")
								net.WriteBit(true)
								net.WriteUInt(Stor[1],32,"Value")
								net.WriteUInt(Stor[2],32,"Max")
								Ent.SentData[ply:EntIndex()].Outputs[I] = Stor
							elseif Stor[I] and (not Ent.SentData[ply:EntIndex()].Outputs[I] or 
									(#Ent.StoredLinks.Outputs[I] > 0 and Ent.SentData[ply:EntIndex()].Outputs[I][2] == 0) or 
									(#Ent.StoredLinks.Outputs[I] == 0 and Ent.SentData[ply:EntIndex()].Outputs[I][2] > 0) or
									Ent.SentData[ply:EntIndex()].Outputs[I] ~= Stor[I][2]) then 
								net.WriteBit(true)
								net.WriteUInt(table.KeyFromValue(Resources,I),8,"Resource")
								net.WriteBit(true)
								net.WriteUInt(Stor[I][1],32,"Value")
								net.WriteUInt(Stor[I][2],32,"Max")
								Ent.SentData[ply:EntIndex()].Outputs[I] = Stor[I]
							end
						else
							if not Ent.SentData[ply:EntIndex()].Outputs[I] or Ent.SentData[ply:EntIndex()].Outputs[I][2] > 0 then
								net.WriteBit(true)
								net.WriteUInt(table.KeyFromValue(Resources,I),8,"Resource")
								net.WriteBit(false)
								Ent.SentData[ply:EntIndex()].Outputs[I] = {0,0}
							end
						end
					end
				else
					for I,P in pairs(Ent.ROutputs) do
						if not Ent.SentData[ply:EntIndex()].Outputs[I] or Ent.SentData[ply:EntIndex()].Outputs[I][2] > 0 then
							net.WriteBit(true)
							net.WriteUInt(table.KeyFromValue(Resources,I),8,"Resource")
							net.WriteBit(false)
							Ent.SentData[ply:EntIndex()].Outputs[I] = {0,0}
						end
					end
				end
				
				net.WriteBit(false)*/
				local I,N = next(Ent.StoredLinks.Inputs)
				if I and #N > 0 then
					State(S_INPUTS,"Inputs Stored")
					for I,P in pairs(Ent.StoredLinks.Inputs) do
						if #P > 0 then
							local Stor = P[1]:UpdateStorage()
							if Stor[1] then
								net.WriteBit(true)
								net.WriteUInt(table.KeyFromValue(Resources,I),8,"Resource")
								net.WriteBit(true)
								net.WriteUInt(Stor[1],32,"Value")
								net.WriteUInt(Stor[2],32,"Max")
								Ent.SentData[ply:EntIndex()].Inputs[I] = Stor
							elseif Stor[I] and (not Ent.SentData[ply:EntIndex()].Inputs[I] or 
									(#Ent.StoredLinks.Inputs[I] > 0 and Ent.SentData[ply:EntIndex()].Inputs[I][2] == 0) or 
									(#Ent.StoredLinks.Inputs[I] == 0 and Ent.SentData[ply:EntIndex()].Inputs[I][2] > 0) or
									Ent.SentData[ply:EntIndex()].Inputs[I] ~= Stor[I][2]) then 
								net.WriteBit(true)
								net.WriteUInt(table.KeyFromValue(Resources,I),8)
								net.WriteBit(true)
								net.WriteUInt(Stor[I][1],32)
								net.WriteUInt(Stor[I][2],32)
								Ent.SentData[ply:EntIndex()].Inputs[I] = Stor[I]
							end
						else
							if not Ent.SentData[ply:EntIndex()].Inputs[I] or Ent.SentData[ply:EntIndex()].Inputs[I][2] > 0 then
								net.WriteBit(true)
								net.WriteUInt(table.KeyFromValue(Resources,I),8)
								net.WriteBit(false)
								Ent.SentData[ply:EntIndex()].Inputs[I] = {0,0}
							end
						end
					end
					net.WriteBit(false)
				elseif next(Ent.RInputs) then
					State(S_INPUTS,"Inputs Zeroed")
					for I,P in pairs(Ent.RInputs) do
						if not Ent.SentData[ply:EntIndex()].Inputs[I] or Ent.SentData[ply:EntIndex()].Inputs[I][2] > 0 then
							net.WriteBit(true)
							net.WriteUInt(table.KeyFromValue(Resources,I),8)
							net.WriteBit(false) 
							Ent.SentData[ply:EntIndex()].Inputs[I] = {0,0}
						end
					end
					net.WriteBit(false)
				end
			end
			
			if Ent.SubClass == "Storage" then
				local Stor = Ent:UpdateStorage()
				State(S_STORAGE,"Storage")
				if not Ent.SentData[ply:EntIndex()].Storage then Ent.SentData[ply:EntIndex()].Storage = {} end
				if not Stor[1] then
					for I,P in pairs(Ent.Storage) do
						if not Ent.SentData[ply:EntIndex()].Storage[I] or 
						(Ent.SentData[ply:EntIndex()].Storage[I][2] ~= Stor[I][2] and Stor[I][2] > 0) or
						(Ent.SentData[ply:EntIndex()].Storage[I][2] ~= Ent.StorageMax[I] and Stor[I][2] == 0) then 
							net.WriteBit(true)
							net.WriteUInt(table.KeyFromValue(Resources,I),8)
							if Stor[I][2] > 0 then
								net.WriteUInt(Stor[I][1],32)
								net.WriteUInt(Stor[I][2],32)
								Ent.SentData[ply:EntIndex()].Storage[I] = Stor[I]
							else
								net.WriteUInt(P,32)
								net.WriteUInt(Ent.StorageMax[I],32)
								Ent.SentData[ply:EntIndex()].Storage[I] = {P,Ent.StorageMax[I]}
							end
						end
					end
				end
				net.WriteBit(false)
			end
			
			if Ent.SubClass == "Node" then
				local Stor = {}
				for I,P in pairs(Ent.Links) do
					if P.SubClass == "Storage" then
						for i,p in pairs(P.Storage) do
							if not Stor[i] then
								Stor[i] = {}
								Stor[i].Storage = p
								Stor[i].StorageMax = P.StorageMax[i]
							else
								Stor[i].Storage = Stor[i].Storage + p
								Stor[i].StorageMax = Stor[i].StorageMax + P.StorageMax[i]
							end
						end
					end
				end
				
				if next(Stor) then
					if not Ent.SentData[ply:EntIndex()].NodeRes then Ent.SentData[ply:EntIndex()].NodeRes = {} end
					State(S_NODERESOURCE,"NodeResource Creation")
					for I,P in pairs(Stor) do
						if not Ent.SentData[ply:EntIndex()].NodeRes[I] or 
							Ent.SentData[ply:EntIndex()].NodeRes[I][1] ~= P.Storage or 
							Ent.SentData[ply:EntIndex()].NodeRes[I][2] ~= P.StorageMax then
							net.WriteBit(true)
							net.WriteUInt(table.KeyFromValue(Resources,I),8)
							net.WriteUInt(P.Storage,32)
							net.WriteUInt(P.StorageMax,32)
							Ent.SentData[ply:EntIndex()].NodeRes[I] = {P.Storage,P.StorageMax}
						end
					end
					
					for I,P in pairs(Ent.SentData[ply:EntIndex()].NodeRes) do
						if not table.HasKey(Stor,I) then
							net.WriteBit(true)
							net.WriteUInt(table.KeyFromValue(Resources,I),8)
							net.WriteUInt(0,32)
							net.WriteUInt(0,32)
							Ent.SentData[ply:EntIndex()].NodeRes[I] = nil
						end
					end
					net.WriteBit(false)
				else
					State(S_NODERESOURCE,"NodeResource Zeroed")
					if not Ent.SentData[ply:EntIndex()].NodeRes then
						net.WriteBit(false)
					else
						for I,P in pairs(Ent.SentData[ply:EntIndex()].NodeRes) do
							net.WriteBit(true)
							net.WriteUInt(table.KeyFromValue(Resources,I),8)
							net.WriteUInt(0,32)
							net.WriteUInt(0,32)
							Ent.SentData[ply:EntIndex()].NodeRes[I] = nil
						end
						net.WriteBit(false)
					end
				end
			else
				if #Ent.Links > 0 then
					if Ent.SentData[ply:EntIndex()].Nodes ~= Ent.Links then
						State(S_NODE,"Nodes Found")
						net.WriteUInt(#Ent.Links,4,"NodeAmount")
						for I,P in pairs(Ent.Links) do
							net.WriteUInt(P:EntIndex(),16)
						end
						Ent.SentData[ply:EntIndex()].Nodes = Ent.Links
					end
				else
					State(S_NODE,"Nodes Zeroed")
					net.WriteUInt(0,4,"NodeAmount")
					Ent.SentData[ply:EntIndex()].Nodes = nil
				end
			end
		net.WriteUInt(0,4,"End")
		net.Send(ply)
		Ent.SentData[ply:EntIndex()].NeedsUpdate = false
	else
		Queue = {}
		local DoSent = false
		net.Start("SA_ObjectLookedUpdate")
			net.WriteEntity(Ent)
			if Ent.Coolant then
				if Ent.SentData[ply:EntIndex()].Temperature ~= Ent.Temperature then
					DoSent = true
					State(S_TEMPERATURE,"Temperature Update")
					net.WriteFloat(Ent.Temperature)
					Ent.SentData[ply:EntIndex()].Temperature = Ent.Temperature
				end
			end
			
			if Ent.Coverage then
				if Ent.SentData[ply:EntIndex()].Coverage ~= Ent.Coverage then
					DoSent = true
					State(S_COVERAGE,"Coverage")
					net.WriteUInt(math.Round(Ent.Coverage * 100),8)
					Ent.SentData[ply:EntIndex()].Coverage = Ent.Coverage
				end
			end
			
			if Ent.SubClass == "Port" then
				if Ent.SentData[ply:EntIndex()].Port ~= Ent.Status then
					DoSent = true
					State(S_PORT,"Port Update")
					net.WriteUInt(Ent.Status,4)
					Ent.SentData[ply:EntIndex()].Port = Ent.Status
				end
				if Ent.ConnectedSocket and Ent.SentData[ply:EntIndex()].ConnectedPort ~= Ent.ConnectedSocket:EntIndex() then
					DoSent = true
					State(S_CONNECTEDPORT,"Connected Port Update")
					net.WriteUInt(Ent.ConnectedSocket:EntIndex(),16)
					Ent.SentData[ply:EntIndex()].ConnectedPort = Ent.ConnectedSocket:EntIndex()
				elseif not Ent.ConnectedSocket and Ent.SentData[ply:EntIndex()].ConnectedPort ~= 0 then
					DoSent = true
					State(S_CONNECTEDPORT,"Connected Port Zeroed")
					net.WriteUInt(0,16)
					Ent.SentData[ply:EntIndex()].ConnectedPort = 0
				end
			end
			
			if next(Ent.ROutputs) or next(Ent.RInputs) or Ent.Class == "LS" then
				if Ent.SentData[ply:EntIndex()].Status ~= Ent.Online and Ent.SubClass ~= "Port" then
					DoSent = true
					State(S_STATUS,"Status Update")
					net.WriteBit(Ent.Online)
					Ent.SentData[ply:EntIndex()].Status = Ent.Online
				end
				State(S_OUTPUTS,"Outputs Updated")
				local I,N = next(Ent.StoredLinks.Outputs)
				if I and #N > 0 then
					for I,P in pairs(Ent.StoredLinks.Outputs) do
						if #P > 0 then
							local Stor = Ent.StoredLinks.Outputs[I][1]:UpdateStorage()
							if not Ent.SentData[ply:EntIndex()].Outputs[I] then Ent.SentData[ply:EntIndex()].NeedsUpdate = true end
							if Stor[1] then
								DoSent = true
								net.WriteBit(true)
								net.WriteUInt(table.KeyFromValue(Resources,I),8)
								net.WriteBit(true)
								net.WriteUInt(Stor[1],32)
								Ent.SentData[ply:EntIndex()].Outputs[I][1] = Stor[1]
							elseif Stor[I] and ((Stor[I][1] ~= Ent.SentData[ply:EntIndex()].Outputs[I][1] and #Ent.StoredLinks.Outputs[I] > 0) or 
									(Ent.SentData[ply:EntIndex()].Outputs[I][1] > 0 and #Ent.StoredLinks.Outputs[I] == 0)) then	
								DoSent = true
								net.WriteBit(true)
								net.WriteUInt(table.KeyFromValue(Resources,I),8)
								net.WriteBit(true)
								net.WriteUInt(Stor[I][1],32)
								Ent.SentData[ply:EntIndex()].Outputs[I][1] = Stor[I][1]
							end
						else
							if Ent.SentData[ply:EntIndex()].Outputs[I] and Ent.SentData[ply:EntIndex()].Outputs[I][1] > 0 then
								DoSent = true
								net.WriteBit(true)
								net.WriteUInt(table.KeyFromValue(Resources,I),8)
								net.WriteBit(false)
								Ent.SentData[ply:EntIndex()].Outputs[I][1] = 0
							end
						end
					end
				else
					for I,P in pairs(Ent.ROutputs) do
						if not Ent.SentData[ply:EntIndex()].Outputs[I] or Ent.SentData[ply:EntIndex()].Outputs[I][1] > 0 then
							DoSent = true
							net.WriteBit(true)
							net.WriteUInt(table.KeyFromValue(Resources,I),8)
							net.WriteBit(false)
							Ent.SentData[ply:EntIndex()].Outputs[I][1] = 0
						end
					end
				end
				net.WriteBit(false)
				local I,N = next(Ent.StoredLinks.Inputs)
				if I and #N > 0 then
					State(S_INPUTS,"Inputs Updated")
					for I,P in pairs(Ent.StoredLinks.Inputs) do
						if #P > 0 then
							local Stor = Ent.StoredLinks.Inputs[I][1]:UpdateStorage()
							//print("Stor:")
							//PrintTable(Stor)
							if Stor[1] then
								DoSent = true
								net.WriteBit(true)
								net.WriteUInt(table.KeyFromValue(Resources,I),8)
								net.WriteBit(true)
								net.WriteUInt(Stor[1],32)
								Ent.SentData[ply:EntIndex()].Inputs[I][1] = Stor[1]
							elseif Stor[I] and ((Stor[I][1] ~= Ent.SentData[ply:EntIndex()].Inputs[I][1] and #Ent.StoredLinks.Inputs[I] > 0) or 
									(Ent.SentData[ply:EntIndex()].Inputs[I][1] > 0 and #Ent.StoredLinks.Inputs[I] == 0)) then
								DoSent = true
								net.WriteBit(true)
								net.WriteUInt(table.KeyFromValue(Resources,I),8)
								net.WriteBit(true)
								net.WriteUInt(Stor[I][1],32)
								Ent.SentData[ply:EntIndex()].Inputs[I][1] = Stor[I][1]
							end
						else
							if Ent.SentData[ply:EntIndex()].Inputs[I] and Ent.SentData[ply:EntIndex()].Inputs[I][1] > 0 then
								DoSent = true
								net.WriteBit(true)
								net.WriteUInt(table.KeyFromValue(Resources,I),8)
								net.WriteBit(false)
								Ent.SentData[ply:EntIndex()].Inputs[I][1] = 0
							end
						end
					end
					net.WriteBit(false)
				elseif next(Ent.RInputs) then
					State(S_INPUTS,"Inputs Updated")
					for I,P in pairs(Ent.RInputs) do
						if Ent.SentData[ply:EntIndex()].Inputs[I][1] > 0 then 
							DoSent = true
							net.WriteBit(true)
							net.WriteUInt(table.KeyFromValue(Resources,I),8)
							net.WriteBit(false) 
							Ent.SentData[ply:EntIndex()].Inputs[I][1] = 0
						end
					end
					net.WriteBit(false)
				end
			end
			
			if Ent.SubClass == "Storage" then
				State(S_STORAGE,"Storage Update")
				local Stor = Ent:UpdateStorage()
				if not Stor[1] then
					for I,P in pairs(Ent.Storage) do
						DoSent = true
						net.WriteBit(true)
						net.WriteUInt(table.KeyFromValue(Resources,I),8)
						if Stor[I][2] > 0 then
							net.WriteUInt(Stor[I][1],32)
						else
							net.WriteUInt(P,32)
						end
					end
				end
				net.WriteBit(false)
			end
			
			if Ent.SubClass == "Node" then
				local Stor = {}
				local Size = 0
				for I,P in pairs(Ent.Links) do
					if P.SubClass == "Storage" then
						for i,p in pairs(P.Storage) do
							if not Stor[i] then
								Size = Size + 1
								Stor[i] = {}
								Stor[i].Storage = p
							else
								Stor[i].Storage = Stor[i].Storage + p
							end
						end
					end
				end
				
				if next(Stor) then
					DoSent = true
					State(S_NODERESOURCE,"Node Resource Update")
					net.WriteUInt(Size,4)
					for I,P in pairs(Stor) do
						net.WriteUInt(table.KeyFromValue(Resources,I),8)
						net.WriteUInt(P.Storage,32)
					end
				end
			end
		net.WriteUInt(0,4)
		if DoSent then
			net.Send(ply)
			//PrintTable(Queue)
		end
	end
end)