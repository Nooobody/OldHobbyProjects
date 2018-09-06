from Random_number_generator import Random
LettersNumbers = [[1,[]],[2,[]],[3,[]],[4,[]],[5,[]],[6,[]],[7,[]],[8,[]],[9,[]],[0,[]],["a",[]],["b",[]],["c",[]],["d",[]],["e",[]],["f",[]],["g",[]],["h",[]],["i",[]],["j",[]],["k",[]],["l",[]],["m",[]],["n",[]],["o",[]],["p",[]],["q",[]],["r",[]],["s",[]],["t",[]],["u",[]],["v",[]],["w",[]],["x",[]],["y",[]],["z",[]]]
import string,math,random,os
Numbers = []
for I in range(10,100):
	Numbers.append(I)
Letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
Pairs = []
for L in range(0,len(Letters)):
	for l in range(0,len(Letters)):
		if l != L:
			Pairs.append(Letters[L] + Letters[l])
Nums = []
for I in range(0,10):
	Nums.append(I)
for I in Letters:
	for N in Nums:
		Pairs.append(I + str(N))
		Pairs.append(str(N) + I)
Combs = []
for L in Pairs:
	Combs.append(L)
for N in Numbers:
	Combs.append(N)
for L in LettersNumbers:
	Lets = random.sample(Combs,104)
	L[1] = Lets
	for I in range(0,104):
		Combs.remove(Lets[I])
for N in Combs:
	Tab = random.choice(LettersNumbers)
	Tab[1].append(N)

F = open(os.path.join("Encrypted.txt"),"w")
F.write(str(LettersNumbers))
Errors = []
for I in LettersNumbers:
	for A in I[1]:
		for i in LettersNumbers:
			if I[0] != i[0]:
				for a in i[1]:
					if A == a:
						Errors.append([I[0],i[0],A,a])
print(str(Errors))
print("Errors: " + str(len(Errors)))
raw_input("")
Errors = 0
for P in range(0,len(Combs)):
	for I in range(0,len(Combs)):
		if P != I:
			if Combs[P] == Combs[I]:
				Errors += 1
print("Errors: " + str(Errors))
raw_input("")