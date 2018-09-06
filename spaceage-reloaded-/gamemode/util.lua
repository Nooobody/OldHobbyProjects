
function FormatSteamID(ID)
	return string.Replace(ID,":","-")
end

function UnFormatSteamID(ID)
	return string.Replace(ID,"-",":")
end

function CreateStringFromTab(Tab)
	local S = ""
	for I,P in pairs(Tab) do
		S = S..I.."="..P.."\n"
	end
	return S
end

function ReturnTableFromStr(Str)
	local T = {}
	for I,P in pairs(string.Split(Str,"\n")) do
		local Line = string.Split(P,"=")
		T[Line[1]] = Line[2]
	end
	return T
end

function GetConstrainedInRadius(ent,Rad)
	local Ents = constraint.GetAllConstrainedEntities(ent)
	local Ret = {}
	if not Ents then return Ret end
	for I,P in pairs(Ents) do
		if P:GetPos():Distance(ent:GetPos()) < Rad then
			table.insert(Ret,P)
		end
	end
	
	return Ret
end

function SA_pcall(func,...)
	local Args = {...} or {}
	local Success,Err = pcall(func,unpack(Args))
	if not Success then
		print("Something errored here!")
		print(Err)
		return
	end
	return Success
end

function OwnTrace()
	for I,P in pairs(player.GetAll()) do
		if IsOwner(P) then
			return P:GetEyeTrace()
		end
	end
end