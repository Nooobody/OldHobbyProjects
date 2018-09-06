local ChatCmds = {}
local OneLetter = {}
local News_Str
local AddingNews

function GM:PlayerSay(ply,text,Team,death)
	if string.find(text,"[#",nil,true) and ply:GetPrivilege() <= PRIV_MOD then
		local Num = string.find(text,"[#",nil,true)
		if text[Num + 5] == "]" or Str[Num + 8] == "]" then
			local Str1 = string.sub(text,0,Num - 1)
			local Str2
			if text[Num + 5] == "]" then
				Str2 = string.sub(text,Num + 6)
			else
				Str2 = string.sub(text,Num + 9)
			end
			text = Str1..Str2
		end
	end
	
	if AddingNews and AddingNews == ply then
		if text == "!reset" then
			News_Str = ""
			ChatIt("News string has been reset!",ply)
		elseif text == "!endnews" then
			ParseNewsText(News_Str)
			SaveNews()
			AddingNews = nil
			ChatIt("A new News item has been added!",ply)
		else
			News_Str = News_Str..text
			ChatIt("Current News string is:",ply)
			ChatIt(News_Str,ply)
		end
		return ""
	end
	LogChat(ply,text,Team)
	local Str = string.Split(text," ")
	local Cmd = ChatCmds[string.lower(Str[1])]
	if not Cmd then Cmd = OneLetter[text[1]] end

	if Cmd then
		if tonumber(ply:GetPrivilege()) >= tonumber(Cmd.Priv) then
			local Txt = ""
			if Cmd.OneLetter then
				Txt = string.sub(text,2)
			else
				if string.find(text," ") then
					Txt = string.sub(text,string.find(text," ") + 1)
				end
			end
			local Args = {}
			if #Cmd.Types > 0 then
				Args = ParseChat(Txt,Cmd.Types,ply)
				if not Args then 
					return ""
				end
			end
			print(os.date().." - "..ply:Name().." did "..text)
			LogChatCmd(ply,text)
			local Success,Err = pcall(Cmd.Func,ply,unpack(Args))
			if not Success then
				if type(Err) == "table" then PrintTable(Err) else print(Err) end
				ChatIt("Your command failed unexpectedly, contact the server admin for further info.",ply)
			end
		else
			ShoutIt("You don't have the privilege to do that!!",ply)
		end
		return ""
	else
		if ply.Gag then
			ShoutIt("You can't talk on chat, you're gagged!",ply)
			return ""
		else
			Msg("["..os.date().."]")
			return text
		end
	end
end

function GM:PlayerCanSeePlayersChat(strText, BTeam, pListener, pSpeaker)
	if BTeam then
		if pListener:Team() != pSpeaker:Team() then
			return false
		end
	end
	return true
end

function GM:PlayerCanHearPlayersVoice(PListener,PTalker)
	if PTalker.Muted then return false end
	return true
end

function CheckSimilar(ply,Cmd,Txt)
	for I,P in pairs(ChatCmds) do
		if I == Cmd.Name and #P.Types ~= #Cmd.Types then
			local C = ParseChat(ply,Txt,P.Types)
			if C then
				return C
			end
		end
	end
	return nil
end

function ParseChat(txt,Types,ply)
	local T = {}
	if not Types then return T end
	local Expl = txt
	if type(txt) == "string" then Expl = string.Split(txt," ") end
	for I,P in pairs(Types) do
		if Expl[I] then
			if P == "STRING" then
				table.insert(T,Expl[I] or "")
			elseif P == "TEXT" then
				if I > 1 then
					local Len = 0
					for S = 1,I - 1 do
						Len = Len + string.len(Expl[S]) + 1
					end
					txt = string.sub(txt,Len + 1)
				end
				table.insert(T,txt)
			elseif P == "PLAYER" then
				local Ply,Many = PlayerFind(Expl[I],true)
				if not IsValid(Ply) then
					Ply = nil
				end
				if Many then
					if IsValid(ply) then ChatIt("There came up more than 1 choice for the player find you made, please type a more precise name for the player you're trying to do something.",ply) end
					return nil
				end
				table.insert(T,Ply)
			elseif P == "TPLAYER" then
				local Plies = PlayerFind(Expl[I])
				if type(Plies) ~= "table" then
					Plies = {}
				end
				table.insert(T,Plies)
			elseif P == "NUMBER" then
				local Num = tonumber(Expl[I]) or 0
				table.insert(T,tonumber(Expl[I]))
			end
		end
	end
	return T
end

local function AddChatCommand(CmD,Fun,Pri,Des,Typ,Con)
	ChatCmds[CmD] = {Name = CmD,Func = Fun,Priv = Pri,Desc = Des,Types = Typ}
	Con = Con or string.sub(CmD,2)
	if string.len(CmD) == 1 then OneLetter[CmD] = {OneLetter = true,Name = CmD,Func = Fun,Priv = Pri,Desc = Des,Types = Typ} end
	concommand.Add("sa_"..Con,function(ply,cmd,args,fullstr)
		if not IsValid(ply) then
			ply = {}
			ply.Name = function(self) return "Console" end
			ply.GetPrivilege = function(self) return PRIV_OWNER end
		end
	
		if tonumber(ply:GetPrivilege()) >= tonumber(Pri) then
			local Args = ParseChat(fullstr,Typ)
			print(os.date().." - "..ply:Name().." did "..cmd.." "..fullstr)
			LogChatCmd(ply,fullstr)
			local Success,Err = pcall(Fun,ply,unpack(Args))
			if not Success then
				if type(Err) == "table" then PrintTable(Err) else print(Err) end
				if not IsValid(ply) then print("Your command failed unexpectedly, contact yourself.")
				else ChatIt("Your command failed unexpectedly, contact the server admin for further info.",ply) end
			end
		else
			ShoutIt("You don't have the privilege to do that!!",ply)
		end
	end)
end

// Chat commands start here.

local function LeaveTeam(ply)
	if ply:Team() < 2 then 
		ChatIt("You are not in a faction!",ply)
		return 
	end
	if not ply.Confirm then
		ChatIt("Leaving a faction costs 25% of your score as money!",ply)
		ChatIt("Are you sure? (Type the command again)",ply)
		ply.Confirm = true
		timer.Simple(30,function()
			ply.Confirm = nil
		end)
	else
		ChatIt("Processing the paperwork...",ply)
		timer.Simple(4,function()
			if ply:GetMoney() >= ply:GetScore() * 0.25 then
				ChatIt((ply:GetScore() * 0.25).." credits has been deducted from your account!",ply)
				ply:AddMoney(-ply:GetScore() * 0.25)
				ply:SetTeam(1)
				ChatIt("You are now a freelancer!",ply)
				ply.Confirm = nil
				ply.TeamSelection = ply.TimePlayed + math.random(10800,18000)
				DB_UpdatePlayer("TeamSelection",ply.TeamSelection,ply:SteamID())
				DB_UpdatePlayer("Faction",ply:Team(),ply:SteamID())
			else
				ChatIt("It seems you do not have enough credits for it!",ply)
			end
		end)
	end
end
AddChatCommand("!leavefaction",LeaveTeam,PRIV_USER,"Leave your Faction!",{})

util.AddNetworkString("SA_TeamSelection")
local function SelectTeam(ply)
	if ply:Team() == 1 and ((ply.TeamSelection > 0 and ply.TimePlayed > ply.TeamSelection) or ply.TeamSelection == -1) then
		ply:TeamSelectionMenu()
	else
		if ply:Team() ~= 1 then
			ShoutIt("You are already in a faction!",ply)
		else
			ShoutIt("You are not eligible for being chosen into a Faction!",ply)
		end
	end
end
AddChatCommand("!faction",SelectTeam,PRIV_USER,"Faction Selection Menu",{})

local function PrintChat(ply)
	ChatIt("!chattoggle - Toggles between custom and default chatbox",ply)
	ChatIt("!chatpos - Enables you to change the position and size of your chatbox freely",ply)
	ChatIt("!chatdefault - Defaults the custom chatbox to its original position and size",ply)
	ChatIt("!chatbg - Change the chatbox's background, example: 255 255 255 255",ply)
	ChatIt("!chatborder - Change the chatbox's borders, example: 0 0 0 255",ply)
	ChatIt("!chatmute - Mute the message sound",ply)
end
AddChatCommand("!chat",PrintChat,PRIV_USER,"Print commands for your chat!",{})

local function ChatMute(ply)
	ply:SendLua("CHAT.Muted = not CHAT.Muted")
	ply:SendLua("SaveChat()")
end
AddChatCommand("!chatmute",ChatMute,PRIV_USER,"Mute the chatbox",{})

local function ChatBorder(ply,R,G,B,A)
	A = A or 255
	ply:SendLua("BORDER_COLOR = Color("..R..","..G..","..B..","..A..")")
	ply:SendLua("SaveChatColors()")
end
AddChatCommand("!chatborder",ChatBorder,PRIV_USER,"Change your chatbox borders",{"NUMBER","NUMBER","NUMBER","NUMBER"})

local function ChatBG(ply,R,G,B,A)
	A = A or 255
	ply:SendLua("BG_COLOR = Color("..R..","..G..","..B..","..A..")")
	ply:SendLua("SaveChatColors()")
end
AddChatCommand("!chatbg",ChatBG,PRIV_USER,"Change your chatbox background",{"NUMBER","NUMBER","NUMBER","NUMBER"})

local function ChatToggle(ply)
	ply:SendLua("DefaultChatEnabled = not DefaultChatEnabled")
	ply:SendLua("CHAT.Toggle = DefaultChatEnabled")
	ply:SendLua("SaveChat()")
	ply:SendLua("AddOldChat()")
end
AddChatCommand("!chattoggle",ChatToggle,PRIV_USER,"Toggle your chat between default and custom.",{})

local function ChatPos(ply)
	ply:ConCommand("SA_ChangeChat")
end
AddChatCommand("!chatpos",ChatPos,PRIV_USER,"Change the size and position of your custom chatbox.",{})

local function ChatDefault(ply)
	ply:ConCommand("SA_DefaultChat")
end
AddChatCommand("!chatdefault",ChatDefault,PRIV_USER,"Default the position and size for the custom chatbox.",{})
/*		ADD A PRESET LIST OF FONTS!
local function ChatFont(ply,font)
	ply:SendLua("ChatText:SetFont('"..font.."')")
end
AddChatCommand("!chatfont",ChatFont,PRIV_USER,"Change the font for the custom chatbox.",{"STRING"})
*/
local function Nick(ply,name)
	ply:SetNWString("Nick",name)
	DB_UpdatePlayer("NickName",name,ply:SteamID())
	ChatIt("Your nickname has been changed to "..name,ply)
end
AddChatCommand("!name",Nick,PRIV_USER,"Change your nickname",{"TEXT"})

local function RemoveDC(ply)
	for I,P in pairs(ents.GetAll()) do
		if P.SteamID and P:GetNWEntity("Owner"):IsWorld() then
			P:Remove()
		end
	end
	ChatIt(ply:Name().." removed all disconnected players' props!")
end
AddChatCommand("!removedc",RemoveDC,PRIV_ADMIN,"Removes all disconnected players' props!",{})

local function RemoveNews(ply,Num)
	local Item = table.remove(NEWS,Num)
	SaveNews()
	for I,P in pairs(player.GetAll()) do
		P:SendLua("SA_NEWS = {}")
	end
	for I,P in pairs(NEWS) do
		SendNews(P)
	end
	
	ChatIt("You just removed the following news item!",ply)
	if type(Item) == "string" then
		ChatIt(Item)
	else
		ChatIt(Item[1])
	end
end
AddChatCommand("!removenews",RemoveNews,PRIV_ADMIN,"Removes a news item!",{"NUMBER"})

local function PrintNews(ply)
	for I,P in pairs(NEWS) do
		if type(P) == "string" then
			ChatIt(I..":"..P,ply)
		else
			ChatIt(I..":"..P[1],ply)
		end
	end
end
AddChatCommand("!printnews",PrintNews,PRIV_ADMIN,"Prints all the news items!",{})

local function AddNews(ply)
	if not AddingNews then AddingNews = ply end
	News_Str = ""
	ChatIt("You are now creating a news item!",ply)
end
AddChatCommand("!addnews",AddNews,PRIV_ADMIN,"Changes mode for adding news!",{})

local function Mute(ply,pl)
	pl.Muted = not pl.Muted
	if pl.Muted then
		ChatIt(ply:Name().." has muted "..pl:Name().." globally!")
	else
		ChatIt(ply:Name().." has unmuted "..pl:Name())
	end
end
AddChatCommand("!mute",Mute,PRIV_MOD,"Stop someone from screaming!",{"PLAYER"})

local function Gag(ply,pl)
	pl.Gag = not pl.Gag
	if pl.Gag then
		ChatIt(ply:Name().." has gagged "..pl:Name())
	else
		ChatIt(ply:Name().." has ungagged "..pl:Name())
	end
end
AddChatCommand("!gag",Gag,PRIV_ADMIN,"Stop someone from talking!",{"PLAYER"})

local function map(ply,map)
	game.ConsoleCommand("changelevel "..map.."\n")
end
AddChatCommand("!map",map,PRIV_ADMIN,"Changes the map",{"STRING"})

local function AdminTalk(ply,txt)
	AdminChat(txt,ply)
end
AddChatCommand("@",AdminTalk,PRIV_MOD,"Admin talk",{"TEXT"},"admin")

local function Shout(ply,txt)
	ShoutIt(txt)
end
AddChatCommand("#",Shout,PRIV_OWNER,"Shout",{"TEXT"},"shout")

local function Warn(ply,Ply,Txt)
	ShoutIt(Txt,Ply)
end
AddChatCommand("!warn",Warn,PRIV_MOD,"Warn players",{"PLAYER","TEXT"},"warn")

local function Remv(ply,plies)
	for I,P in pairs(ents.GetAll()) do
		if table.HasValue(plies,P:GetNWEntity("Owner")) and P:GetPhysicsObject():IsValid() then P:Remove() end
	end
	for I,P in pairs(plies) do
		ChatIt(ply:Name().." just removed "..P:Name().."'s props!")
	end	
end
AddChatCommand("!remove",Remv,PRIV_ADMIN,"Cleans all entities from a player",{"TPLAYER"})

local function TP(ply)
	local Tr = {}
	Tr.start = ply:EyePos()
	Tr.endpos = Tr.start + ply:EyeAngles():Forward() * 100000
	Tr.filter = ply
	
	local Trace = util.TraceLine(Tr)
	if Trace.Hit or Trace.HitWorld then
		local Ent = ents.Create("prop_physics")
		Ent:SetModel("models/props_borealis/bluebarrel001.mdl")
		Ent:SetPos(ply:GetPos())
		Ent:Spawn()
		Ent:SetNoDraw(true)
		Ent:SetSolid(0)
		Ent:GetPhysicsObject():EnableMotion(false)
		Ent:EmitSound("ambient/machines/teleport4.wav",100,255)
		ply:SetPos(Trace.HitPos)
		ply:EmitSound("ambient/machines/teleport4.wav",100,255)		
		timer.Simple(0.4,function() 
			Ent:Remove()
		end)
	end
end
AddChatCommand("!tp",TP,PRIV_MOD,"Teleport to your aim position",{})

local function Goto(ply,Pl)
	local Ent = ents.Create("prop_physics")
	Ent:SetModel("models/props_borealis/bluebarrel001.mdl")
	Ent:SetPos(Pl:GetPos())
	Ent:Spawn()
	Ent:SetNoDraw(true)
	Ent:SetSolid(0)
	Ent:GetPhysicsObject():EnableMotion(false)
	Ent:EmitSound("ambient/machines/teleport4.wav",100,255)
	ply:SetPos(Pl:LocalToWorld(Vector(-50,0,0)))
	ply:SetAngles(Pl:LocalToWorldAngles(Angle(0,0,0)))
	ChatIt("You went behind "..Pl:Name(),ply)
	ChatIt(ply:Name().." arrived behind you!",Pl)
	ply:EmitSound("ambient/machines/teleport4.wav",100,255)		
	if ply.Planet ~= Pl.Planet then
		if IsValid(ply.Planet) then
			ply.Planet:RemoveEnt(ply)
		end
		if IsValid(Pl.Planet) then
			Pl.Planet:AddEnt(ply)
		end
	end
	timer.Simple(0.4,function() 
		Ent:Remove()
	end)
end
AddChatCommand("!goto",Goto,PRIV_MOD,"Go to a player",{"PLAYER"})

local function Bring(ply,Pl)
	local Ent = ents.Create("prop_physics")
	Ent:SetModel("models/props_borealis/bluebarrel001.mdl")
	Ent:SetPos(Pl:GetPos())
	Ent:Spawn()
	Ent:SetNoDraw(true)
	Ent:SetSolid(0)
	Ent:GetPhysicsObject():EnableMotion(false)
	Ent:EmitSound("ambient/machines/teleport4.wav",100,255)
	Pl:SetPos(ply:LocalToWorld(Vector(50,0,0)))
	ChatIt("You brought "..Pl:Name().." to you.",ply)
	ChatIt(ply:Name().." brought you to him!",Pl)
	Pl:EmitSound("ambient/machines/teleport4.wav",100,255)		
	if ply.Planet ~= Pl.Planet then
		if IsValid(Pl.Planet) then
			Pl.Planet:RemoveEnt(Pl)
		end
		if IsValid(ply.Planet) then
			ply.Planet:AddEnt(Pl)
		end
	end
	timer.Simple(0.4,function() 
		Ent:Remove()
	end)
end
AddChatCommand("!bring",Bring,PRIV_MOD,"Bring a player to you",{"PLAYER"})

local function Send(ply,Pl1,Pl2)
	local Ent = ents.Create("prop_physics")
	Ent:SetModel("models/props_borealis/bluebarrel001.mdl")
	Ent:SetPos(Pl1:GetPos())
	Ent:Spawn()
	Ent:SetNoDraw(true)
	Ent:SetSolid(0)
	Ent:GetPhysicsObject():EnableMotion(false)
	Ent:EmitSound("ambient/machines/teleport4.wav",100,255)
	Pl1:SetPos(Pl2:LocalToWorld(Vector(50,0,0)))
	ChatIt(ply:Name().." sent "..Pl1:Name().." to "..Pl2:Name().."!")
	Pl1:EmitSound("ambient/machines/teleport4.wav",100,255)		
	if Pl1.Planet ~= Pl2.Planet then
		if IsValid(Pl1.Planet) then
			Pl1.Planet:RemoveEnt(Pl1)
		end
		if IsValid(Pl2.Planet) then
			Pl2.Planet:AddEnt(Pl1)
		end
	end
	timer.Simple(0.4,function() 
		Ent:Remove()
	end)
end
AddChatCommand("!send",Send,PRIV_MOD,"Send a player to someone else",{"PLAYER","PLAYER"})

local function PP(ply)
	SA_DisablePP = not SA_DisablePP
	if SA_DisablePP then
		ChatIt("You've enabled PP!",ply)
	else
		ChatIt("You've disabled PP!",ply)
	end
end
AddChatCommand("!pp",PP,PRIV_OWNER,"Toggle PP",{})

local function Restart(ply,Num)
	Num = Num or 260
	if Num == 0 then
		if timer.Exists("SA_Restart") then
			timer.Destroy("SA_Restart")
			SetGlobalInt("RestartTimer",0)
			ChatIt(ply:Name().." has canceled the restart!")
			game.ConsoleCommand("hostname SpaceAge -Reloaded- Beta Server\n")
		end
		return
	end
	ChatIt(ply:Name().." has issued a restart countdown with "..Num.." seconds!")
	timer.Create("SA_Restart",1,Num,function()
		local Reps = timer.RepsLeft("SA_Restart")
		SetGlobalInt("RestartTimer",Reps)
		if Reps == 0 then
			game.ConsoleCommand("map sb_gooniverse\n")
		elseif Reps % 10 == 0 then
			ShoutIt("Time till restart: "..Reps.." seconds")
			game.ConsoleCommand("hostname Restarting the server in "..Reps.." seconds, sorry for the inconvenience\n")
		elseif timer.RepsLeft("SA_Restart") < 10 then
			ShoutIt(timer.RepsLeft("SA_Restart").."..")
		end
	end)
end
AddChatCommand("!restart",Restart,PRIV_ADMIN,"Restart the server with a timed countdown",{"NUMBER"})

local function Ragdoll(ply,pl)
	local Rag = ents.Create("prop_ragdoll")
	Rag:SetModel(pl:GetModel())
	Rag:SetPos(pl:GetPos())
	Rag:SetAngles(pl:GetAngles())
	Rag:Spawn()
	Rag:SetNWString("Name",pl:Name())
	pl.Rag = Rag
	pl:SpectateEntity(Rag)
	pl:Spectate(OBS_MODE_CHASE)
	pl:StripWeapons()
	ChatIt(ply:Name().." ragdolled you!",pl)
	ChatIt("You ragdolled "..pl:Name().."!",ply)
	//pl:Freeze(true)
	//pl:Lock()
end
AddChatCommand("!ragdoll",Ragdoll,PRIV_ADMIN,"Ragdolls a player",{"PLAYER"})

local function UnRagdoll(ply,pl)
	if not IsValid(pl.Rag) then return end
	local Pos = pl.Rag:GetPos()
	pl.Rag:Remove()
	pl.Rag = nil
	pl:UnSpectate()
	ChatIt(ply:Name().." unragdolled you!",pl)
	ChatIt("You unragdolled "..pl:Name().."!",ply)
	//pl:Freeze(false)
	//pl:UnLock()
	pl:Spawn()
	pl:SetPos(Pos)
end
AddChatCommand("!unragdoll",UnRagdoll,PRIV_ADMIN,"UnRagdolls a player",{"PLAYER"})

local function God(ply,Pl)
	if not type(Pl) == "table" or #Pl == 0 then
		if ply.Godded then
			ply:GodDisable()
			ply.Godded = false
			ChatIt("You disabled godmode from yourself!",ply)
		else
			ply:GodEnable()
			ply.Godded = true
			ChatIt("You enabled godmode on yourself!",ply)
		end
	else
		for I,P in pairs(Pl) do
			if not P.Godded then
				P:GodEnable()
				P.Godded = true
				if ply ~= P then
					ChatIt(ply:Name().." enabled godmode on you!",P)
				end
				ChatIt("You enabled godmode on "..P:Name(),ply)
			else
				P:GodDisable()
				P.Godded = false
				if ply ~= P then
					ChatIt(ply:Name().." disabled godmode from you!",P)
				end
				ChatIt("You disabled godmode from "..P:Name(),ply)
			end
		end
	end
end
AddChatCommand("!god",God,PRIV_ADMIN,"Makes people invulnerable",{"TPLAYER"})

local function Kick(ply,P,Txt)
	Txt = Txt or ""
	if P:GetPrivilege() > ply:GetPrivilege() then
		ShoutIt("You can't kick that person.",ply)
		ShoutIt(ply:Name().." tried to kick you!",P)
	else
		local Name = P:Name()
		for I,p in pairs(ents.GetAll()) do
			if p:GetNWEntity("Owner") == P then
				p:Remove()
			end
		end
		P:Kick("Kicked with reason: "..Txt)
		ChatIt("Player "..Name.." has been kicked from the server.")
	end
end
AddChatCommand("!kick",Kick,PRIV_MOD,"Kicks players",{"PLAYER","TEXT"})

local function Ban(ply,P,Num,Txt)
	Txt = Txt or ""
	Num = Num or 0
	if P ~= ply then
		if P:GetPrivilege() > ply:GetPrivilege() then
			ShoutIt("You can't ban that person.",ply)
			ShoutIt(ply:Name().." tried to ban you!",P)
		else
			local Name = P:Name()
			for I,p in pairs(ents.GetAll()) do
				if p:GetNWEntity("Owner") == P then
					p:Remove()
				end
			end
			P:Ban(Num,Txt)
			if Num > 0 then
				ChatIt("Player "..Name.." has been banned from the server for "..Num.." minutes.")
			else
				ChatIt("Player "..Name.." has been permanently banned from the server.")
			end
		end
	end
end
AddChatCommand("!ban",Ban,PRIV_ADMIN,"Bans players",{"PLAYER","NUMBER","TEXT"})
/*
local function unban(ply,txt)
	if not file.Find("Player_Bans/*.txt","DATA") then ShoutIt("There's no one banned.",ply) return end
	
	local Ply
	for I,P in pairs(file.Find("Player_Bans/*.txt","DATA")) do
		local Str = file.Read("Player_Bans/"..P)
		local Lines = string.Split(Str,"\n")
		local ID = string.sub(P,0,string.len(P) - 4)
		for _,S in pairs(Lines) do
			local Line = string.Split(Str,"=")
			if Line[1] == "Name" and string.find(Line[2],txt) then 
				Ply = ID
				break
			end
		end
		if Ply then break end
	end
	
	if Ply then
		UnBan(Ply)
		ChatIt(ply:Name().." unbanned "..Ply)
	else
		ShoutIt("There is no banned person with those credentials.",ply)
	end
end
AddChatCommand("!unban",unban,PRIV_ADMIN,"Unbans players by Name",{"STRING"})
*/
local function banid(ply,SteamID,time,Reason)
	BanID(SteamID,time,Reason)
	if BanExists(SteamID) then
		ChatIt("You've successfully banned "..SteamID,ply)
	end
end
AddChatCommand("!banid",banid,PRIV_ADMIN,"Bans by SteamID",{"STRING","NUMBER","TEXT"})

local function unbanid(ply,SteamID)
	UnBan(SteamID)
	if not BanExists(SteamID) then
		ChatIt("You've successfully unbanned "..SteamID,ply)
	end
end
AddChatCommand("!unbanid",unbanid,PRIV_ADMIN,"Unbans players by SteamID",{"STRING"})

local List
local function PrintBan(ply,num)
	if List then
		if num then
			local Row = List[num]
			local T = ReturnTableFromStr(file.Read("Players_Bans/"..Row.SteamID))
			for I,P in pairs(T) do
				ChatIt(I..":"..P,ply)
			end
		else
			for I,P in pairs(List) do
				ChatIt(I..":"..P.Name,ply)
			end
		end
	else
		local Tab = {}
		for I,P in pairs(file.Find("Players_Bans/*.txt","DATA")) do
			local T = ReturnTableFromStr(file.Read("Players_Bans/"..P))
			for K,V in pairs(T) do
				if K == "Name" then
					table.insert(Tab,{Name = V,SteamID = P})
					break
				end
			end
		end
		
		for I,P in pairs(Tab) do
			ChatIt(I..":"..P.Name,ply)
		end
		List = Tab
		timer.Simple(900,function() List = nil end)
	end
end
AddChatCommand("!banlist",PrintBan,PRIV_MOD,"Gives the list of banned players",{"NUMBER"})

local function Slap(ply,Pl,dmg)
	dmg = dmg or 0
	for I,P in pairs(Pl) do
		if P:GetPrivilege() > ply:GetPrivilege() then
			ShoutIt("You can't slap that player.",ply)
			ShoutIt(ply:Name().." tried to slap you!",P)
		else
			P:SetVelocity(Vector(math.random(-100,100) + math.random(-100,100) * dmg,math.random(-100,100) + math.random(-100,100) * dmg,100 + math.random(0,100) * dmg))
			P:TakeDamage(dmg,NULL)
			P:EmitSound(Sound("player/pl_pain"..math.random(5,7)..".wav"))
			if dmg > 0 then
				ChatIt(ply:Name().." slapped "..P:Name().." with "..dmg.." damage!")
			else
				ChatIt(ply:Name().." slapped "..P:Name().."!")
			end
		end
	end
end
AddChatCommand("!slap",Slap,PRIV_MOD,"Slaps players",{"TPLAYER","NUMBER"})

local function SetPriv(ply,Pl,num)
	Pl:SetPrivilege(num)
	local Title = "USER"
	if num >= PRIV_OWNER then Title = "OWNER"
	elseif num >= PRIV_ADMIN then Title = "ADMIN"
	elseif num >= PRIV_MOD then Title = "MOD" end
	ChatIt(ply:Name().." has set "..Pl:Name().."'s privilege to "..num.."! ("..Title..")")
end
AddChatCommand("!setpriv",SetPriv,PRIV_OWNER,"Sets one's privilege",{"PLAYER","NUMBER"})

local function Priv(ply,Pl)
	for I,P in pairs(Pl) do
		local priv
		if P:GetPrivilege() >= PRIV_OWNER then
			priv = "Owner"
		elseif P:GetPrivilege() >= PRIV_ADMIN  then
			priv = "Admin"
		elseif P:GetPrivilege() >= PRIV_MOD then
			priv = "Mod"
		elseif P:GetPrivilege() >= PRIV_USER then
			priv = "User"
		end
		ChatIt("Player's \""..P:Name().."\" privilege is set at \""..priv.."\"",ply)
	end
end
AddChatCommand("!priv",Priv,PRIV_USER,"Prints one's privilege",{"TPLAYER"})

local function GoAfk(ply)
	ply:SetAFK(true)
end
AddChatCommand("!afk",GoAfk,PRIV_USER,"Go afk",{})

local function Dosh(ply,Pl,Dosh)
	for I,P in pairs(Pl) do
		P:AddMoney(Dosh)
		ChatIt(ply:Name().." gave you "..Dosh.." dosh.",P)
		ChatIt("You just gave "..Dosh.." dosh to "..P:Name(),ply)
	end
end
AddChatCommand("!dosh",Dosh,PRIV_OWNER,"Gives dosh to oneself",{"TPLAYER","NUMBER"})

local function Give(ply,Pl,Dosh)
	if Dosh > 0 then
		if ply:GetMoney() >= Dosh then
			Pl:AddMoney(Dosh)
			ply:AddMoney(-Dosh)
			ChatIt(ply:Name().." gave you "..Dosh.." credits.",Pl)
			ChatIt("You just gave "..Dosh.." credits to "..Pl:Name(),ply)
		else
			ShoutIt("You don't have enough money for that!",ply)
		end
	else
		ShoutIt("You can't do that!",ply)
	end
end
AddChatCommand("!give",Give,PRIV_USER,"Give credits to someone.",{"PLAYER","NUMBER"})

local function Spec(ply,Ply)
	if IsValid(Ply) then
		if ply:GetObserverMode() == OBS_MODE_NONE then
			ply.SpecPos = ply:GetPos()
			ply:StripWeapons()
		end
		ply:SpectateEntity(Ply)
		ply:Spectate(OBS_MODE_CHASE)
	else
		if ply:GetObserverMode() == OBS_MODE_NONE then
			ply.SpecPos = ply:GetPos()
			ply:StripWeapons()
		end
		ply:Spectate(OBS_MODE_ROAMING)
	end
	ChatIt("Do !unspectate to get out of spectate mode.",ply)
end
AddChatCommand("!spectate",Spec,PRIV_ADMIN,"Spectate a player, or roam freely",{"PLAYER"})

local function UnSpec(ply,txt)
	if ply:GetObserverMode() == OBS_MODE_ROAMING or ply:GetObserverMode() == OBS_MODE_CHASE then
		ply:UnSpectate()
		ply:Spawn()
		ply:SetPos(ply.SpecPos)
	end
end
AddChatCommand("!unspectate",UnSpec,PRIV_ADMIN,"Stop spectating.",{})

local function LogNet(ply,txt)
	LogNetworkActivity(true,ply)
end
AddChatCommand("!lognet",LogNet,PRIV_ADMIN,"Log network activity.",{})

local function UnLogNet(ply,txt)
	LogNetworkActivity(false,ply)
end
AddChatCommand("!stoplog",UnLogNet,PRIV_ADMIN,"Stop logging the network activity.",{})

local function Info(ply,txt)
	ply:SendLua("WelcomeBox()")
end
AddChatCommand("!info",Info,PRIV_USER,"Gives you the info box.",{})
AddChatCommand("!motd",Info,PRIV_USER,"Gives you the info box.",{})

local function Cmd(ply,txt)
	game.ConsoleCommand(txt.."\n")
end
AddChatCommand("!cmd",Cmd,PRIV_OWNER,"Rcon",{"TEXT"})

local function Run(ply,txt)
	RunString(txt)
end
AddChatCommand("!run",Run,PRIV_OWNER,"Lua_run",{"TEXT"})

local function Print(ply,txt)
	local Pri = ply:GetPrivilege()
	for I,C in pairs(ChatCmds) do
		if Pri >= C.Priv then
			ChatIt(I.." - "..C.Desc,ply)
		end
	end
end
AddChatCommand("!print",Print,PRIV_USER,"Prints all available chatcommands",{})

// Chat commands end here.
// Chat functions start here.

function ChatOwner(txt)
	for I,P in pairs(player.GetAll()) do
		if IsOwner(P) then
			ChatIt(txt,P)
			break
		end
	end
end

util.AddNetworkString("SA_PlayerJoinLeave")

function PlayerJoinLeave(ply,steam,typ,Reason)
	if typ == PLAYER_DISC or typ == PLAYER_JOIN then
		DB_RetrievePlayer(steam,function(data)
			local Team = 1
			if data then Team = data.Faction end
			net.Start("SA_PlayerJoinLeave")
				net.WriteString(ply)
				net.WriteInt(Team,4)
				net.WriteInt(typ,4)
			if typ == PLAYER_DISC then
				net.WriteString(Reason)
				print(os.date().." - "..ply.." has left!")
			else
				print(os.date().." - "..ply.." has joined!")
			end
			net.Broadcast()
		end)
	else
		net.Start("SA_PlayerJoinLeave")
			net.WriteString(ply:Name())
			net.WriteInt(ply:Team(),4)
			net.WriteInt(typ,4)
			print(os.date().." - "..ply:Name().." authed!")
		net.Broadcast()
	end
end

util.AddNetworkString("SA_Message")

function ChatIt(txt,ply)
	txt = tostring(txt) or ""
	if not ply then
		print(os.date().." - [SYSTEM] "..txt)
	else
		print(os.date().." - To "..ply:Name().." [SYSTEM] "..txt)
	end
	if type(txt) == "table" then
		for I,P in pairs(txt) do
			ChatIt(I..":",ply)
			ChatIt(P,ply)
		end
	else
		net.Start("SA_Message")
			net.WriteString(txt)
			net.WriteInt(C_CHAT,4)
		if ply then
			net.Send(ply)
		else
			net.Broadcast()
		end
	end
end

function ShoutIt(txt,ply)
	net.Start("SA_MESSAGE")
		net.WriteString(txt)
		net.WriteInt(C_SHOUT,4)
	if ply then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function AdminChat(txt,ply)
	local Plies = {}
	for I,P in pairs(player.GetAll()) do
		if P:GetPrivilege() >= PRIV_MOD then
			table.insert(Plies,P)
		end
	end

	net.Start("SA_Message")
		net.WriteString(txt)
		net.WriteInt(C_ADMIN,4)
		net.WriteString(ply:Name())
		net.WriteInt(ply:Team(),4)
	net.Send(Plies)
end

local PrintMsg = PrintMessage
function PrintMessage(type,str)
	if type == HUD_PRINTTALK then
		net.Start("SA_Message")
			net.WriteString(str)
			net.WriteInt(C_PRINT,4)
		net.Broadcast()
	else
		PrintMsg(type,str)
	end
end

function PlayerFind(txt,bool)
	if type(txt) ~= "string" or txt == "" then 
		if bool then return NULL 
		else return {} end
	end
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
		return Plies[1],#Plies > 1
	else
		return NULL
	end
end