import pygame,os,base64,pickle
from types import *
from pygame.locals import *

NumOrder = {"A" : 0,"2" : 1,"3" : 2,"4" : 3,"5" : 4,"6" : 5,"7" : 6,"8" : 7,"9" : 8,"T" : 9,"J" : 10,"Q" : 11,"K" : 12}
ConOrder = {"H" : 0,"S" : 1,"C" : 2,"D" : 3}

Cards = ["SA","S2","S3","S4","S5","S6","S7","S8","S9","ST","SJ","SQ","SK",
         "DA","D2","D3","D4","D5","D6","D7","D8","D9","DT","DJ","DQ","DK",
         "CA","C2","C3","C4","C5","C6","C7","C8","C9","CT","CJ","CQ","CK",
         "HA","H2","H3","H4","H5","H6","H7","H8","H9","HT","HJ","HQ","HK"]
Pos = { "2" : [(40,60),(40,120)],
		"3" : [(40,40),(40,90),(40,140)],
		"4" : [(25,40),(55,40),(25,140),(55,140)],
		"5" : [(25,40),(55,40),(25,140),(55,140),(40,90)],
		"6" : [(25,40),(25,90),(25,140),(55,40),(55,90),(55,140)],
		"7" : [(25,40),(25,90),(25,140),(55,40),(55,90),(55,140),(40,60)],
		"8" : [(25,40),(25,90),(25,140),(55,40),(55,90),(55,140),(40,60),(40,120)],
		"9" : [(25,20),(25,65),(25,110),(25,155),(55,20),(55,65),(55,110),(55,155),(40,85)],
		"T" : [(25,20),(25,65),(25,110),(25,155),(55,20),(55,65),(55,110),(55,155),(40,40),(40,130)],
		"J" : [(0,0)],
		"Q" : [(0,0)],
		"K" : [(0,0)]}

Elements = pygame.image.load("Pics/Pic.png")
Numbers = []
for I in range(13):
	Numbers.append(Elements.subsurface(I * 20,0,20,20))

Countries = []
for I in range(4):
	Countries.append(Elements.subsurface(20 * I,20,20,20))

Blank = pygame.Surface((100,200),SRCALPHA)
pygame.draw.circle(Blank,(0,0,0),(20,20),20,1)
pygame.draw.circle(Blank,(0,0,0),(20,180),20,1)
pygame.draw.circle(Blank,(0,0,0),(80,20),20,1)
pygame.draw.circle(Blank,(0,0,0),(80,180),20,1)
pygame.draw.circle(Blank,(255,255,255),(20,20),19,0)
pygame.draw.circle(Blank,(255,255,255),(20,180),19,0)
pygame.draw.circle(Blank,(255,255,255),(80,20),19,0)
pygame.draw.circle(Blank,(255,255,255),(80,180),19,0)
pygame.draw.rect(Blank,(255,255,255),(20,0,60,200))
pygame.draw.rect(Blank,(255,255,255),(0,20,100,160))
pygame.draw.line(Blank,(0,0,0),(20,0),(80,0))
pygame.draw.line(Blank,(0,0,0),(0,20),(0,180))
pygame.draw.line(Blank,(0,0,0),(20,199),(80,199))
pygame.draw.line(Blank,(0,0,0),(99,20),(99,180))

def ReadFile(file):
	File = open(os.path.join(file),"r+")
	Decoded = base64.b64decode(File.read())
	Unpickled = pickle.loads(Decoded)
	File.close()
	return Unpickled
	
Contents = ReadFile("Settings.txt")

def CheckRed(Card):
	if Card[0] == "H" or Card[0] == "D":
		return True
	else:
		return False

def ColorNumberRed(Num):
	for X in range(20):
		for Y in range(20):
			if Num.get_at((X,Y))[0] == 0:
				Num.set_at((X,Y),(255,0,0))
	return Num

def CreateACard(Card):
	Copy = Blank.copy()
	Num = Numbers[NumOrder[Card[1]]]
	Con = Countries[ConOrder[Card[0]]]
	if CheckRed(Card):
		Num = ColorNumberRed(Num.copy())
		
	Copy.blit(Num,(2,18))
	Copy.blit(Con,(2,38))
	Copy.blit(pygame.transform.flip(Num,True,True),(78,162))
	Copy.blit(pygame.transform.flip(Con,True,True),(78,142))
	Contents = ReadFile("Settings.txt")
	Cover = pygame.image.load("Pics/" + Contents["Deck"] + "/" + Card[1] + Card[0] + ".png")
	Copy.blit(Cover,(20,30))
	pygame.image.save(Copy,"Pics/" + Card[0] + Card[1] + ".png")
	return Copy
	
for P in Cards:
	Copy = Blank.copy()
	Num = Numbers[NumOrder[P[1]]]
	Con = Countries[ConOrder[P[0]]]
	if CheckRed(P):
		Num = ColorNumberRed(Num.copy())
		
	Copy.blit(Num,(2,18))
	Copy.blit(Con,(2,38))
	Copy.blit(pygame.transform.flip(Num,True,True),(78,162))
	Copy.blit(pygame.transform.flip(Con,True,True),(78,142))
	
	if P[1] == "A":
		Copy.blit(pygame.transform.scale(Con,(60,60)),(20,70))
	elif Pos[P[1]]:
		if P[1] == "J" or P[1] == "Q" or P[1] == "K":
			Cover = pygame.image.load("Pics/" + Contents["Deck"] + "/" + P[1] + P[0] + ".png")
			Copy.blit(Cover,(20,30))
		else:
			for Po in Pos[P[1]]:
				if Po[1] >= 100:
					Copy.blit(pygame.transform.flip(Con,False,True),Po)
				else:
					Copy.blit(Con,Po)
	pygame.image.save(Copy,"Pics/" + P + ".png")