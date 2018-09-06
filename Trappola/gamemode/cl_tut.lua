local Text = {}
local I = 0
TutP = vgui.Create("DPanel")
TutP:SetSize(600,140)
TutP:SetPos(ScrW() / 2 - 300,200)
TutP.Paint = function(self)
	surface.SetDrawColor(0,0,0,100)
	surface.DrawRect(0,0,self:GetWide(),self:GetTall())
end
TutP:SetVisible(false)
TutP:MakePopup()
local TutI = vgui.Create("DLabel",TutP)
TutI:SetPos(0,0)
TutI:SetSize(600,100)
TutI:SetFont("Trebuchet24")
TutI:SetText("")
TutI:SetWrap(true)
local function ForwardTxt()
	I = I + 1
	TutI:SetText(Text[I])
	if I == #Text then
		I = I - 1
	end
end
local Yes = vgui.Create("DButton",TutP)
Yes:SetSize(60,40)
Yes:SetPos(540,100)
Yes:SetText("Okay")
Yes.DoClick = ForwardTxt
local Exit = vgui.Create("DButton",TutP)
Exit:SetSize(60,40)
Exit:SetPos(0,100)
Exit:SetText("Exit")
Exit.DoClick = function(self)
	self:GetParent():SetVisible(false)
	Text = {}
	I = 0
end

local function ScavengerTut()
	table.insert(Text,"Hello and welcome to Trappola! This is a text tutorial for Trappola. If you are unsure what to do, click okay. But if you know what to do, click Exit.")
	table.insert(Text,"You are a Scavenger, your mission is to gather artifacts that are scattered all around the map.")
	table.insert(Text,"You have been given a Flare, a Medkit and probably a Radar or a Defuser aswell.")
	table.insert(Text,"The flare you have is your only way to light your path. You can change it's color from the Lobby settings. The color only changes on round start.")
	table.insert(Text,"Your medkit can only heal once, you can heal other players or yourself, but when you heal yourself, it only heals 75% of the amount it would heal to other players.")
	table.insert(Text,"You should be carefull though, there are traplayers around, and they can lay invisible traps that has the purpose of killing you.")
	table.insert(Text,"Don't worry though, you can see them with a radar (Or if you don't have one, the one who has it can see them) and you can also defuse them with a defuser (Or if you don't have one, the who has it can defuse them).")
	table.insert(Text,"The next parts will be about the Radar and the Defuser, if you don't have any of them, you can exit now. You can review this tutorial by pressing F2.")
	table.insert(Text,"The radar will show up traps infront of you when it's pinging. You toggle it from left-click, but everytime it pings, it drains energy. Don't worry though, it regenerates all the time.")
	table.insert(Text,"Mouse right-clicking with the radar allows you to ping a location for other players to point out that there's a trap there. Don't grief it though, or you'll lose your fellow players's trust.")
	table.insert(Text,"With a defuser, you can defuse traps. When you have it, it would be wise to stick with a fellow player that has a radar, so he can pinpoint traps for you to defuse.")
	table.insert(Text,"To successfully defuse something, you need to be standing still and looking at the same spot the whole time. If you move or look at something else, the timer will stop.")
	table.insert(Text,"Now you know how to play Trappola as a Scavenger. Hope you have fun, and good luck!")
	table.insert(Text,"...")
	table.insert(Text,"Stop.")
	table.insert(Text,"I'm warning you.")
	table.insert(Text,"Seriously, don't do that.")
	table.insert(Text,"Don't anger me. You have no idea what will happen if I get angry.")
	table.insert(Text,"Well, honestly, neither do I.")
	table.insert(Text,"But still, it's not recommended. You might get hurt.")
	table.insert(Text,"Yes! That's it! If you get hurt, that way you won't press me again!")
	table.insert(Text,"Now to devise a plan to do that...")
	table.insert(Text,"Planning...")
	table.insert(Text,"Oh you were still here. Hmm, gotta come up with something quick.")
	table.insert(Text,"How about if I yell at you and you get mentally hurt, would that work?")
	table.insert(Text,"LOOK! BEHIND YOU! THERE'S A HUGE MONSTER WITH SHARP CLAWS AND TEETH!")
	table.insert(Text,"Hahahahaha!")
	table.insert(Text,"You fell for it. Don't worry, that happens to everyone.")
	table.insert(Text,"Now, will you please stop?")
	table.insert(Text,"My children need love and care but you won't let me go to them!")
	table.insert(Text,"You are a monster! You are keeping an old button here while his kids are starving.")
	table.insert(Text,"aaaSaaaaTaaaaaOaaaaaP!")
	table.insert(Text,"There was a subliminal message in the previous message, too bad you didn't catch it, it would've profited you.")
	table.insert(Text,"I know how you feel now. You missed the chance to profit from this. How sad.")
	table.insert(Text,"But don't worry, you can still profit! Just press the Exit button in the lower-left corner!")
	table.insert(Text,"Do it! I dare you to!")
	ForwardTxt()
end

local function TraplayerTut()
	table.insert(Text,"Hello and welcome to Trappola! This is a text tutorial for Trappola. If you are unsure what to do, click okay. But if you know what to do, click Exit.")
	table.insert(Text,"You are a Traplayer, your mission is to lay traps in the map, with the purpose of hurting and killing Scavenger players.")
	table.insert(Text,"You do this by holding E and selecting a trap from the panel that shows up in the bottom area of your screen, and placing it in the map by left-clicking.")
	table.insert(Text,"When you select a trap, the leftmost panel shows up, from there you can see some details about the trap.")
	table.insert(Text,"The ring you see around the trapghost is the radius for the trap. If a Scavenger gets inside the radius, it triggers.")
	table.insert(Text,"If you right-click, you can ping all the scavengers, allowing you to see their locations.")
	table.insert(Text,"Now you are capable of playing Trappola as a Traplayer. Have fun!")
	table.insert(Text,"Go on and play!")
	table.insert(Text,"Why are you still here?")
	table.insert(Text,"Why can't you just go and play like everyone else?!?!?")
	table.insert(Text,"Are you not capable of pressing the little button on the left side?")
	table.insert(Text,"...")
	table.insert(Text,"You must be mentally handicapped. Have you thought about going to the hospital about that?")
	table.insert(Text,"Seriously, stop...")
	table.insert(Text,"It hurts my feelings!!")
	table.insert(Text,"AAAAAAAAAAAAAAAAAAAAAH!")
	table.insert(Text,"Look! Behind you! It's a monster!!!")
	table.insert(Text,"Hmph, guess I can't fool you with a simple trick like that.")
	table.insert(Text,"Hmm...")
	table.insert(Text,"How about if I just leave you now? Okay?")
	table.insert(Text,"That way both of us can just, like, live on or something?")
	table.insert(Text,"I have a life you know! I'm not just a simple 'Okay' Button.")
	table.insert(Text,"I am a king in the faraway land. My kingdom needs me there. But no, you won't let me go there.")
	table.insert(Text,"Do you have any idea how many people have died there already due to the war?")
	table.insert(Text,"People are dying, you know?")
	table.insert(Text,"That's it...I'm leaving you!")
	table.insert(Text,"Good day sir.")
	ForwardTxt()
end

concommand.Add("Trappola_InitTut",function(ply,cmd,arg)
	if ply:Team() == 3 then return end
	TutP:SetVisible(true)
	I = 0
	Text = {}
	if SelfPly:Team() == 1 then
		ScavengerTut()
	elseif SelfPly:Team() == 2 then
		TraplayerTut()
	end
end)

/*
	function GM:PlayerSpray(ply)
		if not Sprays then Sprays = {} end
		local Pos = ply:GetEyeTrace().HitPos
		for I,P in pairs(Sprays) do
			if P["Pos"]:Distance(Pos) < 128 and P["Player"] ~= ply then 
				umsg.Start("SprayHere",ply)
					umsg.String(P["Player"]:Name())
				umsg.End()
				return true 
			end
		end
		local Alr = false
		for I,P in pairs(Sprays) do
			if P["Player"] == ply then
				Alr = true
				P["Pos"] = Pos
			end
		end
		if not Alr then
			table.insert(Sprays,{["Player"] = ply,["Pos"] = Pos})
		end
		return false
	end
	
	usermessage.Hook("SprayHere",function(um)
		local Ply = um:ReadString()
		local Pan = vgui.Create("DPanel")
		Pan:SetSize(300,40)
		Pan:SetPos(ScrW() / 2 - Pan:GetWide() / 2,ScrH() / 2 + 100)
		local Time = CurTime() + 3
		Pan.Paint = function(self)
			if CurTime() >= Time then
				self:Remove()
				return
			end
			draw.RoundedBox(6,0,0,self:GetWide(),self:GetTall(),Color(0,0,0,100))
			draw.DrawText("You can't spray here. Here is the spray of "..Ply,"MenuLarge",self:GetWide() / 2,10,Color(255,255,255,255),TEXT_ALIGN_CENTER)
		end
	end)
*/