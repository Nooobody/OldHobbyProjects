AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")			   

function ENT:Initialize()
	self.Entity:SetModel("models/props_lab/tpplugholder_single.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "RD"
	self.SubClass = "Port"
	self.ScreenName = "Port #"..self:EntIndex()
	self.Humming = nil
	self.Connected = nil
	self:SetNWBool("Connected",false)
	self.Weld = nil
	self.ConnectedSocket = nil
	self.Terminal = nil
	self.TransmitAmount = 0
	
	self.SendingNow = ""
	self.Sending = ""
	self.Receiving = ""
	self.DefAmount = math.pow(2,10)
	self.Amount = 0
	self.Status = PORT_UNPLUGGED
	self.NextThnk = 1
	
	self.Inputs = WireLib.CreateSpecialInputs(self,{"Unplug","Amount","Sending"},{"NORMAL","NORMAL","STRING"})
	self.Outputs = WireLib.CreateSpecialOutputs(self,{"Status","AmountLeft","Resource"},{"STRING","NORMAL","STRING"})
end

function ENT:Use(Act,Cal)
	if self.Connected or not Act:CheckLimit("sa_plug") then return end
	local Ent1 = MakePlugs(Act,self:LocalToWorld(Vector(5,13,10)),self:LocalToWorldAngles(Angle(0,0,0)),false)
	local Ent2 = MakePlugs(Act,self:LocalToWorld(Vector(25,13,10)),self:LocalToWorldAngles(Angle(0,0,0)),false)
	
	local Rope
	if Act:GetResearch("Socket_Plasma_Fiber") > 0 then
		Ent1:SetMaterial("models/props_lab/xencrystal_sheet")
		Ent2:SetMaterial("models/props_lab/xencrystal_sheet")
		Rope = constraint.Rope(Ent1,Ent2,0,0,Vector(12,.115219,-0.085065,-0.158239),Vector(12.115219,-0.085065,-0.158239),500,0,0,10,"cable/hydra",false)
		Ent1.Plasma = true
		Ent2.Plasma = true
	elseif Act:GetResearch("Socket_Optic_Fiber") > 0 then
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
		undo.SetPlayer(Act)
	undo.Finish()
	
	Act:AddCount("sa_plug",Ent1)
	Act:AddCount("sa_plug",Ent2)
	
	Act:AddCleanup("sa_plug",Ent1)
	Act:AddCleanup("sa_plug",Ent2)
	
	self.Closest = Ent1
	self:CheckClosest()
end

function ENT:StartTouch(Ent)
	if Ent:GetClass() == "sa_plug" and not self.Connected then
		local P = Ent
		Ent:GetPhysicsObject():EnableMotion(false)
		self.Connected = P
		P.Connected = self
		
		P:SetPos(self:LocalToWorld(Vector(5, 13, 10)))
		P:SetAngles(self:LocalToWorldAngles(Angle(0,0,0)))
		
		local weld = constraint.Weld(self,P,0,0,2500,true)
		if weld and weld:IsValid() then
			P:DeleteOnRemove(weld)
			P.Weld = weld
			self:DeleteOnRemove(weld)
			self.Weld = weld
		end
		
		self.Status = PORT_PLUGGED
		if self.Connected.LinkPlug.Connected then
			self.ConnectedSocket = self.Connected.LinkPlug.Connected
			self.ConnectedSocket.ConnectedSocket = self
			
			self.Status = PORT_STANDBY
			self.ConnectedSocket.Status = PORT_STANDBY
			self.ConnectedSocket:TriggerOutput()
		end
		self:SetNWBool("Connected",true)
		self:TriggerOutput()
	end
end

function ENT:CheckClosest()
	if IsValid(self.Closest) then
		local P = self.Closest
		self.Connected = P
		P.Connected = self
		
		P:SetPos(self:LocalToWorld(Vector(5, 13, 10)))
		P:SetAngles(self:LocalToWorldAngles(Angle(0,0,0)))
		
		local weld = constraint.Weld(self,P,0,0,500,true)
		if weld and weld:IsValid() then
			P:DeleteOnRemove(weld)
			P.Weld = weld
			self:DeleteOnRemove(weld)
			self.Weld = weld
		end
		
		self.Closest = nil
		self.Status = PORT_PLUGGED
		if IsValid(self.Connected.LinkPlug) and self.Connected.LinkPlug.Connected then
			self.ConnectedSocket = self.Connected.LinkPlug.Connected
			self.ConnectedSocket.ConnectedSocket = self
			
			self.Status = PORT_STANDBY
			self.ConnectedSocket.Status = PORT_STANDBY
			self.ConnectedSocket:TriggerOutput()
		end
		self:TriggerOutput()
		self:SetNWBool("Connected",true)
		return true
	end
	
	return false
end

function ENT:ThinkStart()
	if not self.Connected then
		if not self:CheckClosest() then
			local Plugs = {}
			for I,P in pairs(ents.FindInSphere(self:GetPos(),20)) do
				if P:GetClass() == "sa_plug" and IsValid(P) and not P.Connected then
					P:GetPhysicsObject():EnableMotion(false)
					self.Connected = P
					P.Connected = self
					
					P:SetPos(self:LocalToWorld(Vector(5, 13, 10)))
					P:SetAngles(self:LocalToWorldAngles(Angle(0,0,0)))
					
					local weld = constraint.Weld(self,P,0,0,2500,true)
					if weld and weld:IsValid() then
						P:DeleteOnRemove(weld)
						P.Weld = weld
						self:DeleteOnRemove(weld)
						self.Weld = weld
					end
					
					self.Status = PORT_PLUGGED
					if IsValid(self.Connected.LinkPlug) and self.Connected.LinkPlug.Connected then
						self.ConnectedSocket = self.Connected.LinkPlug.Connected
						self.ConnectedSocket.ConnectedSocket = self
						
						self.Status = PORT_STANDBY
						self.ConnectedSocket.Status = PORT_STANDBY
						self.ConnectedSocket:TriggerOutput()
					end
					self:SetNWBool("Connected",true)
					self:TriggerOutput()
					break
				end
			end
		end
	else
		if self.Connected.PlayerHolding then
			constraint.RemoveConstraints(self.Connected,"Weld")
		end	
		
		if (self.Weld and not IsValid(self.Weld)) or (self.Connected and not IsValid(self.Connected)) or self:GetPos():Distance(self.Connected:GetPos()) > 18 then
			self.Weld = nil
			
			if self.ConnectedSocket and IsValid(self.ConnectedSocket) then
				self.ConnectedSocket.ConnectedSocket = nil
				self.ConnectedSocket:ResetValues()
				self.ConnectedSocket.Status = PORT_PLUGGED
				self.ConnectedSocket = nil
			end
			
			self.Connected.Connected = nil
			self.Connected = nil
			
			self:SetNWBool("Connected",false)
			self.Status = PORT_UNPLUGGED
			self:TriggerOutput()
			
			self:ResetValues()
		elseif self.ConnectedSocket and (not IsValid(self.ConnectedSocket) or not IsValid(self.Connected.LinkPlug)) then
			self.ConnectedSocket = nil
			self.Status = PORT_PLUGGED
			self:ResetValues()
			self:TriggerOutput()
		elseif not self.ConnectedSocket then
			if IsValid(self.Connected.LinkPlug) and self.Connected.LinkPlug.Connected then
				self.ConnectedSocket = self.Connected.LinkPlug.Connected
				self.ConnectedSocket.ConnectedSocket = self
				
				self.Status = PORT_STANDBY
				self.ConnectedSocket.Status = PORT_STANDBY
				self.ConnectedSocket:TriggerOutput()
				self:TriggerOutput()
			end
		end
	end
	
	if self.Connected and self.ConnectedSocket then
		if self.Terminal or self.ConnectedSocket.Terminal then 
			if self.Terminal and IsValid(self.Terminal.PlayerUsing) then
				if self.Status == PORT_SENDING then
					self.ConnectedSocket.Queue = {}
					if self.ConnectedSocket:GetStorage(self.Sending,math.min(self.ConnectedSocket.Amount,self.TransmitAmount)) then
						for I,P in pairs(self.ConnectedSocket.Queue) do
							P[1]:AddResource(P[2],P[3])
						end
						self.ConnectedSocket.Queue = {}
						self.Terminal.PlayerUsing.Storage[self.Sending] = self.Terminal.PlayerUsing.Storage[self.Sending] - math.min(self.Amount,self.TransmitAmount)
						self.TransmitAmount = math.max(self.TransmitAmount - self.Amount,0)
						DB_UpdatePlayer("Resources",SQLStringFromRes(self.Terminal.PlayerUsing.Storage),self.Terminal.PlayerUsing:SteamID())
					end
				elseif self.Status == PORT_INCOMING then
					self.ConnectedSocket.Queue = {}
					if self.ConnectedSocket:GetLinkRes(self.Receiving,math.min(self.ConnectedSocket.Amount,self.TransmitAmount)) then
						for I,P in pairs(self.ConnectedSocket.Queue) do
							P[1]:AddResource(P[2],P[3])
						end
						self.ConnectedSocket.Queue = {}
						if not self.Terminal.PlayerUsing.Storage[self.Receiving] then self.Terminal.PlayerUsing.Storage[self.Receiving] = 0 end
						self.Terminal.PlayerUsing.Storage[self.Receiving] = self.Terminal.PlayerUsing.Storage[self.Receiving] + math.min(self.Amount,self.TransmitAmount)
						self.TransmitAmount = math.max(self.TransmitAmount - self.ConnectedSocket.Amount,0)
						self.ConnectedSocket.TransmitAmount = self.TransmitAmount
						self.ConnectedSocket:TriggerOutput()
						DB_UpdatePlayer("Resources",SQLStringFromRes(self.Terminal.PlayerUsing.Storage),self.Terminal.PlayerUsing:SteamID())
					end
				end
			end
			return
		end
		if self.Status == PORT_INCOMING and not self.Online then
			self.Online = true
		end
		
		if self.Sending ~= "" and table.HasValue(Resources,self.Sending) and (self.Status == PORT_STANDBY or self.Status == PORT_SENDING) and self.Sending ~= self.SendingNow then
			self:ResetValues()
			self.ConnectedSocket:ResetValues()
			
			self.SendingNow = self.Sending
			self.Status = PORT_SENDING
			self.ConnectedSocket.Status = PORT_INCOMING
			
			for I,P in pairs(self.SentData) do
				self.SentData[I].NeedsUpdate = true
			end
			
			for I,P in pairs(self.ConnectedSocket.SentData) do
				self.ConnectedSocket.SentData[I].NeedsUpdate = true
			end
			
			self.RInputs[self.Sending] = 1
			self.ConnectedSocket.ROutputs[self.Sending] = 1
			
			local Amount
			if self.Connected.Plasma and self:GetNWEntity("Owner"):GetResearch("Socket_Plasma_Fiber") > 0 then
				Amount = math.Round(self.DefAmount * math.pow(2,10) * (1 + self:GetNWEntity("Owner"):GetResearch("Socket_Plasma_Fiber") / 10))
			elseif self.Connected.Golden and self:GetNWEntity("Owner"):GetResearch("Socket_Optic_Fiber") > 0 then
				Amount = math.Round(self.DefAmount * math.pow(2,5) * (1 + self:GetNWEntity("Owner"):GetResearch("Socket_Optic_Fiber") / 10))
			else
				Amount = math.Round(self.DefAmount * (1 + self:GetNWEntity("Owner"):GetResearch("Socket_Transmission_Speed") / 100))
			end
			
			self.ConnectedSocket.Receiving = self.Sending
			
			local PL = 0.95 + 0.001 * self:GetNWEntity("Owner"):GetResearch("Socket_Packet_Loss")
			
			self.Amount = Amount
			self.ConnectedSocket.Amount = math.Round(Amount * PL)
			
			self.TransmitAmount = self.ToTransmit or -1
			if self.TransmitAmount == 0 then self.ToTransmit = -1 end
			
			self:UpdateLinks()
			self.ConnectedSocket:UpdateLinks()
			
			self:TriggerOutput()
			self.ConnectedSocket:TriggerOutput()
			
			self.ConnectedSocket.Online = true
		elseif self.Status == PORT_SENDING and self.Sending == "" then
			self.SendingNow = ""
			self.Status = PORT_STANDBY
			self.ConnectedSocket.Status = PORT_STANDBY
			
			self:ResetValues()
			self.ConnectedSocket:ResetValues()
			
			self:TriggerOutput()
			self.ConnectedSocket:TriggerOutput()
		end
	end
end

function ENT:BeforeQueue()
	self.Queue = {}
	if self.Terminal or self.ConnectedSocket.Terminal then
		return true
	else
		if self.Status == PORT_INCOMING then
			local Transmit = self.ConnectedSocket.TransmitAmount
			local Am = math.min(self.ConnectedSocket.Amount,Transmit)
			local PLAm = math.min(self.Amount,Transmit * (0.98 + 0.001 * (self:GetNWEntity("Owner"):GetResearch("Socket_Packet_Loss"))))
			if Transmit == -1 then 
				PLAm = self.Amount
				Am = self.ConnectedSocket.Amount
			end
			
			if (Transmit > 0 or Transmit == -1) and self.ConnectedSocket:GetLinkRes(self.Receiving,Am) then
				local Queue = table.Copy(self.ConnectedSocket.Queue)
				self.ConnectedSocket.Queue = {}
				
				if self:GetStorage(self.Receiving,math.min(self.Amount,PLAm)) then
					for I,P in pairs(Queue) do
						P[1]:AddResource(P[2],P[3])
					end
					
					if Transmit ~= -1 then
						self.ConnectedSocket.TransmitAmount = self.ConnectedSocket.TransmitAmount - Am
						self.ConnectedSocket:TriggerOutput()
					end
				end
			end
		end
	end
	
	return true
end

function ENT:TriggerInput(iname,value)
	if self.Terminal then return end
	if iname == "Sending" then self.Sending = value or ""
	elseif iname == "Amount" then self.ToTransmit = value or -1
	elseif iname == "Unplug" and value > 0 then
		self:Unplug()
	end
end

function ENT:TriggerOutput()
	Wire_TriggerOutput(self,"Status",PORT_STATUS[self.Status])
	if self.Status == PORT_SENDING or self.Status == PORT_INCOMING then
		if self.Status == PORT_SENDING then 
			Wire_TriggerOutput(self,"Resource",self.Sending)
			Wire_TriggerOutput(self,"AmountLeft",self.TransmitAmount)
		else 
			Wire_TriggerOutput(self,"Resource",self.ConnectedSocket.Receiving) 
			Wire_TriggerOutput(self,"AmountLeft",0)
		end
	else
		Wire_TriggerOutput(self,"Resource","")
		Wire_TriggerOutput(self,"AmountLeft",0)
	end
end

function ENT:Unplug()
	if self.Connected then
		self.Connected:GetPhysicsObject():EnableMotion(true)
		self.Connected:GetPhysicsObject():SetVelocity(self:LocalToWorld(Vector(0,0,100)))
	end
end

function ENT:ResetValues()
	self.RInputs = {}
	self.ROutputs = {}
	self.StoredLinks.Inputs = {}
	self.StoredLinks.Outputs = {}
	self:UpdateLinks()
	
	self.Online = false
	self.SendingNow = ""
	
	for I,P in pairs(self.SentData) do
		self.SentData[I].NeedsUpdate = true
	end
end