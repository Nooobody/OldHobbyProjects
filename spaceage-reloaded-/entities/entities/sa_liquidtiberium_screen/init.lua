AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("helperfunctions/cl_tqstates.lua")

include("shared.lua")

util.AddNetworkString("Terminal_StartLiqTib")
util.AddNetworkString("Terminal_LiqTibTransmit")
util.AddNetworkString("Terminal_LiqTibTransmitProgress")
util.AddNetworkString("Terminal_Loader_Open")
util.AddNetworkString("Terminal_Loader_Close")
util.AddNetworkString("Terminal_Loader_Load")
util.AddNetworkString("Terminal_Loader_Unload")

function ENT:CheckLink()
	return IsValid(self.Loader.Stor)
end

function ENT:Check(CameFromC)
	if not IsValid(self.PlayerUsing) then return false end
	if self:CheckLink() then
		local Sto = self.Loader.Stor
		net.Start("Terminal_StartLiqTib")
			net.WriteEntity(self)
			net.WriteInt(TIB_REF.RawTiberium,32)
			net.WriteInt(TIB_REF.Tiberium,32)
			net.WriteBit(true)
			net.WriteInt(Sto.Storage.LiquidTiberium,32)
			net.WriteInt(Sto.StorageMax.LiquidTiberium,32)
		net.Send(self.PlayerUsing)
		return true
	else
		net.Start("Terminal_StartLiqTib")
			net.WriteEntity(self)
			net.WriteInt(TIB_REF.RawTiberium,32)
			net.WriteInt(TIB_REF.Tiberium,32)
			net.WriteBit(false)
		net.Send(self.PlayerUsing)
		timer.Simple(1,function() self:Check() end)
		return false
	end
end

function ENT:TimeOutAction()
	if self.Loader.State > 0 then
		self.Loader.DoneTransmit = true
		self.Loader.State = 1
		self.Loader.Stage = 0
		self.Loader.Queue = {}
		self.Loader:Close()
	end
end

function ENT:UseAction(act,cal)
	if self:CheckLink() then
		self:SetNWString("Loader_Status","Loaded")
	else self:SetNWString("Loader_Status","Closed") end
	self:Check()
	local Int = 0
	timer.Create(self.TimerName,1,0,function()
		if not IsValid(self.PlayerUsing) or not self.PlayerUsing:IsPlayer() then 
			self:TimeOut(true)
			return 
		end
		local Tr = self.PlayerUsing:GetEyeTrace()
		if not Tr.Entity or Tr.Entity ~= self or self:GetPos():Distance(self.PlayerUsing:GetPos()) > 100 then
			Int = Int + 1
		elseif Int > 0 then
			Int = 0
		end
		
		if not self:CheckLink() then
			if Int > 30 then
				self:TimeOut()
			end
		end
	end)
end

net.Receive("Terminal_LiqTibTransmit",function(len,ply)
	local Ent = net.ReadEntity()
	Ent:SetNWString("Loader_Status","Transmitting")

	local Stor = Ent.Loader.Stor
	Ent.Loader.DoneTransmit = false
	Ent.Loader:Transmit()
	local TimerName = "Tib_Terminal #"..Stor:EntIndex()
	timer.Create(TimerName,1,0,function()
		local Stor = Ent.Loader.Stor
		if not IsValid(Stor) or not Stor.Storage then // It got removed! :S
			Ent.Loader.DoneTransmit = true
			Ent.Loader:Unload(function() Ent.Loader:Close() end)
			Ent:SetNWString("Loader_Status","Closed")
			timer.Destroy(TimerName)
		end

		if Stor.Storage.LiquidTiberium < Stor.StorageMax.LiquidTiberium and TIB_REF.Tiberium > 0 then
			local Am = math.Round(math.min(Stor.StorageMax.LiquidTiberium / 60,Stor.StorageMax.LiquidTiberium - Stor.Storage.LiquidTiberium,TIB_REF.Tiberium))
			TIB_REF.Tiberium = TIB_REF.Tiberium - Am
			Stor:AddResource("LiquidTiberium",Am)
			SaveTib()
			
			net.Start("Terminal_LiqTibTransmitProgress")
				net.WriteEntity(Ent)
				net.WriteInt(TIB_REF.Tiberium,32)
				net.WriteInt(Stor.Storage.LiquidTiberium,32)
			net.Send(Ent.PlayerUsing)
		else
			Ent.Loader.DoneTransmit = true
			Ent:SetNWString("Loader_Status","Loaded")
			timer.Destroy(TimerName)
		end
	end)
end)

net.Receive("Terminal_Loader_Open",function(len,ply)
	local Ent = net.ReadEntity()
	Ent:SetNWString("Loader_Status","Moving")
	local Res = Ent.Loader:Open(function()
		Ent:SetNWString("Loader_Status","Open")
	end)
	if not Res then
		Ent:SetNWString("Loader_Status","Closed")
	end
end)

net.Receive("Terminal_Loader_Close",function(len,ply)
	local Ent = net.ReadEntity()
	Ent:SetNWString("Loader_Status","Moving")
	local Res = Ent.Loader:Close(function()
		Ent:SetNWString("Loader_Status","Closed")
	end)
	if not Res then
		Ent:SetNWString("Loader_Status","Open")
	end
end)

net.Receive("Terminal_Loader_Load",function(len,ply)
	local Ent = net.ReadEntity()
	Ent:SetNWString("Loader_Status","Moving")
	local Res = Ent.Loader:Load(function()
		Ent:SetNWString("Loader_Status","Loaded")
		Ent:Check()
	end)
	if not Res then
		Ent:SetNWString("Loader_Status","Open")
	end
end)

net.Receive("Terminal_Loader_Unload",function(len,ply)
	local Ent = net.ReadEntity()
	Ent:SetNWString("Loader_Status","Moving")
	local Res = Ent.Loader:Unload(function()
		Ent:SetNWString("Loader_Status","Open")
		Ent:Check()
	end)
	if not Res then
		Ent:SetNWString("Loader_Status","Loaded")
	end
end)