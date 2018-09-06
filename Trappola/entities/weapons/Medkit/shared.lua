if SERVER then
	AddCSLuaFile("shared.lua")
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
end

if CLIENT then
	SWEP.PrintName			= "Medkit"
	SWEP.DrawAmmo			= false
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 40
    SWEP.Slot               = 1
    SWEP.SlotPos            = 1
	SWEP.ViewModelFlip		= false
end

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.ViewModel				= "models/w_models/weapons/w_eq_medkit.mdl"
SWEP.WorldModel				= "models/w_models/weapons/w_eq_medkit.mdl"

SWEP.Primary.Sound			= Sound( "" )
SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 0
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0
SWEP.Primary.Delay			= 1

SWEP.Primary.ClipSize		= 1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "pistol"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.HoldType = "physgun"
function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
	self.Time = 3
end

function SWEP:Deploy()
	self.Time = 3
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:GetViewModelPosition(pos,ang)
	pos = self.Owner:EyePos() + self.Owner:GetAngles():Forward() * 20 - Vector(0,0,10)
	return pos,ang
end

function SWEP:DrawHUD()
	if timer.IsTimer("Healing - "..self.Owner:EntIndex()) then
		local Scl = 1 - (self.Time / 3)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawOutlinedRect(ScrW() / 2 - 100,200,200,40)
		surface.SetDrawColor(0,255,0,255)
		surface.DrawRect(ScrW() / 2 - 90,210,180 * Scl,20)
		draw.DrawText("Healing...","TargetID",ScrW() / 2,180,Color(255,255,255,255),TEXT_ALIGN_CENTER)
	end
end

function SWEP:PrimaryAttack()
	if self.Owner:KeyDown(IN_ATTACK2) then return end
	local Ply = self.Owner:GetEyeTrace().Entity
	if Ply:GetPos():Distance(self.Owner:GetPos()) > 100 then return end
	if Ply:GetVelocity():Length() > 0 then 
		if not self.Said then
			RunConsoleCommand("say","Quit buzzing and let me heal you!") 
			self.Said = true 
		end
		return 
	end
	if Ply and Ply:IsPlayer() and Ply:Health() < Ply:GetNWInt("MaxHealth") and not timer.IsTimer("Healing - "..self.Owner:EntIndex()) then
		if SERVER then
			Ply:SetNWInt("Healing",self.Time)
			Ply:SetNWString("Healer",self.Owner:Name())
		end
		timer.Create("Healing - "..self.Owner:EntIndex(),0.1,0,function(Idx)
			if not self.Owner then timer.Remove("Healing - "..Idx) return end
			if not self.Owner:KeyDown(IN_ATTACK) or self.Owner:GetVelocity():Length() > 0 or Ply:GetVelocity():Length() > 0 then
				if SERVER then
					Ply:SetNWInt("Healing",0)
					Ply:SetNWString("Healer","")
				end
				self.Time = 3
				timer.Remove("Healing - "..Idx)
				return
			end
			self.Time = self.Time - 0.1
			if SERVER then
				Ply:SetNWInt("Healing",self.Time)
			end
			if CLIENT then
				if self.Time ~= Ply:GetNWInt("Healing") then
					self.Time = Ply:GetNWInt("Healing")
				end
			end
			if self.Time <= 0 then
				if SERVER then
					local hp = math.min(Ply:GetNWInt("MaxHealth"),Ply:Health() + self.Owner.Medic)
					Ply:SetHealth(hp)
					Ply:SetNWString("Healer","")
					self.Owner:SetNWBool("Medkit",false)
					self:TakePrimaryAmmo(1)
					self.Owner:StripWeapon("MedKit")
				end
				timer.Remove("Healing - "..Idx)
				return
			end
		end,self.Owner:EntIndex())
	end
end

function SWEP:SecondaryAttack()
	if self.Owner:KeyDown(IN_ATTACK) or self.Owner:GetVelocity():Length() > 0 then return end
	if self.Owner:Health() < self.Owner.MaxHealth and not timer.IsTimer("Healing - "..self.Owner:EntIndex()) then
		timer.Create("Healing - "..self.Owner:EntIndex(),0.1,0,function(Idx)
			if not self.Owner then timer.Remove("Healing - "..Idx) return end
			if not self.Owner:KeyDown(IN_ATTACK2) or self.Owner:GetVelocity():Length() > 0 then
				self.Time = 3
				timer.Remove("Healing - "..Idx)
				return
			end
			self.Time = self.Time - 0.1
			if self.Time <= 0 then
				if SERVER then
					local hp = math.min(self.Owner.MaxHealth,self.Owner:Health() + (self.Owner.Medic * 0.75))
					self.Owner:SetHealth(hp)
					self.Owner:SetNWBool("Medkit",false)
					self:TakePrimaryAmmo(1)
					self.Owner:StripWeapon("MedKit")
				end
				timer.Remove("Healing - "..Idx)
			end
		end,self.Owner:EntIndex())
	end
end