
function SaveNews()
	local Str = ""
	for I,P in pairs(NEWS) do
		if type(P) == "string" then
			Str = Str..P
		else
			Str = Str..P[1].."#"..P[2]
		end
		Str = Str.."\n"
	end
	file.Write("SA_News.txt",Str)
end

function LoadNews()
	NEWS = {}
	if file.Exists("SA_News.txt","DATA") then
		local Str = file.Read("SA_News.txt","DATA")
		Str = string.Split(Str,"\n")
		for I,P in pairs(Str) do
			if P ~= "" then
				ParseNewsText(P)
			end
		end
		ChatIt("Succesfully loaded "..#NEWS.." news items!")
	else
		ChatIt("Failed to load news items, there are none!")
	end
end

function ParseNewsText(Str)
	local Item = Str
	if string.find(Str,"#") then
		local Expl = string.Split(Str,"#")
		Item = {Expl[1],Expl[2]}
	end
	table.insert(NEWS,Item)
	SendNews(Item)
	return Item
end

function SendNews(Item,ply)
	ply = ply or player.GetAll()
	net.Start("SA_News")
		if type(Item) == "string" then
			net.WriteBit(false)
			net.WriteString(Item)
		else
			net.WriteBit(true)
			net.WriteString(Item[1])
			net.WriteString(Item[2])
		end
	net.Send(ply)
end