import math
from multiprocessing import Process,Pipe
from mpmath import mp
mp.dps = 3

def GetRGB(H):
	Col = 240
	Frac = Col / 21.0
	H = H % Col
	R = 0
	G = 0
	B = 0
	if H >= 0 and H < Frac:
		R = Col
		G = Col * (H / float(Frac))
	elif H >= Frac and H < Frac * 2:
		R = Col * (1 - ((H % Frac) / float(Frac)))
		G = Col
	elif H >= Frac * 2 and H < Frac * 3:
		G = Col
		B = Col * ((H % Frac) / float(Frac))
	elif H >= Frac * 3 and H < Frac * 4:
		G = Col * (1 - ((H % Frac) / float(Frac)))
		B = Col
	elif H >= Frac * 4 and H < Frac * 5:
		B = Col * (1 - ((H % Frac) / float(Frac)))
		G = (Col / 2) * ((H % Frac) / float(Frac))
		R = Col * ((H % Frac) / float(Frac))
	elif H >= Frac * 5 and H < Frac * 6:
		B = Col * ((H % Frac) / float(Frac))
		G = Col / 2
		R = Col * (1 - ((H % Frac) / float(Frac)))
	elif H >= Frac * 6 and H < Frac * 7:
		R = Col * ((H % Frac) / float(Frac))
		G = (Col / 2) * (1 - ((H % Frac) / float(Frac)))
		B = Col
	elif H >= Frac * 7 and H < Frac * 8:
		R = Col
		B = Col * (1 - ((H % Frac) / float(Frac)))
	elif H >= Frac * 8 and H < Frac * 9:
		R = Col * (1 - ((H % Frac) / float(Frac)))
		G = Col * ((H % Frac) / float(Frac))
	elif H >= Frac * 9 and H < Frac * 10:
		G = Col * (1 - ((H % Frac) / float(Frac)))
		B = Col * ((H % Frac) / float(Frac))
	elif H >= Frac * 10 and H < Frac * 11:
		B = Col * (1 - ((H % Frac) / float(Frac)))
		R =	Col * ((H % Frac) / float(Frac))
		G = Col * ((H % Frac) / float(Frac))
	elif H >= Frac * 11 and H < Frac * 12:
		G = Col * (1 - ((H % Frac) / float(Frac)))
		R = Col
		B = Col * ((H % Frac) / float(Frac))
	elif H >= Frac * 12 and H < Frac * 13:
		R = Col
		B = Col * (1 - ((H % Frac) / float(Frac)))
	elif H >= Frac * 13 and H < Frac * 14:
		R = Col * (1 - ((H % Frac) / float(Frac)))
		G = Col * ((H % Frac) / float(Frac))
		B = Col * ((H % Frac) / float(Frac))
	elif H >= Frac * 14 and H < Frac * 15:
		G = Col * (1 - ((H % Frac) / float(Frac)))
		B = Col
		R = (Col / 2) * ((H % Frac) / float(Frac))
	elif H >= Frac * 15 and H < Frac * 16:
		B = Col * (1 - ((H % Frac) / float(Frac)))
		R = (Col / 2) + (Col / 2) * ((H % Frac) / float(Frac))
	elif H >= Frac * 16 and H < Frac * 17:
		R = Col
		G = Col * ((H % Frac) / float(Frac))
		B = Col * ((H % Frac) / float(Frac))
	elif H >= Frac * 17 and H < Frac * 18:
		R = Col * (1 - ((H % Frac) / float(Frac)))
		G = Col * (1 - ((H % Frac) / float(Frac)))
		B = Col - (Col / 2) * ((H % Frac) / float(Frac))
	elif H >= Frac * 18 and H < Frac * 19:
		R = ((Col / 4) * 3) * ((H % Frac) / float(Frac))
		G = Col * ((H % Frac) / float(Frac))
		B = Col / 2
	elif H >= Frac * 19 and H < Frac * 20:
		R = ((Col / 4) * 3) + (Col / 4) * ((H % Frac) / float(Frac))
		G = Col
		B = (Col / 2) + (Col / 2) * ((H % Frac) / float(Frac))
	elif H >= Frac * 20 and H < Frac * 21:
		R = Col
		G = Col * (1 - ((H % Frac) / float(Frac)))
		B = Col * (1 - ((H % Frac) / float(Frac)))
	return (R,G,B)

XMag = 3
XStart = -2
def XZoom(X):
	return X * XMag + XStart

YMag = 2
YStart = -1
def YZoom(Y):
	return Y * YMag + YStart

def M(Conn):
	while True:
		Result = Conn.recv()
		A,Max,MaxEsc,X,Y,Level,DPS = Result[0],Result[1],Result[2],Result[3],Result[4],Result[5],Result[6]
		mp.dps = DPS
		Iter = 0
		B = 0
		while True:
			B = B ** 2 + A
			Iter += 1
			if abs(B) > 2: break
			if Iter > Max: break

		Col = (0,0,0)
		if Iter < Max:
			B = B ** 2 + A
			Iter += 1
			Iter = Iter + 1 - math.log(math.log(abs(B))) / math.log(2)
			Col = GetRGB(Iter)
		Conn.send((Col,(X,Y),Level))

if __name__ == "__main__":
	from pygame.locals import *
	from types import *
	import pygame,sys,time

	def Clamp(Value,Min,Max = False):
		if Value < Min:
			return Min
		if Max and Value > Max:
			return Max
		return Value

	def GetZeros(Num):
		Str = str(Num)
		if Str[0] != "0":
			E = Str.split("-")
			if len(E) > 1:
				return int(E[1])
			else:
				return 0
		else:
			Zeros = 0
			for L in Str:
				if L != "." and int(L) == 0:
					Zeros += 1
				elif L != "." and int(L) != 0:
					return Zeros

	def GetTime():
		T = time.asctime()
		T = T.split(":")
		T = T[0] + "_" + T[1] + "_" + T[2]
		return T

	Processes = []
	for I in range(4):
		Parent,Child = Pipe()
		P = Process(target = M,args = (Child,))
		P.name = "Rendering core #" + str(I + 1)
		P.start()
		Processes.append({"Process" : P,"Pipe" : Parent,"InUse" : False})

	Sets = []
	Width,Height = 1920,1080
	Screen = pygame.display.set_mode((Width,Height))
	Screen.fill((0,0,0))
	BG = pygame.Surface((Width,Height))
	Level = 0
	Int = 0
	Max = 10000
	MaxEsc = 3

	Start = [0,0]
	Star = [0,0]
	End = [0,0]
	En = [0,0]
	MBD = False
	Respon = False
	CoresUsed = 4
	while True:
		for Event in pygame.event.get():
			if Event.type == QUIT:
				pygame.quit()
				for P in Processes:
					P["Process"].terminate()
				sys.exit()
			elif Event.type == MOUSEMOTION and MBD:
				En = Event.pos
				W,H = Clamp(En[0] - Star[0],1),Clamp(En[1] - Star[1],1)
			elif Event.type == MOUSEBUTTONDOWN:
				if Event.button == 1 and not Respon:
					Star = Event.pos
					Start = (XZoom(Event.pos[0] / mp.mpf(Width)),YZoom(Event.pos[1] / mp.mpf(Height)))
					MBD = True
				elif Event.button == 4 and len(Sets) > Level + 1:
					if len(Sets) < Level + 1:
						Sets.append(False)
					Sets[Level] = {"Coords" : (XStart,YStart,XMag,YMag),"Int" : Int,"BG" : BG,"Saved" : Int >= Width * Height}
					Level += 1
					Set = Sets[Level]
					Coords = Set["Coords"]
					XStart = Coords[0]
					YStart = Coords[1]
					XMag = Coords[2]
					YMag = Coords[3]
					mp.dps = GetZeros(XMag) + 3
					Int = Set["Int"]
					BG = Set["BG"]
					Respon = False
					MBD = False
					Star = [0,0]
					En = [0,0]
				elif Event.button == 5 and Level > 0:
					if len(Sets) < Level + 1:
						Sets.append(False)
					Sets[Level] = {"Coords" : (XStart,YStart,XMag,YMag),"Int" : Int,"BG" : BG,"Saved" : Int >= Width * Height}
					Level -= 1
					Set = Sets[Level]
					Coords = Set["Coords"]
					XStart = Coords[0]
					YStart = Coords[1]
					XMag = Coords[2]
					YMag = Coords[3]
					mp.dps = GetZeros(XMag) + 3
					Int = Set["Int"]
					BG = Set["BG"]
					Respon = False
					MBD = False
					Star = [0,0]
					En = [0,0]
			elif Event.type == MOUSEBUTTONUP and MBD and not Respon:
				En = Event.pos
				End = (XZoom(Event.pos[0] / mp.mpf(Width)),YZoom(Event.pos[1] / mp.mpf(Height)))
				print("Start: " + str((float(Start[0]),float(Start[1]))))
				print("End: " + str((float(End[0]),float(End[1]))))
				print("XMag: " + str(float(End[0] - Start[0])))
				print("YMag: " + str(float(End[1] - Start[1])))
				print("Are you sure? y/n")
				MBD = False
				Respon = True
			elif Event.type == KEYDOWN:
				if Respon:
					if Event.key == K_y:
						if len(Sets) < Level + 1:
							Sets.append(False)
						Sets[Level] = {"Coords" : (XStart,YStart,XMag,YMag),"Int" : Int,"BG" : BG,"Saved" : Int >= Width * Height}
						Level += 1
						XMag = End[0] - Start[0]
						XStart = Start[0]
						YMag = End[1] - Start[1]
						YStart = Start[1]
						mp.dps = GetZeros(XMag) + 3
						Star = [0,0]
						En = [0,0]
						Int = 0
						BG = pygame.Surface((Width,Height))
						Respon = False
						print("Zooming...")
					elif Event.key == K_n:
						Start = [0,0]
						End = [0,0]
						Star = [0,0]
						En = [0,0]
						Respon = False
						print("Declining zoom request.")
				elif Event.key == K_KP_PLUS:
					CoresUsed = Clamp(CoresUsed + 1,0,8)
					print("Core count has been increased to " + str(CoresUsed))
				elif Event.key == K_KP_MINUS:
					CoresUsed = Clamp(CoresUsed - 1,0,8)
					print("Core count has been decreased to " + str(CoresUsed))

		Screen.blit(BG,(0,0))
		if MBD or Respon:
			W,H = Clamp(En[0] - Star[0],1),Clamp(En[1] - Star[1],1)
			Bx = pygame.Surface((W,H),SRCALPHA)
			pygame.draw.rect(Bx,(255,255,255),(0,0,W,H),1)
			Screen.blit(Bx,Star)
		pygame.display.flip()
		if CoresUsed > 0:
			if Int < Width * Height:
				for I,Pro in enumerate(Processes):
					if I < CoresUsed and not Pro["InUse"]:
						X = Int % Width
						X0 = XZoom(X / mp.mpf(Width))
						Y = math.floor(Int / mp.mpf(Width))
						Y0 = YZoom(Y / mp.mpf(Height))
						Int += 1
						P = math.sqrt(((X0 - (1.0/4.0)) ** 2) + (Y0 ** 2))
						C = mp.mpc(X0,Y0)
						if X0 < P - 2 * (P ** 2) + (1.0 / 4.0) or (X0 + 1) ** 2 + Y0 ** 2 < (1.0 / 16.0):
							pass
						else:
							Pro["Pipe"].send((C,Max,MaxEsc,X,Y,Level,mp.dps))
							Pro["InUse"] = True
			else:
				for I,Pro in enumerate(Processes):
					if I < CoresUsed and not Pro["InUse"]:
						for i in range(len(Sets)):
							Set = Sets[len(Sets) - 1 - i]
							if Set["Int"] < Width * Height:
								OldD = mp.dps
								mp.dps = GetZeros(Set["Coords"][2]) + 3
								Oldies = (XStart,YStart,XMag,YMag)
								XStart = Set["Coords"][0]
								YStart = Set["Coords"][1]
								XMag = Set["Coords"][2]
								YMag = Set["Coords"][3]
								X = Set["Int"] % Width
								X0 = XZoom(X / mp.mpf(Width))
								Y = math.floor(Set["Int"] / mp.mpf(Width))
								Y0 = YZoom(Y / mp.mpf(Height))
								Set["Int"] += 1
								P = math.sqrt(((X0 - (1.0/4.0)) ** 2) + (Y0 ** 2))
								C = mp.mpc(X0,Y0)
								XStart = Oldies[0]
								YStart = Oldies[1]
								XMag = Oldies[2]
								YMag = Oldies[3]
								mp.dps = OldD
								if X0 < P - 2 * (P ** 2) + (1.0 / 4.0) or (X0 + 1) ** 2 + Y0 ** 2 < (1.0 / 16.0):
									pass
								else:
									Pro["Pipe"].send((C,Max,MaxEsc,X,Y,len(Sets) - 1 - i,GetZeros(Set["Coords"][2]) + 3))
									Pro["InUse"] = True
									break



		for P in Processes:
			if P["Pipe"].poll():
				Res = P["Pipe"].recv()
				P["InUse"] = False
				if Res[2] != Level:
					Set = Sets[Res[2]]
					Pic = Set["BG"]
					Surf = pygame.Surface((1,1))
					Surf.fill(Res[0])
					Pic.blit(Surf,Res[1])
					Sets[Res[2]]["BG"] = Pic
					if Res[1][0] == Width - 1 and Res[1][1] == Height - 1 and Res[2] > 0 and not Set["Saved"]:
						Set["Saved"] = True
						Time = GetTime()
						pygame.image.save(Pic,"Fractals/" + Time + ".png")
						print("A fractal has been saved as " + Time + ".png")
				else:
					Surf = pygame.Surface((1,1))
					Surf.fill(Res[0])
					BG.blit(Surf,Res[1])
					if Res[1][0] == Width - 1 and Res[1][1] == Height - 1 and Res[2] > 0 and not Set["Saved"]:
						Set["Saved"] = True
						Time = GetTime()
						pygame.image.save(BG,"Fractals/" + Time + ".png")
						print("A fractal has been saved as " + Time + ".png")
