N = int(input())
while N != 0:
	for i in range(0, N):
		v = input().split()
		g = []
		for i in range(0, 5):
			v[i] = int(v[i])
		for i in range(0, 5):
			if (v[i]) <= 127:
				if i == 0:
					g.append("A")
				elif i == 1:
					g.append("B")
				elif i == 2:
					g.append("C")
				elif i == 3:
					g.append("D")
				elif i == 4:
					g.append("E")
		if len(g) > 1 or len(g) < 1:
			print("*")
		else:
			print(g[0])

	N = int(input())