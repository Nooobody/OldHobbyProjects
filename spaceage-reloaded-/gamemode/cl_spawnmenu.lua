hook.Add("AddToolMenuTabs","SpaceAge",function()
	spawnmenu.AddToolTab("SA","Space Age","icon16/shield.png")

	spawnmenu.AddToolCategory("SA","LS","Life Support")
	spawnmenu.AddToolCategory("SA","RD","Resource Distribution")
	spawnmenu.AddToolCategory("SA","M","Mining")
end)

hook.Add("PopulateContent","SpaceAge",function()
	for I,P in pairs(g_SpawnMenu.CreateMenu.Items) do
		if P.Tab:GetText() == language.GetPhrase("spawnmenu.category.npcs") or
		   P.Tab:GetText() == language.GetPhrase("spawnmenu.category.saves") or
		   P.Tab:GetText() == language.GetPhrase("spawnmenu.category.dupes") then
		   g_SpawnMenu.CreateMenu:CloseTab(P.Tab,true)
		end
	end
end)

hook.Add("Initialize","SaveTab",function()
	for I,P in pairs(g_SpawnMenu.CreateMenu.Items) do
		if P.Tab:GetText() == language.GetPhrase("spawnmenu.category.saves") then
			g_SpawnMenu.CreateMenu:CloseTab(P.Tab,true)
		end
	end
end)