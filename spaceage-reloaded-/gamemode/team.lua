
util.AddNetworkString("SA_TeamSelected")

net.Receive("SA_TeamSelected",function(len,ply)
	local Team = net.ReadUInt(4)
	if Team == 1 then
		ply.TeamSelection = -1
		ChatIt("You can join a faction afterwards with !faction command!",ply)
		DB_UpdatePlayer("TeamSelection",ply.TeamSelection,ply:SteamID())
	else
		ply:SetTeam(Team)
		ply:Spawn()
		ply.TeamSelection = 0
		ply.JoinedTeams = ply.JoinedTeams + 1
		DB_UpdatePlayer("Faction",ply:Team(),ply:SteamID())
		DB_UpdatePlayer("JoinedTeams",ply.JoinedTeams,ply:SteamID())
		DB_UpdatePlayer("TeamSelection",ply.TeamSelection,ply:SteamID())
	end
	//local ID = FormatSteamID(ply:SteamID())
	//local Str = SavePlayerInfo(ply)
	//file.Write("Players/"..ID..".txt",Str)
end)