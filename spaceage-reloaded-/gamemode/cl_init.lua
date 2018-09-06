include("shared.lua")

include("cl_draw.lua")
include("cl_help_panel.lua")
include("custom_vgui/sa_button.lua")
include("custom_vgui/sa_checkbox.lua")

include("cl_team.lua")
include("cl_spawnmenu.lua")
include("cl_player.lua")
include("cl_chat.lua")
include("cl_hud.lua")
include("sh_player.lua")
include("sh_research.lua")
include("sh_pp.lua")
include("sh_cppi.lua")

function GM:InitPostEntity()
	local Ents = scripted_ents.GetList()
	for I,P in pairs(Ents) do
		if string.sub(I,1,3) == "sa_" and P.t.ScreenName then
			language.Add("SBoxLimit_"..I,"You've hit the limit for "..P.t.ScreenName.."s")
		end
	end
	language.Add("SBoxLimit_sa_mining","You've hit the limit for Mining devices")
	language.Add("SBoxLimit_sa_mining_storage","You've hit the limit for Mining storages")
	
	local function CheckRef()
		if not IsValid(LocalPlayer()) then timer.Simple(5,CheckRef) return end
		LocalPlayer().Oxy = 5
		LocalPlayer().Ice = 5
		LocalPlayer().Steam = 5
		LocalPlayer().NotDanger = true
		
		LocalPlayer().Pliers = {}
		for I,P in pairs(player.GetAll()) do
			if LocalPlayer() ~= P then
				LocalPlayer().Pliers[P:SteamID()] = table.Copy(DEFAULT_PP)
			end
		end
		if game.SinglePlayer() then return end
		
		/*
		local Ent = ents.CreateClientProp()
		Ent:SetModel("models/ce_miningmodels/miningstorage/storage_tiny.mdl")
		Ent:SetPos(Vector(0,0,0))
		Ent:Spawn()
		print("Test")
		print(Ent)
		print(Ent:GetModel())*/
		//if Ent:GetModel() == "" or Ent:GetModel() == "models/error.mdl" or not util.IsValidModel(Ent:GetModel()) then
		if not util.GetModelInfo("models/ce_miningmodels/miningstorage/storage_tiny.mdl")["KeyValues"] then 
			WelcomeBox()
		end
		//Ent:Remove()
	end
	timer.Simple(5,CheckRef)
	local AFKTimer = 0
	timer.Create("SA_AFKDetect",1,0,function()
		local IsStill = CheckPlayerActivity()
		if LocalPlayer():GetNWBool("AFK") then
			if not IsStill then
				AFKTimer = 0
				net.Start("SA_IsAFK")
					net.WriteBit(false)
				net.SendToServer()
			end
		else
			if IsStill then 
				AFKTimer = AFKTimer + 1
				if AFKTimer > 120 then
					net.Start("SA_IsAFK")
						net.WriteBit(true)
					net.SendToServer()
				end
			else
				AFKTimer = 0
			end
		end
	end)
end

function GM:Initialize()
	surface.CreateFont("Futuristic",{
		font = "Courier New",
		size = 28,
		weight = 500,
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
		outline = false
	})
	surface.CreateFont("Lucida",{
		font = "Lucida Console",
		size = 20,
		weight = 500,
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
		outline = false
	})
	surface.CreateFont("LucidaSmall",{
		font = "Lucida Console",
		size = 14,
		weight = 500,
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
		outline = false
	})
	surface.CreateFont("TeamMenuFont",{
		font = "Lucida Console",
		size = 32,
		weight = 800,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false
	})
	surface.CreateFont("TeamMenuFontSmall",{
		font = "Lucida Console",
		size = 16,
		weight = 800,
		blursize = 0,
		scanlines = 0,
		antialias = true,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = true,
		additive = false,
		outline = false
	})
	SA_NEWS = {}
	DefaultChatEnabled = true
	ShowTopBar = true
	CreateChat()
end

hook.Add("Think","Key_Detection",function()
	LocalPlayer().KeysDown = {}
	LocalPlayer().AFKKeys = {}
	for I=1,106 do
		if input.IsKeyDown(I) and not LocalPlayer().KeysDown[I] then
			LocalPlayer().KeysDown[I] = true
			table.insert(LocalPlayer().AFKKeys,I)
		elseif not input.IsKeyDown(I) and LocalPlayer().KeysDown[I] then
			LocalPlayer().KeysDown[I] = false
		end
	end
end)

net.Receive("PlayerSurv",function(len)
	LocalPlayer().Oxy = net.ReadUInt(8)
	LocalPlayer().Ice = net.ReadUInt(8)
	LocalPlayer().Steam = net.ReadUInt(8)
	LocalPlayer().Temperature = net.ReadInt(16)
	LocalPlayer().Pressure = math.Round(net.ReadFloat() * 100) / 100
	
	local NotDanger = net.ReadBit() == 1
	if not NotDanger and NotDanger ~= LocalPlayer().NotDanger then
		LocalPlayer():EmitSound("common/warning.wav")
	end
	LocalPlayer().NotDanger = NotDanger
end)

function GM:HUDPaint()
	self.BaseClass:HUDPaint()
	if LocalPlayer():GetNWBool("AFK") then
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,0,ScrW(),ScrH())
		return
	end
	DrawHP()
	DrawTopBar()
		
	local Tr = LocalPlayer():GetEyeTrace()
	if IsValid(Tr.Entity) then
		DrawTarget(Tr)
	end
	
	if not LocalPlayer().NotDanger then
		DrawAtmo()
	end
end

if not PARTICLE_EMITTER then PARTICLE_EMITTER = ParticleEmitter; end
function ParticleEmitter(_pos,_use3D)
	if not _GLOBAL_PARTICLE_EMITTER then 
		_GLOBAL_PARTICLE_EMITTER = {}
	end

	if _use3D then
		if not IsValid(_GLOBAL_PARTICLE_EMITTER.use3D) then
			_GLOBAL_PARTICLE_EMITTER.use3D = PARTICLE_EMITTER(_pos,true)
		else
			_GLOBAL_PARTICLE_EMITTER.use3D:SetPos(_pos)
		end

		return _GLOBAL_PARTICLE_EMITTER.use3D;
	else
		if not IsValid(_GLOBAL_PARTICLE_EMITTER.use2D) then
			_GLOBAL_PARTICLE_EMITTER.use2D = PARTICLE_EMITTER(_pos,false)
		else
			_GLOBAL_PARTICLE_EMITTER.use2D:SetPos(_pos)
		end

		return _GLOBAL_PARTICLE_EMITTER.use2D;
	end
end

hook.Add( "HUDShouldDraw", "SA_HideThings", function(name)
	if name == "CHudHealth" or name == "CHudBattery" then return false end
	if not DefaultChatEnabled and name =="CHudChat" then return false end
	return true
end)

hook.Add("ChatText","HideLeave",function(_,_,_,msg)
	if msg == "joinleave" then return true end
end)

hook.Add("PlayerBindPress","ContextMenu",function(ply,bind,pressed)
	if string.find(bind,"+menu_context") then LocalPlayer().ContextMenuOpen = true end
	if string.find(bind,"messagemode") and not string.find(bind,"messagemode2") and pressed then 
		if StartChat then StartChat() end 
		if not DefaultChatEnabled then return true end
	end
	if string.find(bind,"messagemode2") and pressed then 
		if StartTeamChat then StartTeamChat() end
		if not DefaultChatEnabled then return true end
	end
end)