function GM:InitPostEntity()
	All = ents.FindByModel("models/combine_helicopter/helicopter_bomb01.mdl")
	for I,P in pairs(All) do
		P:GetPhysicsObject():EnableMotion(false)
		P:SetNoDraw(true)
		P:SetNotSolid(true)
		if not util.IsInWorld(P:GetPos() + Vector(0,0,10)) then 
			P:Remove()
			All[I] = nil
		end
	end
end

function ArtifactSpawn()
	for I,A in pairs(ents.FindByClass("Artifact")) do
		A:Remove()
	end
	Int = 0
	if not All then
		All = ents.FindByModel("models/combine_helicopter/helicopter_bomb01.mdl")
	end
	Copy = table.Copy(All)
	MaxArt = 0
	local Playa = #team.GetPlayers(1) + #team.GetPlayers(2)
	for I = 1,Playa do
		MaxArt = math.min(MaxArt + math.random(5,10),50)
	end
	SetGlobalInt("MaxArties",MaxArt)
	ForArtifact(#Copy)
	if #ents.FindByClass("artifact") < GetGlobalInt("MaxArties") then
		ArtifactSpawn()
	end
end

function ForArtifact(i)
	for I = 1,i do
		local E = table.Random(Copy)
		local Find = ents.FindInSphere(E:GetPos(),250)
		local F = false
		for i,P in pairs(Find) do
			if P:GetClass() == "artifact" then
				F = true
				break
			end
		end
		if not F then
			Artifact(E)
			table.remove(Copy,Num)
		else
			table.remove(Copy,Num)
		end
		if MaxArt <= Int then
			break
		end
	end
end

function Artifact(Ent)
	if Int < MaxArt then
		local Pos = Ent:GetPos()
		local Angles = Ent:GetAngles()
		local Arti = ents.Create("Artifact")
		Arti:SetPos(Pos)
		Arti:SetAngles(Angles)
		Arti:Spawn()
		Int = Int + 1
	end
end