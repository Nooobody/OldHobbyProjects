local ChatCmds = {}
function GM:PlayerSay(ply,text,Team,death)
	local Already
	local Cmd
	local Priv
	local Txt
	for I,P in pairs(ChatCmds) do
		if string.Left(string.lower(text),string.len(P[1])) == P[1] then
			Already = true
			Cmd = P[2]
			Priv = P[3]
			Txt = string.Right(text,string.len(text) - string.len(P[1].." "))
		end
	end
	
	if Already then
		if ply:GetPrivilege() >= Priv then
			print(os.date().." - "..ply:Name().." did "..text)
			Cmd(ply,Txt)
		else
			ShoutIt("You don't have the privilege to do that!!",ply)
		end
		return ""
	else
		print(os.date().." - "..ply:Name()..": "..text)
		return text
	end
end

function GM:PlayerCanSeePlayersChat(strText, BTeam, pListener, pSpeaker)
	if not IsValid(pSpeaker) then
		return true
	end
	if BTeam then
		if pListener:Team() != pSpeaker:Team() then
			return false
		end
	end
	if not GetGlobalBool("Lobby") then
		if IsScavenger(pSpeaker) and pSpeaker:Health() <= 0 and IsScavenger(pListener) and pListener:Health() > 0 then
			if pSpeaker.FirstTime3 then
				ChatIt("Dead people can't talk to living Scavengers.",pSpeaker)
				ChatIt("If you're bored, you can play games at the arcade.",pSpeaker)
				pSpeaker.FirstTime3 = false
			end
			return false
		elseif pSpeaker:Team() == 3 and pListener:Team() == 1 then
			if pSpeaker.FirstTime4 then
				ChatIt("Spectators can't talk to living Scavengers.",pSpeaker)
				ChatIt("If you're bored, you can play games at the arcade.",pSpeaker)
				pSpeaker.FirstTime4 = false
			end
			return false
		end
	end
	return true
end

function GM:PlayerCanHearPlayersVoice(PListener,PTalker)
	if not GetGlobalBool("Lobby") and #player.GetAll() > 2 then
		if PListener:Team() ~= PTalker:Team() then
			return false
		elseif IsScavenger(PListener) and IsScavenger(PTalker) and PListener:Health() > 0 and PTalker:Health() <= 0 then
			return false
		end
	end
	return true
end

local function AddChatCommand(CmD,Func,Priv,Desc)
	table.insert(ChatCmds,{CmD,Func,Priv,Desc})
end

// Chat commands start here.

local function exit(p)
	p:SetNWBool("InLobby",false)
	if p.FirstTime1 then
		p.FirstTime1 = false
		ChatIt("Press F1 anytime to open the lobby menu.",p)
	end
end
AddChatCommand("!exit",exit,0,"Exits from lobby")

local function mapv()
	local Tab = file.Find("maps/traps_*.bsp",true)
	umsg.Start("Map")
		umsg.Short(#Tab)
		for I = 1,#Tab do
			local Num = math.random(1,#Tab)
			umsg.String(Tab[Num])
			table.remove(Tab,Num)
		end
	umsg.End()
end
AddChatCommand("!mapvote",mapv,1,"Starts the map vote")

local function map(ply,txt)
	game.ConsoleCommand("changelevel "..txt.."\n")
end
AddChatCommand("!map",map,1,"Changes the map")

local Plys = {}
local function rtv(ply)
	local Already = false
	for _,ent in pairs(Plys) do
		if ply == ent then
			Already = true
		end
	end
	if not Already then
		table.insert(Plys,ply)
		ChatIt(ply:Name().." has RTVed! ["..table.Count(Plys).."/"..math.Round(table.Count(player.GetAll())/2).."]")
		timer.Simple(120,function() table.remove(Plys,1) end)
	else
		ShoutIt("You have Already RTVed.",ply)
	end
	Already = false
	if table.Count(Plys) >= math.Round(table.Count(player.GetAll())/2) then
		ChatIt("Map Vote has Started!")
		Plys = {}
		local Tab = file.Find("maps/traps_*.bsp",true)
		umsg.Start("Map")
			umsg.Short(#Tab)
			for I = 1,#Tab do
				local Num = math.random(1,#Tab)
				umsg.String(Tab[Num])
				table.remove(Tab,Num)
			end
		umsg.End()
	end
end
AddChatCommand("!rtv",rtv,0,"Rocks the vote")

local function AdminTalk(ply,txt)
	AdminChat(txt,ply)
end
AddChatCommand("<",AdminTalk,1,"Admin talk")

local function Shout(ply,txt)
	ShoutIt(txt)
end
AddChatCommand("#",Shout,2,"Shout")

local function Kick(ply,txt)
	local tx = string.Explode(" ",txt)
	local Pl = PlayerFind(tx[1])
	if type(Pl) == "table" then
		local t = tx[1].." "
		local Reason = ""
		if tx[2] then
			Reason = string.Right(txt,string.len(txt) - string.len(t)) or ""
		end
		for I,P in pairs(Pl) do
			if P ~= ply then
				if P:GetPrivilege() > ply:GetPrivilege() then
					ShoutIt("You can't kick that person.",ply)
					if Owner then
						ChatIt(ply:Name().." tried to kick you.",Owner)
					end
				else
					local Name = P:Name()
					P:Kick(Reason)
					ChatIt("Player "..Name.." has been kicked from the server.")
					ChatIt("Reason: "..Reason)
					if Owner and ply ~= Owner then
						ChatIt(ply:Name().." kicked "..Name..".",Owner)
					end
				end
			end
		end
	else
		ShoutIt("Invalid player found!",ply)
	end
end
AddChatCommand("!kick",Kick,1,"Kicks players")

local function Ban(ply,txt)
	local tx = string.Explode(" ",txt)
	local Pl = PlayerFind(tx[1])
	if type(Pl) == "table" then
		local Time = tonumber(tx[2]) or 1
		local Reason = ""
		if tx[2] then
			local t = tx[1].." "..tx[2].." "
			if tx[3] then
				Reason = string.Right(txt,string.len(txt) - string.len(t))
			end
		end
		for I,P in pairs(Pl) do
			if P ~= ply then
				if P:GetPrivilege() > ply:GetPrivilege() then
					ShoutIt("You can't ban that person.",ply)
					if Owner then
						ChatIt(ply:Name().." tried to ban you.",Owner)
					end
				else
					local Name = P:Name()
					P:Ban(Time,Reason)
					if Time > 0 then
						ChatIt("Player "..Name.." has been banned from the server for "..Time.." minutes.")
					else
						ChatIt("Player "..Name.." has been permanently banned from the server.")
					end
					ChatIt("Reason: "..Reason)
					if Owner and ply ~= Owner then
						ChatIt(ply:Name().." banned "..Name..".",Owner)
					end
				end
			end
		end
	else
		ShoutIt("Invalid player found!",ply)
	end
end
AddChatCommand("!ban",Ban,1,"Bans players")

local function unban(ply,txt)
	if not Bans then ShoutIt("There's no one banned.",ply) return end
	local tx = string.Explode(" ",txt)
	local Alr
	for I,P in pairs(Bans) do
		if P.Name == tx[1] or P.SteamID == tx[1] then
			Alr = true
		end
	end
	if Alr then
		UnBan(tx[1])
		ChatIt(ply:Name().." unbanned "..tx[1])
	else
		ShoutIt("There is no banned person with those credentials.",ply)
	end
end
AddChatCommand("!unban",unban,1,"Unbans players")

local function PrintBan(ply)
	if not Bans then
		ShoutIt("There's no one banned",ply)
		return
	end
	for I,P in pairs(Bans) do
		local Time
		if P.Time > 0 then
			Time = math.ceil(((P.CurTime + P.Time * 60) - os.time()) / 60).." minutes"
		else
			Time = "Perma"
		end
		ChatIt(P.Name.." - "..P.SteamID.." - Reason: "..P.Reason.." - Time: "..Time,ply)
	end
end
AddChatCommand("!banlist",PrintBan,1,"Gives the list of banned players")

local function Slap(ply,txt)
	local tx = string.Explode(" ",txt)
	local Pl = PlayerFind(tx[1])
	if type(Pl) == "table" then
		local dmg = tonumber(tx[2]) or 0
		for I,P in pairs(Pl) do
			if P ~= ply then
				if P:GetPrivilege() > ply:GetPrivilege() then
					ShoutIt("You can't slap that player.",ply)
					if Owner then
						ChatIt(ply:Name().." tried to slap you.",Owner)
					end
				else
					P:SetVelocity(Vector(math.random(-100,100),math.random(-100,100),100))
					P:TakeDamage(dmg,NULL)
					P:EmitSound(Sound("player/pl_pain"..math.random(5,7)..".wav"))
					ChatIt("You slapped "..P:Name().." with "..dmg.." damage.",ply)
					ChatIt(ply:Name().." slapped you with "..dmg.." damage.",P)
					if Owner and ply ~= Owner then
						ChatIt(ply:Name().." slapped "..P:Name().." with "..dmg.." damage.",Owner)
					end
				end
			end
		end
	else
		ShoutIt("Invalid player found!",ply)
	end
end
AddChatCommand("!slap",Slap,1,"Slaps players")

local function Team(ply,txt)
	local tx = string.Explode(" ",txt)
	local Pl = PlayerFind(tx[1])
	if type(Pl) == "table" then
		local team = tonumber(tx[2])
		for I,P in pairs(Pl) do
			P:SetTeam(team)
			if team ~= 3 then
				if not P:GetNWBool("Ready") then
					P:SetNWBool("Ready",true)
					table.insert(Ready,P)
				end
			else
				if P:GetNWBool("Ready") then
					P:SetNWBool("Ready",false)
					for a,b in pairs(Ready) do
						if P == b then
							table.remove(Ready,a)
							break
						end
					end
				end
			end
			ChatIt("You changed "..P:Name().."'s team to "..team)
		end
	else
		ShoutIt("Invalid player found!",ply)
	end
end
AddChatCommand("!team",Team,2,"Changes the team of oneself's")

local function Give(ply,txt)
	local tx = string.Explode(" ",txt)
	local Pl = PlayerFind(tx[1])
	if type(Pl) == "table" then
		local Wep = tx[2]
		for I,P in pairs(Pl) do
			P:Give(Wep)
			ChatIt("You gave "..P:Name().." a weapon called "..Wep)
		end
	else
		ShoutIt("Invalid player found!",ply)
	end
end
AddChatCommand("!give",Give,2,"Gives a weapon to oneself")

local function SetPriv(ply,txt)
	local tx = string.Explode(" ",txt)
	local Pl = PlayerFind(tx[1])
	if type(Pl) == "table" then
		local num = tonumber(tx[2])
		for I,P in pairs(Pl) do
			P:SetPrivilege(num)
			DB_UpdateIndPly(P:SteamID(),"Privilege",num)
			ChatIt("You set "..P:Name().."'s privilege to "..num..".",ply)
			ChatIt(ply:Name().." set your privilege to "..num..".",P)
		end
	else
		ShoutIt("Invalid player found!",ply)
	end
end
AddChatCommand("!setpriv",SetPriv,2,"Sets one's privilege")

local function Priv(ply,txt)
	local tx = string.Explode(" ",txt)
	local Pl = PlayerFind(tx[1])
	if type(Pl) == "table" then
		for I,P in pairs(Pl) do
			local priv
			if P:GetPrivilege() == 0 then
				priv = "User"
			elseif P:GetPrivilege() == 1 then
				priv = "Admin"
			elseif P:GetPrivilege() == 2 then
				priv = "Owner"
			end
			ChatIt("Player's \""..P:Name().."\" privilege is set at \""..priv.."\"",ply)
		end
	else
		ShoutIt("Invalid player found!",ply)
	end
end
AddChatCommand("!priv",Priv,0,"Prints one's privilege")

local function Dosh(ply,txt)
	local tx = string.Explode(" ",txt)
	local Pl = PlayerFind(tx[1])
	if type(Pl) == "table" then
		local Dosh = tonumber(tx[2])
		for I,P in pairs(Pl) do
			P:AddDosh(Dosh)
			ChatIt(ply:Name().." gave you "..Dosh.." dosh.",P)
			ChatIt("You just gave "..Dosh.." dosh to "..P:Name(),ply)
		end
	else
		ShoutIt("Invalid player found!",ply)
	end
end
AddChatCommand("!dosh",Dosh,2,"Gives dosh to oneself")

local function Cmd(ply,txt)
	game.ConsoleCommand(txt.."\n")
end
AddChatCommand("!cmd",Cmd,2,"Rcon")

local function Run(ply,txt)
	RunString(txt)
end
AddChatCommand("!run",Run,2,"Lua_run")

local function Bots(ply,txt)
	local Num = tonumber(txt)
	for I = 1,Num do
		game.ConsoleCommand("bot\n")
	end
	timer.Simple(1,function()
		for I,P in pairs(player.GetAll()) do
			if P:IsBot() then
				P:SetTeam(1)
				P:SetNWBool("Ready",true)
				table.insert(Ready,P)
			end
		end
	end)
end
AddChatCommand("!bots",Bots,2,"Spawns bots")

local function rtd(ply,txt)
	if math.random(0,1) == 1 then
		ChatIt("You rolled the dice! The monster from Amnesia will now follow you for the rest of the round! Just don't look behind you!",ply)
	else
		ChatIt("You rolled the dice! Nothing happened.",ply)
	end
end
AddChatCommand("!rtd",rtd,0,"Rolls the dice")

local function Print(ply,txt)
	local Pri = ply:GetPrivilege()
	for I,C in pairs(ChatCmds) do
		if C[3] <= Pri then
			ChatIt(C[1].." - "..C[4],ply)
		end
	end
end
AddChatCommand("!print",Print,0,"Prints all available chatcommands")

local function Def(ply,txt)
	ply:SendLua("RunConsoleCommand('Trappola_DefaultChat')")
end
AddChatCommand("!default",Def,0,"Defaults the chatbox Position and Size")

// Chat commands end here.
// Chat functions start here.

function ChatIt(txt,ply)
	if not ply then
		print(os.date().." - [SYSTEM] "..txt)
	else
		print(os.date().." - To "..ply:Name().." [SYSTEM] "..txt)
	end
	umsg.Start("Message",ply)
		umsg.String(txt)
		umsg.Bool(false)
	umsg.End()
end

function ShoutIt(txt,ply,LineAmount,Line1,Line2,Line3)
	umsg.Start("Shout",ply)
		umsg.String(txt)
		if LineAmount then
			umsg.Short(LineAmount)
			umsg.String(Line1)
			if LineAmount > 1 then
				umsg.String(Line2)
				if LineAmount > 2 then
					umsg.String(Line3)
				end
			end
		end
	umsg.End()
end

function AdminChat(txt,ply)
	local Name
	local Team
	if not ply then
		Name = "Console"
		Team = 3
	else
		Name = ply:Name()
		Team = ply:Team()
	end
	local tx = txt
	local Plies = RecipientFilter()
	for I,P in pairs(player.GetAll()) do
		if P:GetPrivilege() >= 1 then
			Plies:AddPlayer(P)
		end
	end
	umsg.Start("Message",Plies)
		umsg.String(tx)
		umsg.String(Name)
		umsg.Short(Team)
		umsg.Bool(true)
	umsg.End()
end

function PlayerFind(txt,bool)
	if type(txt) ~= "string" then return NULL end
	if txt == "*" then return player.GetAll() end
	local Plies = {}
	for I,P in pairs(player.GetAll()) do
		if string.find(string.lower(P:Name()),string.lower(txt)) then
			table.insert(Plies,P)
		end
	end
	if #Plies > 0 and not bool then
		return Plies
	elseif #Plies > 0 and bool then
		return Plies[1]
	else
		return NULL
	end
end