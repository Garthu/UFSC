# -*- coding: utf-8 -*-
V = int(input())
n = 0
while V != 0:
    I = (V // 50)
    J = ((V % 50) // 10)
    K = ((V % 10) // 5)
    L = ((V % 5) // 1)
    n = n + 1
    print("Teste %d" % (n))
    print("%d %d %d %d" % ((I), (J), (K), (L)))
    print()
    V = int(input())