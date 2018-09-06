
require("mysqloo")

local Queue = {}

local DB = mysqloo.connect("10.1.10.27","admin","qwer123","SpaceAge",3306)

function DB:onConnected()
	print(os.date().." - Successfully connected to the database!")
	if #Queue > 0 then
		print("Going through "..#Queue.." query items!")
	end
	for I,P in pairs(Queue) do
		Query(P[1],P[2])
	end
	Queue = {}
end

function DB:onConnectionFailed(err)
	print(os.date().." - Failed connecting to database with the error '"..err.."'")
end

DB:connect()

function Query(Sql,CB)
	local Q = DB:query(Sql)
	function Q:onSuccess(data)
		if CB then
			CB(data)
		end
	end
	
	function Q:onError(Err)
		if DB:status() == mysqloo.DATABASE_NOT_CONNTED then
			table.insert(Queue,{Sql,CB})
			DB:connect()
			return
		end
		print(os.date().." - Query failed with the error '"..Err.."'")
	end
	
	Q:start()
end

function ConvertAll()
	local All = file.Find("Players/*.txt","DATA")
	for I,P in pairs(All) do
		DB_ConvertText(P)
	end
end

function DB_ConvertText(ID)
	local File = file.Read("Players/"..ID)
	local Tab = ReturnTableFromStr(File)
	local New = {}
	New.SteamID = UnFormatSteamID(string.Split(ID,".")[1])
	New.Name = ""
	New.Score = 0
	New.Credits = 0
	New.Faction = 1
	New.Privilege = 0
	New.TimePlayed = 0
	New.Research = {}
	New.Resources = {}
	local Res = GetAllResearch()
	for I,P in pairs(Tab) do
		if I == "Name" then New.Name = P
		elseif I == "Score" then New.Score = P
		elseif I == "Money" then New.Credits = P
		elseif I == "Faction" then New.Faction = P
		elseif I == "Privilege" then New.Privilege = P
		elseif I == "TimePlayed" then New.TimePlayed = P
		elseif table.HasKey(Res,I) then New.Research[I] = P
		elseif table.HasValue(Resources,I) then New.Resources[I] = P end
	end
	
	Query("INSERT INTO player_data VALUES ('"..DB:escape(New.Name).."','"..New.SteamID.."','"..New.Faction.."','"..New.Privilege.."','"..New.Score.."','"..New.Credits.."','"..New.TimePlayed.."','"..SQLStringFromRes(New.Research).."','"..SQLStringFromRes(New.Resources).."','0','0');")
end

function DB_AddBug(Name,Text)
	Query("INSERT INTO bug_tracker VALUES ('"..DB:escape(Name).."','"..DB:escape(Text).."');")
end

function DB_CreateBan(Name,ID,Reason,TimeOnBan,BanTime)
	Query("INSERT INTO player_bans VALUES ('"..DB:escape(Name).."','"..ID.."','"..Reason.."','"..TimeOnBan.."','"..BanTime.."');")
end

function DB_CreatePlayer(ply)
	Query("INSERT INTO player_data VALUES ('"..DB:escape(ply:Name()).."','"..ply:SteamID().."','1','0','0','0','0','"..SQLStringFromRes(ply.Research).."','','0','"..ply.TeamSelection.."','');")
end

function DB_UpdatePlayer(name,value,ID)
	if type(value) == "string" then value = DB:escape(value) end
	Query("UPDATE player_data SET "..name.."='"..value.."' WHERE SteamID='"..ID.."';")
end

function DB_RetrievePlayer(SteamID,CB)
	Query("SELECT * FROM player_data WHERE SteamID='"..SteamID.."';",function(data)
		CB(data[1] or nil)
	end)
end

function DB_UpdateRefinery()
	Query("UPDATE refinery SET RawTiberium='"..TIB_REF.RawTiberium.."',ProcessedTiberium='"..TIB_REF.Tiberium.."';")
end

function SQLStringFromRes(tab)
	local S = ""
	for I,P in pairs(tab) do
		S = S..I.."="..P..","
	end
	return S
end

function ResFromSQLString(Str)
	local Tab = {}
	local Lines = string.Split(Str,",")
	for I,P in pairs(Lines) do
		if P ~= "" then
			local Expl = string.Split(P,"=")
			Tab[Expl[1]] = tonumber(Expl[2])
		end
	end
	return Tab
end