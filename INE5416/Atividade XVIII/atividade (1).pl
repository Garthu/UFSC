distanciaEntrePontos2D(pontoEm2D(X1,Y1), pontoEm2D(X2,Y2), D) :- D is ((X1-X2)^2+(Y1-Y2)^2)^1/2.

colineares(pontoEm2D(X1,Y1),pontoEm2D(X2,Y2),pontoEm2D(X3,Y3),C) :- C is ((X1*(Y2-Y3))+(X2*(Y3-Y1))+(X3*(Y1-Y2))^1/2).

saoColineares(X1,Y1,X2,Y2,X3,Y3,S) :- (colineares(pontoEm2D(X1,Y1),pontoEm2D(X2,Y2),pontoEm2D(X3,Y3),C), C =:= 0).

eTriangulo(X1,Y1,X2,Y2,X3,Y3,E) :- (colineares(pontoEm2D(X1,Y1),pontoEm2D(X2,Y2),pontoEm2D(X3,Y3),C), C =\= 0).

/*
?- distanciaEntrePontos2D(pontoEm2D(1,4),pontoEm2D(3,5),D).
D = 2.5.

?- saoColineares(1,1,1,1,1,1,C).
true.

?- eTriangulo(1,4,3,5,3,6,C).
true.
*/