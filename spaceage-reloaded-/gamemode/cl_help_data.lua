if (!CLIENT) then return; end

HELPDATA = {};
NEWSITEMS = {};

// Information about usable silkicons can be found at: http://wiki.garrysmod.com/page/silkicons
local function AddCategory(name, icon)
	if (!icon or icon == "") then
		icon = "gui/silkicons/user";
	end

	local tbl = {Name = name, Icon = icon, SubCategories = {}};
	table.insert(HELPDATA, tbl);

	return tbl;
end

local function AddSubCategory(category, name)
	if (category) then
		if (!icon or icon == "") then
			icon = "gui/silkicons/user";
		end

		local tbl = {Name = name, Icon = icon, Entities = {}};
		table.insert(category.SubCategories, tbl);

		return tbl;
	end
	return nil;
end

local function AddItem(subcat, name, model, modeloffset, modelang, zoom, desc, info)
	if (subcat) then
		info = '<html><body bgcolor=#FFF><div style="font-size: 12px; font-family: Tahoma; text-align: left; padding: 16px;">'..info;
		info = string.Replace(info, "\n", "<br />")..'</div></body></html>';

		local tbl = {Name = name, Model = model, ModelOffset = modeloffset, ModelAngles = modelang, ModelZoom = zoom, Desc = desc, Info = info};
		table.insert(subcat.Entities, tbl);

		return tbl;
	end
	return nil;
end

/*
local WhatsNewCat = AddCategory("What's new?", "");
local MiningNewsCat = AddSubCategory(WhatsNewCat, "Mining");
AddItem(MiningNewsCat, "Ice Mining!", "models/beer/wiremod/gate_e2.mdl", Vector(0, 0, 1), Angle(-45, 45, 0), 9, 
	    "Something about Ice...",
	    "Some basic tutorial info...\n...more info\n...\n...\n...\n...\n...\n...\n...\n...");
*/

local WireCat = AddCategory("Transportation", "icon16/car.png");
/*local E2WireCat = AddSubCategory(WireCat, "E2");
AddItem(E2WireCat, "Basic Programming", "models/beer/wiremod/gate_e2.mdl", Vector(0, 0, 1), Angle(-45, 45, 0), 9, 
	    "E2s are very powerful, and they can be used for a variety of contraptions to control just about everything; However, they can be difficulty to start learning if you don't have prior programming experience!",
	    "Some basic tutorial info...\n...more info\n...\n...\n...\n...\n...\n...\n...\n...");
AddItem(E2WireCat, "Prop Core", "models/beer/wiremod/gate_e2.mdl", Vector(0, 0, 1), Angle(-45, 45, 0), 9, 
	    "Prop core allows for a lot more control of entities. It allows your E2s to, just to name a few, set an entity's position and angles, constraint entities, and spawn props. However, you better be willing to pay the substantial price tag!",
	    "Some basic tutorial info...\n...more info\n...\n...\n...\n...\n...\n...\n...\n...");
*/
local SBEPWireCat = AddSubCategory(WireCat, "SBEP");
AddItem(SBEPWireCat, "Gyropod", "models/spacebuild/nova/drone2.mdl", Vector(0, 0, -16), Angle(-45, 45, 0), 60, 
	    "Gyropods are great for ship propulsion. They are easy to set up, and very easy to control from a chair.",
	    "Depending on whether you want to use a pre-built ship (only 1 prop) or make one yourself, you might want to change the gyropod's model.\n\nThis can be done by pressing R on a prop with the gyropod tool.\n\nHow to setup:\n\nYou have to use Wire to set this up. If you want to control it from a chair, use a pod controller. Link the pod controller to the seat by right-clicking on the controller and then on the seat.\n\nThen you can wire stuff from the gyropod to the controller. The ones recommended are:\n - Forward (To W)\n - Backward (To S)\n - Enable (Constant value)\n - Level (Something like R, levels the ship)\n\nIf you want mouse-control, you have to link the gyropod to the seat. To do this, you right-click the gyropod, and then right-click the seat with the gyropod tool.\n\nIf you don't want mouse-control, you can wire YawLeft and YawRight to A and D. Otherwise you can wire MoveLeft and MoveRight to A and D, if you want.");
local Wire = AddSubCategory(WireCat,"Wire")
AddItem(Wire,"Hoverdrive","models/props_c17/utilityconducter001.mdl",Vector(0,0,-15),Angle(-20,0,0),40,
		"When going by the laws of physics seems too slow.",
		"Hoverdrives are mainly used for long-range teleportation. For an example, interplanetary travel could be much easier with hoverdrives, compared to normal spaceships.\n\nSetting up a hoverdrive requires some knowledge of wire, details of which I won't go through here.\n\nBasic usage is easy though. You spawn the hoverdrive, wire the Target Position to coordinates, for an example, from a GPS. Then you wire the Jump to something, like a button. Then whenever you press the button, the hoverdrive goes to the target position.\n\nUsing the hoverdrive spends some energy though, so make sure you have enough for the trip!")

local RD = AddCategory("Resource System", "icon16/cog.png")
local RD_Basics = AddSubCategory(RD,"How-To")
AddItem(RD_Basics,"Generators","models/lifesupport/generators/waterairextractor.mdl",Vector(0,0,-20),Angle(-20,0,0),60,
		"To output something, you need a generator.",
		"Generators are the common way to generate resources.\n\nMost generators require energy to work, excluding energy generators of course. Some generators may even have multiple requirements for it to work, or multiple outputs.\n\nA generator should work if its requirements are met, and it's linked to a storage that has the resource the generator is outputting.\n\nWhen you think it should work, just press E on the generator and see what happens.")
AddItem(RD_Basics,"Storages","models/ce_ls3additional/energy_cells/energy_cell_large.mdl",Vector(0,0,0),Angle(-45,0,0),90,
		"Generators generate resources, right? So where is it stored? In storages of course! Duh...",
		"Storages are used everytime there's something to be stored.\n\nThere are no requirements to use a storage, just link them and you're good.")
AddItem(RD_Basics,"Link Node","models/snakesvx/resource_node_medium.mdl",Vector(0,0,0),Angle(-45,0,0),60,
		"When you have anything at all, you need link nodes.",
		"Whether you're pumping water, generating energy, or just storing resources, you need a link node. Everything in your setup has to be linked to a link node, as it connects all the stuff, and even to other nodes if necessary.")
AddItem(RD_Basics,"Link Tool","",Vector(0,0,0),Angle(0,0,0),0,
		"This is what you'll use most of the time.\nYou need it for everything with resources.",
		"To get stuff linked, you'll need to use this tool.\n\nHow to:\nYou left-click on all the stuff you want to link (can include nodes too), then right-click on the link node you have. And you're done, everything should be linked now.")
AddItem(RD_Basics,"Multiplier","",Vector(0,0,0),Angle(0,0,0),0,
		"You can't make one generator work like 5 generators...or can you?",
		"Yes, you can. Every non-Energy generator has a wire input called 'Multiplier'. If you wire a value, like 10, to this, the generator will work like there'd be 10 of them.\n\n\nHow to do this:\n\nYou whip out the Constant Value (Wire --> Wire I/O) then put a value of 10 into it. Then spawn it and wire the multiplier from the generator of your choice, into the constant value. If you want to change the multiplier afterwards, just change the constant value. You can wire all multipliers to the same constant value if you want.")
		
local Energy = AddSubCategory(RD,"Energy Generators")
AddItem(Energy,"Solar","models/slyfo_2/miscequipmentsolar.mdl",Vector(0,0,-48),Angle(-25,45,0),170,
		"Solar power is the most basic when it comes to easy-to-access energy.",
		"Solar panels are the easiest energy setup, just spawn them, point them at the moving sun, and you're done.\n\nAs the sun is moving, you probably need to apply some fancy wire stuff to it to maintain maximum coverage. You don't have to, though.")
AddItem(Energy,"Hydro","models/chipstiks_ls3_models/largeh2opump/largeh2opump.mdl",Vector(0,0,-32),Angle(-25,45,0),180,
		"If you're close to a water source, hydro power is an easy way to generate energy for your needs.",
		"Hydro turbines work by being in water. Simple as that.\n\nJust spawn them underwater, or put them underwater, and you're done.")
AddItem(Energy,"Fusion","",Vector(0,0,0),Angle(0,0,0),60,
		"When you're prepared for the consequences.",
		"Fusion is the best power source, but most challenging to maintain.\n\nFusions, when they are running, generate heat. When it reaches a certain point, it will start generating energy spikes throughout the network, and when it has had enough, it explodes.\n\nTo combat this, you need water and/or heavy water. Water is used to slow down the heating process, and Heavy Water cools down the generator completely. Heavy Water can be attained from a Water Compressor.")

local Water = AddSubCategory(RD,"Water-related")
AddItem(Water,"Pump","",Vector(0,0,0),Angle(0,0,0),60,
		"The main source for water.",
		"Whenever you find yourself in need of water, you need water pumps.\n\nThese work just like the hydro turbines, except these need energy to work.\n\nJust put these into water and they'll do the job. Simple as that.\n\nInputs:\n - Energy\n\nOutputs:\n - Water")
AddItem(Water,"Heater&Freezer","",Vector(0,0,0),Angle(0,0,0),60,
		"When a neutral temperature is not enough.",
		"Oftentimes you need to change the Water's state. This can be done by either heating up or freezing the water.\n\nThese generators either make the Water into Steam or Ice. You need Energy and Water for this process.\n\nInputs:\n - Energy\n - Water\n\nOutputs:\n - Steam/Ice")
AddItem(Water,"Splitter","",Vector(0,0,0),Angle(0,0,0),60,
		"Haven't we done enough of splitting, with atoms?",
		"Splitting the water molecyles (H2O) into Oxygen (O2) and Hydrogen (H) is a tricky process. Luckily we got this generator to do the hard jobs for us. Just plug it in and let it do its job.\n\nInputs:\n - Energy\n - Water\n\nOutputs:\n - Oxygen\n - Hydrogen")
AddItem(Water,"Compressor","",Vector(0,0,0),Angle(0,0,0),60,
		"No light water was found on the list, and they wanted to be different.",
		"Whenever you use a fusion generator, you might find yourself in need of some Heavy Water, you need to compress the water. For this, you need some Hydrogen with the water.\n\nInputs:\n - Energy\n - Water\n - Hydrogen\n\nOutputs:\n - Heavy Water")

local LS = AddCategory("Life Support","icon16/heart.png")
local StillAlive = AddSubCategory(LS,"Staying Alive")
AddItem(StillAlive,"Atmosphere","",Vector(0,0,0),Angle(0,0,0),0,
		"The basis of survival is breathable air and a good temperature.",
		"On Earth, there's plenty of Oxygen to come by. There's also a stable amount of pressure, and a little bit of a temperature aswell. These are the characteristics you'll need for survival.\n\nFor another atmosphere to be habitable, it has to be terraformed beforehand. Things like pressure, oxygen levels and temperature has to be kept in check in order to stay alive on the planet without external input.")
AddItem(StillAlive,"Exchangers","",Vector(0,0,0),Angle(0,0,0),60,
		"The easy way to stay alive in a multitude of environments.",
		"Exchangers create a sphere around themselves, they then emit a resource into the sphere.\n\nAtleast 2 of the exchangers, air and heat, are required for space travel. Heat is for cold environments, like space, and Cold is needed for hot environments, like the lava planet.")
AddItem(StillAlive,"Gravity Regulator","",Vector(0,0,0),Angle(0,0,0),60,
		"When gravity is amiss",
		"If you want to Noclip in space, or just plain walk on surfaces, you need a Gravity Regulator.\n\nIt works by emitting a sphere of gravity, and all players inside are affected by it.\n\nBeware of the energy costs!")
AddItem(StillAlive,"Climate Regulators - Coming soon!","",Vector(0,0,0),Angle(0,0,0),60,
		"",
		"")
		 
local Suit = AddSubCategory(LS,"Suit")
AddItem(Suit,"Operation","",Vector(0,0,0),Angle(0,0,0),60,
		"Your suit is a magnificent thing, you know.",
		"A suit is the basis for the preservation of a human body in a hostile environment.\n\nIt requires Air, Heat and Coolant to operate correctly. For these, it uses Oxygen, Steam and Ice.\n\nThere are several ways of manipulating the resources in your suit, which will be explained in the following sections.\n\nKeep in mind that there can only be 200 of Steam and Ice combined, so you can't have 200 of both, only 100. When you are in a hostile environment, either steam or ice is drained for coolant, and its then transformed into the other resource.")
AddItem(Suit,"Dispenser","",Vector(0,0,0),Angle(0,0,0),60,
		"Running out of stuff? Here, have a refill.",
		"Suit dispenser is the one needed for filling up your suit. It gives all resources that it has linked to it to your suit on a steady speed. Just hold down E and you'll be fine.\n\nIt won't allow you to go over the limits, however. You can only have 200 coolant in total. So that means, if you have 0 ice and 200 steam, you can't get anymore of either one. You have to transform the steam into ice to get them balanced, if you want that.")
AddItem(Suit,"Manipulators","",Vector(0,0,0),Angle(0,0,0),60,
		"'It's a huge ****ing thing.' - Everyone, everywhere",
		"Suit manipulators are used to transform one coolant to the other. Just spawn it, link it, feed it some resources and just hop on it.\n\nCome on now, it won't bite.\n\nThere we go, now, you can see that the freezer transforms your 200 ice into 200 steam in no time.")
		
		
local Terraform = AddCategory("Terraforming","icon16/world.png")
local Needed = AddSubCategory(Terraform,"Basics")
AddItem(Needed,"Atmosphere levels","",Vector(0,0,0),Angle(0,0,0),0,"For an atmosphere to be suitable, it's recommended to have only nitrogen and oxygen.","Nitrogen provides the basis for an atmosphere. It fills the atmosphere so any other gases won't affect that much.\n\nOxygen makes breathing happen, with nominal levels, though. It's recommended to have around 15-25% of oxygen in the atmosphere.\n\nKeep in mind, that if there's a toxic gas in the atmosphere, it will make breathing highly unlikely, but if none of the gases are toxic, it doesn't matter how much of them there is, as long as there's enough Oxygen.")
AddItem(Needed,"Temperature","",Vector(0,0,0),Angle(0,0,0),0,"The human body can only handle certain temperatures.","Nominal temperature levels for a human body can be considered to be between -30 and 30 celsius.")
AddItem(Needed,"Pressure","",Vector(0,0,0),Angle(0,0,0),0,"An atmosphere without pressure is like space. Pressure is what keeps the stuff inside.","Pressurization of a planet requires special equipment. An atmosphere stabilizer is used for that. It only requires energy and Nitrogen. This is also the way you have to put the Nitrogen in to the atmosphere.")

local InhaleExhale = AddSubCategory(Terraform,"Compressing and Ventilating")
AddItem(InhaleExhale,"Compressors","",Vector(0,0,0),Angle(0,0,0),60,
		"For any sucking purposes",
		"If you find an atmosphere abundant with a certain gas, you might be able to use a compressor to suck it out. Works by being in the atmosphere, and by being on. Just attach the needed storage and some energy and you're good.\n\nInputs:\n - Energy\n\nOutputs:\n - The resource it compresses.")
AddItem(InhaleExhale,"Ventilators","",Vector(0,0,0),Angle(0,0,0),60,
		"When you find yourself in need of some ventilation.",
		"Ventilators are the opposite from Compressors. They 'exhale' the resource into the atmosphere. Can be used to fill up an atmosphere with a certain resource.\n\nInputs:\n - Energy\n - The resource it ventilates")
		

local Science = AddSubCategory(Terraform,"Chemistry - Coming soon")
/*
local LSCat = AddCategory("Life Support", "icon16/world.png");
local GeneralLSCat = AddSubCategory(LSCat, "General");
AddItem(GeneralLSCat, "The Humble Multiplier", "models/chipstiks_ls3_models/largeh2opump/largeh2opump.mdl", Vector(0, 0, -32), Angle(-25, 45, 0), 180, 
	    "You don't need 5 of each generator to keep up with your resource hungry machines! Just make one generator work harder!",
	    "Wire multiplier to a value 1-10...\n...Only works on certain machines\n...etc\n...\n...\n...\n...\n...\n...\n...");

local PowerLSCat = AddSubCategory(LSCat, "Power");
AddItem(PowerLSCat, "Fusion", "models/ce_ls3additional/fusion_generator/fusion_generator_large.mdl", Vector(0, 0, -32), Angle(-35, 45, 0), 250, 
	    "Fusion is the way of the future. It supplies a large amount of power, and it is perfect for any power hungry contraptions. It can be a bit difficult to setup and maintain, however.",
	    "Some basic tutorial info...\n...more info\n...\n...\n...\n...\n...\n...\n...\n...");
AddItem(PowerLSCat, "Solar", "models/slyfo_2/miscequipmentsolar.mdl", Vector(0, 0, -48), Angle(-25, 45, 0), 170, 
	    "Solar panels are much easier to maintain, and in many cases, you can set them up and forget about them. However, solar panels output power based on how directly they are aimed at the moving sun, so they may need an E2 controller to aim them.",
	    "Some basic tutorial info...\n...more info\n...\n...\n...\n...\n...\n...\n...\n...");

local VitalsLSCat = AddSubCategory(LSCat, "Vitals");
AddItem(VitalsLSCat, "Extracting Gases from the Atmosphere", "models/ce_ls3additional/canisters/canister_medium.mdl", Vector(0, 0, -42), Angle(-25, 45, 0), 90, 
	    "Gas is everywhere, why not tap into one of the most abundant supplies of life supporting compounds: The Earth!", 
	    "Gases can be generated from compressors...\n...can drain the atmosphere(?)\n...etc\n...\n...\n...\n...\n...\n...\n...");
AddItem(VitalsLSCat, "Splitting Water", "models/props_c17/substation_transformer01a.mdl", Vector(0, 0, 32), Angle(-25, 45, 0), 280, 
	    "Running out of O2? What happens when you are in space and you have tons of water? You make Oxygen and Hydrogen by splitting water!", 
	    "Uses the water splitter...\n...costs energy\n...produces 2 hydrogen for every unit of oxygen\n...\n...\n...\n...\n...\n...\n..."); 
*/
function AddNews(title, text, link)
	local item = {Title = title, Text = text, URL = link};
	table.insert(NEWSITEMS, item);
end

// Some XML trickery to load the news from the forums:
local function GetLink(PostXML)
	// The link tags we want happen to be after many other unrelated link tags, so we need to get rid of any other blocks that may trip up the search.
	local Start = string.find(PostXML, "<poster>", nil, true); // Get the string index after the end of the opening poster tag.
	local End = string.find(PostXML, "</poster>", Start, true) + 9; // Get the string index one before the ending poster tag.
	local RemoveStr = string.sub(PostXML, Start, End);
	PostXML = string.Replace(PostXML, RemoveStr, "");

	Start = string.find(PostXML, "<board>", nil, true); // Get the string index after the end of the opening board tag.
	End = string.find(PostXML, "</board>", Start, true) + 8; // Get the string index one before the ending board tag.
	RemoveStr = string.sub(PostXML, Start, End);
	PostXML = string.Replace(PostXML, RemoveStr, "");

	// Now take the new slimmed XML and find the correct link.
	local LinkContentStart = string.find(PostXML, "<link>", nil, true) + 6; // Get the string index after the end of the opening link tag.
	local LinkContentEnd = string.find(PostXML, "</link>", LinkContentStart, true) - 1; // Get the string index one before the ending link tag.

	local LinkContent = string.sub(PostXML, LinkContentStart, LinkContentEnd);
	LinkContent = string.Trim(LinkContent); // Make sure we get any random whitespace we may have missed.

	return LinkContent;
end
local function GetSubject(PostXML)
	local SubjectContentStart = string.find(PostXML, "<subject>", nil, true) + 9; // Get the string index after the end of the opening subject tag.
	local SubjectContentEnd = string.find(PostXML, "</subject>", SubjectContentStart, true) - 1; // Get the string index one before the ending subject tag.

	local SubjectContent = string.sub(PostXML, SubjectContentStart, SubjectContentEnd);
	SubjectContent = string.Replace(SubjectContent, "<![CDATA[", ""); // Remove an extra data tag that isn't needed.
	SubjectContent = string.Replace(SubjectContent, "]]>", ""); // Remove the ending to the previous data tag.
	SubjectContent = string.Trim(SubjectContent); // Make sure we get any random whitespace we may have missed.
	
	return SubjectContent;
end
local function GetBody(PostXML)
	local BodyContentStart = string.find(PostXML, "<body>", 0, true) + 6; // Get the string index after the end of the opening body tag.
	local BodyContentEnd = string.find(PostXML, "</body>", BodyContentStart, true) - 1; // Get the string index one before the ending body tag.

	local BodyContent = string.sub(PostXML, BodyContentStart, BodyContentEnd);
	BodyContent = string.Replace(BodyContent, "<![CDATA[", ""); // Remove an extra data tag that isn't needed.
	BodyContent = string.Replace(BodyContent, "]]>", ""); // Remove the ending to the previous data tag.
	BodyContent = string.Trim(BodyContent); // Make sure we get any random whitespace we may have missed.
	
	return BodyContent;
end

local function ProcessPosts(XML)
	local StartIndex = 1;

	local FoundPost = false;

	_,StartIndex = string.find(XML, "<article>", StartIndex, true);
	while (StartIndex) do
		local EndIndex,_ = string.find(XML, "</article>", StartIndex + 1, true);
		if (!EndIndex) then
			ErrorNoHalt("Malformed article XML! Check that the URL in cl_help_data is valid!");
			return;
		end

		local ArticleBody = string.sub(XML, StartIndex + 1, EndIndex - 1);
		AddNews(GetSubject(ArticleBody), GetBody(ArticleBody), GetLink(ArticleBody));
		_,StartIndex = string.find(XML, "<article>", StartIndex, true);
	end
end

local NewsURL = "http://www.sareloaded.com/index.php?action=.xml;sa=news;boards=2.0,6.0;limit=10";
function LoadNews()
	print("Loading news...");
	http.Fetch(NewsURL,
		function(body, len, headers, code)
			print("Processing news...");
			ProcessPosts(body);
			print("Done!");
		end,
		function(error)
			ErrorNoHalt("We had an error loading the news: "..error);
		end
	);
end

timer.Simple(5, LoadNews);
//LoadNews();