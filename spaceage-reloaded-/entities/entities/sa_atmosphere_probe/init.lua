AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

local DEFAULT = {["s"] = {},
				 ["stypes"] = {},
				 ["n"] = {},
				 ["ntypes"] = {},
				 ["size"] = 0}
				 
function ENT:Initialize()
	self:SetModel("models/slyfo/moisture_condenser.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Class = "LS"
	self.SubClass = "Probe"
	self.RInputs.Energy = math.pow(2,4)
	self.SentData = {}
	self.WireData = {}
	
	self.Humming = nil
	self.sDenied = ""
	self.Data = ""
	
	self.Inputs = Wire_CreateInputs(self,{"Sound Off"})
	self.Outputs = WireLib.CreateSpecialOutputs(self,{"Status","Name","Temperature","Pressure","Atmosphere"},{"NORMAL","STRING","NORMAL","NORMAL","TABLE"})
end

function ENT:LifeSupport()
	local Old = self.Data
	self.Data = "Online\n"
	if self.Planet then
		self.Data = "Planet "..self.Planet.ScreenName.."\n"
		self.Data = self.Data.."Is breathable: "..tostring(self.Planet:IsBreathable()).."\n"
		self.Data = self.Data.."Temperature: "..self.Planet.Temperature.."\n"
		self.Data = self.Data.."Pressure: "..self.Planet.Pressure.."\n"
		for I,P in pairs(self.Planet.Atmosphere) do
			self.Data = self.Data..I..": "..P.."%\n"
		end
	else
		self.Data = "Space\n"
		self.Data = self.Data.."Is breathable: False"
	end
	if self.Data ~= Old then
		self.SentData = {}
	end
	return true
end

function ENT:Use()
end

function ENT:ThinkStart()
	self:TriggerOutput()
	if not next(self.StoredLinks.Inputs) and self.Online then 
		self:Off()
		return 
	end
	if self.Planet and self:CheckForInput() then
		if not self.Online then self:On() end
	else
		if self.Online then self:Off() end
	end
end

function ENT:TriggerInput(Name,Value)
	if Name == "Sound Off" then
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
	
	if self.Online then
		if self.Planet then
			if self.WireData.Temperature ~= self.Planet.Temperature then
				self.WireData.Temperature = self.Planet.Temperature
				Wire_TriggerOutput(self,"Temperature",self.Planet.Temperature)
			end
			if self.WireData.Pressure ~= self.Planet.Pressure then
				self.WireData.Pressure = self.Planet.Pressure
				Wire_TriggerOutput(self,"Pressure",self.Planet.Pressure)
			end
			if self.WireData.Name ~= self.Planet.ScreenName then
				self.WireData.Name = self.Planet.ScreenName
				Wire_TriggerOutput(self,"Name",self.Planet.ScreenName)
			end
			local Diff = false
			if self.WireData.Atmosphere then
				for I,P in pairs(self.Planet.Atmosphere) do
					if P ~= self.WireData.Atmosphere[I] then
						Diff = true
						break
					end
				end
			else Diff = true end
			
			if Diff then
				self.WireData.Atmosphere = self.Planet.Atmosphere
				local Atmo = table.Copy(DEFAULT)
				for I,P in pairs(self.Planet.Atmosphere) do
					Atmo.s[I] = P
					Atmo.stypes[I] = "n"
					Atmo.size = Atmo.size + 1
				end
				Wire_TriggerOutput(self,"Atmosphere",Atmo)
			end
		else
			self.WireData.Temperature = -100
			self.WireData.Pressure = 0
			self.WireData.Name = "Space"
			self.WireData.Atmosphere = nil
			Wire_TriggerOutput(self,"Temperature",-100)
			Wire_TriggerOutput(self,"Pressure",0)
			Wire_TriggerOutput(self,"Name","Space")
			Wire_TriggerOutput(self,"Atmosphere",table.Copy(DEFAULT))
		end
	else
		self.WireData.Temperature = 0
		self.WireData.Pressure = 0
		self.WireData.Name = "Unpowered"
		self.WireData.Atmosphere = nil
		Wire_TriggerOutput(self,"Temperature",0)
		Wire_TriggerOutput(self,"Pressure",0)
		Wire_TriggerOutput(self,"Name","Unpowered")
		Wire_TriggerOutput(self,"Atmosphere",table.Copy(DEFAULT))
	end
end

net.Receive("SA_LSProbeLooked",function(len,ply)
	local Ent = ply:GetEyeTrace().Entity
	if Ent:GetClass() ~= "sa_atmosphere_probe" then return end
	local Str = ""
	if Ent.Online then
		Str = Str..Ent.Data
	else
		Str = Str.."Offline"
	end
	if Ent.SentData[ply:EntIndex()] and Ent.SentData[ply:EntIndex()] == Str then return end
	Ent.SentData[ply:EntIndex()] = Str
	net.Start("SA_LSProbeLookedReceive")
		net.WriteEntity(Ent)
		net.WriteString(Str)
	net.Send(ply)
end)

util.AddNetworkString("SA_LSProbeLooked")
util.AddNetworkString("SA_LSProbeLookedReceive")