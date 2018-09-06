AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')

TEMP_MIN = -30
TEMP_MAX = 30

function ENT:Initialize()
	self:Init()
end

function ENT:Init()
	self.Ents = {}
	self.ScreenName = "Base"
	self.Gravity = 1
	self.ParentPlanet = nil
	self.Breathable = false
	self.Locked = false
	self.Temperature = 0
	self.Pressure = 0
	self.NextLerp = CurTime() + math.random(6000,1200)
	self.NextScience = CurTime() + 1
	self.RealAtmosphere = {}
	self.Atmosphere = {}
end

function ENT:Think()
	self:NextThink(CurTime() + 0.5)
	
	for I,P in pairs(self.Ents) do
		if IsValid(P) and P:GetPos():Distance(self.Pos) > self.Size then
			self:RemoveEnt(P,I,true)
			if P:IsPlayer() and not P.Planet then
				for I,Plan in pairs(ents.FindByClass("sa_planet")) do
					if P:GetPos():Distance(Plan.Pos) <= Plan.Size then
						Plan:AddEnt(P)
						break
					end
				end
			end
		elseif IsValid(P) and P.Grav != self.Gravity then
			self:SetGrav(P)
		elseif not IsValid(P) then
			table.remove(self.Ents,I)
		end
	end	
	
	for I,P in pairs(ents.FindInSphere(self.Pos,self.Size)) do
		if IsValid(P) and IsValid(P:GetPhysicsObject()) and P:GetPos():Distance(self.Pos) < self.Size then
			if P.Planet then
				if P.Planet.Pos:Distance(P:GetPos()) > self.Pos:Distance(P:GetPos()) then
					self:AddEnt(P)
				end
			else
				self:AddEnt(P)
			end
		end
	end
	
	if CurTime() > self.NextLerp then
		self:LerpAtmo()
	end
	
	if CurTime() > self.NextScience then
		self:DoScience()
	end
	return true
end

function ENT:IsBreathable()
	if self.Breathable and
		self.Temperature > TEMP_MIN and self.Temperature < TEMP_MAX and
		self.Pressure > 0.8 and self.Pressure < 1.2 then
		return true
	end
	return false
end

function ENT:RemoveEnt(ent,I,PutParent)
	if not I then
		for I,P in pairs(self.Ents) do
			if P == ent then table.remove(self.Ents,I) break end
		end
	else table.remove(self.Ents,I) end
	if IsValid(ent) then
		ent.Planet = nil
		ent:SetNWBool("Planet",false)
		self:SetGrav(ent)
		if PutParent and self.ParentPlanet then
			self.ParentPlanet:AddEnt(ent)
		end
	end
end

function ENT:AddEnt(ent)
	table.insert(self.Ents,ent)
	ent.Planet = self
	ent:SetNWBool("Planet",true)
	self:SetGrav(ent)
end

function ENT:CalcAtmo()
	local Total = 0
	for I,P in pairs(self.RealAtmosphere) do
		Total = Total + P
		if P == 0 then
			self.RealAtmosphere[I] = nil
			if self.Atmosphere[I] then
				self.Atmosphere[I] = nil
			end
		end
	end
	
	for I,P in pairs(self.RealAtmosphere) do
		self.Atmosphere[I] = math.Round((P / Total) * 10000) / 100
	end
	
	self.Temperature = 0
	for I,P in pairs(self.Atmosphere) do
		self.Temperature = self.Temperature + math.Round(Gases[I].Temperature * P / 10)
	end

	self:CalcBreath()
	self:SaveAtmo()
end

function ENT:LerpAtmo()
	local Map = map_goon[self.ScreenName]
	
	for I,P in pairs(Map.RealAtmosphere) do
		if not self.RealAtmosphere[I] then self.RealAtmosphere[I] = 0 end
		self.RealAtmosphere[I] = Lerp(0.01,self.RealAtmosphere[I],P)
	end
	for I,P in pairs(self.RealAtmosphere) do
		if not table.HasKey(Map.RealAtmosphere,I) then
			self.RealAtmosphere[I] = Lerp(0.01,self.RealAtmosphere[I],0)
		end
	end
	self.Pressure = Lerp(0.01,self.Pressure,Map.Pressure)
	
	self:CalcAtmo()
	self.NextLerp = CurTime() + math.random(9000,18000)
end

function ENT:SaveAtmo()
	if not file.Exists("Atmos","DATA") then file.CreateDir("Atmos") end
	self.Pressure = self.Pressure or 0
	self.RealAtmosphere = self.RealAtmosphere or {}
	
	local Str = "Pressure="..self.Pressure.."\r\n"
	Str = Str..CreateStringFromTab(self.RealAtmosphere)
	
	file.Write("Atmos/"..self.ScreenName..".txt",Str)
end

function ENT:LoadAtmo()
	if not file.Exists("Atmos","DATA") or not file.Exists("Atmos/"..self.ScreenName..".txt","DATA") then return false end
	
	local Str = file.Read("Atmos/"..self.ScreenName..".txt","DATA")
	local Tab = ReturnTableFromStr(Str)
	for I,P in pairs(Tab) do
		if I == "Pressure" then self.Pressure = tonumber(P)
		else
			self.RealAtmosphere[I] = tonumber(P)
		end
	end
	
	self:CalcAtmo()
	return true
end

function ENT:CalcBreath()
	for I,P in pairs(self.Atmosphere) do
		if Gases[I].Toxic and P >= 1 then
			self.Breathable = false
			return
		end
	end
	
	self.Breathable = self.Atmosphere["Oxygen"] and self.Atmosphere["Oxygen"] > 15 and self.Atmosphere["Oxygen"] < 25 and self.RealAtmosphere["Oxygen"] > 10000
end

function ENT:DoScience()
	if self.Atmosphere.Steam and self.Atmosphere.Steam > 0 and self.Temperature < 100 then
		self:AddAtmosphere("Steam",-16)	// Rain
	end
	
	self.NextScience = CurTime() + 1
end

function ENT:SetAtmosphere(Str,Val)
	if self.Locked then return end
	if not table.HasValue(I_Gases,Str) then return end
	self.RealAtmosphere[Str] = math.Clamp(Val,0,math.pow(2,20))
	self:CalcAtmo()
end

function ENT:AddAtmosphere(Str,Val)
	if self.Locked then return end
	if not table.HasValue(I_Gases,Str) or not Val or Val == 0 then return end
	if not self.RealAtmosphere[Str] then self.RealAtmosphere[Str] = 0 end
	self.RealAtmosphere[Str] = math.Clamp(self.RealAtmosphere[Str] + Val,0,math.pow(2,20))
	self:CalcAtmo()
end

function ENT:GetAtmosphere(Str)
	if not self.Atmosphere[Str] then return 0 end
	return self.Atmosphere[Str] or 0
end

function ENT:IsOnPlanet(ent)
	return table.HasValue(self.Ents,ent)
end

function ENT:SetGrav(ent)
	if not IsValid(ent) then return end
	if self:IsOnPlanet(ent) then
		ent.Grav = self.Gravity
		local Grav = 0
		if self.Gravity == 0 then 
			Grav = 0.000001 
		else 
			Grav = self.Gravity 
		end
		ent:SetGravity(Grav)
		local Phys = ent:GetPhysicsObject()
		if Phys:IsValid() then
			Phys:EnableGravity(true)
			Phys:EnableDrag(true)
		end
	elseif not ent.GravityGot then
		ent.Grav = false
		ent:SetGravity(0.000001)
		local Phys = ent:GetPhysicsObject()
		if Phys:IsValid() then
			Phys:EnableGravity(false)
			Phys:EnableDrag(false)
		end
	end
end