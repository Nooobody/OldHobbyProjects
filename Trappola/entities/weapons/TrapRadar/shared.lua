if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if CLIENT then
	SWEP.PrintName			= "TrapRadar"
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 40
    SWEP.Slot               = 3
    SWEP.SlotPos            = 1
	SWEP.ViewModelFlip		= false
end

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel				= "models/weapons/v_pistol.mdl"
SWEP.WorldModel				= "models/weapons/w_pistol.mdl"

SWEP.Primary.Sound			= Sound( "" )
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.Delay			= 1

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

if CLIENT then

	Targets = {}
	
	function SWEP:AddEnrg(Val)
		self.Energy = math.Clamp(self.Energy + Val,0,RadarMaxEnergy)
	end
	
	function SWEP:GetEnrg()
		return self.Energy
	end
	
	function SWEP:ToggleRadar()
		if self.Radar then
			self.Radar = false
		else
			self.Radar = true
			if not self.Ping:IsVisible() then
				self:Pinging()
			end
		end
	end
	
	function SWEP:Pinging()
		if not self.Radar then return end
		if self.Ping:IsVisible() then return end
		if self:GetEnrg() < 10 then self.Radar = false return end
		for I,P in pairs(ents.FindInCone(self.Owner:EyePos(),self.Owner:EyeAngles():Forward(),500,20)) do
			if string.Left(P:GetClass(),5) == "trap_" and P:GetClass() ~= "trap_fakeartifact" then
				local LocalPos,Pos = self.Owner:EyePos(),P:GetPos()
				local L = math.sqrt(math.pow(Pos.x - LocalPos.x,2) + math.pow(Pos.y - LocalPos.y,2))
				local Arc = (math.acos((Pos.y - LocalPos.y) / L) * 180) / math.pi
				local Ang = (Pos - LocalPos):Angle() - self.Owner:EyeAngles()
				table.insert(Targets,{300 + (-Ang:Forward().y * 3) * 100,L,1,false,P})
			end
		end
		local Size = 0
		Al = 105
		if not self.Ping or not self.Ping:IsValid() then
			self.Ping = vgui.Create("DPanel",Panel)
			self.Ping:SetSize(1,1)
			self.Ping:SetPos(300,580)
			if not self.Panel or not self.Panel:IsValid() then
				self:Deploy()
			end
		end
		self.Ping:SetVisible(true)
		timer.Create("Pinging",0,0,function()
			Size = Size + RadarPingSpeed
			if not self.Ping or not self.Ping:IsValid() then timer.Remove("Pinging") return end
			self.Ping:SetSize(Size * 2,math.min(Size,20))
			self.Ping:SetPos(300 - Size,580 - Size)
			self.Ping.Paint = function(Self)
				if self.Owner:GetActiveWeapon() ~= self then return end
				local Circ
				if Size < 20 then
					Circ = Size / 2
				elseif Size < 300 then
					Circ = Size
				else
					Circ = Size * 2
				end
				surface.DrawCircle(Size,Circ,Circ,Color(255,255,255,255))
			end
			for I,P in pairs(Targets) do
				local X,Distance,BDone = P[1],P[2],P[4]
				if not BDone then
					if Distance < Size then
						local SavedSize = Size
						if X >= 300 - SavedSize / 2 and X <= 300 + SavedSize / 2 then
							self.Owner:EmitSound(Sound("buttons/blip1.wav"))
							Targets[I][4] = true
						else
							table.remove(Targets,I)
						end
					end
				end
			end
			if Size >= 580 then
				self.Ping:SetVisible(false)
				timer.Remove("Pinging")
				timer.Simple(RadarDelay,function() 
					if self.Radar then
						self:Pinging()
					end
				end)
			end
		end)
		self:AddEnrg(-10)
	end
	SWEP.Radar = false
	SWEP.Triggered = false
	SWEP.SecTriggered = false
	SWEP.Energy = 100
	Al = 0
end

function SWEP:Think()
	if not self.Panel or not self.Panel:IsValid() then return end
	if LobbyPanel:IsVisible() or ChatAnchor:IsVisible() and self.Panel:IsVisible() then
		self.Panel:SetVisible(false)
	elseif not self.Panel:IsVisible() and not LobbyPanel:IsVisible() and not ChatAnchor:IsVisible() then
		self.Panel:SetVisible(true)
	end
end

function SWEP:Initialize()
end

function SWEP:Deploy()
	if SERVER then return end
	if not self.Weapon:IsCarriedByLocalPlayer() then return end
	for I,P in pairs(Lvls) do
		if P["I"] == "RadarMaxEnergy" then
			RadarMaxEnergy = GetData("Scout","RadarMaxEnergy",P["lvl"])
		elseif P["I"] == "RadarRegain" then
			RadarRegain = GetData("Scout","RadarRegain",P["lvl"])
		elseif P["I"] == "RadarDelay" then
			RadarDelay = GetData("Scout","RadarDelay",P["lvl"])
		elseif P["I"] == "RadarPingSpeed" then
			RadarPingSpeed = GetData("Scout","RadarPingSpeed",P["lvl"])
		end
	end
	timer.Create("Regenerating - "..self.Owner:Name(),0.1,0,function(Name)
		if not LocalPlayer() or not LocalPlayer():IsValid() or self.Weapon ~= LocalPlayer():GetActiveWeapon() or not self.Weapon:IsCarriedByLocalPlayer() then timer.Remove("Regenerating - "..Name) return end
		self:AddEnrg(RadarRegain)
	end,self.Owner:Name())
	self.Energy = self.Energy or RadarMaxEnergy
	self.Radar = false
	self.Triggered = false
	self.SecTriggered = false
	if self.Panel and self.Panel:IsValid() then
		self.Panel:Remove()
	end
	self.Panel = vgui.Create("DPanel")
	self.Panel:SetSize(600,600)
	self.Panel:SetPos(10,10)
	self.Panel.Paint = function()
		if not self or not self.Weapon then return end
		if LocalPlayer():GetActiveWeapon() ~= self.Weapon then return end
		if Al > 0 then
			Al = Al - 0.1
		end
		surface.SetDrawColor(150 + Al,150 + Al,150 + Al,255)
		surface.DrawLine(20,20,300,580)
		surface.DrawLine(300,580,580,20)
		surface.DrawOutlinedRect(500,500,80,6)
		draw.DrawText("Energy","DefaultLarge",540,480,Color(150 + Al,150 + Al,150 + Al,255),TEXT_ALIGN_CENTER)
		local Percent = self:GetEnrg() / RadarMaxEnergy
		surface.SetDrawColor(0,150 + Al,0,255)
		surface.DrawRect(501,501,78 * Percent,4)
		for I,P in pairs(Targets) do
			local X,Distance,Time,B = P[1],P[2],P[3],P[4]
			if B then
				local Al = Time * 255
				surface.SetDrawColor(255,0,0,Al)
				surface.DrawRect(X - 2,580 - Distance - 4,4,8)
				surface.DrawRect(X - 4,580 - Distance - 2,8,4)
				Targets[I][3] = Time - 0.01
				if Time <= 0 then
					table.remove(Targets,I)
				end
			end
		end
	end
	self.OC = vgui.Create("DPanel",self.Panel)
	self.OC:SetSize(580,20)
	self.OC:SetPos(10,15)
	self.OC.Paint = function()
		if LocalPlayer():GetActiveWeapon() ~= self.Weapon then return end
		surface.DrawCircle(280,1500,1500,Color(150 + Al,150 + Al,150 + Al,255))
	end
	self.IC = vgui.Create("DPanel",self.Panel)
	self.IC:SetSize(480,20)
	self.IC:SetPos(135,290)
	self.IC.Paint = function()
		if LocalPlayer():GetActiveWeapon() ~= self.Weapon then return end
		surface.DrawCircle(165,400,400,Color(150 + Al,150 + Al,150 + Al,255))
	end
	self.Ping = vgui.Create("DPanel",self.Panel)
	self.Ping:SetSize(1,1)
	self.Ping:SetPos(300,580)
	self.Ping:SetVisible(false)
	
	hook.Add("PreDrawTranslucentRenderables","RadarPings",function()
		if not self or not self.Weapon then hook.Remove("PreDrawTranslucentRenderables","RadarPings") return end
		if not self.Weapon:IsCarriedByLocalPlayer() or LocalPlayer():GetActiveWeapon() ~= self.Weapon then hook.Remove("PreDrawTranslucentRenderables","RadarPings") return end
		for I,P in pairs(Targets) do
			if P[4] then
				local Time = P[3]
				local Ent = P[5]
				if not Ent:IsValid() then table.remove(Targets,I) return end
				cam.Start3D2D(Ent:GetPos(),Angle(0,0,0),1)
					cam.IgnoreZ(true)
					surface.DrawCircle(0,0,(1 - Time) * 20,Color(255,0,0,255 * Time))
					cam.IgnoreZ(false)
				cam.End3D2D()
			end	
		end
	end)
	return true
end

function SWEP:Holster()
	if SERVER then return true end
	self.Radar = false
	self.Triggered = false
	self.SecTriggered = false
	if self.Panel and self.Panel:IsValid() then
		self.Panel:Remove()
	end
	return true
end

function SWEP:OnRemove()
	if SERVER then return end
	self.Radar = false
	self.Triggered = false
	self.SecTriggered = false
	if self.Panel and self.Panel:IsValid() then
		self.Panel:Remove()
	end
end

function SWEP:PrimaryAttack()
	if CLIENT and not self.Triggered then
		self.Triggered = true
		self:ToggleRadar()
		timer.Simple(0.5,function() self.Triggered = false end)
	end
end

function SWEP:SecondaryAttack()
	if CLIENT then return end
	if self.SecTriggered then return end
	self.SecTriggered = true
	timer.Simple(0.1,function() self.SecTriggered = false end)
	local Tr = self.Owner:GetEyeTrace().HitPos
	if Tr:Distance(self.Owner:GetPos()) >= 500 then return end
	local RF = RecipientFilter()
	for I,P in pairs(team.GetPlayers(1)) do
		RF:AddPlayer(P)
	end
	umsg.Start("TrapHere",RF)
		umsg.Short(Tr.x)
		umsg.Short(Tr.y)
		umsg.Short(Tr.z)
	umsg.End()
	for I,P in pairs(ents.FindInSphere(Tr,100)) do
		if string.Left(string.lower(P:GetClass()),5) == "trap_" then
			P.RadarGuy = self.Owner:EntIndex()
			timer.Simple(15,function() P.RadarGuy = nil end)
		end
	end
end

function SWEP:Reload()
end