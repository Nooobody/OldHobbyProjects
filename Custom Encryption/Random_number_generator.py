import time,math
Seed = time.time()
Seed1 = time.time()
Seed2 = time.time()
Seed3 = time.time()
Seed4 = time.time()
def Round(Val):
	Frac,Int = math.modf(Val)
	if Frac >= 0.5:
		return math.ceil(Val)
	else:
		return math.floor(Val)

def Clamp(Val,Min,Max):
	if Val < Min:
		return Min
	elif Val > Max:
		return Max
	return Val
		
def Random1():
	global Seed1
	Num = float(((Seed1 ** 2) % (Seed1 * 0.25123491)) / (Seed1 / 3.9989612))
	Seed1 = Seed1 + Seed1 * Num
	if Seed1 > 10 ** 60:
		Seed1 = time.time()
	return Num
		
def Random2():
	global Seed2
	Num = float(((Seed2 ** 3) % (Seed2 * 0.25123101)) / (Seed2 / 3.9988612))
	Seed2 = Seed2 + Seed2 * Num
	if Seed2 > 10 ** 60:
		Seed2 = time.time()
	return Num
	
def Random3():
	global Seed3
	Num = float(((Seed3 ** 4) % (Seed3 * 0.25123519)) / (Seed3 / 3.9989012))
	Seed3 = Seed3 + Seed3 * Num
	if Seed3 > 10 ** 60:
		Seed3 = time.time()
	return Num
	
def Random4():
	global Seed4
	Num = float(((Seed4 ** 5) % (Seed4 * 0.25123009)) / (Seed4 / 3.9987561))
	Seed4 = Seed4 + Seed4 * Num
	if Seed4 > 10 ** 60:
		Seed4 = time.time()
	return Num

def RandomInc(Min,Max):
	global Seed
	Num = float(((Seed ** 3) % (Seed * 0.251234)) / (Seed / 3.9989123))
	Seed = Seed + Seed * Num
	if Seed > 10 ** 100:
		Seed = time.time()
	return Round((Num * (Max - Min)) + Min)	
	
def Random(Min = 0,Max = 1):
	global Seed
	Num1,Num2,Num3,Num4 = Random1(),Random2(),Random3(),Random4()
	"""Num = float(((Seed ** 3) % (Seed * 0.251234)) / (Seed / 3.9989123))"""
	Num = (Clamp((Num1 + Num2 + Num3 + Num4) / 4,0.3,0.7) - 0.3) / 0.4
	Inc = Num
	if Num == 0:
		Inc = RandomInc(0.1,0.9)
	Seed = Seed + Seed * Inc
	if Seed > 10 ** 60:
		Seed = time.time()
	return int(Round((Num * (Max - Min)) + Min))

while 1:
	Min = int(raw_input("Input the min value."))
	Max = int(raw_input("Input the max value."))
	Loop = int(raw_input("How many times should it loop?"))
	Int = 0
	for I in range(Loop):
		Int += Random(Min,Max)
	print(Int / Loop)
	"""
	Nums = []
	for I in range(0,Max + 1):
		Nums.append(0)
	
	for I in range(0,Loop):
		Num = int(Random(Min,Max))
		Nums[Num] += 1
		
	for N in range(Min,Max + 1):
		print(str(N) + ":" + str(Nums[N]))
		
	time.sleep(0.1)"""