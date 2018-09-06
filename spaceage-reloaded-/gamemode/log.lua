
local NReceive = net.Receive
local NSend = net.Send
local NBroadcast = net.Broadcast
local NSendOmit = net.SendOmit
local Net_LoggingActivator = nil
local Net_Logging = false
local Activated = 0
local Net_Logger = {Received = 0,TriedSending = 0,ReceivedBits = 0}
function LogNetworkActivity(b,ply)
	if b ~= Net_Logging then
		Net_Logging = b
		if b then
			Activated = CurTime()
			ChatIt("Activating Net transmission logging.",ply)
			ChatIt("Results will appear in 30 seconds.",ply)
			Net_LoggingActivator = nil
			timer.Create("SA_NetLogger",30,1,function()
				ChatIt("Net transmissions during the last 30 seconds:",ply)
				ChatIt("Transmissions received: "..Net_Logger.Received,ply)
				ChatIt("Transmissions received total size: "..Net_Logger.ReceivedBits,ply)
				ChatIt("Transmissions tried to send: "..Net_Logger.TriedSending,ply)
				Net_Logger.Received = 0
				Net_Logger.TriedSending = 0
				Net_Logger.ReceivedBits = 0
				Net_LoggingActivator = nil
				Net_Logging = false
			end)
		else
			timer.Destroy("SA_NetLogger")
			ChatIt("Net logging has been deactivated!",ply)
			ChatIt("Net transmissions during the last "..math.floor(CurTime() - Activated).." seconds:",ply)
			ChatIt("Transmissions received: "..Net_Logger.Received,ply)
			ChatIt("Transmissions received total size: "..Net_Logger.ReceivedBits,ply)
			ChatIt("Transmissions tried to send: "..Net_Logger.TriedSending,ply)
			Net_Logging = false
			Net_LoggingActivator = nil
			Net_Logger.Received = 0
			Net_Logger.TriedSending = 0
			Net_Logger.ReceivedBits = 0
		end
	elseif b and Net_LoggingActivator then
		ChatIt("Sorry, but "..Net_LoggingActivator:GetName().." has already activated the net logging.",ply)
	end
end

function net.Receive(Str,func)
	NReceive(Str,function(len,ply) 
		if Net_Logging then
			Net_Logger.Received = Net_Logger.Received + 1
			Net_Logger.ReceivedBits = Net_Logger.ReceivedBits + len
		end
		func(len,ply)
	end)
end

function net.Send(Ply)
	if Net_Logging then
		if type(Ply) == "table" then
			Net_Logger.TriedSending = Net_Logger.TriedSending + #Ply
		else
			Net_Logger.TriedSending = Net_Logger.TriedSending + 1
		end
	end
	
	NSend(Ply)
end

function net.Broadcast()
	if Net_Logging then
		Net_Logger.TriedSending = Net_Logger.TriedSending + #player.GetAll()
	end
	
	NBroadcast()
end

function net.SendOmit(Ply)
	if Net_Logging then
		if type(Ply) == "table" then
			Net_Logger.TriedSending = Net_Logger.TriedSending + (#player.GetAll() - #Ply)
		else
			Net_Logger.TriedSending = Net_Logger.TriedSending + (#player.GetAll() - 1)
		end
	end
	
	NSendOmit(Ply)
end

function LogChatCmd(ply,str)
	local Str = os.date().." - "..ply:Name().." did "..str
	if not file.Exists("CMD_Log.txt","DATA") then
		file.Write("CMD_Log.txt","")
	end
	file.Append("CMD_Log.txt",Str.."\r\n")
end

function LogCL(ply,str)
	local Str = os.date().." - "..ply:Name().." did "..str
	if not file.Exists("RUNCL_Log.txt","DATA") then
		file.Write("RUNCL_Log.txt","")
	end
	file.Append("RUNCL_Log.txt",Str.."\r\n")
end

function LogChat(ply,str,IsTeam)
	local Team = ""
	if IsTeam then Team = " [TEAM] " end
	local Str = os.date().." - "..Team..ply:Name()..": "..str
	if not file.Exists("Chat.txt","DATA") then
		file.Write("Chat.txt","")
	end
	file.Append("Chat.txt",Str.."\r\n") 
end