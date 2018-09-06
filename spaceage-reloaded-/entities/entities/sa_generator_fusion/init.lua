AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:Int()
	self.Coolant = 0
	self.Temperature = 30
	self.Exploding = false
	self.Class = "RD"
	self.SubClass = "Generator"
	self.ROutputs.Energy = math.pow(2,10)
	self.ROutputs.Steam = math.pow(2,6)
	self.RInputs.Water = math.pow(2,6)
	self.RInputs.Heavy_Water = math.pow(2,5)
	self.Humming = CreateSound(self,Sound("ambient/machines/combine_shield_loop3.wav"))
	
	self.Inputs = Wire_CreateInputs(self,{"On","Sound Off"})
	self.Outputs = Wire_CreateOutputs(self,{"Status","Temperature"})
end

function ENT:CheckLevel()
	if self:GetNWEntity("Owner"):GetResearch("Fusion_Research") < self.SizeNumber then return false end
	return true
end

function ENT:SetSizeNumber(Num)
	self.SizeNumber = Num	
	if Num == 4 then Num = 20 end
	self.ROutputs.Energy = math.Round((math.pow(2,10) / 2) * Num) * (1 + self:GetNWEntity("Owner"):GetResearch("Fusion_Power_Up") / 100)
end

function ENT:ThinkStart()
	if not self.Online then
		if self.Coolant > 0 then self.Coolant = math.Clamp(self.Coolant - 0.2,0,100)
		elseif self.Coolant < 0 then self.Coolant = math.Clamp(self.Coolant + 0.2,-50,0) end
		
		self.Temperature = 30 + math.Round(((self.Coolant / 100) * 70) * 100) / 100
		Wire_TriggerOutput(self,"Temperature",self.Temperature)
	end
end

function ENT:BeforeQueue()
	if not table.HasValue(self.Got,"Water") and not table.HasValue(self.Got,"Heavy_Water") then
		for I,P in pairs(self.Queue) do
			if P[2] == "Steam" then
				table.remove(self.Queue,I)
			end
		end
	end
	return true
end

function ENT:ThinkEnd()
	if table.HasValue(self.Got,"Heavy_Water") then
		if self.Coolant > -50 then self.Coolant = math.Clamp(self.Coolant - 1,-50,100) end
	elseif table.HasValue(self.Got,"Water") then
		self.Coolant = self.Coolant + 0.2 - (1 * self:GetNWEntity("Owner"):GetResearch("Fusion_Generator_Coolant") / 100)
	else
		self.Coolant = self.Coolant + 1 - (1 * self:GetNWEntity("Owner"):GetResearch("Fusion_Generator_Coolant") / 100)
	end
	self.Temperature = 30 + math.Round(((self.Coolant / 100) * 70) * 100) / 100
	Wire_TriggerOutput(self,"Temperature",self.Temperature)
	
	if self.Coolant > 60 then
		local Eff = EffectData()
		Eff:SetScale(1)
		Eff:SetRadius(100)
		local Min,Max = self:WorldSpaceAABB()
		Eff:SetOrigin(self:GetPos() + ((Max - Min) / 2) * Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
		Eff:SetStart(self:GetPos() + ((Max - Min) / 2) * Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
		util.Effect("ManhackSparks",Eff)
		if math.random(1,3) == 2 then
			local Links = self:UpdateLinks()
			local Ran = math.random(1,math.Round(self.Coolant / 40))
			for I,P in pairs(Links) do
				if Ran > 0 and P ~= self then
					if P.SubClass == "Storage" then
						local Min,Max = P:WorldSpaceAABB()
						Ran = Ran - 1
						if P.Storage.Energy then
							P:AddResource("Energy",math.Round(-P.Storage.Energy * 0.1))
							Eff:SetOrigin(P:GetPos() + ((Max - Min) / 2) * Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
							Eff:SetStart(P:GetPos() + ((Max - Min) / 2) * Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
							util.Effect("ManhackSparks",Eff)
						else
							local N,A = next(P.Storage)
							P:AddResource(N,math.Round(-A * 0.1))
							Eff:SetOrigin(P:GetPos() + ((Max - Min) / 2) * Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
							Eff:SetStart(P:GetPos() + ((Max - Min) / 2) * Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
							util.Effect("ManhackSparks",Eff)
						end
					elseif P.SubClass == "Generator" and P.Online then
						Ran = Ran - 1
						P:Off()
						local Min,Max = P:WorldSpaceAABB()
						Eff:SetOrigin(P:GetPos() + ((Max - Min) / 2) * Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
						Eff:SetStart(P:GetPos() + ((Max - Min) / 2) * Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
						util.Effect("ManhackSparks",Eff)
					end
				elseif Ran == 0 then
					break
				end
			end
		end
		
		self:SetColor(Color(255 * 1 - (self.Coolant / 150),255 * 1 - (self.Coolant / 150),255 * 1 - (self.Coolant / 150)))
	end
	
	if self.Coolant > 80 then
		if math.random(1,3) == 2 then
			local Min,Max = self:WorldSpaceAABB()
			local Eff = EffectData()
			Eff:SetScale(2)
			Eff:SetRadius(100)
			Eff:SetScale(math.random(1,5))
			Eff:SetOrigin(self:GetPos() + ((Max - Min) / 2) * Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
			util.Effect("Explosion",Eff)
		end
	end
	
	if self.Coolant >= 100 and not self.Exploding then
		self.Exploding = true
		local Eff = EffectData()
		Eff:SetScale(math.random(3,5))
		local Min,Max = self:WorldSpaceAABB()
		Eff:SetOrigin(self:GetPos() + ((Max - Min) / 2) * Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
		util.Effect("Explosion",Eff)
		timer.Create("FusionExplosion #"..self:EntIndex(),0.4,3,function()
			local Eff = EffectData()
			Eff:SetScale(math.random(5,8))
			Eff:SetOrigin(self:GetPos() + ((Max - Min) / 2) * Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
			util.Effect("Explosion",Eff)
		end)
		timer.Simple(1.6,function()
			local Eff = EffectData()
			Eff:SetScale(math.random(5,8))
			Eff:SetOrigin(self:GetPos() + ((Max - Min) / 2) * Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
			util.Effect("reactor_exp",Eff)
		end)
		timer.Simple(2,function() 
			local Eff = EffectData()
			Eff:SetScale(math.random(5,8))
			Eff:SetOrigin(self:GetPos() + ((Max - Min) / 2) * Vector(math.Rand(-1,1),math.Rand(-1,1),math.Rand(-1,1)))
			util.Effect("reactor_exp2",Eff)
			local Pos = self:GetPos() 
			local Ents = GetConstrainedInRadius(self,(Max - Min):Length() * 2)
			for I,P in pairs(Ents) do
				if P.Links and P.Class then
					P:Snap()
					P:EmitSound("phx/epicmetal_hard4.wav",100,255)
				end
				constraint.RemoveAll(P)
			end
			self:Remove()
		end)
	end
end