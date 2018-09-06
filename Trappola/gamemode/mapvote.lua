local Dontchange = 0
local Already = false
local Maps = {}
local Votes = {}
local Pliers = {}
local Highest = 0
local Winner = ""
local Afkers = 0
concommand.Add("VotingforMap",function(ply,cmd,arg)
	if not arg[1] then return end
	local Map = arg[1]
	local All = false
	for I,P in pairs(Pliers) do
		if ply == P[1] then
			All = true
			if Map != Pliers[I][2] and Map != "TimeLeft" then
				Pliers[I][2] = Map
			end
		end
	end
	if not All then
		table.insert(Pliers,{ply,Map})
	end
	
	local Plys = #Pliers
	if Plys < #player.GetAll() and Map ~= "TimeLeft" then
		local Old = Plys
		timer.Simple(10,function() if Old == Plys then Plys = #player.GetAll() end end)
		umsg.Start("UpdateMaps")
			local txt = ""
			for I,P in pairs(Pliers) do
				txt = txt..P[2]..","
			end
			umsg.String(txt)
		umsg.End()
	elseif Plys >= #player.GetAll() and Map ~= "TimeLeft" then
		umsg.Start("UpdateMaps")
			local txt = ""
			for I,P in pairs(Pliers) do
				txt = txt..P[2]..","
			end
			umsg.String(txt)
		umsg.End()
	elseif Map == "TimeLeft" then
		for I,P in pairs(Pliers) do
			if P[2] == "TimeLeft" then
				Afkers = Afkers + 1
			end
		end
		if Afkers >= Plys then
			Highest = 0
			Plys = 0
			Afkers = 0
			Maps = {}
			Votes = {}
			Winner = ""
		else
			for I,M in pairs(Pliers) do
				table.insert(Maps,M[2])
			end
			for ind,map in pairs(Maps) do
				Val = 1
				for I,MAP in pairs(Maps) do
					if I != ind then
						if map == MAP then
							Val = Val + 1
						end
					end
				end
				Already = false
				for i,voti in pairs(Votes) do
					if voti[1] == map then 
						Already = true
					end
				end
				if not Already then
					table.insert(Votes,{map,Val})
				end
				Already = false
			end
			for i,vote in pairs(Votes) do	
				local Map = vote[1]
				local Vote = vote[2]
				if Vote > Highest then
					Highest = Vote
					Winner = Map
				end
			end
			timer.Simple(3,function()
				RunConsoleCommand("changelevel",string.Explode(".",Winner)[1])
			end)
		end
	end
end)