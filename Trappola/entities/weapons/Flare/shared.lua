if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if CLIENT then
	SWEP.PrintName			= "Flare"
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 40
    SWEP.Slot               = 0
    SWEP.SlotPos            = 1
	SWEP.ViewModelFlip		= false
end

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel				= "models/props/viewflaremodel.mdl"
SWEP.WorldModel				= "models/props/worldflaremodel.mdl"

SWEP.Primary.Sound			= Sound( "" )
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.Delay			= 0

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

function SWEP:Think()
	if SERVER then
		if self == self.Owner:GetActiveWeapon() and not self.Online then
			if not self.Triggered then
				self.Triggered = true
				timer.Simple(1,function() self.Triggered = false end)
				umsg.Start("flare")
					umsg.Short(self.Owner:EntIndex())
					umsg.Long(self:EntIndex())
					umsg.String(self.Owner.FlareR..","..self.Owner.FlareG..","..self.Owner.FlareB)
				umsg.End()
				self.Online = true
			end
		end
	end
end

function SWEP:DrawWorldModel()
end

SWEP.HoldType = "pistol"
function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
	if SERVER then
		umsg.PoolString("flare")
		self.Triggered = false
		self.Online = false
	end
end

function SWEP:GetViewModelPosition(pos,ang)
	pos = self.Owner:EyePos() + self.Owner:GetAngles():Forward() * 20 + self.Owner:GetAngles():Right() * 10 - Vector(0,0,15)
	return pos,ang
end

function SWEP:Deploy()
	if SERVER then
		if not self.Triggered then
			self.Triggered = true
			timer.Simple(1,function() self.Triggered = false end)
			umsg.Start("flare")
				umsg.Short(self.Owner:EntIndex())
				umsg.Long(self:EntIndex())
				umsg.String(self.Owner.FlareR..","..self.Owner.FlareG..","..self.Owner.FlareB)
			umsg.End()
			self.Online = true
		end
	end
	return true
end

function SWEP:Holster()
	self.Online = false
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