from Random_number_generator import Random,Round
import pygame,math,os,pickle,base64
from types import *
from pygame.locals import *
pygame.init()

def Sort(Tab):
    Len = len(Tab)
    for I in range(Len * 2):
        Var = Tab[I % Len]
        Ran = Random(0,Len - 1)
        V = Tab[Ran]
        Tab[Ran] = Var
        Tab[I % Len] = V
    return Tab

def Clamp(Value,Min,Max = False):
	if Value < Min:
		return Min
	if Max and Value > Max:
		return Max
	return Value
	
def ReadFile(file):
	File = open(os.path.join(file),"r+")
	Decoded = base64.b64decode(File.read())
	Unpickled = pickle.loads(Decoded)
	File.close()
	return Unpickled
	
def WriteFile(file,Tab):
	File = open(os.path.join(file),"w+")
	Pickled = pickle.dumps(Tab)
	File.write(base64.b64encode(Pickled))
	File.close()
	
if not os.path.exists("Settings.txt"):
	Contents = {}
	Contents["Cover"] = "Blank4.png"
	Contents["Deck"] = "Default"
	Contents["BG"] = "BG.png"
	Contents["Music"] = "Sunset Solitaire.mp3"
	Contents["Animation"] = "True"
	WriteFile("Settings.txt",Contents)
	
if not os.path.exists("Scores.txt"):
	Scores = {}
	Scores["Wins"] = 0
	Scores["Losses"] = 0
	Scores["Best time"] = "None"
	WriteFile("Scores.txt",Scores)
	
from Solitaire_MakeCards import CreateACard
Actions = []
def AddAction(Action = "HandIt",Card = False,Tab = False,UponTab = False,UponCard = False,OldParent = False,Amount = False,Auto = False):
	Dict = {}
	Dict["Action"] = Action
	Dict["Card"] = Card
	Dict["Tab"] = Tab
	Dict["UponTab"] = UponTab
	Dict["UponCard"] = UponCard
	Dict["OldParent"] = OldParent
	Dict["Amount"] = Amount
	Dict["Auto"] = Auto
	Actions.append(Dict)
	
def GetParent(Main,Card):
	if Main == "Hand":
		for I,P in enumerate(Hand):
			if P.Card == Card.Card:
				return {"Main" : "Hand","Par1" : I,"Par2" : -1,"Par3" : -1}
	elif Main == "Places":
		for I,P in enumerate(Places):
			for i,p in enumerate(P):
				for a,b in enumerate(p):
					if b.Card == Card.Card:
						return {"Main" : "Places","Par1" : I,"Par2" : i,"Par3" : a}
	elif Main == "Slots":
		for I,P in enumerate(Slots):
			for i,p in enumerate(P):
				if p.Card == Card.Card:
					return {"Main" : "Slots","Par1" : I,"Par2" : i,"Par3" : -1}
	return Main
	
def GetPos(Parent):
	if Parent["Main"] == "Hand":
		return (GlobalPos["Hand"][0] + 20,GlobalPos["Hand"][1])
	elif Parent["Main"] == "Slots":
		return GlobalPos["Slots"][Parent["Par1"]]
	elif Parent["Main"] == "Places":
		Top = GlobalPos["Places"][Parent["Par1"]]
		if Parent["Par2"] == 0:
			return (Top[0],Top[1] + Parent["Par2"] * 10)
		else:
			Shades = len(Places[Parent["Par1"]][0]) * 10
			return (Top[0],Top[1] + Shades + Parent["Par3"] * 30)
	
NumOrder = {"A" : 1,"2" : 2,"3" : 3,"4" : 4,"5" : 5,"6" : 6,"7" : 7,"8" : 8,"9" : 9,"T" : 10,"J" : 11,"Q" : 12,"K" : 13}
Cards = ["SA","S2","S3","S4","S5","S6","S7","S8","S9","ST","SJ","SQ","SK",
         "DA","D2","D3","D4","D5","D6","D7","D8","D9","DT","DJ","DQ","DK",
         "CA","C2","C3","C4","C5","C6","C7","C8","C9","CT","CJ","CQ","CK",
         "HA","H2","H3","H4","H5","H6","H7","H8","H9","HT","HJ","HQ","HK"]

Black,Red = 1,2
TabPos = (20,20)
HandPos = (160,20)
SlotsPos = [(460,20),(600,20),(740,20),(880,20)]
PlacesPos = [(20,250),(160,250),(300,250),(460,250),(600,250),(740,250),(880,250)]
GlobalPos = {"Places" : PlacesPos,"Slots" : SlotsPos,"Tab" : TabPos,"Hand" : HandPos}					
			 
def CheckBR(Card):
    if Card[0] == "S" or Card[0] == "C":
        return Black
    else:
        return Red

def CanBeSlot(Card,Upon = False):
    if Upon and Upon[0] == Card[0] and NumOrder[Upon[1]] == NumOrder[Card[1]] - 1:
        for I,P in enumerate(Slots):
            if len(P) > 0 and P[len(P) - 1].Card == Upon:
                return True,I
    elif not Upon and NumOrder[Card[1]] == 1:
        for I,P in enumerate(Slots):
            if len(P) == 0:
                return True,I
    elif not Upon:
        for I,P in enumerate(Slots):
			if len(P) > 0:
				Can,Slot = CanBeSlot(Card,P[len(P) - 1].Card)
				if Can:
					return True,I
    return False,False

def CanBePlaced(Tobeplaced,Upon,IsEmpty = False):
    if Tobeplaced[1] == "K" and IsEmpty:
        return True
    if IsEmpty: return False
    if CheckBR(Tobeplaced) != CheckBR(Upon) and NumOrder[Tobeplaced[1]] == NumOrder[Upon[1]] - 1:
        return True
    return False

def SlotIt(Tab,Card,TabUpon,Auto = False):
    AddAction("SlotIt",Card,Tab,TabUpon,False,Card.OldParent["Main"],Auto = Auto)
    Tab.pop()
    I = TabUpon.append(Card)
    Ind = 0
    for i,P in enumerate(Slots):
        if P == TabUpon:
            Ind = i
            break
    Card.SetTargetPos(GlobalPos["Slots"][Ind])
    Card.UpdateParent("Slots",Ind,I)

def PlaceIt(Card,Upon,Tab,TabUpon,Index = False):
    if Tab == TabUpon:
        return
    AddAction("PlaceIt",Card,Tab,TabUpon,Upon,Card.OldParent["Main"])
    Num = Index
    if not Index:
        for I,P in enumerate(Places):
            if P[1] == TabUpon:
                Num = I 
                break
    i = 0
    for I in range(len(Tab)):
        if Card == Tab[I]:
            i = I
    Top = GlobalPos["Places"][Num]
    Top = (Top[0],Top[1] + len(Places[Num][0]) * 10 + len(Places[Num][1]) * 30)
    for Ind in range(i,len(Tab)):
        C = Tab[Ind]
        Val = TabUpon.append(C)
        C.SetTargetPos((Top[0],Top[1] + (Ind - i) * 30))
        C.UpdateParent("Places")
    for Ind in range(i,len(Tab)):
        Tab.pop()
	global NoActs
	NoActs = 0

def HandIt():
    Tab = Globals["Tab"]
    Len = len(Tab)
    if Len >= 3:
        AddAction(Amount = 3)
        for I in range(3):
            C = Tab[len(Tab) - 1]
            Hand.append(C)
            C.SetTargetPos((GlobalPos["Hand"][0] + I * 10,GlobalPos["Hand"][1]))
            C.UpdateParent("Hand")
            Tab.pop()
    elif Len > 0 and Len < 3:
        AddAction(Amount = Len)
        for I in range(Len):
            C = Tab[len(Tab) - 1]
            Hand.append(C)
            C.SetTargetPos((GlobalPos["Hand"][0] + I * 10,GlobalPos["Hand"][1]))
            C.UpdateParent("Hand")
            Tab.pop()
    elif Len == 0:
        AddAction()
        for I in range(len(Hand)):
            C = Hand[len(Hand) - 1]
            Tab.append(C)
            C.SetTargetPos(GlobalPos["Tab"])
            C.UpdateParent("Tab")
            Hand.pop()
    if len(Hand) == 0:
        return
		
    Acts = CheckForActions()
    global NoActs
    if Acts == 0:
        NoActs += 1
    else:
        NoActs = 0
    if NoActs > math.ceil((len(Hand) / 3) + (len(Tab) / 3)) + 1:
        End()
		
def Undo(Action):
	if Action["Action"] == "HandIt":
		Hand = Globals["Hand"]
		Tab = Globals["Tab"]
		Len = len(Hand)
		if Len > 0:
			for I in range(Action["Amount"]):
				C = Hand[len(Hand) - 1]
				Tab.append(C)
				C.SetTargetPos(GlobalPos["Tab"])
				C.UpdateParent("Tab")
				Hand.pop()
		elif Len == 0:
			for I in range(len(Tab)):
				C = Tab[len(Tab) - (I + 1)]
				Hand.append(C)
				if I < len(Tab) - 3:
					C.SetTargetPos(GlobalPos["Hand"])
				else:
					Num = len(Tab) - (I + 1)
					C.SetTargetPos((GlobalPos["Hand"][0] + 10 * Num,GlobalPos["Hand"][1]))
				C.UpdateParent("Hand")
			for I in range(len(Tab)):
				Tab.pop()
	elif Action["Action"] == "SlotIt":
		Action["UponTab"].pop()
		Action["Tab"].append(Action["Card"])
		Par = GetParent(Action["OldParent"],Action["Card"])
		Action["Card"].SetTargetPos(GetPos(Par))
		Action["Card"].UpdateParent(Action["OldParent"])
	elif Action["Action"] == "PlaceIt":
		Tab = Action["UponTab"]
		Card = Action["Card"]
		i = 0
		for I in range(len(Tab)):
			if Card == Tab[I]:
				i = I
		for Ind in range(i,len(Tab)):
			C = Tab[Ind]
			Action["Tab"].append(C)
			Par = GetParent(Action["OldParent"],Action["Card"])
			C.SetTargetPos(GetPos(Par))
			C.UpdateParent(Action["OldParent"])
		for Ind in range(i,len(Tab)):
			Tab.pop()
	elif Action["Action"] == "ShadeOut":
		Action["UponTab"].pop()
		Action["Tab"].append(Action["Card"])
		Action["Card"].UpdateParent("Places")
	global NoActs
	NoActs = 0
		
Width,Height = 1000,800
Screen = pygame.display.set_mode((Width,Height))
pygame.display.set_caption("Solitaire - By Nooobody","Solitaire")
Circle = pygame.Surface((20,20),SRCALPHA)
pygame.draw.circle(Circle,(0,255,0),(20,20),20,1)

Hover = pygame.Surface((100,200),SRCALPHA)
pygame.draw.line(Hover,(0,255,0),(0,20),(0,180))
pygame.draw.line(Hover,(0,255,0),(20,0),(80,0))
pygame.draw.line(Hover,(0,255,0),(99,20),(99,180))
pygame.draw.line(Hover,(0,255,0),(20,199),(80,199))
Hover.blit(Circle,(0,0))
Hover.blit(pygame.transform.flip(Circle.copy(),False,True),(0,180))
Hover.blit(pygame.transform.flip(Circle.copy(),True,False),(80,0))
Hover.blit(pygame.transform.flip(Circle.copy(),True,True),(80,180))

Circle = pygame.Surface((20,20),SRCALPHA)
pygame.draw.circle(Circle,(0,0,0),(20,20),20,1)
Blank = pygame.Surface((100,200),SRCALPHA)
pygame.draw.line(Blank,(0,0,0),(0,20),(0,180))
pygame.draw.line(Blank,(0,0,0),(20,0),(80,0))
pygame.draw.line(Blank,(0,0,0),(99,20),(99,180))
pygame.draw.line(Blank,(0,0,0),(20,199),(80,199))
Blank.blit(Circle,(0,0))
Blank.blit(pygame.transform.flip(Circle.copy(),False,True),(0,180))
Blank.blit(pygame.transform.flip(Circle.copy(),True,False),(80,0))
Blank.blit(pygame.transform.flip(Circle.copy(),True,True),(80,180))

Contents = ReadFile("Settings.txt")
Black = pygame.image.load("Pics/" + Contents["Cover"])
Deck = Contents["Deck"]
BGVal = Contents["BG"]
BG = pygame.image.load("Pics/" + BGVal)
Music = Contents["Music"]
Animation = eval(Contents["Animation"])
if Music != "Disable":
	pygame.mixer.music.load(os.path.join("Music/" + Music))
	pygame.mixer.music.play(-1)
"""
Black = pygame.Surface((100,200),SRCALPHA)
pygame.draw.circle(Black,(0,0,0),(20,20),20)
pygame.draw.circle(Black,(0,0,0),(20,180),20)
pygame.draw.circle(Black,(0,0,0),(80,20),20)
pygame.draw.circle(Black,(0,0,0),(80,180),20)
pygame.draw.circle(Black,(255,255,255),(20,20),20,1)
pygame.draw.circle(Black,(255,255,255),(20,180),20,1)
pygame.draw.circle(Black,(255,255,255),(80,20),20,1)
pygame.draw.circle(Black,(255,255,255),(80,180),20,1)
pygame.draw.rect(Black,(0,0,0),(20,0,60,200))
pygame.draw.rect(Black,(0,0,0),(0,20,100,160))
pygame.draw.line(Black,(255,255,255),(20,0),(80,0))
pygame.draw.line(Black,(255,255,255),(0,20),(0,180))
pygame.draw.line(Black,(255,255,255),(99,20),(99,180))
pygame.draw.line(Black,(255,255,255),(20,199),(80,199))
"""

Font = pygame.font.Font("Arial.ttf",(14))
class Menu(object):
	def __init__(self,Pos,Size):
		self.Pos = Pos
		self.Size = Size
		self.Elements = []
		self.Visible = False
		self.Stuff = False
		
	def AddElement(self,Elm):
		self.Elements.append(Elm)
		Elm.Parent = self
		
	def Draw(self):
		pygame.draw.rect(Screen,(0,0,0),(self.Pos[0],self.Pos[1],self.Size[0],self.Size[1]))
		pygame.draw.rect(Screen,(255,255,255),(self.Pos[0],self.Pos[1],self.Size[0],self.Size[1]),1)
		for E in self.Elements:
			E.Draw()
		if self.Stuff:
			Screen.blit(self.Stuff,(self.Pos[0] + 1,self.Pos[1] + 1))
			
	def SetVisible(self,Visible):
		self.Visible = Visible
		
	def Clicked(self,MPos,MButton):
		for E in self.Elements:
			if MPos[0] >= E.Pos[0] and MPos[0] <= E.Pos[0] + E.Size[0] and MPos[1] >= E.Pos[1] and MPos[1] <= E.Pos[1] + E.Size[1]:
				E.Clicked(MPos,MButton)
		
class Button(object):
	def __init__(self,Pos,Size,Text,Parent):
		self.Parent = Parent
		self.Pos = (Pos[0] + Parent.Pos[0],Pos[1] + Parent.Pos[1])
		self.Size = Size
		self.Text = Font.render(Text,False,(255,255,255))
		self.Wide = Font.size(Text)[0]
	
	def Draw(self):
		pygame.draw.rect(Screen,(0,0,0),(self.Pos[0],self.Pos[1],self.Size[0],self.Size[1]))
		pygame.draw.rect(Screen,(255,255,255),(self.Pos[0],self.Pos[1],self.Size[0],self.Size[1]),1)
		Screen.blit(self.Text,(self.Pos[0] + ((self.Size[0] / 2) - (self.Wide / 2)),self.Pos[1] + 3))
		
	def Clicked(self,MPos,MButton):
		if MButton > 3:
			return
		self.Parent.SetVisible(False)
		global Sel
		if Sel:
			Globals["Cover"] = pygame.image.load(os.path.join("Pics/" + Sel.Var))
			global Black
			Black = Globals["Cover"]
			Contents = ReadFile("Settings.txt")
			if Sel.Var != Contents["Cover"]:
				Contents["Cover"] = Sel.Var
				WriteFile("Settings.txt",Contents)
				global Pic
				Pic = False
		
class List(object):
	def __init__(self,Pos,Size,Parent,ElmSize = (100,200)):
		self.Parent = Parent
		self.Pos = (Pos[0] + Parent.Pos[0],Pos[1] + Parent.Pos[1])
		self.Size = Size
		self.Height = 0
		self.Elements = []
		self.ElmSize = ElmSize
		self.UpBtn = Button((self.Size[0] - 10,(self.Size[1] / 3)),(10,20),"U",self)
		self.UpBtn.Clicked = self.MouseWheelUp
			
		self.DownBtn = Button((self.Size[0] - 10,(self.Size[1] / 3) * 2),(10,20),"D",self)
		self.DownBtn.Clicked = self.MouseWheelDown
		
	def Draw(self):
		pygame.draw.rect(Screen,(0,0,0),(self.Pos[0],self.Pos[1],self.Size[0],self.Size[1]))
		Height = self.Height + self.Pos[1]
		for I,E in enumerate(self.Elements):
			if E.Pos[1] >= Height and E.Pos[1] + self.ElmSize[1] <= Height + self.Size[1]:
				E.Draw(self.Height)
			elif E.Pos[1] < Height and E.Pos[1] + self.ElmSize[1] > Height:
				E.Draw(self.Height,-1,((E.Pos[1] - self.Pos[1]) - self.Height) * -1)
			elif E.Pos[1] < Height + self.Size[1] and E.Pos[1] + self.ElmSize[1] > Height + self.Size[1]:
				E.Draw(self.Height,1,(E.Pos[1] + self.ElmSize[1]) - (Height + self.Size[1]))
		pygame.draw.rect(Screen,(255,255,255),(self.Pos[0],self.Pos[1],self.Size[0],self.Size[1]),1)
		self.UpBtn.Draw()
		self.DownBtn.Draw()
			
	def UpdatePos(self):
		Amount = math.floor(self.Size[0] / self.ElmSize[0])
		Side = (self.Size[0] - (self.ElmSize[0] * Amount)) / Amount
		for I,E in enumerate(self.Elements):
			X = (self.ElmSize[0] + Side) * (I % Amount)
			Y = (self.ElmSize[1] + 10) * math.floor(I / Amount)
			E.Pos = (X + self.Pos[0],Y + self.Pos[1])
			
	def AddItem(self,Item):
		self.Elements.append(Item)
		Item.Parent = self
		self.UpdatePos()
		
	def MouseWheelUp(self):
		self.Height = Clamp(self.Height - 10,0,(self.ElmSize[1] + 10) * math.floor(len(self.Elements) / math.floor(self.Size[0] / self.ElmSize[0])))
		
	def MouseWheelDown(self):
		self.Height = Clamp(self.Height + 10,0,(self.ElmSize[1] + 10) * math.floor(len(self.Elements) / math.floor(self.Size[0] / self.ElmSize[0])))
		
	def Clicked(self,MPos,MButton):
		if MButton == 4:
			self.MouseWheelUp()
			return
		elif MButton == 5:
			self.MouseWheelDown()
			return
		if MPos[0] >= self.UpBtn.Pos[0] and MPos[0] <= self.UpBtn.Pos[0] + self.UpBtn.Size[0] and MPos[1] >= self.UpBtn.Pos[1] and MPos[1] <= self.UpBtn.Pos[1] + self.UpBtn.Size[1]:
			self.UpBtn.Clicked()
		elif MPos[0] >= self.DownBtn.Pos[0] and MPos[0] <= self.DownBtn.Pos[0] + self.DownBtn.Size[0] and MPos[1] >= self.DownBtn.Pos[1] and MPos[1] <= self.DownBtn.Pos[1] + self.DownBtn.Size[1]:
			self.DownBtn.Clicked()
		for E in self.Elements:
			if MPos[0] >= E.Pos[0] and MPos[0] <= E.Pos[0] + self.ElmSize[0] and MPos[1] >= E.Pos[1] - self.Height and MPos[1] <= E.Pos[1] + self.ElmSize[1] - self.Height:
				E.Clicked(MPos)
		
class Element(object):
	def __init__(self,Pic,Var,Parent):
		self.Parent = Parent
		self.Pic = Pic
		self.Var = Var
		self.Size = Pic.get_size()
		
	def Draw(self,Hgt,Cut = 0,Height = 0):
		P = self.Pic
		Pos = self.Pos
		if Cut < 0:
			P = self.Pic.subsurface((0,Height,self.Size[0],self.Size[1] - Height))
			Pos = (self.Pos[0],self.Parent.Pos[1])
		elif Cut > 0:
			P = self.Pic.subsurface((0,0,self.Size[0],Clamp(self.Size[1] - Height,0,self.Size[1])))
			Pos = (self.Pos[0],self.Pos[1] - Hgt)
		elif Cut == 0:
			Pos = (self.Pos[0],self.Pos[1] - Hgt)
		Screen.blit(P,Pos)
		global Sel
		if Sel == self:
			if Cut < 0:
				pygame.draw.line(Screen,(0,255,0),(Pos[0],Pos[1]),(Pos[0],Pos[1] + (self.Size[1] - Height)))
				pygame.draw.line(Screen,(0,255,0),(Pos[0],Pos[1] + (self.Size[1] - Height)),(Pos[0] + self.Size[0],Pos[1] + (self.Size[1] - Height)))
				pygame.draw.line(Screen,(0,255,0),(Pos[0] + self.Size[0],Pos[1]),(Pos[0] + self.Size[0],Pos[1] + (self.Size[1] - Height)))
			elif Cut > 0:
				pygame.draw.line(Screen,(0,255,0),(Pos[0],Pos[1]),(Pos[0],Pos[1] + (self.Size[1] - Height)))
				pygame.draw.line(Screen,(0,255,0),(Pos[0],Pos[1]),(Pos[0] + self.Size[0],Pos[1]))
				pygame.draw.line(Screen,(0,255,0),(Pos[0] + self.Size[0],Pos[1]),(Pos[0] + self.Size[0],Pos[1] + (self.Size[1] - Height)))
			elif Cut == 0:
				pygame.draw.rect(Screen,(0,255,0),(Pos[0],Pos[1],self.Size[0],self.Size[1]),1)
		
	def Clicked(self,MPos):
		global Sel
		Sel = self
		
CoverMenu = Menu((200,200),(600,300))
CoverMenu.SetVisible(False)
Lst = List((20,20),(560,220),CoverMenu)
CoverMenu.AddElement(Lst)
CoverMenu.AddElement(Button((20,260),(60,20),"Accept",CoverMenu))
Blanks = os.listdir(os.path.join("Pics/"))
for P in Blanks:
	if P.find("Blank") > -1:
		 Lst.AddItem(Element(pygame.image.load("Pics/" + P),P,Lst))		 
		
DeckMenu = Menu((200,200),(300,200))
DeckMenu.SetVisible(False)
Lst = List((20,20),(260,120),DeckMenu,(260,20))
DeckMenu.AddElement(Lst)
Btn = Button((20,160),(60,20),"Accept",DeckMenu)
def New(MPos,MButton):
	if MButton > 3:
		return
	DeckMenu.SetVisible(False)
	global Sel
	if Sel:
		Globals["Deck"] = Sel.Var
		Contents = ReadFile("Settings.txt")
		if Sel.Var != Contents["Deck"]:
			Contents["Deck"] = Sel.Var
			WriteFile("Settings.txt",Contents)
			global Pic
			Pic = False
Btn.Clicked = New
DeckMenu.AddElement(Btn)
		
Find = os.listdir(os.path.join("Pics/"))
Dirs = []
for F in Find:
	if os.path.isdir(os.path.join("Pics/" + F)):
		Dirs.append(F)
for D in Dirs:
	Surf = pygame.Surface((260,20))
	Txt = Font.render(D,False,(255,255,255))
	Surf.blit(Txt,(2,2))
	Lst.AddItem(Element(Surf,D,Lst))
		
BGMenu = Menu((200,200),(300,200))
BGMenu.SetVisible(False)
Lst = List((20,20),(260,120),BGMenu,(100,100))
BGMenu.AddElement(Lst)
Btn = Button((20,160),(60,20),"Accept",BGMenu)
def New(MPos,MButton):
	if MButton > 3:
		return
	BGMenu.SetVisible(False)
	global Sel
	if Sel:
		Globals["BG"] = Sel.Var
		global BG
		BG = pygame.image.load(os.path.join("Pics/" + Sel.Var))
		Contents = ReadFile("Settings.txt")
		if Sel.Var != Contents["BG"]:
			Contents["BG"] = Sel.Var
			WriteFile("Settings.txt",Contents)
			global Pic
			Pic = False
Btn.Clicked = New
BGMenu.AddElement(Btn)
		
Blanks = os.listdir(os.path.join("Pics/"))
for P in Blanks:
	if P.find("BG") > -1:
		 Lst.AddItem(Element(pygame.transform.scale(pygame.image.load("Pics/" + P),(100,100)),P,Lst))		 
		
MusicMenu = Menu((200,200),(300,200))
MusicMenu.SetVisible(False)
Lst = List((20,20),(260,120),MusicMenu,(260,20))
MusicMenu.AddElement(Lst)
Btn = Button((20,160),(60,20),"Accept",MusicMenu)
def New(MPos,MButton):
	if MButton > 3:
		return
	MusicMenu.SetVisible(False)
	global Sel
	if Sel:
		Globals["Music"] = Sel.Var
		Contents = ReadFile("Settings.txt")
		if Sel.Var != Contents["Music"]:
			if Sel.Var != "Disable":
				pygame.mixer.music.load(os.path.join("Music/" + Sel.Var))
				pygame.mixer.music.play(-1)
			else:
				pygame.mixer.music.stop()
			Contents["Music"] = Sel.Var
			WriteFile("Settings.txt",Contents)
			global Pic
			Pic = False
Btn.Clicked = New
MusicMenu.AddElement(Btn)

Surf = pygame.Surface((260,20))
Txt = Font.render("Disable",False,(255,255,255))
Surf.blit(Txt,(2,2))
Lst.AddItem(Element(Surf,"Disable",Lst))

All = os.listdir(os.path.join("Music/"))
for D in All:
	Surf = pygame.Surface((260,20))
	Txt = Font.render(D,False,(255,255,255))
	Surf.blit(Txt,(2,2))
	Lst.AddItem(Element(Surf,D,Lst))

HelpMenu = Menu((200,200),(300,200))
HelpMenu.SetVisible(False)
Btn = Button((20,160),(60,20),"Close",HelpMenu)
def New(MPos,MButton):
	if MButton > 3:
		return
	HelpMenu.SetVisible(False)
Btn.Clicked = New
HelpMenu.AddElement(Btn)

Surf = pygame.Surface((280,140))
Txt = Font.render("Right-click to undo.",False,(255,255,255))
Surf.blit(Txt,(20,20))
Txt = Font.render("Space to autoslot.",False,(255,255,255))
Surf.blit(Txt,(20,40))
Txt = Font.render("R (or mouse wheel click) to restart.",False,(255,255,255))
Surf.blit(Txt,(20,60))
Txt = Font.render("C, D, B and M to open different menus",False,(255,255,255))
Surf.blit(Txt,(20,80))
Txt = Font.render("for changing different settings.",False,(255,255,255))
Surf.blit(Txt,(20,100))
Txt = Font.render("A to toggle Animations.",False,(255,255,255,255))
Surf.blit(Txt,(20,120))

HelpMenu.Stuff = Surf
	
Throwing = True
OCards = []
Moving = []
class CardEnt(object):
	def __init__(self,Card):
		self.Card = Card
		self.Surf = pygame.image.load("Pics/" + Card + ".png")
		self.Parent = None
		self.UpdateParent("Tab")
		self.OldParent = None
		self.Hover = False
		self.Selected = False
		self.Target = False
		self.MPos = (0,0)
		self.SelPos = (0,0)
		self.Deck = False
		self.Pos = (300,20)
		self.Vel = (0,0)
		self.Added = -90000
		self.PhysicsTick = 0
		OCards.append(self)
		
	def UpdateParent(self,Main,Par1 = -1,Par2 = -1,Par3 = -1):
		if self.Parent and self.Parent["Main"] != "Mouse":
			self.OldParent = self.Parent
		self.Parent = {"Main" : Main,"Par1" : Par1,"Par2" : Par2,"Par3" : Par3}
		
	def GetParent(self):
		Par = self.Parent
		if Par["Main"] == "Mouse":
			Par = self.OldParent

		if Par["Main"] == "Places":
			return Globals["Places"][Par["Par1"]][Par["Par2"]]
		elif Par["Main"] == "Slots":
			return Globals["Slots"][Par["Par1"]]
		elif Par["Main"] == "Hand":
			return Globals["Hand"]
		
	def FindParent(self):
		if self.Parent["Main"] == "Tab":
			return
		elif self.Parent["Main"] == "Hand":
			if self.Parent["Par1"] == -1:
				for I,P in enumerate(Hand):
					if P.Card == self.Card:
						self.UpdateParent("Hand",I)
						return
			return
		elif self.Parent["Main"] == "Slots":
			if self.Parent["Par1"] == -1 or self.Parent["Par2"] == -1:
				for I,P in enumerate(Slots):
					for i,p in enumerate(P):
						if p.Card == self.Card:
							self.UpdateParent("Slots",I,i)
							return
			return
		elif self.Parent["Main"] == "Places":
			if self.Parent["Par1"] == -1 or self.Parent["Par2"] == -1 or self.Parent["Par3"] == -1:
				for I,P in enumerate(Places):
					for i,H in enumerate(P):
						for Ind,C in enumerate(H):
							if C.Card == self.Card:
								self.UpdateParent("Places",I,i,Ind)
								return
			return
		
	def GetPos(self):
		if self.Pos and (Animation or Throwing):
			return self.Pos
		if self.Parent:
			if self.Parent["Main"] == "Tab":
				return GlobalPos["Tab"]
			elif self.Parent["Main"] == "Hand":
				if self.Parent["Par1"] == -1:
					self.FindParent()
				if self.Parent["Par1"] >= len(Hand) - 3:
					return (GlobalPos["Hand"][0] + 10 * (self.Parent["Par1"] - (len(Hand) - 3)),GlobalPos["Hand"][1])
				return GlobalPos["Hand"]
			elif self.Parent["Main"] == "Slots":
				if self.Parent["Par1"] == -1:
					self.FindParent()
				return GlobalPos["Slots"][self.Parent["Par1"]]
			elif self.Parent["Main"] == "Places":
				if self.Parent["Par1"] == -1 or self.Parent["Par2"] == -1 or self.Parent["Par3"] == -1:
					self.FindParent()
				Xtra = 0
				if self.Parent["Par2"] == 1:
					if self.Parent["Par3"] > 0:
						Var = Places[self.Parent["Par1"]][1][self.Parent["Par3"] - 1].GetPos()
						return (Var[0],Var[1] + 30)
					else:
						Xtra = len(Places[self.Parent["Par1"]][0]) * 10 + self.Parent["Par3"] * 30
				else:
					Xtra = self.Parent["Par3"] * 10
				return (GlobalPos["Places"][self.Parent["Par1"]][0],GlobalPos["Places"][self.Parent["Par1"]][1] + Xtra)
			elif self.Parent["Main"] == "Mouse":
				return (self.MPos[0] - self.SelPos[0],self.MPos[1] - self.SelPos[1])
				
	def SetTargetPos(self,Pos):
		if not Animation and not Throwing:
			return
		self.Target = Pos
		self.Pos = self.GetPos()
		self.Vel = ((self.Target[0] - self.Pos[0]) / 5,(self.Target[1] - self.Pos[1]) / 5)
		self.Added = 0
		Moving.append(self)
				
	def ProcessMovement(self):
		if not self.Pos or not self.Target:
			return
		self.Pos = (self.Pos[0] + self.Vel[0],self.Pos[1] + self.Vel[1])
		self.Added += 1
		if self.Added == 5:
			self.Added = False
			self.Pos = False
			self.Target = False
			global Pic
			Pic = False
			Moving.remove(self)
				
	def CheckForCover(self):
		if self.Card[1] != "J" and self.Card[1] != "Q" and self.Card[1] != "K":
			return
		if self.Deck != Globals["Deck"]:
			self.Surf = CreateACard(self.Card)
			self.Deck = Globals["Deck"]
				
	def Draw(self,Surf = Screen):
		self.CheckForCover()
		if Surf != Screen:
			if self.Parent["Main"] == "Mouse":
				return
			elif self.Parent["Main"] == "Places" and self.Parent["Par2"] == 1:
				for I in range(len(Globals["Places"][self.Parent["Par1"]][1])):
					if Globals["Places"][self.Parent["Par1"]][1][I].Parent["Main"] == "Mouse" and I < self.Parent["Par3"]:
						return
		Pos = self.GetPos()
		if self.Parent["Main"] == "Tab" or (self.Parent["Main"] == "Places" and self.Parent["Par2"] == 0):
			Surf.blit(Globals["Cover"],Pos)
			return
		Surf.blit(self.Surf,Pos)
			
Places = [[[],[]],[[],[]],[[],[]],[[],[]],[[],[]],[[],[]],[[],[]]]
Slots = [[],[],[],[]]
Hand = []
Actions = []
Cards = Sort(Cards)
Tab = Sort(Cards)
Repl = []
Time = pygame.time.get_ticks()
for I in Tab:
	Repl.append(CardEnt(I))
Tab = Repl
Globals = {"Places" : Places,"Slots" : Slots,"Cards" : OCards,"Hand" : Hand,"Tab" : Tab,"Cover" : Black,"Deck" : Deck,"BG" : BGVal,"Music" : Music}
		
def Reset():
	global Places
	global Slots
	global OCards
	global Hand
	global Actions
	global NoActs
	global AutoSlot
	global Throwing
	global Tab
	global TimerRunning
	global OldAction
	global HoverCard
	global Hov
	global GameTime
	HoverCard = False
	Hov = False
	TimerRunning = False
	Throwing = True
	AutoSlot = False
	Places = [[[],[]],[[],[]],[[],[]],[[],[]],[[],[]],[[],[]],[[],[]]]
	Slots = [[],[],[],[]]
	Hand = []
	OCards = []
	Actions = []
	NoActs = 0
	GameTime = 0
	global Cards
	Cards = Sort(Cards)
	Tab = Sort(Cards)
	Repl = []
	for C in Tab:
		Repl.append(CardEnt(C))
	Tab = Repl
	global Globals
	Globals = {"Places" : Places,"Slots" : Slots,"Cards" : OCards,"Hand" : Hand,"Tab" : Repl,"Cover" : Black,"Deck" : Deck,"BG" : BGVal,"Music" : Music}
			
OldAction = 0
Pic = False
def GetANewPic():
	Pic = pygame.Surface((Width,Height))
	Pic.fill((0,0,0))
	Pic.blit(BG,(0,0))
	for I,P in enumerate(GlobalPos["Slots"]):
		if len(Slots[I]) == 0:
			Pic.blit(Blank,P)
	for I,P in enumerate(GlobalPos["Places"]):
		if len(Places[I][0]) == 0:
			Pic.blit(Blank,P)
	for P in Globals["Places"]:
		for p in P:
			for I in p:
				if not I.Pos:
					I.Draw(Pic)
	for I,P in enumerate(Globals["Slots"]):
		if len(P) > 0:
			if len(P) > 1:
				if len(P) > 2:
					P[len(P) - 3].Draw(Pic)
					P[len(P) - 2].Draw(Pic)
				else:
					Pic.blit(Blank,GlobalPos["Slots"][I])
					P[len(P) - 2].Draw(Pic)
			else:
				Pic.blit(Blank,GlobalPos["Slots"][I])
			if not P[len(P) - 1].Pos:
				P[len(P) - 1].Draw(Pic)
	
	for I in range(Clamp(len(Hand) - 4,0),len(Hand)):
		if not Hand[I].Pos:
			Hand[I].Draw(Pic)
	if len(Globals["Tab"]) == 0:
		Pic.blit(Blank,GlobalPos["Tab"])
	for P in Globals["Tab"]:
		P.Draw(Pic)
	return Pic

def CalcActs():
	global Actions
	Acts = []
	for A in Actions:
		if A["Action"] != "ShadeOut" and not A["Auto"]:
			Acts.append(A)
	return Acts
	
def FinishRenders():
	pygame.display.flip()
	
def Renders():
	global OldAction
	global Pic
	global GameTime
	if OldAction != len(Actions):
		OldAction = len(Actions)
		Pic = False
		global TimerRunning
		if len(CalcActs()) > 0 and not TimerRunning:
			TimerRunning = True
	if not Pic:
		Pic = GetANewPic()
	Screen.blit(Pic,(0,0))
	if HoverCard and HoverCard != Selected:
		Par = HoverCard.Parent
		if Par["Main"] == "Places" and Par["Par3"] < len(Globals["Places"][Par["Par1"]][1]) - 1:
			global Hov
			if not Hov:
				Len = (len(Globals["Places"][Par["Par1"]][1]) - 1) - Par["Par3"]
				Hgt = 200 + 30 * Len
				Hov = pygame.Surface((100,Hgt),SRCALPHA)
				pygame.draw.line(Hov,(0,255,0),(0,20),(0,Hgt - 20))
				pygame.draw.line(Hov,(0,255,0),(20,0),(80,0))
				pygame.draw.line(Hov,(0,255,0),(99,20),(99,Hgt - 20))
				pygame.draw.line(Hov,(0,255,0),(20,Hgt - 1),(80,Hgt - 1))
				Circle = pygame.Surface((20,20),SRCALPHA)
				pygame.draw.circle(Circle,(0,255,0),(20,20),20,1)
				Hov.blit(Circle,(0,0))
				Hov.blit(pygame.transform.flip(Circle.copy(),False,True),(0,Hgt - 20))
				Hov.blit(pygame.transform.flip(Circle.copy(),True,False),(80,0))
				Hov.blit(pygame.transform.flip(Circle.copy(),True,True),(80,Hgt - 20))
			Screen.blit(Hov,HoverCard.GetPos())
		elif Par["Main"] == "Hand" and Par["Par1"] < len(Hand) - 1:
			pass
		else:
			Screen.blit(Hover,HoverCard.GetPos())
	if Selected:
		if Selected.OldParent["Main"] == "Places" and Selected.OldParent["Par3"] < len(Globals["Places"][Selected.OldParent["Par1"]][1]) - 1:
			for I in range(Selected.OldParent["Par3"],len(Globals["Places"][Selected.OldParent["Par1"]][1])):
				C = Places[Selected.OldParent["Par1"]][1][I]
				C.Draw()
		else:
			Selected.Draw()
	for P in Moving:
		if P.Pos and (Throwing or Animation):
			P.Draw()
	BotBar = pygame.Surface((Width,20))
	BotBar.fill((0,0,0))
	pygame.draw.line(BotBar,(255,255,255),(0,0),(Width,0))
	if TimerRunning:
		Taimu = Font.render("Time: " + str(GameTime / 1000),False,(255,255,255))
	else:
		Taimu = Font.render("Time: 0",False,(255,255,255))
	Actns = Font.render("Action: " + str(len(CalcActs())),False,(255,255,255))
	BotBar.blit(Taimu,(Width - 100,5))
	BotBar.blit(Actns,(Width - 200,5))
	BotBar.blit(Font.render("Press H to open the help menu.",False,(255,255,255)),(20,5))
	Screen.blit(BotBar,(0,Height - 20))

def CheckForCards(MPos):
	if CoverMenu.Visible:
		if MPos[0] >= CoverMenu.Pos[0] and MPos[0] <= CoverMenu.Pos[0] + CoverMenu.Size[0] and MPos[1] >= CoverMenu.Pos[1] and MPos[1] <= CoverMenu.Pos[1] + CoverMenu.Size[1]:
			return CoverMenu
	if MPos[0] >= 20 and MPos[0] <= 120 and MPos[1] >= 20 and MPos[1] <= 220:
		return "Tab"
	for I,P in enumerate(GlobalPos["Slots"]):
		if len(Slots[I]) == 0 and MPos[0] >= P[0] and MPos[0] <= P[0] + 100 and MPos[1] >= P[1] and MPos[1] <= P[1] + 200:
			return "S:" + str(I)
	for I,P in enumerate(GlobalPos["Places"]):
		if len(Places[I][1]) == 0 and len(Places[I][0]) == 0 and MPos[0] >= P[0] and MPos[0] <= P[0] + 100 and MPos[1] >= P[1] and MPos[1] <= P[1] + 200:
			return "P:" + str(I)
	if len(Hand) > 0:
		C = Hand[len(Hand) - 1]
		Pos = C.GetPos()
		if C != Selected and MPos[0] >= Pos[0] and MPos[0] <= Pos[0] + 100 and MPos[1] >= Pos[1] and MPos[1] <= Pos[1] + 200:
			return C
	for T in Places:
		P = T[1]
		Ind = 0
		while Ind < len(P):
			C = P[len(P) - (1 + Ind)]
			if C != Selected:
				Pos = C.GetPos()
				if MPos[0] >= Pos[0] and MPos[0] <= Pos[0] + 100 and MPos[1] >= Pos[1] and MPos[1] <= Pos[1] + 200:
					return C
			Ind = Ind + 1
	for T in Slots:
		for I,C in enumerate(T):
			if I == len(T) - 1 and C != Selected:
				Pos = C.GetPos()
				if MPos[0] >= Pos[0] and MPos[0] <= Pos[0] + 100 and MPos[1] >= Pos[1] and MPos[1] <= Pos[1] + 200:
					return C
	return False

def CheckForPos(Card):
	Par = Card.GetParent()
	Pos = []
	for I,P in enumerate(Places):
		Var = False
		Empty = len(P[1]) == 0
		if not Empty:
			Var = P[1][len(P[1]) - 1].Card
		if CanBePlaced(Card.Card,Var,Empty):
			Xtra = len(Globals["Places"][I][0]) * 10 + len(Globals["Places"][I][1]) * 30
			Position = (GlobalPos["Places"][I][0],GlobalPos["Places"][I][1] + Xtra)
			Pos.append({"Pos" : Position,"Place" : "Places","Index" : I})
	Tbl = Card.Parent
	if Tbl["Main"] == "Mouse":
		Tbl = Card.OldParent
	if Tbl["Main"] == "Places" and Tbl["Par3"] < len(Par) - 1:
		return Pos
	for I,P in enumerate(Slots):
		Var = False
		if len(P) > 0:
			Var = P[len(P) - 1].Card
		Can,Slot = CanBeSlot(Card.Card,Var)
		Ace = NumOrder[Card.Card[1]] == 1
		if Can and ((I == Slot and not Ace) or (not Var and Ace)):
			Pos.append({"Pos" : GlobalPos["Slots"][I],"Place" : "Slots","Index" : I})
	return Pos
	
def FlipNewCards():
	for I,P in enumerate(Places):
		if len(P[1]) == 0 and len(P[0]) > 0:
			C = P[0][len(P[0]) - 1]
			P[1].append(C)
			C.UpdateParent("Places")
			P[0].pop()
			AddAction("ShadeOut",C,P[0],P[1])
			Pic = False
	
def End(Win = False):
	Box = pygame.Surface((400,240))
	Box.fill((255,255,255))
	Box.fill((0,0,0),(1,1,398,238))
	WinText = Font.render("You lost the game!",False,(255,255,255))
	Scores = ReadFile("Scores.txt")
	Wins = int(Scores["Wins"])
	Losses = int(Scores["Losses"])
	if Win:
		WinText = Font.render("You won! Congratulations!",False,(255,255,255))
		Wins += 1
		Scores["Wins"] = Wins
		WriteFile("Scores.txt",Scores)
	else:
		Losses += 1
		Scores["Losses"] = Losses
		WriteFile("Scores.txt",Scores)
	global GameTime
	Box.blit(WinText,(200 - (WinText.get_rect().width / 2),20))
	WinTime = GameTime / 1000
	Box.blit(Font.render("Time: " + str(WinTime) + " seconds",False,(255,255,255)),(20,60))
	Box.blit(Font.render("Actions per second: " + str(Round((float(len(CalcActs())) / float(WinTime)) * 100) / 100),False,(255,255,255)),(200,60))
	Per = math.floor((float(Wins) / float(Wins + Losses)) * 10000) / 100
	Box.blit(Font.render("Win percentage: " + str(Per) + " %",False,(255,255,255)),(20,80))
	Box.blit(Font.render("Amount of games: " + str(Losses + Wins),False,(255,255,255)),(200,80))
	BestTime = Scores["Best time"]
	if BestTime == "None":
		if Win:
			BestTime = WinTime
			Scores["Best time"] = BestTime
			WriteFile("Scores.txt",Scores)
	else:
		BestTime = int(Scores["Best time"])
		if Win and WinTime < BestTime:
			BestTime = WinTime
			Scores["Best time"] = BestTime
			WriteFile("Scores.txt",Scores)
		if BestTime < 60:
			BestTime = str(BestTime) + " seconds"
		else:
			BestTime = str(int(math.floor(BestTime / 60))) + " minutes and " + str(BestTime % 60) + " seconds"
	Box.blit(Font.render("Best recorded time: " + str(BestTime),False,(255,255,255)),(20,120))
	Rest = Font.render("Press R or middle mouse button (mouse wheel)",False,(255,255,255))
	Rest2 = Font.render("to start a new game.",False,(255,255,255))
	Rest3 = Font.render("Or undo if you want to continue.",False,(255,255,255))
	Box.blit(Rest,(200 - (Rest.get_rect().width / 2),160))
	Box.blit(Rest2,(200 - (Rest2.get_rect().width / 2),180))
	Box.blit(Rest3,(200 - (Rest3.get_rect().width / 2),200))
		
	Pic = GetANewPic()
	while 1:
		for C in Moving:
			C.ProcessMovement()
		Renders()
		Screen.blit(Box,(Width / 2 - 200,280))
		FinishRenders()
		for Event in pygame.event.get():
			if Event.type == QUIT:
				pygame.quit()
				sys.exit()
			elif Event.type == MOUSEBUTTONDOWN:
				if Event.button == 2:
					Reset()
					return
				elif Event.button == 3 and not Win:
					Action = Actions.pop()
					if Action == "ShadeOut":
						Undo(Action)
						Action = Actions.pop()
					Undo(Action)
					Pic = False
					global NoActs
					NoActs = 0
					global AutoSLot
					AutoSlot = False
					Losses -= 1
					Scores["Losses"] = Losses
					WriteFile("Scores.txt",Scores)
					return
			elif Event.type == KEYDOWN:
				if Event.key == K_r:
					Reset()
					File.close()
					return
	
def CheckForActions():
	Acts = 0
	if len(Hand) > 0:
		HandCard = Hand[len(Hand) - 1]
		Can,Slot = CanBeSlot(HandCard.Card)
		if Can:
			Acts += 1
		for P in Places:
			Empty = len(P[1]) == 0
			Crd = False
			if len(P[1]) > 0:
				Crd = P[1][len(P[1]) - 1].Card
			if CanBePlaced(HandCard.Card,Crd,Empty):
				Acts += 1
		for I,P in enumerate(Slots):
			if len(P) > 0:
				Crd = P[len(P) - 1]
				if CanBePlaced(HandCard.Card,Crd.Card):
					for i,p in enumerate(Places):
						Empty = len(p[1]) == 0
						AnCrd = False
						if not Empty:
							AnCrd = p[1][len(p[1]) - 1].Card
						if CanBePlaced(Crd.Card,AnCrd,Empty):
							Acts += 1
							break
					break
					
	for I,P in enumerate(Places):
		if len(P[1]) > 0:
			Src = P[1][0]
			if not (Src.Card[1] == "K" and len(P[0]) == 0):
				for i,p in enumerate(Places):
					if I != i:
						Empty = len(p[1]) == 0
						Crd = False
						if not Empty:
							Crd = p[1][len(p[1]) - 1].Card
						if CanBePlaced(Src.Card,Crd,Empty):
							Acts += 1
			if len(P[0]) > 0:
				for i,p in enumerate(Slots):
					if len(p) > 0:
						Crd = p[len(p) - 1]
						if CanBePlaced(Src.Card,Crd.Card):
							for Ind,Var in enumerate(Places):
								if Ind != I:
									Empty = len(Var[1]) == 0
									AnCrd = False
									if not Empty:
										AnCrd = Var[1][len(Var[1]) - 1].Card
									if CanBePlaced(Crd.Card,AnCrd,Empty):
										Acts += 1
										break
							break
			Src = P[1][len(P[1]) - 1]
			Can,Slot = CanBeSlot(Src.Card)
			if Can:
				Acts += 1
			for i,C in enumerate(P[1]):
				Can,Slot = CanBeSlot(C.Card)
				if Can and i < len(P[1]) - 1:
					for a,p in enumerate(Places):
						if len(p[1]) > 0:
							for b,c in enumerate(p[1]):
								if b == len(p[1]) - 1 and CheckBR(C.Card) == CheckBR(c.Card) and C.Card[1] == c.Card[1]:
									Acts += 1
									break
	return Acts
	
def OpenMenu(Val = 0):
	Menu = CoverMenu
	if Val == 1:
		Menu = DeckMenu
	elif Val == 2:
		Menu = BGMenu
	elif Val == 3:
		Menu = MusicMenu
	elif Val == 4:
		Menu = HelpMenu
	global Sel
	Sel = False
	Menu.SetVisible(True)
	global Time
	global Delay
	while Menu.Visible:
		Delay = pygame.time.get_ticks() - Time
		Time = pygame.time.get_ticks()
		Renders()
		Menu.Draw()
		FinishRenders()
		for Event in pygame.event.get():
			if Event.type == QUIT:
				pygame.quit()
				sys.exit()
			elif Event.type == MOUSEBUTTONDOWN:
				if Event.pos[0] >= Menu.Pos[0] and Event.pos[0] <= Menu.Pos[0] + Menu.Size[0] and Event.pos[1] >= Menu.Pos[1] and Event.pos[1] <= Menu.Pos[1] + Menu.Size[1]:
					Menu.Clicked(Event.pos,Event.button)

Sel = False
Selected = False
Hov = False
HoverCard = False
Check = False
AutoSlot = False
TimerRunning = False
Leftie = False
RequiredPos = []
NoActs = 0
Ind = 0
TabI = 0
GameTime = 0
Ticks = 0
PlaceRange = (1,2,3,4,5,6,7)
Time = pygame.time.get_ticks()
while 1:
	Delay = pygame.time.get_ticks() - Time
	Time = pygame.time.get_ticks()
	if Throwing:
		if len(Places[6][0]) < 7:
			Ind = Ind % 7
			Plc = Places[Ind][0]
			if len(Plc) < PlaceRange[Ind]:
				Card = Tab[0]
				Plc.append(Card)
				Card.SetTargetPos((GlobalPos["Places"][Ind][0],GlobalPos["Places"][Ind][1] + len(Places[Ind][0] * 10)))
				Card.UpdateParent("Places")
				Card.FindParent()
				Tab.pop(0)
			Ind += 1
		else:
			if TabI < len(Tab):
				for I in range(3):
					C = Tab[TabI]
					C.SetTargetPos(GlobalPos["Tab"])
					TabI += 1
			else:
				Throwing = False
				TabI = 0
				Ind = 0

	for I in Moving:
		I.ProcessMovement()
			
	if TimerRunning and not AutoSlot:
		GameTime += Delay
		
	if AutoSlot:
		Slotted = False
		for i,P in enumerate(Places):
			if len(P[1]) > 0 and not Slotted:
				Last = P[1][len(P[1]) - 1]
				CanSlot,Slot = CanBeSlot(Last.Card)
				if CanSlot:
					SlotIt(Last.GetParent(),Last,Slots[Slot],Auto = True)
					Slotted = True
		if not Slotted and len(Hand) > 0:
			Last = Hand[len(Hand) - 1]
			CanSlot,Slot = CanBeSlot(Last.Card)
			if CanSlot:
				SlotIt(Last.GetParent(),Last,Slots[Slot],Auto = True)
				Slotted = True
		if not Slotted:
			AutoSlot = False	
	
	if not Throwing:
		FlipNewCards()
		
	for Event in pygame.event.get():
		if Event.type == QUIT:
			pygame.quit()
			sys.exit()
		elif Event.type == MOUSEMOTION and not Throwing and not AutoSlot:
			Check = CheckForCards(Event.pos)
			if Check != "Tab" and not (type(Check) == StringType and (Check[0] == "S" or Check[0] == "P")) and not Selected:
				if not Check and HoverCard:
					HoverCard = False
					Hov = False
				elif Check and Check != HoverCard:
					HoverCard = Check
					Hov = False
			if Selected is not False:
				Selected.MPos = Event.pos
		elif Event.type == MOUSEBUTTONDOWN and not Throwing and not AutoSlot:
			if Event.button == 1:
				Leftie = True
				Check = CheckForCards(Event.pos)								
				if Check and not (type(Check) == StringType and (Check[0] == "S" or Check[0] == "P")):
					if Check == "Tab":
						HandIt()
					else:
						Selected = Check
						Pos = Selected.GetPos()
						Selected.UpdateParent("Mouse")
						Selected.SelPos = (Event.pos[0] - Pos[0],Event.pos[1] - Pos[1])
						Selected.MPos = Event.pos
						Pic = False
						RequiredPos = CheckForPos(Selected)
			elif Event.button == 3 and not Selected:
				if Leftie:
					AutoSlot = True
					AddAction("AutoSlot")
					Leftie = False
				elif len(CalcActs()) > 0:
					Action = Actions.pop()
					while Action["Action"] == "ShadeOut":
						Undo(Action)
						Action = Actions.pop()
					Undo(Action)
					Pic = False
					AutoSlot = False
			elif Event.button == 2:
				Reset()
				if TimerRunning:
					File = open(os.path.join("Scores.txt"),"r")
					Contents = File.read().split(":")
					File.close()
					File = open(os.path.join("Scores.txt"),"w")
					Losses = int(Contents[1]) + 1
					File.write(Contents[0] + ":" + str(Losses))
					File.close()
		elif Event.type == MOUSEBUTTONUP and not Throwing:
			if Event.button == 1:
				Leftie = False
			if Event.button == 1 and Selected:
				Fail = False
				SelMain = Selected.OldParent["Main"]
				if len(RequiredPos) > 0:
					MPos = Event.pos
					GotIt = False
					for P in RequiredPos:
						Pos = P["Pos"]
						if MPos[0] >= Pos[0] - 50 and MPos[0] <= Pos[0] + 150 and MPos[1] >= Pos[1] - 50 and MPos[1] <= Pos[1] + 250:
							Par = Selected.GetParent()
							if P["Place"] == "Slots":
								SlotIt(Par,Selected,Slots[P["Index"]])
								GotIt = True
								break
							elif P["Place"] == "Places":
								Check = False
								if len(Places[P["Index"]][1]) > 0:
									Check = Places[P["Index"]][1][len(Places[P["Index"]][1]) - 1]
								PlaceIt(Selected,Check,Par,Places[P["Index"]][1],Index = P["Index"])
								GotIt = True
								break
					if not GotIt:
						Fail = True
				else:
					Check = CheckForCards(Event.pos)
					if Check and Check != "Tab":
						CheMain = ""
						if type(Check) != StringType:
							CheMain = Check.Parent["Main"]
						if type(Check) == StringType:
							if Check[0] == "S":
								Slot = int(Check[2])
								Can,Sl = CanBeSlot(Selected.Card)
								if Can:
									Tab = Selected.GetParent()
									SlotIt(Tab,Selected,Globals["Slots"][Slot])
								else:
									Fail = True
							elif Check[0] == "P":
								Place = int(Check[2])
								if CanBePlaced(Selected.Card,False,True):
									Tab = Selected.GetParent()
									if Tab["Par1"] != Place:
										PlaceIt(Selected,False,Tab,Globals["Places"][Place][1])
								else:
									Fail = True
						elif CheMain == "Places":
							Tab = Selected.GetParent()
							ChePar = Check.GetParent()
							if CanBePlaced(Selected.Card,Check.Card) and Selected.OldParent["Par1"] != Check.Parent["Par1"] and Check.Parent["Par3"] == len(ChePar) - 1:
								PlaceIt(Selected,Check,Tab,ChePar)
							else:
								Fail = True
						elif CheMain == "Slots":
							Tab = Selected.GetParent()
							if Selected.OldParent["Main"] == "Places" and Selected.OldParent["Par3"] < len(Tab) - 1:
								Fail = True
							else:
								Can,Slot = CanBeSlot(Selected.Card,Check.Card)
								if Can:
									SlotIt(Tab,Selected,Check.GetParent())
								else:
									Fail = True
						elif CheMain == "Hand":
							Fail = True
					else:
						Fail = True
				if Fail:
					if Selected.OldParent["Main"] == "Places" and Selected.OldParent["Par3"] < len(Globals["Places"][Selected.OldParent["Par1"]][1]) - 1:
						for I in range(Selected.OldParent["Par3"],len(Globals["Places"][Selected.OldParent["Par1"]][1])):
							C = Places[Selected.OldParent["Par1"]][1][I]
							if C == Selected:
								C.SetTargetPos(GetPos(C.OldParent))
							else:
								C.SetTargetPos(GetPos(C.Parent))
					else:
						Selected.SetTargetPos(GetPos(Selected.OldParent))
					Selected.UpdateParent(SelMain,Selected.OldParent["Par1"],Selected.OldParent["Par2"],Selected.OldParent["Par3"])
				Selected = False
				Pic = False
				RequiredPos = []
		elif Event.type == KEYDOWN:
			if Event.key == K_r:
				Reset()
				if TimerRunning:
					File = open(os.path.join("Scores.txt"),"r")
					Contents = File.read().split(":")
					File.close()
					File = open(os.path.join("Scores.txt"),"w")
					Wins = int(Contents[0])
					Losses = int(Contents[1]) + 1
					File.write(str(Wins) + ":" + str(Losses))
					File.close()
			elif Event.key == K_SPACE and not Selected:
				AutoSlot = True
				AddAction("AutoSlot")
			elif Event.key == K_c:
				OpenMenu()
			elif Event.key == K_d:
				OpenMenu(1)
			elif Event.key == K_b:
				OpenMenu(2)
			elif Event.key == K_m:
				OpenMenu(3)
			elif Event.key == K_h:
				OpenMenu(4)
			elif Event.key == K_a:
				Animation = not Animation
				Contents = ReadFile("Settings.txt")
				Contents["Animation"] = str(Animation)
				WriteFile("Settings.txt",Contents)
			
	if len(Slots[0]) + len(Slots[1]) + len(Slots[2]) + len(Slots[3]) == 52:
		End(True)
		AutoSlot = False
		
	
	if len(Hand) + len(Globals["Tab"]) == 0:
		if CheckForActions() == 0:
			Ticks += 1
			if Ticks > 10:
				End()
		else:
			Ticks = 0
		
	Renders()
	FinishRenders()
			
"""
local Over = false
local Runs = 0
local Hands = 0
local Lose = false
while not Over do
    local Done = false
    for I,P in pairs(Places) do
        if #P[2] == 0 then
            local C = P[1][#P[1]]
            table.insert(P[2],C)
            table.remove(P[1])
        end
    end
    local Action,Card = "",""
    for I,P in pairs(Places) do
        if #P[2] > 0 then
            if CanBeSlot(P[2][#P[2]]) then
                local card = P[2][#P[2]]
                SlotIt(P[2],card)
                Done = true
                Action = "Slot"
                Card = card
            end
            if not Done then
                local card = P[2][1]
                local Top = #P[1] == 0
                for A,B in pairs(Places) do
                    if I ~= A then
                        local IsEmpty = #B[1] == 0 and #B[2] == 0
                        if #B[2] > 0 then
                            if CanBePlaced(card,B[2][#B[2]],P[2],B[2],Top,IsEmpty) then
                                PlaceIt(P[2],B[2],card,B[2][#B[2]])
                                Done = true
                                Action = "Placement"
                                Card = card
                                break
                            end
                        else
                            if CanBePlaced(card,nil,P[2],B[2],Top,IsEmpty) then
                                PlaceIt(P[2],B[2],card,nil)
                                Done = true
                                Action = "PlacementKing"
                                Card = card
                                break
                            end
                        end 
                    end
                end
            end
        end   
        if Done then
            break
        end
    end
    if not Done and #Hand > 0 then
        local card = Hand[#Hand]
        if CanBeSlot(card) then
            SlotIt(Hand,card)
            Done = true
            Action = "HandSlot"
            Card = card
        end
        if not Done then
            for I,P in pairs(Places) do
                if #P[2] > 0 then
                    if CanBePlaced(card,P[2][#P[2]]) then
                        PlaceIt(Hand,P[2],card,P[2][#P[2]])
                        Action = "HandPlacement"
                        Card = card
                        Done = true
                        break
                    end
                else
                    if CanBePlaced(card,nil,nil,nil,nil,true) then
                        PlaceIt(Hand,P[2],card,nil)
                        Action = "HandPlacementKing"
                        Card = card
                        Done = true
                        break
                    end
                end
            end
        end
    end
    if not Done then
        if #Tab > 0 or #Hand > 0 then
            HandIt()
        else
            Lose = true
        end
        Action = "Hand"
        Card = "Hand"
        Hands = Hands + 1
        if Hands > 10 then
            Lose = true
        end
    else
        Hands = 0
    end
    print(Action..": "..Card)
    Runs = Runs + 1
    local Win = #Slots[1] + #Slots[2] + #Slots[3] + #Slots[4] == 52
    if Win or Lose then
        if Win then
            print("Congratulations! You have won the game!")
        else
            print("You have lost the game!")
        end
        Over = true
        print("Runs: "..Runs)
        print("Slots")
        PrintTable(Slots)
        print("Places")
        PrintTable(Places)
    end
end
"""