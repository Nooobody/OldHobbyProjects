import random,os
F = open(os.path.join("Encrypted.txt"),"r")
LettersNumbers = eval(F.read())

while 1:
	Txt = list(raw_input(""))
	Encrypted = ""
	for I in Txt:
		Found = False
		for N in LettersNumbers:
			if I.isdigit():
				if N[0] == int(I):
					Found = True
					Encrypted = Encrypted + str(random.choice(N[1]))
					break
			if not I.isdigit():
				if N[0] == I.lower():
					Found = True
					Encrypted = Encrypted + str(random.choice(N[1]))
					break
		if not Found:
			Encrypted = Encrypted + I
	print(Encrypted)
	F = open(os.path.join("Encryptext.txt"),"w")
	F.write(Encrypted)
	F.close()