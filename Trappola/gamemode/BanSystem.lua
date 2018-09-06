require"glon"
local TBR = {}
local function CountingDown()
	if not Bans then
		CountBans()
		return
	end
	if #Bans <= 0 then 
		file.Write("Trappola/Bans.txt",glon.encode({}))
		timer.Remove("CountingBans") 
		return
	end
	for I,P in pairs(Bans) do
		if P.Time > 0 then
			if os.time() >= P.CurTime + P.Time * 60 then
				table.insert(TBR,P)
			end
		end
	end
	if #TBR > 0 then
		for I,P in pairs(TBR) do
			for i,p in pairs(Bans) do
				if P == p then
					table.remove(Bans,i)
				end
			end
		end
		file.Write("Trappola/Bans.txt",glon.encode(Bans))
		TBR = {}
	end
end

function CountBans()
	if not file.Exists("Trappola/Bans.txt") then
		file.Write("Trappola/Bans.txt",glon.encode({}))
	end
	Bans = glon.decode(file.Read("Trappola/Bans.txt"))
	if not timer.IsTimer("CountingBans") and #Bans > 0 then
		timer.Create("CountingBans",1,0,CountingDown)
	end
end

local Meta = FindMetaTable("Player")

function Meta:Kick(Reason)
	gatekeeper.Drop(self:UserID(),Reason)
end

function Meta:Ban(Time,Reason)
	local SteamID = self:SteamID()
	local Name = self:Name()
	local IP = self:IPAddress()
	gatekeeper.Drop(self:UserID(),Reason)
	local File = glon.decode(file.Read("Trappola/Bans.txt"))
	table.insert(File,{["SteamID"] = SteamID,["Name"] = Name,["Time"] = Time,["CurTime"] = os.time(),["Reason"] = Reason,["IP"] = IP})
	file.Write("Trappola/Bans.txt",glon.encode(File))
	CountBans()
end

function UnBan(ID)
	for I,P in pairs(Bans) do
		if P.SteamID == ID or P.Name == ID then
			table.insert(TBR,P)
			CountingDown()
			break
		end
	end
end

function CheckBan(SteamID,IP,Name)
	for I,P in pairs(Bans) do
		if P.SteamID == SteamID or (P.IP == IP and P.Name == Name) then
			local Time = math.ceil(((P.CurTime + P.Time * 60) - os.time()) / 60)
			return P.Reason,Time
		end
	end
	return
end

hook.Add("PlayerPasswordAuth","BanCheck",function(name,pass,steamid,ip)
	CountBans()
	local Reason,Check = CheckBan(steamid,ip,name)
	if Check then
		return {false,Format("You are banned because of %s! Your ban ends in %s minutes.",Reason,Check)}
	end
	return
end)