
local function CheckBan(SteamID)
	if not BanExists(SteamID) then return false end
	
	local Str = file.Read("Players_Bans/"..FormatSteamID(SteamID)..".txt","DATA")
	local T = ReturnTableFromStr(Str)
	if tonumber(T.Time) == 0 then return true end
	local IsBan = os.time() - tonumber(T.TimeOnBan) < tonumber(T.Time)
	if not IsBan then
		UnBan(SteamID)
	end
	
	return IsBan,T.Reason
end

function BanExists(SteamID)
	return file.Exists("Players_Bans/"..FormatSteamID(SteamID)..".txt","DATA")
end

function UnBan(SteamID)
	if not BanExists(SteamID) then return false end
	file.Delete("Players_Bans/"..FormatSteamID(SteamID)..".txt","DATA")
end

function BanID(SteamID,Time,Reason)
	Time = Time or 0
	Reason = Reason or ""
	
	local T = {TimeOnBan = os.time(),Time = Time * 60,Reason = Reason,Name = "",SteamID = SteamID}
	file.Write("Players_Bans/"..FormatSteamID(SteamID)..".txt",CreateStringFromTab(T))
	ChatIt(SteamID.." has been banned for '"..Reason.."'")
	DB_CreateBan(nil,SteamID,Reason,T.TimeOnBan,Time)
end

local Meta = FindMetaTable("Player")

function Meta:Ban(Time,Reason)
	local SteamID = self:SteamID()
	local Name = self:Name()
	Reason = Reason or ""
	Time = Time or 0
	
	if Time == 0 then
		self:Kick("Permanently banned with Reason: "..Reason)
	else
		self:Kick("Banned for "..Time.." minutes with Reason: "..Reason)
	end
	local T = {TimeOnBan = os.time(),Time = Time * 60,Reason = Reason,Name = Name,SteamID = SteamID}
	file.Write("Players_Bans/"..FormatSteamID(SteamID)..".txt",CreateStringFromTab(T))
	DB_CreateBan(Name,SteamID,Reason,T.TimeOnBan,Time * 60)
end

function GM:CheckPassword(SteamID,IP,SvPass,ClPass,Name)
	if timer.Exists("SA_Restart") then 
		SteamID = util.SteamIDFrom64(SteamID)
		local Found = false
		for I,P in pairs(ents.GetAll()) do
			if P.SteamID == SteamID then
				Found = true
			end
		end
		if not Found then
			return false,"We are restarting the server, sorry for the inconvenience!" 
		end
	end
	if SvPass ~= ClPass and SvPass ~= "" then return false,"Unmatching password!" end
	
	local B,R = CheckBan(util.SteamIDFrom64(SteamID))
	if B then
		return false,R
	end
	
	PlayerJoinLeave(Name,util.SteamIDFrom64(SteamID),PLAYER_JOIN)
	return true
end