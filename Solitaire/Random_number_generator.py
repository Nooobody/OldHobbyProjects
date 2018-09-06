import time,math
Seed = time.time()
def Round(Val):
	Frac,Int = math.modf(Val)
	if Frac >= 0.5:
		return math.ceil(Val)
	else:
		return math.floor(Val)

def Random(Min = 0,Max = 1):
	global Seed
	Num = float(((Seed ** 3) % (Seed * 0.251234)) / (Seed / 3.9989123))
	Seed = Seed + Seed * Num
	if Seed > 10 ** 100:
		Seed = time.time()
	return int(Round((Num * (Max - Min)) + Min))

#while 1:
#	Min = int(raw_input("Input the min value."))
#	Max = int(raw_input("Input the max value."))
#	Loop = int(raw_input("How many times should it loop?"))
#	Nums = []
#	for I in range(0,Max + 1):
#		Nums.append(0)
#		
#	for I in range(0,Loop):
#		Num = int(Random(Min,Max))
#		Nums[Num] += 1
#		
#	for N in range(Min,Max + 1):
#		print(str(N) + ":" + str(Nums[N]))
#		
#	time.sleep(0.1)