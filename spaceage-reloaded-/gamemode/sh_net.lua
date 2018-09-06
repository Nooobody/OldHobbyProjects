//AddCSLuaFile("sh_net.lua")

function SendMessage()
	net.Start("Message")
	net.WriteInt(24,5)
	net.SendOmit()
end

net.Receive("Message",function(len,ply)
	print("Number was "..net.ReadInt(5))
	if ply then	print("Message received from "..ply:Nick().."!!")
	else print("Message received from server!!") end
end)