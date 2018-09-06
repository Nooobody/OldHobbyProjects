require("mysqloo")
 
local DATABASE_HOST = "89.238.163.133"
local DATABASE_PORT = 3306
local DATABASE_NAME = "nooilpro_Trappola"
local DATABASE_USERNAME = "nooilpro_Adm"
local DATABASE_PASSWORD = "+%$eUd=Z_yLZ"

local function Fail(self,Fail)
	print(Fail)
	if DB:status() == 2 then
		DB_Connect()
	end
end

function DB_Connect()
	DB = mysqloo.connect(DATABASE_HOST, DATABASE_USERNAME, DATABASE_PASSWORD, DATABASE_NAME, DATABASE_PORT)
	DB.onConnectionFailed = Fail
	DB.onConnectionSuccess = function()
		if not IDs then 
			DB_SelectIDs() 
		end
	end
	DB:connect()
end

function DB_CreatePly(ply,Nam)
	local Q = DB:query("INSERT INTO PlayerTable (SteamID,Name) VALUES ('"..ply.."','"..Nam.."')")
	Q.onSuccess = function() DB_SelectIDs() end
	Q.onFailure = Fail
	Q:start()
	local Q = DB:query("INSERT INTO Player_Upgrades (SteamID) VALUES ('"..ply.."')")
	Q.onFailure = Fail
	Q:start()
	local Q = DB:query("INSERT INTO Player_Dosh (SteamID,Tokens_Cooldown) VALUES ('"..ply.."',2)")
	Q.onFailure = Fail
	Q.onSuccess = function() Ply_Add(ply) end
	Q:start()
end

function DB_UpdateStrPly(ply,idx,val)
	Ply_Update(ply,idx,val)
	local Q = DB:query("UPDATE PlayerTable SET "..idx.." = '"..val.."' WHERE SteamID='"..ply.."'")
	Q.onFailure = Fail
	Q:start()
end

function DB_UpdateIndPly(ply,idx,val)
	Ply_Update(ply,idx,val)
	local Q = DB:query("UPDATE PlayerTable SET "..idx.." = "..val.." WHERE SteamID='"..ply.."'")
	Q.onFailure = Fail
	Q:start()
end

function DB_UpdateAddIndPly(ply,idx,val)
	local Val = tonumber(Ply_Select(ply,idx)) or 0
	local val = Val + val
	Ply_Update(ply,idx,val)
	local Q = DB:query("UPDATE PlayerTable SET "..idx.." = "..val.." WHERE SteamID='"..ply.."'")
	Q.onFailure = Fail
	Q:start()
end

function DB_UpgradeLevel(ply,idx,val)
	Ply_Upgrade(ply,idx,val)
	local Q = DB:query("UPDATE Player_Upgrades SET "..idx.." = "..val.." WHERE SteamID='"..ply.."'")
	Q.onFailure = Fail
	Q:start()
end

function DB_SelectIDs()
	local Q = DB:query("SELECT SteamID,Name,Model,Privilege,Experience,FlareR,FlareG,FlareB FROM PlayerTable")
	Q.onFailure = Fail
	Q.onSuccess = function(self)
		IDs = self:getData()
		if #IDQueue > 0 then
			for I,P in pairs(IDQueue) do
				gamemode.Call("PlayerAuthed",P[1],P[2])
			end
			IDQueue = {}
		end
	end
	Q:start()
end

function DB_DoshPly(Ply,Idx,Val)
	Ply_Dosh(Ply,Idx,Val)
	local Q = DB:query("UPDATE Player_Dosh SET "..Idx.." = "..Val.." WHERE SteamID = '"..Ply.."'")
	Q.onFailure = Fail
	Q:start()
end

function DB_Clear()
	local Q = DB:query("DELETE * FROM PlayerTable")
	Q.onFailure = Fail
	Q.onSuccess = function() ChatIt("MySQL table has been cleared!") end
	Q:start()
	local Q = DB:query("DELETE * FROM Player_Upgrades")
	Q.onFailure = Fail
	Q.onSuccess = function() ChatIt("MySQL Upgrades table has been cleared!") end
	Q:start()
end

function Ply_Check(ply)
	for I,P in pairs(IDs) do
		if P.SteamID == ply then
			if not table.HasValue(Players,ply) then
				Ply_Add(ply)
			end
			return P
		end
	end
	return false
end

function Ply_Add(ply)
	local Q = DB:query("SELECT * FROM PlayerTable WHERE SteamID = '"..ply.."'")
	Q.onFailure = Fail
	Q.onSuccess = function(self) table.insert(Players,self:getData()[1]) end
	Q:start()
	local Q = DB:query("SELECT * FROM Player_Upgrades WHERE SteamID = '"..ply.."'")
	Q.onFailure = Fail
	Q.onSuccess = function(self) table.insert(PlayerUpgrades,self:getData()[1]) SendLvls(self:getData()[1]) end
	Q:start()
	local Q = DB:query("SELECT * FROM Player_Dosh WHERE SteamID = '"..ply.."'")
	Q.onFailure = Fail
	Q.onSuccess = function(self) table.insert(PlayerDosh,self:getData()[1]) SendDosh(self:getData()[1]) end
	Q:start()
	for I,P in pairs(player.GetAll()) do
		if P:SteamID() == ply then
			P:SetNWBool("MySQL",true)
			P:SendLua("RunConsoleCommand('Trappola_Search',LocalPlayer():Name())")
			break
		end
	end
end

function SendLvls(Lvls)
	local txt = ""
	for I,P in pairs(TrapUpgrades) do
		for i,p in pairs(Lvls) do
			if i == P["Trap"].."_"..P["Var"] then
				txt = txt..p
			end
		end
	end
	for I,P in pairs(ScavUpgrades) do
		for i,p in pairs(Lvls) do
			if i == P["Var"] then
				txt = txt..p
			end
		end
	end
	local Ply
	for I,P in pairs(player.GetAll()) do
		if P:SteamID() == Lvls["SteamID"] then
			Ply = P
			break
		end
	end
	umsg.Start("Lvls",Ply)
		umsg.String(txt)
	umsg.End()
end

function SendDosh(Dosh)
	local txt = ""
	for I,P in pairs(DoshUpgs) do
		for i,p in pairs(Dosh) do
			if i == P["Class"].."_"..P["Name"] then
				txt = txt..p
			end
		end
	end
	local Ply
	for I,P in pairs(player.GetAll()) do
		if P:SteamID() == Dosh["SteamID"] then
			Ply = P
			break
		end
	end
	Ply:Dosh(Dosh.Dosh)
	umsg.Start("Dosh",Ply)
		umsg.String(txt)
	umsg.End()
end

function Ply_Remove(ply)
	for I,P in pairs(Players) do
		if P.SteamID == ply then
			table.remove(Players,I)
			break
		end
	end
	for I,P in pairs(PlayerUpgrades) do
		if P.SteamID == ply then
			table.remove(PlayerUpgrades,I)
			break
		end
	end
	for I,P in pairs(PlayerDosh) do
		if P.SteamID == ply then
			table.remove(PlayerDosh,I)
			break
		end
	end
end

function Ply_Dosh(ply,Idx,val)
	for I,P in pairs(PlayerDosh) do
		if P.SteamID == ply then
			P[Idx] = val
			SendDosh(P)
			break
		end
	end
end

function Ply_Upgrade(ply,Idx,val)
	for I,P in pairs(PlayerUpgrades) do
		if P.SteamID == ply then
			P[Idx] = val
			SendLvls(P)
			break
		end
	end
end

function Ply_Update(ply,Idx,val)
	for I,P in pairs(Players) do
		if P.SteamID == ply then
			P[Idx] = val
			break
		end
	end
end

function Ply_SelectDosh(ply,Idx)
	for I,P in pairs(PlayerDosh) do
		if P.SteamID == ply then
			return P[Idx]
		end
	end
end

function Ply_SelectLvl(ply,Idx)
	for I,P in pairs(PlayerUpgrades) do
		if P.SteamID == ply then
			return P[Idx]
		end
	end
end

function Ply_Select(ply,Idx)
	for I,P in pairs(Players) do
		if P.SteamID == ply then
			return P[Idx]
		end
	end
end

concommand.Add("Trappola_Search",function(ply,cmd,arg)
	if not arg[1] then return end
	local Name = arg[1]
	local Alr = false
	for I,P in pairs(IDs) do
		if string.find(string.lower(P.Name),string.lower(Name)) then
			Alr = true
			local Q = DB:query("SELECT Model,trap_explosive,trap_fakeartifact,trap_poison,trap_harpoon,trap_fakewall,trap_spike,TotalExperience,Experience,Kills,Scores,Defusings,Pinged,Triggered FROM PlayerTable WHERE SteamID = '"..P.SteamID.."'")
			Q.onFailure = Fail
			Q.onSuccess = function(self)
				local Data = self:getData()[1]
				umsg.Start("SearchResult",ply)
					umsg.Bool(true)
					umsg.String(P.Name)
					umsg.String(Data.Model)
					umsg.Short(tonumber(Data.trap_explosive))
					umsg.Short(tonumber(Data.trap_fakeartifact))
					umsg.Short(tonumber(Data.trap_poison))
					umsg.Short(tonumber(Data.trap_harpoon))
					umsg.Short(tonumber(Data.trap_fakewall))
					umsg.Short(tonumber(Data.trap_spike))
					umsg.Long(tonumber(Data.TotalExperience))
					umsg.Short(tonumber(Data.Experience))
					umsg.Short(tonumber(Data.Kills))
					umsg.Short(tonumber(Data.Scores))
					umsg.Short(tonumber(Data.Defusings))
					umsg.Short(tonumber(Data.Pinged))
					umsg.Short(tonumber(Data.Triggered))
				umsg.End()
			end
			Q:start()
		end
	end
	if not Alr then
		umsg.Start("SearchResult",ply)
			umsg.Bool(false)
		umsg.End()
	end
end)