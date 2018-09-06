
function MakeNewPlayerInfo(ply)
	print("Making a new player row for "..ply:Name())
	Data = {}
	for I,P in pairs(GetAllResearch()) do
		if not P.PreReqs then
			Data[I] = 0
		end
	end
	Data.Laser_Tech_Research = 1
	Data.Storage_Tech_Research = 1
	Data.Drill_Tech_Research = 1
	Data.Tiberium_Storage_Tech_Research = 1
	Data.Refinery_Tech = 1
	Data.Ice_Laser_Tech_Research = 1
	Data.Raw_Ice_Tech_Research = 1
	Data.Refined_Ice_Tech_Research = 1
	Data.Multiple_Resource_Storage = 0
	Data.Solar_Research = 1
	Data.Fusion_Research = 1
	Data.Hydro_Turbine_Research = 1
	ply.Research = Data
	ply.Storage = {}
	ply:SetMoney(0)
	ply:SetScore(0)
	ply:SetTeam(1)
	ply:SetPrivilege(PRIV_USER)
	ply.Cooldown = 0
	ply.TimePlayed = 0
	ply.JoinedTeams = 0
	ply.TeamSelection = math.random(10800,18000)
	ply:SetNWInt("TimePlayed",0)
	DB_CreatePlayer(ply)
end

function SavePlayerInfo(ply)
	/*
		return glon.encode(ply.Data)

	local Str = "Name="..ply:GetName()
	Str = Str.."\r\nScore="..ply:GetScore()
	Str = Str.."\r\nMoney="..ply:GetMoney()
	Str = Str.."\r\nPrivilege="..ply:GetPrivilege()
	Str = Str.."\r\nFaction="..ply:Team()
	ply.TimePlayed = math.floor(ply.TimePlayed + (CurTime() - ply.Joined))
	Str = Str.."\r\nTimePlayed="..ply.TimePlayed
	Str = Str.."\r\nJoinedTeams="..ply.JoinedTeams
	Str = Str.."\r\nTeamSelection="..ply.TeamSelection
	ply.Joined = CurTime()
	for I,P in pairs(ply.Storage) do
		Str = Str.."\r\n"..I.."="..P
	end
	for I,P in pairs(ply.Research) do
		Str = Str.."\r\n"..I.."="..P
	end
	return Str*/
end

function GetPlayerInfo(ply)
	ply.Cooldown = 0
	ply.Research = {}
	ply.Storage = {}
	ply.JoinedTeams = 0
	ply.TeamSelection = 0
	DB_RetrievePlayer(ply:SteamID(),function(data)
		if not data then
			MakeNewPlayerInfo(ply)
			CheckSpecial(ply)
			return
		end
		for I,P in pairs(data) do
			if I == "Score" then
				ply:SetScore(tonumber(P))
			elseif I == "Credits" then
				ply:SetMoney(tonumber(P))
			elseif I == "Privilege" then
				ply:SetPrivilege(tonumber(P),true)
			elseif I == "Timeplayed" then
				ply.TimePlayed = tonumber(P)
				ply:SetNWInt("TimePlayed",tonumber(P))
			elseif I == "Faction" then
				ply:SetTeam(tonumber(P))
			elseif I == "JoinedTeams" then
				ply.JoinedTeams = tonumber(P)
			elseif I == "TeamSelection" then
				ply.TeamSelection = tonumber(P)
			elseif I == "NickName" then
				ply:SetNWString("Nick",P)
			elseif I == "Resources" then
				ply.Storage = ResFromSQLString(P)
			elseif I == "Research" then
				ply.Research = ResFromSQLString(P)
			end
		end
		
		for I,P in pairs(GetAllResearch()) do
			
			if not P.PreReqs and not ply.Research[I] then
				if P.Costs[1] == 0 then
					ply.Research[I] = 1
				else
					ply.Research[I] = 0
				end
			elseif P.Category == "Tech" and P.InitialCost == 0 and not ply.Research[I] then
				ply.Research[I] = 1
			end
		end
	end)
	/*
	local Str = file.Read("Players/"..FormatSteamID(ply:SteamID())..".txt","DATA")
	
		ply.Data = glon.decode(Str)
	
	local Res = GetAllResearch()
	local Tab = ReturnTableFromStr(Str)
	for I,P in pairs(Tab) do
		if I == "Score" then
			ply:SetScore(tonumber(P))
		elseif I == "Money" then
			ply:SetMoney(tonumber(P))
		elseif I == "TimePlayed" then
			ply.TimePlayed = tonumber(P)
			ply:SetNWInt("TimePlayed",tonumber(P))
		elseif I == "Privilege" then
			ply:SetPrivilege(tonumber(P))
		elseif I == "Faction" then
			ply:SetTeam(tonumber(P))
		elseif I == "JoinedTeams" then
			ply.JoinedTeams = tonumber(P)
		elseif I == "TeamSelection" then
			ply.TeamSelection = tonumber(P)
		elseif table.HasValue(Resources,I) then
			ply.Storage[I] = tonumber(P)
		elseif table.HasKey(Res,I) then
			ply.Research[I] = tonumber(P)
		end
	end
	if ply:Team() == 1 and ply.TeamSelection == 0 then
		ply.TeamSelection = math.random(10800,18000) - ply.TimePlayed
		if ply.TeamSelection < 0 then
			ply.TeamSelection = 1
		end
	end*/
end

function GetTheScorePlayers()
	local Players = {}
	local Files = file.Find("Players/*.txt","DATA")
	for I,P in pairs(Files) do
		local Str = file.Read("Players/"..P)
		local Tab = ReturnTableFromStr(Str)
		if Tab.Score then
			local ID = UnFormatSteamID(string.Split(P,".")[1])
			if tonumber(Tab.Score) >= 500000 then
				print(Tab.Name)
				Players[ID] = 500000
			elseif tonumber(Tab.Score) > 0 then
				print(Tab.Name)
				Players[ID] = 100000
			end
		end
	end
	
	local Str = CreateStringFromTab(Players)
	file.Write("SpecialPlayers.txt",Str)
end

util.AddNetworkString("BetaTester")

function CheckSpecial(ply)
	local Str = file.Read("SpecialPlayers.txt")
	local Tab = ReturnTableFromStr(Str)
	for I,P in pairs(Tab) do
		if I == ply:SteamID() then
			ply:AddMoney(tonumber(P))
			net.Start("BetaTester")
				net.WriteBit(500000 == tonumber(P))
			net.Send(ply)
			Tab[I] = nil
			break
		end
	end
	
	file.Write("SpecialPlayers.txt",CreateStringFromTab(Tab))
end

function GM:ShowSpare1(ply)
	ply:ConCommand("SA_Suggestion")
end

util.AddNetworkString("SA_Suggestion")

net.Receive("SA_Suggestion",function(len,ply)
	local Str = net.ReadString()
	ChatOwner(ply:Name().." suggested something!")
	
	DB_AddBug(ply:Name(),Str)
end)

local Ply = FindMetaTable("Player")

function Ply:TeamSelectionMenu()
	net.Start("SA_TeamSelection")
		net.WriteUInt(self.JoinedTeams,8)
	net.Send(self)
end

function Ply:GotResearch(str,lv)
	DB_UpdatePlayer("Research",SQLStringFromRes(self.Research),self:SteamID())
	local R = GetResearch(str)
	if R.Class then
		for I,P in pairs(ents.FindByClass(R.Class)) do
			if P:GetNWEntity("Owner") == self then
				P:SetSizeNumber(P.SizeNumber)
			end
		end
	end
end

function Ply:AddMoney(money)
	self.Money = math.floor(self.Money + money)
	self:SetNetworkedInt("Money",self.Money)
	DB_UpdatePlayer("Credits",self.Money,self:SteamID())
end

function Ply:SetMoney(money)
	self.Money = math.floor(money)
	self:SetNetworkedInt("Money",self.Money)
end

function Ply:SetScore(Score)
	self.Score = math.floor(Score)
	self:SetNetworkedInt("Score",self.Score)
end

function Ply:AddScore(Score)
	self.Score = math.floor(self.Score + Score)
	self:SetNetworkedInt("Score",self.Score)
	DB_UpdatePlayer("Score",self.Score,self:SteamID())
end

function Ply:SetPrivilege(Priv)
	self:SetNWInt("Privilege",Priv)
	DB_UpdatePlayer("Privilege",Priv,self:SteamID())
end

function Ply:CheckFaction(typ)
	if self:Team() == 1 then return 0 end
	
	local Fact = self:GetFact()
	if not Fact.Upgrades[typ] then return 0 end
	return Fact.Upgrades[typ]
end

function Ply:SetAFK(IsAFK)
	if self.AFKed then return end
	self:SetNWBool("AFK",IsAFK)
	self.AFKed = true
	timer.Simple(2,function() if IsValid(self) then self.AFKed = nil end end)
	
	if IsAFK then
		ChatIt(self:Name().." went AFK!")
		self:GodEnable()
		if self:InVehicle() and self:GetVehicle():GetNWEntity("Owner") ~= self then
			self.OldVehicle = self:GetVehicle()
			self:ExitVehicle()
			self:SetMoveType(MOVETYPE_NOCLIP)
			self.OldPos = self:GetPos()
			self:SetPos(Vector(-11204,-2497,-8147))
		else
			self.OldMove = self:GetMoveType()
			self:SetMoveType(MOVETYPE_NOCLIP)
			self.OldPos = self:GetPos()
			self:SetPos(Vector(-11204,-2497,-8147))
		end
	else
		ChatIt(self:Name().." came back!")
		if not self.Godded then self:GodDisable() end
		if IsValid(self.OldVehicle) then
			if not IsValid(self.OldVehicle:GetDriver()) then
				self:EnterVehicle(self.OldVehicle)
				self.OldVehicle = nil
			else
				ChatIt("The seat where you were got occupied!",self)
				self:SetPos(self.OldPos)
				self.OldPos = nil
			end
			self.OldVehicle = nil
		elseif self.OldMove then
			self:SetMoveType(self.OldMove)
			self.OldMove = nil
			self:SetPos(self.OldPos)
			self.OldPos = nil
		end
	end
end

local Ent = FindMetaTable("Entity")

function Ent:SetNWOwner(ply)
	self:SetNWEntity("Owner",ply)
	if ply:IsPlayer() then
		gamemode.Call("CPPIAssignOwnership",ply,self)
	end
end

function Ent:CheckFaction()
	return 0
end

function Ent:GetResearch(str)
	if not self:IsPlayer() then return 0 end
end

local SetPrnt = Ent.SetParent
function Ent:SetParent(E)
	if not self:GetNWEntity("Owner") or self:GetNWEntity("Owner"):IsWorld() then return end
	//if not CanSomethingDo(self:GetNWEntity("Owner"),E,"ConstrainAble") then return end
	SetPrnt(self,E)
end

local function SortScores(a,b)
	return a.Score > b.Score or a.Name > b.Name
end

function UpdateScoreboard()/* Add MySQL
	local Files = file.Find("Players/*.txt","DATA")
	
	Scores = {}
	for I,P in pairs(Files) do
		local Str = file.Read("Players/"..P,"DATA")
		local Tab = ReturnTableFromStr(Str)
		table.insert(Scores,{Name = Tab.Name,
							Score = tonumber(Tab.Score),
							Money = tonumber(Tab.Money),
							TimePlayed = tonumber(Tab.TimePlayed)})
	end
	
	table.SortByMember(Scores,"Score",false)*/
end