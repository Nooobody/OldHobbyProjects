AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("helperfunctions/cl_tstates.lua")

include("shared.lua")

util.AddNetworkString("Terminal_StartTib")
util.AddNetworkString("Terminal_TibTransmit")
util.AddNetworkString("Terminal_TibTransmitProgress")

function ENT:CheckLink()
	local Stor = self.Holder:ReturnStor()
	return IsValid(Stor[1]) or IsValid(Stor[2])
end

function ENT:Check(CameFromC)
	if not IsValid(self.PlayerUsing) then return false end
	if self:CheckLink() then
		local Sto = self.Holder:ReturnStor()
		local T = {}
		for I,P in pairs(Sto) do
			if P.Storage.RawTiberium > 0 then
				table.insert(T,{P.Storage.RawTiberium,P.StorageMax.RawTiberium,I,P.GreenTiberium or 0,P.BlueTiberium or 0})
			end
		end
		net.Start("Terminal_StartTib")
			net.WriteEntity(self)
			net.WriteBit(true)
			net.WriteTable(T)
		net.Send(self.PlayerUsing)
		return true
	else
		net.Start("Terminal_StartTib")
			net.WriteEntity(self)
			net.WriteBit(false)
		net.Send(self.PlayerUsing)
		timer.Simple(1,function() self:Check() end)
		return false
	end
end

function ENT:UseAction(act,cal)
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
			if Int > 15 then
				self:TimeOut()
			end
		end
	end)
end

net.Receive("Terminal_RefreshTable",function(len,ply)
	local Ent = net.ReadEntity()
	Ent:Check(true)
end)

net.Receive("Terminal_TibTransmit",function(len,ply)
	local Ent = net.ReadEntity()
	local Int = net.ReadInt(4)
	
	local Stor = Ent.Holder:ReturnStor()[Int]
	if Stor:GetNWEntity("Owner") ~= Ent.PlayerUsing then 
		ShoutIt("You can't do that!",Ent.PlayerUsing)
		Ent:TimeOut()
		return
	end
	local TimerName = "Tib_Terminal #"..Stor:EntIndex()
	timer.Create(TimerName,1,0,function()
		local Stors = Ent.Holder:ReturnStor()
		if not IsValid(Stors[Int]) then	// Link broke
			timer.Destroy(TimerName)
			return
		end
		if Stor.Storage.RawTiberium > 0 then
			local IsBlue,Blue,Green = Stor:GetTib()
			if not IsBlue then
				Green = Blue
				Blue = 0
			end
			
			TIB_REF.RawTiberium = TIB_REF.RawTiberium + Blue + Green
			SaveTib()
			
			local Bonus = 1 + (Ent.PlayerUsing:CheckFaction("Money_Tib") / 100)
			Ent.PlayerUsing:AddMoney((MARKETABLE["RawTiberium"] * Green + MARKETABLE["RawTiberium"] * Blue * 3) * Bonus)
			Ent.PlayerUsing:AddScore(MARKETABLE["RawTiberium"] * Green * 0.3 + MARKETABLE["RawTiberium"] * Blue * 3 * 0.6)
			
			net.Start("Terminal_TibTransmitProgress")
				net.WriteEntity(Ent)
				local T = {}
				for I,P in pairs(Stors) do
					if P.Storage.RawTiberium > 0 then
						table.insert(T,{P.Storage.RawTiberium,P.StorageMax.RawTiberium,I,P.GreenTiberium or 0,P.BlueTiberium or 0})
					end
				end
				net.WriteTable(T)
			net.Send(Ent.PlayerUsing)
		else
			timer.Destroy(TimerName)
		end
	end)
end)