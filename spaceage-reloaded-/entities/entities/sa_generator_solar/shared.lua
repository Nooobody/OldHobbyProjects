DEFINE_BASECLASS("base_sa_object")

list.Add("sa_generator","Solar")
list.Add("sa_generator_solar",{
	"models/ce_ls3additional/solar_generator/solar_generator_small.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_medium.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_large.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_huge.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_giant.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_c_small.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_c_medium.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_c_large.mdl",
	"models/ce_ls3additional/solar_generator/solar_generator_c_huge.mdl"
	})
list.Add("sa_generator_solar",{"models/slyfo_2/miscequipmentsolar.mdl"})

ENT.ScreenName = "Solar Panel"
ENT.Model = "models/slyfo_2/miscequipmentsolar.mdl"