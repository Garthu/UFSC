# -*- coding: utf -8 -*-
p1 = input()
x1, y1 = p1.split()
x1 = float(x1)
y1 = float(y1)
p2 = input()
x2, y2 = p2.split()
x2 = float(x2)
y2 = float(y2)
print("%.4f" % (((x2 - x1) ** 2 + (y2 - y1) ** 2) ** 0.5))