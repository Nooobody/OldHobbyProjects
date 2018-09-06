GM.Name = "SpaceAge -Reloaded-"
GM.Author = "Nooobody"
GM.Email = "N/A"
GM.Website = "N/A"
DeriveGamemode("sandbox")

function IsOwner(ply)
	return game.SinglePlayer() or ply:SteamID() == "STEAM_0:1:22097575" or ply:GetPrivilege() == PRIV_OWNER
end

function table.HasKey(tabl,key)
	return tabl[key]
end

function IsResource(Res)
	return table.HasValue(Resources,Res)
end
/*
ErrorTable = {}
local Err = Error
function Error(...)
	local Self
	for I = 1,8 do
		if not debug.getinfo(I) then break end
		local Name,Value = debug.getlocal(I,1)
		if Name == "self" then
			Self = Value
			break
		end
	end
	
	local T = {}
	T.Args = {...}
	T.self = Self
	T.Trace = debug.traceback()
	T.Continous = false
	
	for I,P in pairs(ErrorTable) do
		if P.Trace == T.Trace and not P.Continous then 
			print(os.date().." - "..os.time())
			print(tostring(P.self).." seems to be causing a continous error!")
			P.Continous = true
			
			return 
		end
	end
	
	table.Add(ErrorTable,T)
	print(os.date().." - "..os.time())
	print(tostring(Self).." has caused the following error: ")
	Err(...)
end


function error(str,lvl)
	Error(str)
end
*/
MARKETABLE = {
	Rare_Diamonds = 3.4,
	Compressed_Air = 0.5,
	Oxidized_Crystals = 2.1,
	Valuable_Minerals = 1.7,
	RawTiberium = 8.2,
	LiquidTiberium = 8.5,
	Refined_BlueIce = 800,
	Refined_ClearIce = 800,
	Refined_GlareCrust = 1200,
	Refined_GlacialMass = 1800,
	Refined_WhiteGlaze = 2000,
	Refined_Gelidus = 2250,
	Refined_Krystallos = 2350,
	Refined_DarkGlitter = 3000
}

REFINE_MATERIALS = {
	RawOre = {
		//Iron = 0.01,
		//Lithium = 0.03,
		//Sulfur = 0.04,
		Oxidized_Crystals = 0.2,
		Valuable_Minerals = 1.6,
		Compressed_Air = 2.5,
		Rare_Diamonds = 0.1,
		Nitrogen = 0.01,
		Oxygen = 0.02,
	}
}

PLAYER_JOIN = 1
PLAYER_AUTH = 2
PLAYER_DISC = 3

PRIV_OWNER = 390
PRIV_ADMIN = 100
PRIV_MOD = 50
PRIV_USER = 0

PRIVs = {}
PRIVs[PRIV_OWNER] = {
	Color = Color(0,248,248),
	Tag = "Dev",
	Name = "Developer"
}
PRIVs[PRIV_ADMIN] = {
	Color = Color(255,0,0),
	Tag = "A",
	Name = "Admin"
}
PRIVs[PRIV_MOD] = {
	Color = Color(0,255,100),
	Tag = "M",
	Name = "Mod"
}

C_CHAT = 0
C_SHOUT = 1
C_ADMIN = 2
C_PRINT = 3



Solids = {
	"Ice",
	"Lithium",									// Refined from ore
	"Sulfur",									// Refined from ore
	"Iron",										// Refined from ore
	"Lithium_Nitride",							// 6 Lithium + Nitrogen + 3 Water = 3 LiOH + NH3
	"Lithium_Hydroxide"							// LiOH = 2 Li + 2 H2O = 2 LiOH + H2 // Used in CO2 Scrubbing (2 LiOH + CO2 = Li2CO3 + H2O, Carbonate ignored) 
}

Liquids = {
	"Water",
	"Heavy_Water",								// Hydrogen Sulfide + Water = Heavy_Water
	"Sulfuric_Acid",							// H2SO4: 2 SO2 + 2 H2O + O2 = 2 H2SO4  // Possible planet killer
	"Methanol"									// Carbon dioxide with 3 Hydrogen = Methanol + Water
}

Gases = {
	Oxygen = {							// Distilled from atmosphere
		Toxic = false,
		Temperature = -36
	},
	Methane = {								// Sabatier: CO2 + 4 H = Methane + 2 Water
		Toxic = false,						// Burns with oxygen, results in CO2 and Water
		Temperature = 300
	},
	Hydrogen = {							// Results in water when used with oxygen. (Burned)
		Toxic = false,
		Temperature = -30
	},
	Argon = {								// Possible use: Laser output Extender
		Toxic = false,
		Temperature = 0
	},
	Steam = {								// Burn water (duh)
		Toxic = false,
		Temperature = 100
	},
	Nitrogen = {						// Distilled from atmosphere
		Toxic = false,
		Temperature = 10
	},
	Carbon_dioxide = {					// Primary reason for heating atmospheres
		Toxic = false,
		Temperature = 60
	},
	Sulfur_Dioxide = { 					// SO2 = S + O2	(Burned)
		Toxic = true,					// Also: 2 H2S + 3 O2 = 2 H2O + 2 SO2 (Also burned)
		Temperature = 100				// Abundant in volcanic areas
	},
	Hydrogen_Sulfide = {				// H2S = (Fe + S) + 2 HCl = FeCl2 + H2S, Chlorines and iron byproduct ignored
		Toxic = true,					// Also: SO2 + 2 H2S = 3 S + 2 H2O
		Temperature = 20
	},
	Formaldehyde = {					// CH20 = 2 Methanol + 2 Oxygen = 2 Formaldehyde + 2 Water	(Burned)
		Toxic = true,
		Temperature = 2
	},
	Sulfuric_Acid_Gas = {				// Sulfuric acid with Oxygen. (Burned)
		Toxic = true, // very			// Makes a planet VERY inhabitable.
		Temperature = 200				// Only possible way to remove is to dilute with water.
	},
	Ammonia = {							// 4 NH3 + 5 O2 = 2 N2 + 6 H20 (Burned)	
		Toxic = false,
		Temperature = 0
	}
}

// Burning requires O2
// Condensation requires H2

Resources = {"Energy","RawOre","RawTiberium","LiquidTiberium","RawIce"}

Res_Ice = {
	"Raw_BlueIce",
	"Raw_ClearIce",
	"Raw_GlareCrust",
	"Raw_GlacialMass",
	"Raw_WhiteGlaze",
	"Raw_Gelidus",
	"Raw_Krystallos",
	"Raw_DarkGlitter",
	"Refined_BlueIce",
	"Refined_ClearIce",
	"Refined_GlareCrust",
	"Refined_GlacialMass",
	"Refined_WhiteGlaze",
	"Refined_Gelidus",
	"Refined_Krystallos",
	"Refined_DarkGlitter"
}

/*
	models/Punisher239/punisher239_reactor_small.mdl For refinery
	models/hunter/tubes/tubebend2x2x90.mdl For pipes

	ICE RESOURCES (in value order):
		- Dark Glitter
		- Krystallos
		- Gelidus
		- White Glaze
		- Glacial Mass
		- Glare Crust
		- Clear Ice
		- Blue Ice
*/

I_Gases = {
	"Oxygen",
	"Methane",
	"Hydrogen",
	"Argon",
	"Steam",
	"Nitrogen",
	"Carbon_dioxide",
	"Sulfur_Dioxide",
	"Hydrogen_Sulfide",
	"Formaldehyde",
	"Sulfuric_Acid_Gas",
	"Ammonia"
}

table.Add(Resources,Res_Ice)
table.Add(Resources,Solids)
table.Add(Resources,Liquids)
table.Add(Resources,I_Gases)