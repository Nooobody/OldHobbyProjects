
SA_Limits = {}
SA_Limits.sa_atmosphere_probe = 2
SA_Limits.sa_atmosphere_stabilizer = 2
SA_Limits.sa_compressor_heavy_water = 2
SA_Limits.sa_compressor_steam = 2
SA_Limits.sa_dispenser_freezer = 2
SA_Limits.sa_dispenser_heater = 2
SA_Limits.sa_dispenser_suit = 3
SA_Limits.sa_exchanger_ice = 3
SA_Limits.sa_exchanger_steam = 3
SA_Limits.sa_exchanger_oxygen = 3
SA_Limits.sa_exhaler_argon = 2
SA_Limits.sa_exhaler_carbon_dioxide = 2
SA_Limits.sa_exhaler_hydrogen = 2
SA_Limits.sa_exhaler_methane = 2
SA_Limits.sa_exhaler_nitrogen = 2
SA_Limits.sa_exhaler_oxygen = 2
SA_Limits.sa_generator_energy = 5
SA_Limits.sa_generator_fusion = 5
SA_Limits.sa_generator_gas = 5
SA_Limits.sa_generator_hydro = 5
SA_Limits.sa_generator_ice = 2
SA_Limits.sa_generator_solar = 5
SA_Limits.sa_generator_steam = 2
SA_Limits.sa_generator_water = 2
SA_Limits.sa_generator_water_splitter = 2
SA_Limits.sa_inhaler_argon = 2
SA_Limits.sa_inhaler_carbon_dioxide = 2
SA_Limits.sa_inhaler_hydrogen = 2
SA_Limits.sa_inhaler_methane = 2
SA_Limits.sa_inhaler_nitrogen = 2
SA_Limits.sa_inhaler_oxygen = 2
SA_Limits.sa_gravity_regulator = 2
SA_Limits.sa_link_node = 5
SA_Limits.sa_mining = 1
SA_Limits.sa_mining_laser = 1
SA_Limits.sa_mining_icelaser = 1
SA_Limits.sa_mining_drill = 1
SA_Limits.sa_mining_refinery = 1
SA_Limits.sa_mining_storage = 4
SA_Limits.sa_mining_rawore_storage = 4
SA_Limits.sa_mining_rawtib_storage = 4
SA_Limits.sa_mining_rawice_storage = 4
SA_Limits.sa_mining_refinedice_storage = 4
SA_Limits.sa_mining_liquidtib_storage = 1
SA_Limits.sa_mining_scanner = 2
SA_Limits.sa_tiberium_storage_holder = 2
SA_Limits.sa_plant = 10
SA_Limits.sa_plug = 10
SA_Limits.sa_port = 5
SA_Limits.sa_storage_cache = 5
SA_Limits.sa_storage_argon = 5
SA_Limits.sa_storage_carbon_dioxide = 5
SA_Limits.sa_storage_energy = 10
SA_Limits.sa_storage_heavy_water = 5
SA_Limits.sa_storage_hydrogen = 5
SA_Limits.sa_storage_ice = 5
SA_Limits.sa_storage_methane = 5
SA_Limits.sa_storage_nitrogen = 5
SA_Limits.sa_storage_oxygen = 5
SA_Limits.sa_storage_steam = 5
SA_Limits.sa_storage_sulfur = 5
SA_Limits.sa_storage_water = 5

local New = {}
for I,P in pairs(SA_Limits) do
	if I == "sa_tiberium_storage_holder" then
		duplicator.RegisterEntityClass(I,WireLib.MakeWireEnt,"Data","Links","Storages")
	else duplicator.RegisterEntityClass(I,WireLib.MakeWireEnt,"Data","Links","SizeNumber") end
	New[I:sub(6).."s"] = P
end
table.Merge(SA_Limits,New)
