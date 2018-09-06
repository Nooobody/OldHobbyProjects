function InitExtract()
	local C1,C2 = MapExtract()
	if not C1 or not C2 then return end
	timer.Create("Extracting",0.1,0,function()
		if GetGlobalBool("Lobby") then return end
		for I,P in pairs(ents.FindInBox(C1,C2)) do
			if P:IsPlayer() and GetPlyArtStat(P) and P:Health() > 0 then
				if P:GetNWBool("Arti") then
					P:SetNWBool("Arti",false)
					P:AddFrags(1)
					if P.ArtiPinger and P.ArtiPinger:IsValid() then
						P.ArtiPinger:AddExp(20)
					end
					if not GetGlobalInt("OverTime") then
						SetGlobalInt("ExtraTime",GetGlobalInt("ExtraTime") + 10)
					end
					SetGlobalInt("Arties",GetGlobalInt("Arties") + 1)
					DB_UpdateAddIndPly(P:SteamID(),"Scores",1)
					local Exp = math.min(math.Round(((100 * (GetGlobalInt("Arties") / GetGlobalInt("MaxArties"))) / (GetGlobalInt("MaxArties") / 3)) * math.max(math.random(-1,1) + P:Frags(),1)),100)
					P:AddExp(Exp)
					local RF = RecipientFilter()
					for I,p in pairs(player.GetAll()) do
						if p ~= P then
							RF:AddPlayer(p)
						end
					end
					ShoutIt("An artifact has been returned!",RF,1,"By: "..P:Name())
					ShoutIt("An artifact has been returned!",P,2,"By: "..P:Name(),"You received "..Exp.." experience points!")
				elseif P:GetNWBool("FakeArti") then
					P:SetNWBool("FakeArti",false)
					P:SetVelocity(Vector(math.random(-500,500),math.random(-500,500),1000))
					local ply = P.FakeArtiOwner
					util.BlastDamage(ply,ply,P:GetPos() + Vector(0,0,100),200,35)
					local ef = EffectData()
					ef:SetOrigin(P:GetPos())
					ef:SetScale(1)
					util.Effect("Explosion",ef)
				end
			end
		end
	end)
end

MapExtracts = {}
local function AddMapExtract(map,vector1,vector2)
	MapExtracts[map] = {vector1,vector2}
end

function MapExtract()
	local Map = "_"..string.Explode("_",game.GetMap())[2].."_"
	local Vectors = MapExtracts[Map]
	if not Vectors then
		ChatIt("This map does not have a designated extract point.")
		return
	else
		return Vectors[1],Vectors[2]
	end
end

AddMapExtract("_fortress_",Vector(-376,-288,0),Vector(376,288,100))
AddMapExtract("_aztec_",Vector(-991,544,0),Vector(-544,991,100))
AddMapExtract("_bunker_",Vector(-161.9688,-1917.3442,64.0313),Vector(161.9688,-2551.8320,200))
AddMapExtract("_clockwork_",Vector(920,5264,128),Vector(1364,5712,256))	