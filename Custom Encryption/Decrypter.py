import random,os,string
F = open(os.path.join("Encrypted.txt"),"r")
LettersNumbers = eval(F.read())

while 1:
	Txt = raw_input("")
	List = Txt.split(" ")
	Words = []
	for W in List:
		Decrypted = ""
		I = 0
		while I < len(W):
			Found = False
			for L in string.ascii_letters:
				if W[I] == L:
					Found = True
			if not Found:
				for N in string.digits:
					if W[I] == str(N):
						Found = True
			if Found:
				Str = str(W[I]) + str(W[I + 1])
				I += 2
				Found = False
				for N in LettersNumbers:
					if not Found:
						for C in N[1]:
							if Str == str(C):
								Found = True
								Decrypted = Decrypted + str(N[0])
								break
					if Found:
						break
			else:
				Decrypted = Decrypted + W[I]
				I += 1
		Words.append(Decrypted)
	Decrypted = " ".join(Words)
	print(Decrypted)