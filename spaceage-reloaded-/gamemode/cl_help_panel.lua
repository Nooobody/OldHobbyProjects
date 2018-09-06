if (!HELPDATA) then // Make sure we don't load the data twice if GMod loaded the data file first.
	include("cl_help_data.lua");
end

HELPPANEL = nil;

local SelectedEntityPanel = nil;

function ApplyInfo(item, DetailsModelBox, DetailsNameLabel, DetailsDescLabel, DetailsInfoLabel)
	if (item) then
		DetailsModelBox:SetModel(item.Model);

		local CamPos = item.ModelAngles:Forward() * item.ModelZoom;

		DetailsModelBox:SetCamPos(CamPos - item.ModelOffset);
		DetailsModelBox:SetLookAt(-item.ModelOffset);

		DetailsNameLabel:SetText(item.Name);
		DetailsDescLabel:SetText(item.Desc);
		DetailsInfoLabel:SetHTML(item.Info);
	end
end

function CreateHelpPanel()
	if HELPDATA and not IsValid(HELPPANEL) then
		local iconSize = ((ScrH() / 1080) * 164);
		local fontSizePerc = (ScrH() / 1080);

		surface.CreateFont("HelpItemTitle", {
			font = "Coolvetica",
			size = 48 * fontSizePerc,
			weight = 300,
			blursize = 0,
			scanlines = 0,
			antialias = true,
			underline = false,
			italic = false,
			strikeout = false,
			symbol = false,
			rotary = false,
			shadow = false,
			additive = false,
			outline = false,
		});
		surface.CreateFont("HelpItemDesc", {
			font = "Coolvetica",
			size = 32 * fontSizePerc,
			weight = 200,
			blursize = 0,
			scanlines = 0,
			antialias = true,
			underline = false,
			italic = false,
			strikeout = false,
			symbol = false,
			rotary = false,
			shadow = false,
			additive = false,
			outline = false,
		});

		local width = ScrW() / 1.25;
		local height = ScrH() / 1.25;

		HELPPANEL = vgui.Create("DFrame");
		HELPPANEL:SetSize(width, height);
		HELPPANEL:SetPos((ScrW() / 2) - (width / 2), (ScrH() / 2) - (height / 2));
		HELPPANEL:SetTitle("SpaceAge-Reloaded Player Manual");
		HELPPANEL:SetDraggable(true);
		HELPPANEL:ShowCloseButton(true);
		HELPPANEL:SetDeleteOnClose(false);
		HELPPANEL:MakePopup()

		local CatTabs = vgui.Create("DPropertySheet", HELPPANEL);
		CatTabs:SetPos(4, 28);
		CatTabs:SetSize(width - 8, height - 32);

		// Add the custom "What's New" tab
		local NewsTabFrame = vgui.Create("DPanel", CatTabs);
		NewsTabFrame:SetPos(0, 0);
		NewsTabFrame:SetSize(width, height - 32);
		CatTabs:AddSheet("What's New?", NewsTabFrame, "icon16/newspaper.png", false, false, "All the things happening in the world of SA.");

		// Generate the news category box.
		local NewsGroupList = vgui.Create("DCategoryList", NewsTabFrame);
		NewsGroupList:Dock(FILL);
		NewsGroupList:DockMargin(6, 6, 6, 6);

		// Generate news Items
		local First = true;
		for _, item in pairs(NEWSITEMS) do
			if (item.Title and item.Text) then
				local Title = item.Title;
				local Text = item.Text;
				local Link = item.URL;

				local group = NewsGroupList:Add(Title);
				
				group:SetExpanded(First);
				First = false;

				local NewsBodyHolder = vgui.Create("DPanel", group);
				NewsBodyHolder:SetPos(0, 19);
				NewsBodyHolder:SetSize(width - 42, 196);

				local NewsBodyHTML = vgui.Create("HTML", NewsBodyHolder);
				//NewsBodyHTML:SetPos(0, 0);
				NewsBodyHTML:Dock(FILL);
				NewsBodyHTML:SetHTML('<html><body bgcolor=#FFF><div style="font-size: 12px; font-family: Tahoma; text-align: left; padding: 4px;">'..Text..'</div></body></html>');
				NewsBodyHTML:SetSize(width - 42, 196 - 24);
			
				local NewsForumLink = vgui.Create("DButton", NewsBodyHolder);
				NewsForumLink:Dock(BOTTOM);
				NewsForumLink:DockMargin(8, 0, 0, 0);
				NewsForumLink:SetHeight(24);
				NewsForumLink:SetColor(Color(0, 0, 150, 255));
				//NewsForumLink:SetFont("TargetID"); //"Coolvetica"); //"Trebuchet24");
				NewsForumLink:SetText("Forum Post");
				//NewsForumLink.Paint = function() end;
				NewsForumLink:SetDrawBorder(false);
				NewsForumLink:SetDrawBackground(false);
				NewsForumLink.OnMousePressed = function()
					gui.OpenURL(Link);
				end
			end
		end

		// Generate the tabs on the to bar.
		for _, cat in pairs(HELPDATA) do
			local CatTabFrame = vgui.Create("DPanel", CatTabs);
			CatTabFrame:SetPos(0, 0);
			CatTabFrame:SetSize(width, height - 32);
			CatTabs:AddSheet(cat.Name, CatTabFrame, ((!cat.Icon or cat.Icon == "") and "gui/silkicons/user" or cat.Icon), false, false, cat.Name);

			// Generate the left sub-category box.
			local SubCatGroupList = vgui.Create("DCategoryList", CatTabFrame);
			SubCatGroupList:SetPos(0, 0);
			SubCatGroupList:SetSize(width / 6, height - 68);

			// Create the Right details panel components.
			local DetailsHolderPanel = vgui.Create("DPanel", CatTabFrame);
			DetailsHolderPanel:SetBackgroundColor(Color(200, 200, 200));
			DetailsHolderPanel:Dock(FILL);
			DetailsHolderPanel:DockMargin((width / 6), 0, 0, 0);

			local DetailsDescHolderPanel = vgui.Create("DPanel", DetailsHolderPanel);
			DetailsDescHolderPanel:SetPos(6, 2);
			DetailsDescHolderPanel:Dock(TOP);
			DetailsDescHolderPanel:DockMargin(4, 4, 4, 0);
			DetailsDescHolderPanel:SetHeight(iconSize);
			DetailsDescHolderPanel:SetBackgroundColor(Color(124, 190, 255));

			local DetailsModelBox = vgui.Create("DModelPanel", DetailsDescHolderPanel);
			DetailsModelBox:SetPos(1, 1);
			DetailsModelBox:SetSize(iconSize, iconSize);
			DetailsModelBox:SetModel("models/props_lab/binderredlabel.mdl"); // The SBEP Manual model is "models/spacebuild/sbepmanual.mdl" but it doesn't rotate on the correct axis.
			DetailsModelBox:SetCamPos((Angle(-25, 0, 0):Forward() * 18) + Vector(0, 0, 5));
			DetailsModelBox:SetLookAt(Vector(0, 0, 5));

			local descWidth = (((width * 5 / 6) - 26) - iconSize - 8);
			local DetailsNameLabel = vgui.Create("DLabel", DetailsDescHolderPanel);
			DetailsNameLabel:SetPos(iconSize + 4, 8);
			DetailsNameLabel:SetColor(Color(80, 80, 80));
			DetailsNameLabel:SetSize(descWidth, 48);
			DetailsNameLabel:SetFont("HelpItemTitle");
			DetailsNameLabel:SetAutoStretchVertical(true);
			DetailsNameLabel:SetText("SpaceAge-Reloaded Manual");

			local DetailsDescLabel = vgui.Create("DLabel", DetailsDescHolderPanel);
			DetailsDescLabel:SetPos(iconSize + 4, 54 * fontSizePerc);
			DetailsDescLabel:SetColor(Color(80, 80, 80));
			DetailsDescLabel:SetSize(descWidth, iconSize - 52);
			DetailsDescLabel:SetFont("HelpItemDesc");
			DetailsDescLabel:SetMultiline(true);
			DetailsDescLabel:SetWrap(true);
			DetailsDescLabel:SetAutoStretchVertical(true);
			DetailsDescLabel:SetText("This is the manual containing useful information and tutorials on various parts of SpaceAge-Reloaded.");

			local DetailsScrollBoxBG = vgui.Create("DPanel", DetailsHolderPanel);
			DetailsScrollBoxBG:SetPos(0, 0);
			DetailsScrollBoxBG:Dock(FILL);
			DetailsScrollBoxBG:DockMargin(4, 0, 4, 4);
			DetailsScrollBoxBG:SetBackgroundColor(Color(255, 255, 255));

			local DetailsInfoBox = vgui.Create("DHTML", DetailsScrollBoxBG);
			DetailsInfoBox:Dock(FILL);
			DetailsInfoBox:DockMargin(0, 0, 0, 0);
			DetailsInfoBox:SetHTML('<html><body bgcolor=#FFF><div style="font-size: 12px; font-family: Tahoma; text-align: left; padding: 16px;"><b>To continue, please click on an item to the left to view useful information about it.</b></div></body></html>');

			// Generate the items in the sub-category box.
			for _, subcat in pairs(cat.SubCategories) do
				local group = SubCatGroupList:Add(subcat.Name);

				local I = 0;
				local HeightOff = 19;
				for _, item in pairs(subcat.Entities) do
					local ItemPanel = vgui.Create("DPanel", group);
					ItemPanel:SetPos(-2, HeightOff);
					ItemPanel:SetSize((width / 6), 20);
					ItemPanel:SetBackgroundColor((I % 2 == 0) and Color(240, 240, 240) or Color(255, 255, 255));
					item.ItemPanel = ItemPanel;

					// When an item is clicked, load the info into the right details box.
					function ItemPanel:OnMousePressed()
						if (SelectedEntityPanel) then
							SelectedEntityPanel:SetBackgroundColor(Color(255, 255, 255));
						end
						SelectedEntityPanel = ItemPanel;
						ItemPanel:SetBackgroundColor(Color(255, 250, 205));

						ApplyInfo(item, DetailsModelBox, DetailsNameLabel, DetailsDescLabel, DetailsInfoBox); //DetailsInfoLabel);
					end

					local ItemPanelLabel = vgui.Create("DLabel", group);
					ItemPanelLabel:SetPos(4, HeightOff);
					ItemPanelLabel:SetSize((width / 6), 20);
					ItemPanelLabel:SetColor(Color(150, 150, 150));
					ItemPanelLabel:SetText(item.Name);

					I = I + 1;
					HeightOff = HeightOff + 20;
				end
			end
		end
	end
end

hook.Add("PlayerBindPress", "PlayerBindPressHelpMenu", function(ply, bind, pressed)
	if (string.find(bind, "gm_showspare2")) then
		if not IsValid(HELPPANEL) then
			SelectedEntityPanel = nil
			CreateHelpPanel();
		end

		if pressed and IsValid(HELPPANEL) then
			HELPPANEL:SetVisible(true);
		end
		return true; // This WILL break anything that is also bound to F4 and happens to get to this event last!
	end
end);