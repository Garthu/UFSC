A, B, C = input().split()
A = int(A)
B = int(B)
C = int(C)
trigo = A
ovo = B
colheres = C
qt = 0
for i in range(1, 101):
    if trigo // 2 != 0:
        trigo = trigo - 2
        if ovo // 3 != 0:
            ovo = ovo - 3
            if colheres // 5 != 0:
                colheres = colheres - 5
                qt = qt + 1
print(qt)