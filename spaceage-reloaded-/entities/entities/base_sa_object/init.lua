AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')
//include("net.lua")
include("net - Copy.lua")

local HARD_RANGE = 1024
local SOFT_RANGE = 5120

function WireLib.MakeWireEnt( pl, Data, ... )
	Data.Class = scripted_ents.Get(Data.Class).ClassName
	if IsValid(pl) then
		if string.Split(Data.Class,"_")[1] ~= "sa" and not pl:CheckLimit(Data.Class:sub(6).."s") then return false
		elseif string.Split(Data.Class,"_")[1] == "sa" then
			if (Data.Class == "sa_mining_laser" or 
				Data.Class == "sa_mining_drill" or 
				Data.Class == "sa_mining_liquidtib_storage" or
				Data.Class == "sa_mining_icelaser") and not pl:CheckLimit("sa_mining") then return false
			elseif (Data.Class == "sa_mining_rawore_storage" or 
					Data.Class == "sa_mining_rawtib_storage" or
					Data.Class == "sa_mining_rawice_storage" or 
					Data.Class == "sa_mining_refinedice_storage") and not pl:CheckLimit("sa_mining_storage") then return false
			elseif not pl:CheckLimit(Data.Class) then return false end
		end
	end
	
	local ent = ents.Create( Data.Class )
	if not IsValid(ent) then return false end
	
	duplicator.DoGeneric( ent, Data )
	ent:Spawn()
	ent:Activate()
	duplicator.DoGenericPhysics( ent, pl, Data ) -- Is deprecated, but is the only way to access duplicator.EntityPhysics.Load (its local)

	ent:SetPlayer(pl)
	ent:SetNWOwner(pl)
	if ent.Setup then ent:Setup(...) end
	if not IsValid(ent) then return false end

	if IsValid(pl) then 
		if string.Split(Data.Class,"_")[1] ~= "sa" then
			pl:AddCount( Data.Class:sub(6).."s", ent )
		else
			if Data.Class == "sa_mining_laser" or Data.Class == "sa_mining_drill" or Data.Class == "sa_mining_liquidtib_storage" or Data.Class == "sa_mining_icelaser" then
				pl:AddCount("sa_mining",ent)
			elseif Data.Class == "sa_mining_rawore_storage" or Data.Class == "sa_mining_rawtib_storage" or Data.Class == "sa_mining_rawice_storage" or Data.Class == "sa_mining_refinedice_storage" then
				pl:AddCount("sa_mining_storage",ent)
			else
				pl:AddCount(Data.Class,ent)
			end
		end
	end

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		if Data.frozen then phys:EnableMotion(false) end
		if Data.nocollide then phys:EnableCollisions(false) end
	end

	return ent
end

hook.Add("AdvDupe_FinishPasting","SA_EntityLinks",function(AdvDupe,PasteData,PasteDataCurrent)
	for I,P in pairs(AdvDupe[1].CreatedEntities) do
		if IsValid(P) and string.Split(P:GetClass(),"_")[1] == "sa" then
			P.FinishedDuping = true
		end
	end
end)

function ENT:ApplyDupeInfo(ply,ent,info,GetEntByID)
	WireLib.ApplyDupeInfo(ply,ent,info,GetEntByID)
	self.FinishedDuping = false
	self.Links = {}
	self:Setup(info)
	if self.SubClass == "Node" and info.Links then
		self.LinkQueue = {}
		for I,P in pairs(info.Links) do
			if type(P) == "number" then
				local E = GetEntByID(P)
				if IsValid(E) then
					table.insert(self.LinkQueue,E)
				end
			end
		end
	end
	if not IsValid(self) then return false end
end

local PhysMeta = FindMetaTable("PhysObj")

local OldMass = PhysMeta.SetMass
function PhysMeta:SetMass(Num,Override)
	if self:GetEntity().sa_ent and next(self:GetEntity().Storage) and not Override then return end
	OldMass(self,Num)
end

function ENT:Setup(info,Num)
	self:SetNWOwner(self:GetPlayer())
	local Mul = info.SizeNumber or Num
	
	if Mul then
		self:SetSizeNumber(Mul)
	else
		for I,P in pairs(list.Get(self:GetClass())) do
			if P == self:GetModel() then
				self:SetSizeNumber(I)
				break
			end
		end
	end
	/*
	if self.Class == "M" then
		if self.SubClass == "Storage" then
			if not self:GetNWEntity("Owner"):CheckLimit("sa_mining_storage") then
				self:GetNWEntity("Owner"):LimitHit("sa_mining_storage")
				self:Remove()
				return false
			end
		else
			if not self:GetNWEntity("Owner"):CheckLimit("sa_mining") then
				self:GetNWEntity("Owner"):LimitHit("sa_mining")
				self:Remove()
				return false
			end
		end
	end*/
	
	if not self:CheckLevel() then
		self:GetPlayer():SendLua("notification.AddLegacy('You do not have sufficient research level for that yet!',NOTIFY_ERROR,5)")
		self:Remove()
		return false
	end
	
	self.DefaultMass = self:GetPhysicsObject():GetMass()
	self:SetMass()
end

function ENT:BuildDupeInfo()
	local info = WireLib.BuildDupeInfo(self) or {}
	info.SizeNumber = self.SizeNumber
	info.Links = {}
	for I,P in pairs(self.Links) do
		table.insert(info.Links,P:EntIndex())
	end
	return info
end
/*
local function SetLinks(ply,ent,data)
	ent.Links = data
end

duplicator.RegisterEntityModifier("Links",SetLinks)*/
/*
function ENT:PreEntityCopy()
	local T = {}
	for I,P in pairs(self.Links) do
		table.insert(T,P:EntIndex())
	end
	duplicator.StoreEntityModifier(self,"Links",T)
	local Info = self:BuildDupeInfo()
	if Info then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",Info)
	end
end
*/
function ENT:AddMultiplier()
	self.Inputs = Wire_CreateInputs(self,{"On","Multiplier","Sound Off"})
	self.TriggerInput = function(self,iname,value)
		if iname == "On" then 
			if value == 1 then self:On() else self:Off() end
		elseif iname == "Multiplier" then
			self.Mul = value
			if self.Mul == 0 then self.Mul = 1 end
			
			if not self.OrgInputs then
				self.OrgInputs = table.Copy(self.RInputs)
			end
			for I,P in pairs(self.RInputs) do
				self.RInputs[I] = self.OrgInputs[I] * self.Mul
			end
			
			if not self.OrgOutputs then
				self.OrgOutputs = table.Copy(self.ROutputs)
			end
			for I,P in pairs(self.ROutputs) do
				self.ROutputs[I] = self.OrgOutputs[I] * self.Mul
			end
			/*
			for I,P in pairs(self.RInputs) do
				self.RInputs[I] = (P / self.OldMul) * self.Mul
			end
			
			for I,P in pairs(self.ROutputs) do
				self.ROutputs[I] = (P / self.OldMul) * self.Mul
			end*/
		elseif iname == "Sound Off" then
			self.SoundOff = value == 1
			if self.SoundOff and self.Humming then self.Humming:Stop()
			elseif not self.SoundOff and self.Humming then 
				self.Humming:Play()
				self.Humming:ChangeVolume(0.5,0.1)
			end
		end
	end
end

function ENT:SetMass()
	if not next(self.StorageMax) then return end
	local Max,Stor = 0,0
	for I,P in pairs(self.Storage) do
		if I ~= "Energy" then
			Stor = Stor + P
			Max = Max + self.StorageMax[I]
		end
	end
	if Max == 0 then return end
	self:GetPhysicsObject():SetMass(math.Round(self.DefaultMass + self.DefaultMass * (Stor / Max) * 3),true)
end

function ENT:Initialize()
	self.Class = "Base"
	self.SubClass = "Base"
	self:Init()
end

function ENT:Int()
	self.sa_ent = true
	self.Online = false
	self.BeingRemoved = false
	self.ScreenName = "Base"
	self.SpawnCD = CurTime() + 1
	self.SizeNumber = 1
	self.NextUse = 0
	self.NextThnk = 1
	self.SentData = {}
	self.Got = {}
	self.Queue = {}
	self.Links = {}
	self.Storage = {}
	self.StorageMax = {}
	self.StoredStorage = {}
	self.StoredStorageMax = {}
	self.ROutputs = {}
	self.RInputs = {}
	self.StoredLinks = {}
	self.StoredLinks.Inputs = {}
	self.StoredLinks.Outputs = {}
	self.StoredLinks.Storage = {}
	self.sStart = Sound("buttons/button1.wav")
	self.sDenied = Sound("buttons/button10.wav")
	self.Humming = CreateSound(self,Sound("ambient/machines/lab_loop1.wav"))
	self.sEnd = Sound("doors/doorstop1.wav")
	self:SetUseType(SIMPLE_USE)
end

function ENT:CheckLevel()
	return true
end

function ENT:Think()
	self:NextThink(CurTime() + self.NextThnk)
	if self.FinishedDuping == false then return true end
	if self.FinishedDuping and self.LinkQueue then
		for I,P in pairs(self.LinkQueue) do
			if I < #self.LinkQueue then
				self:Link(P,true)
			else
				self:Link(P,false)
			end
		end
		self.LinkQueue = nil
	end
	
	for I,E in pairs(self.Links) do
		if not IsValid(E) then table.remove(self.Links,I)
		elseif self.SubClass == "Node" then
			if self:GetPos():Distance(E:GetPos()) > self.Range then
				self:EmitSound("phx/epicmetal_hard4.wav",100,255)
				E:EmitSound("phx/epicmetal_hard4.wav",100,255)
				self:Unlink(E) 
			end
		elseif E.SubClass == "Node" then
			if self:GetPos():Distance(E:GetPos()) > E.Range then
				self:EmitSound("phx/epicmetal_hard4.wav",100,255)
				E:EmitSound("phx/epicmetal_hard4.wav",100,255)
				self:Unlink(E) 
			end
		end
	end
	
	self:ThinkStart()
	
	if not self.Online then return true end

	if not self:GetWaterLevel() then self:Off() return true end

	if #self.Links == 0 then self:Off() return true end

	self.Queue = {}
	self.Got = {}
	
	for I,P in pairs(self.RInputs) do
		if self:IsGas(I) and self.SubClass == "Puller" then
			if not self:LifeSupport() then self:Off() return true end
		else 
			if not self:GetLinkRes(I,P) then 
				if self.Class ~= "LS" and not self.Temperature then self:Off() return true else
					if I == "Energy" then self:Off() return true end
				end
			else
				if self.Class == "LS" or self.Temperature then table.insert(self.Got,I) end
			end
		end
	end
	
	local Off = 0
	local Ret = 0
	for I,P in pairs(self.ROutputs) do
		if not self.StoredLinks.Outputs[I] or (not next(self.StoredLinks.Outputs[I]) and not self:IsGas(I) and self.SubClass ~= "Blower") then Off = Off + 1
		elseif self:IsGas(I) and self.SubClass == "Blower" then
			if not self:LifeSupport() then return true end
		else
			if not self:GetStorage(I,P) then 
				Ret = Ret + 1
			end
		end
	end

	if Off > 0 or Ret > 0 then
		local A = 0
		for I,P in pairs(self.ROutputs) do
			A = A + 1
		end
		
		if Off == A then
			self:Off()
			return true
		elseif Off + Ret == A then
			return true
		end
	end
	
	if self.SubClass ~= "Puller" and self.SubClass ~= "Blower" then	
		if not self:LifeSupport() and #self.Got == 0 then
			if self.SubClass == "Dispenser" then self:Off() end
			return true
		end
	end
	
	if not self:BeforeQueue() then return true end
	
	for I,P in pairs(self.Queue) do
		if P[1] == self.Planet then
			P[1]:AddAtmosphere(P[2],P[3],self)
		else
			P[1]:AddResource(P[2],P[3],self)
		end
	end
	
	self:ThinkEnd()
	return true
end

function ENT:ThinkStart()
end

function ENT:BeforeQueue()
	return true
end

function ENT:ThinkEnd()
end

function ENT:SetSizeNumber(Num)
	local Mul = Num
	if Num == 2 then
		Mul = 5
	elseif Num == 3 then
		Mul = 10
	elseif Num == 4 then
		Mul = 40
	end
		
	self.SizeNumber = Num
	if next(self.RInputs) then
		if not self.OrgInputs then
			self.OrgInputs = table.Copy(self.RInputs)
		end
		for I,P in pairs(self.RInputs) do
			self.RInputs[I] = self.OrgInputs[I] * Mul
		end
	end
	
	if next(self.ROutputs) then
		if not self.OrgOutputs then
			self.OrgOutputs = table.Copy(self.ROutputs)
		end
		for I,P in pairs(self.ROutputs) do
			self.ROutputs[I] = self.OrgOutputs[I] * Mul
		end
	end
	
	if next(self.StorageMax) then
		if not self.OrgStorage then
			self.OrgStorage = table.Copy(self.StorageMax)
		end
		for I,P in pairs(self.StorageMax) do
			self.StorageMax[I] = self.OrgStorage[I] * Mul
		end
	end
end

function ENT:AddToQueue(Ent,Str,Val)
	table.insert(self.Queue,{Ent,Str,Val})
end

function ENT:IsGas(Str)
	return self.Planet and table.HasKey(Gases,Str)
end

function ENT:GetWaterLevel()
	if self:WaterLevel() == 0 then return true else return false end
end

function ENT:LifeSupport()
	return true
end

function ENT:CheckForInput()
	if self.Coolant then return true end
	if next(self.StoredLinks.Inputs) then 
		for I,P in pairs(self.StoredLinks.Inputs) do
			local Amount = 0
			if self:IsGas(I) and self.Class == "LS" and self.SubClass == "Puller" then
				return true
			else
				for i,p in pairs(P) do
					if p.Storage[I] and p.Storage[I] > 0 then
						Amount = Amount + p.Storage[I]
					end
				end
			end
				
			if Amount < self.RInputs[I] and self.Class ~= "LS" and I == "Energy" then
				return false
			end
		end
		return true
	elseif not next(self.RInputs) then return true end
	return false
end

function ENT:On()
	if not self:CheckForInput() then self:EmitSound(self.sDenied) return end 
	if not self.SoundOff then
		self:EmitSound(self.sStart)
		if self.Humming then 
			self.Humming:Play() 
			self.Humming:ChangeVolume(0.5,0.1)
		end
	end
	self.Online = true
	self:TriggerOutput()
end

function ENT:Off()
	self.Data = ""
	if not self.SoundOff then
		if self.Humming then self.Humming:Stop() end
		self:EmitSound(self.sEnd)
	end
	self.Online = false
	self:TriggerOutput()
end

function ENT:TriggerInput(Name,Value)
	if Name == "On" then
		if Value == 1 and not self.Online then self:On() 
		elseif self.Online then self:Off() end
	elseif Name == "Sound Off" then
		self.SoundOff = Value == 1
		if self.SoundOff and self.Humming then self.Humming:Stop()
		elseif not self.SoundOff and self.Humming then 
			self.Humming:Play()
			self.Humming:ChangeVolume(0.5,0.1)
		end
	end
end

function ENT:TriggerOutput()
	local Num = 0
	if self.Online then Num = 1 end
	self:SetNetworkedBool("Online",self.Online)
	Wire_TriggerOutput(self,"Status",Num)
end

function ENT:Link(ent,StopUpdate)
	if not self.Class and not self.SubClass and not self:IsVehicle() then return end
	if not (self.SubClass == "Node" or ent.SubClass == "Node") then return end
	if ent == self then return end
	if not IsValid(ent) then return end
	if table.HasValue(self.Links,ent) then return end
	if self.SubClass == "Node" then
		if self:GetPos():Distance(ent:GetPos()) > self.Range then
			self:EmitSound("phx/epicmetal_hard4.wav",100,255) 
			ent:EmitSound("phx/epicmetal_hard4.wav",100,255)
			return 
		end
	elseif ent.SubClass == "Node" then
		if self:GetPos():Distance(ent:GetPos()) > ent.Range then
			self:EmitSound("phx/epicmetal_hard4.wav",100,255) 
			ent:EmitSound("phx/epicmetal_hard4.wav",100,255)
			return 
		end
	end
	table.insert(self.Links,ent)
	
	if ent:IsVehicle() then
		ent.Link = self
		ent.sa_activated = true
		ent.Think = function(self)
			if not IsValid(self:GetDriver()) then
				if self.Driv then
					self.Driv.OxyGot = nil
					self.Driv.IceGot = nil
					self.Driv.HeatGot = nil
					self.Driv.Seat = nil
					self.Driv = nil
				end
				return true 
			end
			
			if not self.Driv then
				self.Driv = self:GetDriver()
				self.Driv.Seat = self
			end
			
			if not self.StoredEnts then
				self.StoredEnts = {}
				self.StoredEnts.Oxygen = ent.Link:GetLinks("Oxygen")
				self.StoredEnts.Steam = ent.Link:GetLinks("Steam")
				self.StoredEnts.Ice = ent.Link:GetLinks("Ice")
			end
			
			local Got = {}
			
			for I,P in pairs(self.StoredEnts) do
				local A = math.pow(2,5)
				for i,E in pairs(P) do
					if E.Storage[I] >= A then
						table.insert(Got,{E,I,-A})
						A = A - A
						break
					elseif E.Storage[I] > 0 then
						table.insert(Got,{E,I,-E.Storage[I]})
						A = A - E.Storage[I]
					end
				end
				
				if A == 0 then
					if I == "Oxygen" then self:GetDriver().OxyGot = self end
					if I == "Steam" then self:GetDriver().HeatGot = self end
					if I == "Ice" then self:GetDriver().IceGot = self end
				else
					if I == "Oxygen" then self:GetDriver().OxyGot = nil end
					if I == "Steam" then self:GetDriver().HeatGot = nil end
					if I == "Ice" then self:GetDriver().IceGot = nil end
				end
			end
			
			for I,P in pairs(Got) do
				P[1]:AddResource(P[2],P[3])
			end
			
			return true
		end
		return
	end
	
	if ent.Links and not table.HasValue(ent.Links,self) then ent:Link(self) end
	self.SentData = {}
	self:AfterLink()
	if StopUpdate then return end
	self:UpdateLinks()
end

function ENT:AfterLink()
end

function ENT:Unlink(ent)
	if table.HasValue(self.Links,ent) then
		for I,P in pairs(self.Links) do
			if P == ent then table.remove(self.Links,I) break end
		end
		
		if ent:IsVehicle() then 
			ent.Link = nil 
			ent.Think = nil
			ent.sa_activated = nil
		else	
			if ent.Unlink then ent:Unlink(self) end 
			if not self.BeingRemoved then self:UpdateLinks() end
		end
		
		self.SentData = {}
	end	
end

function ENT:Use(Act,Cal)
	if not next(self.ROutputs) and self.Class ~= "LS" and self.Class ~= "M" and CurTime() > self.NextUse then return end
	self.NextUse = CurTime() + 1
	if self.Online then self:Off() else self:On() end
end

function ENT:OnRemove()
	self.BeingRemoved = true
	if self.Humming then self.Humming:Stop() end
	if self.Planet and next(self.Storage) then
		for I,P in pairs(self.Storage) do
			if table.HasKey(Gases,I) then
				self.Planet:AddAtmosphere(I,P)
			end
		end
	end
	self:Snap()
end

function ENT:Snap()
	local I = #self.Links
	while I > 0 do
		if not IsValid(self.Links[I]) or not self.Links[I].Unlink then 
			table.remove(self.Links,I)
		else
			if not self.Links[I]:IsVehicle() then 
				local Ent = self.Links[I]
				self.Links[I]:Unlink(self)
				if Ent == self.Links[I] then
					table.remove(self.Links,I)
				end
			else 
				local Veh = self.Links[I]
				table.remove(self.Links,I)
				Veh.Link = nil
				Veh.sa_activated = nil
			end
		end
		I = I - 1
	end
	
	if #self.Links > 0 then 
		print(tostring(self).." has failed to remove it's links, somehow.")
		print("Links:")
		PrintTable(self.Links)
	end
	self.SentData = {}
end

function ENT:GetResource(Str)
	if not self.Storage[Str] then return end
	return self.Storage[Str]
end

function ENT:SetResource(Str,Val)
	if not self.Storage[Str] then return end
	self.Storage[Str] = math.Clamp(math.Round(Val),0,self.StorageMax[Str])
	self:SetMass()
end

function ENT:AddResource(Str,Val)
	if not self.Storage[Str] then return end
	self.Storage[Str] = math.Clamp(self.Storage[Str] + math.Round(Val),0,self.StorageMax[Str])
	self:SetMass()
end

function ENT:GetLinkRes(Str,Val)
	if #self.StoredLinks.Inputs[Str] == 0 then return false end

	local Amount = 0
	for I,P in pairs(self.StoredLinks.Inputs[Str]) do
		if Amount == Val then return true end
		if P.Storage and P.Storage[Str] and P.Storage[Str] > 0 then
			if P.Storage[Str] >= Val - Amount then 
				self:AddToQueue(P,Str,-(Val - Amount))
				Amount = Amount + (Val - Amount)
			else 
				self:AddToQueue(P,Str,-P.Storage[Str])
				Amount = Amount + P.Storage[Str] 
			end	
		end
	end
	
	if Amount == Val then return true
	else return false,Amount end
end

function ENT:GetStorage(Str,Val)
	if #self.StoredLinks.Outputs[Str] == 0 then return false end
	
	local Amount = 0
	for I,P in pairs(self.StoredLinks.Outputs[Str]) do
		if Amount == Val then return true end
		if P.Storage[Str] and P.Storage[Str] < P.StorageMax[Str] then
			if P.StorageMax[Str] - P.Storage[Str] >= Val then 
				self:AddToQueue(P,Str,Val - Amount)
				Amount = Amount + (Val - Amount)
			else 
				self:AddToQueue(P,Str,P.StorageMax[Str] - P.Storage[Str])
				Amount = Amount + (P.StorageMax[Str] - P.Storage[Str]) 
			end
		end
	end
	
	if Amount > 0 then return true
	else return false,Amount end
end

function ENT:GetLinks(Str,Ents,All)
	if not Ents then Ents = {} end
	if not All then All = {} end
	table.insert(All,self)
	if self.Storage[Str] then table.insert(Ents,self) end
	for I,P in pairs(self.Links) do
		if P:IsVehicle() then table.insert(All,P) end
		if not table.HasValue(All,P) and P.GetLinks then
			Ents,All = P:GetLinks(Str,Ents,All)
		end
	end
	return Ents,All
end

function ENT:UpdateLinks(Updt)
	self.StoredLinks.Inputs = {}
	self.StoredLinks.Outputs = {}
	
	if self:GetClass() ~= "sa_atmosphere_probe" then
		for I,P in pairs(self.SentData) do
			self.SentData[I].NeedsUpdate = true
		end
	end
	
	if not Updt then Updt = {self}
	else table.insert(Updt,self) end
	
	for I,P in pairs(self.Links) do
		if P:IsVehicle() then
			self.StoredEnts = {}
			table.insert(Updt,P)
		end
		if IsValid(P) and P.UpdateLinks and not (table.HasValue(Updt,P)) then Updt = P:UpdateLinks(Updt) end
	end
	
	if next(self.Storage) then 
		self.StoredLinks.Storage = {}
		for I,P in pairs(self.Storage) do
			self.StoredLinks.Storage[I] = self:GetLinks(I)
		end
	end
	
	for I,P in pairs(self.RInputs) do
		self.StoredLinks.Inputs[I] = self:GetLinks(I)
	end
	
	for I,P in pairs(self.ROutputs) do
		self.StoredLinks.Outputs[I] = self:GetLinks(I)
	end
	
	return Updt
end

function ENT:UpdateStorage()
	local StoredStorage = {}
	
	for I,P in pairs(self.Storage) do
		StoredStorage[I] = {0,0}
		if next(self.StoredLinks.Storage) and #self.StoredLinks.Storage[I] > 0 then
			for i,E in pairs(self.StoredLinks.Storage[I]) do
				if E.Storage and E.Storage[I] then
					StoredStorage[I][1] = StoredStorage[I][1] + E.Storage[I]
					StoredStorage[I][2] = StoredStorage[I][2] + E.StorageMax[I]
				end
			end
		end
	end
	return StoredStorage
end