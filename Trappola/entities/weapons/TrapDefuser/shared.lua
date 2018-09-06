if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if CLIENT then
	SWEP.PrintName			= "TrapDefuser"
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

function SWEP:Think()	
	if self.Owner:KeyPressed(IN_ATTACK) then
		if self.Owner:GetPos():Distance(self.Owner:GetEyeTrace().HitPos) > 300 then return end
		local Angl = self.Owner:EyeAngles()
		timer.Create("CountDefu - "..self.Owner:Name(),0.1,0,function(Name)
			if not self.Owner then
				timer.Remove("CountDefu - "..Name)
				return
			end
			if self.Owner:GetVelocity():Length() > 0 or not self.Owner:KeyDown(IN_ATTACK) or self.Owner:EyeAngles() ~= Angl then
				self.Time = self.DefuseTime
				timer.Remove("CountDefu - "..Name)
				return
			end
			self.Time = math.Clamp(self.Time - 0.1,0,self.DefuseTime)
			if self.Time <= 0 then
				if SERVER then
					for I,P in pairs(ents.FindInSphere(self.Owner:GetEyeTrace().HitPos,self.DefuseRadius)) do
						if string.Left(P:GetClass(),5) == "trap_" and not P:GetNWBool("Defused") and not P.Triggered then
								local num = math.random(0,100)
								if num > self.Owner.DefuseChance then
									P:SetNWInt("Defused",true)
									self.Owner.Defused = self.Owner.Defused + 1
									self.Owner:AddExp(25)
									DB_UpdateAddIndPly(self.Owner:SteamID(),"Defusings",1)
									ShoutIt("You got 25 exp from defusing a trap!",self.Owner)
									if P.RadarGuy then
										local RadarGuy = Entity(P.RadarGuy)
										RadarGuy:AddExp(25)
										ShoutIt("You got 25 exp from pinging a trap for a defuser!",RadarGuy)
									end
								else
									P:Trigger(self.Owner)
								end
							break
						end
					end
				end
				timer.Remove("CountDefu - "..Name)
			end
		end,self.Owner:Name())
	elseif self.Owner:KeyReleased(IN_ATTACK) then
		self.Time = self.DefuseTime
		if timer.IsTimer("CountDefu - "..self.Owner:Name()) then
			timer.Remove("CountDefu - "..self.Owner:Name())
		end
	end
end

function SWEP:DrawHUD()
	if self.Owner:KeyDown(IN_ATTACK) and self.Time > 0 then
		if self.Owner:GetPos():Distance(self.Owner:GetEyeTrace().HitPos) > 300 then
			draw.DrawText("Too far away!","MenuLarge",ScrW() / 2,200,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		elseif timer.IsTimer("CountDefu - "..self.Owner:Name()) then
			local Scl = 1 - (self.Time / self.DefuseTime)
			surface.SetDrawColor(255,255,255,255)
			surface.DrawOutlinedRect(ScrW() / 2 - 100,200,200,40)
			surface.SetDrawColor(0,255,0,255)
			surface.DrawRect(ScrW() / 2 - 90,210,180 * Scl,20)
			draw.DrawText("Defusing traps...","TargetID",ScrW() / 2,180,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		end
	end
end

function SWEP:Initialize()
	self.Time = 1.5
end
	
function SWEP:Deploy()
	if CLIENT then
		for I,P in pairs(Lvls) do
			if P["I"] == "DefuseTime" then
				self.DefuseTime = GetData("Defuser","DefuseTime",P["lvl"])
				self.Time = self.DefuseTime
			elseif P["I"] == "DefuseRadius" then
				self.DefuseRadius = GetData("Defuser","DefuseRadius",P["lvl"])
			end
		end
	end
	if SERVER then
		self.DefuseTime = self.Owner.DefuseTime
		self.Time = self.DefuseTime
		self.DefuseRadius = self.Owner.DefuseRadius
	end
	self.Time = self.DefuseTime
	return true
end

function SWEP:ViewModelDrawn()
	local Tab = {self.Owner}
	for I,P in pairs(ents.FindByClass("trap_*")) do
		if P:GetClass() ~= "trap_fakeartifact" then
			table.insert(Tab,P)
		end
	end
	local Tr = {}
	Tr.start = self.Owner:EyePos()
	Tr.endpos = self.Owner:EyePos() + EyeAngles():Forward() * 300
	Tr.filter = Tab
	local Trace = util.TraceLine(Tr)
	if Trace.HitWorld and not Trace.HitNonWorld then
		local Nor = Trace.HitNormal
		local Ang = Nor:Angle()
		cam.Start3D2D(Trace.HitPos,Ang + Angle(90,0,0),1)
			cam.IgnoreZ(true)
			surface.DrawCircle(0,0,self.DefuseRadius,Color(255,0,0,255))
			cam.IgnoreZ(false)
		cam.End3D2D()
	end
end

function SWEP:Holster()
	return true
end

function SWEP:OnRemove()
end
	
function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end