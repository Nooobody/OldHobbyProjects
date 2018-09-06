AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("helperfunctions/cl_rstates.lua")

include("shared.lua")

util.AddNetworkString("Terminal_StartResearch")
util.AddNetworkString("Terminal_Refine")
util.AddNetworkString("Terminal_Market")
util.AddNetworkString("Terminal_MarketAll")
util.AddNetworkString("Terminal_UpgradeSuccesful")
util.AddNetworkString("Terminal_UpgradeResearch")
util.AddNetworkString("Terminal_ResearchStorageTable")
util.AddNetworkString("Terminal_ResearchSendStorage")

function ENT:GetPlyResearch()
	net.Start("Terminal_StartResearch")
		net.WriteEntity(self)
		local Data = table.Copy(self.PlayerUsing.Research)
		local Res = GetAllResearch()
		for I,P in pairs(Res) do
			if not table.HasKey(Data,I) and P.PreReqs then
				local Na,Lv = next(P.PreReqs)
				if Na and table.HasKey(Data,Na) and tonumber(Data[Na]) >= Lv then
					Data[I] = 0
				end
			end
		end
		net.WriteTable(Data)
	net.Send(self.PlayerUsing)
end

function ENT:UseAction(act,cal)
	self:GetPlyResearch()
	net.Start("Terminal_ResearchSendStorage")
		net.WriteEntity(self)
		net.WriteTable(self.PlayerUsing.Storage)
	net.Send(self.PlayerUsing)
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
		
		if Int > 10 then
			self:TimeOut()
		end
	end)
end

function ENT:UpgradeSuccesful(S,I)
	net.Start("Terminal_UpgradeSuccesful")
		net.WriteEntity(self)
		net.WriteString(S)
		net.WriteUInt(I,12)
	net.Send(self.PlayerUsing)
end

local ORE = {
	"Rare_Diamonds",
	"Compressed_Air",
	"Oxidized_Crystals",
	"Valuable_Minerals"
}

local ICE = {
	"Refined_BlueIce",
	"Refined_ClearIce",
	"Refined_GlareCrust",
	"Refined_GlacialMass",
	"Refined_WhiteGlaze",
	"Refined_Gelidus",
	"Refined_Krystallos",
	"Refined_DarkGlitter"
}

net.Receive("Terminal_Market",function(len,ply)
	local Ent = net.ReadEntity()
	local Mat = net.ReadString()
	
	if not MARKETABLE[Mat] then return end
	if not Ent.PlayerUsing.Storage[Mat] or Ent.PlayerUsing.Storage[Mat] == 0 then return end
	
	local Bonus = 1
	if table.HasValue(ORE,Mat) then
		Bonus = 1 + (ply:CheckFaction("Money_Ore") / 100)
	elseif table.HasValue(ICE,Mat) then
		Bonus = 1 + (ply:CheckFaction("Money_Ice") / 100)
	end
	
	Ent.PlayerUsing:AddMoney(MARKETABLE[Mat] * Ent.PlayerUsing.Storage[Mat] * Bonus)
	Ent.PlayerUsing:AddScore(MARKETABLE[Mat] * Ent.PlayerUsing.Storage[Mat] * 0.3)
	Ent.PlayerUsing.Storage[Mat] = nil
	DB_UpdatePlayer("Resources",SQLStringFromRes(Ent.PlayerUsing.Storage),Ent.PlayerUsing:SteamID())
end)

net.Receive("Terminal_MarketAll",function(len,ply)
	local Ent = net.ReadEntity()
	if not IsValid(Ent.PlayerUsing) then return end
	local Cred = 0
	local Scor = 0
	for I,P in pairs(Ent.PlayerUsing.Storage) do
		if table.HasKey(MARKETABLE,I) then
			local Bonus = 1
			if table.HasValue(ORE,I) then
				Bonus = 1 + (ply:CheckFaction("Money_Ore") / 100)
			elseif table.HasValue(ICE,I) then
				Bonus = 1 + (ply:CheckFaction("Money_Ice") / 100)
			end
			Cred = Cred + MARKETABLE[I] * P * Bonus
			Scor = Scor + MARKETABLE[I] * P * 0.3
			Ent.PlayerUsing.Storage[I] = nil
		end
	end
	
	Ent.PlayerUsing:AddMoney(Cred)
	Ent.PlayerUsing:AddScore(Scor)
	DB_UpdatePlayer("Resources",SQLStringFromRes(Ent.PlayerUsing.Storage),Ent.PlayerUsing:SteamID())
end)

net.Receive("Terminal_Refine",function(len,ply)
	local Ent = net.ReadEntity()
	local Mat = net.ReadString()
	
	if not REFINE_MATERIALS[Mat] then return end
	if not Ent.PlayerUsing.Storage[Mat] or Ent.PlayerUsing.Storage[Mat] == 0 then return end
	
	local Get = table.Copy(REFINE_MATERIALS[Mat])
	local Am = Ent.PlayerUsing.Storage[Mat]
	
	for I,P in pairs(Get) do
		Get[I] = Get[I] * Am
	end
	
	Ent.PlayerUsing.Storage[Mat] = nil
	
	for I,P in pairs(Get) do
		if not Ent.PlayerUsing.Storage[I] then Ent.PlayerUsing.Storage[I] = 0 end
		Ent.PlayerUsing.Storage[I] = Ent.PlayerUsing.Storage[I] + math.floor(P)
	end
	DB_UpdatePlayer("Resources",SQLStringFromRes(Ent.PlayerUsing.Storage),Ent.PlayerUsing:SteamID())
end)

net.Receive("Terminal_UpgradeResearch",function(len,ply)
	local Ent = net.ReadEntity()
	local S = net.ReadString()
	if not Ent.PlayerUsing.Research[S] then Ent.PlayerUsing.Research[S] = 0 end
	local L = Ent.PlayerUsing.Research[S]
	local Res = GetResearch(S)
	local Cost = Res.InitialCost + Res.CostMulPer * L
	if Res.CostMulPer == 0 then
		Cost = Res.Costs[L + 1]
	end
	
	if Ent.PlayerUsing:GetNWInt("Money") < Cost or L >= Res.Levels then return end
	
	if Res.PreReqs then
		if Res.CostMulPer == 0 then
			local Na,Lv = next(Res.PreReqs[L + 1])
			if not Ent.PlayerUsing.Research[Na] or Ent.PlayerUsing.Research[Na] < Lv then return end
		else
			local Na,Lv = next(Res.PreReqs)
			if not Ent.PlayerUsing.Research[Na] or Ent.PlayerUsing.Research[Na] < Lv then return end
		end
	end	
	Ent.PlayerUsing:AddMoney(-Cost)
	Ent.PlayerUsing.Research[S] = L + 1
	Ent.PlayerUsing:GotResearch(S,Ent.PlayerUsing.Research[S])
	
	if Ent.PlayerUsing.Research[S] == Res.Levels then 
		Ent:GetPlyResearch() 
	elseif Res.Category == "Tech" then
		Ent:GetPlyResearch()
	elseif Ent.PlayerUsing.Research[S] % 20 == 0 then
		Ent:UpgradeSuccesful(S,Ent.PlayerUsing.Research[S])
	end
end)

net.Receive("Terminal_ResearchStorageTable",function(len,ply)
	local Ent = net.ReadEntity()
	if not Ent.PlayerUsing then return end
	net.Start("Terminal_ResearchSendStorage")
		net.WriteEntity(Ent)
		net.WriteTable(Ent.PlayerUsing.Storage)
	net.Send(ply)
end)