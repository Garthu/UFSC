:- use_module(library(clpfd)).

%Define uma restrição para cada elemento do suguru
%Recebe um elemento da matriz de input e um elemento
%da matriz de limites e associa os dois.

mapFuncLimite(ElementoMatrizEntrada, ElementoMatrizLimites) :-
    ElementoMatrizEntrada in 1..ElementoMatrizLimites.

%Filtra elementos de um vetor
%Recebe elementos de um vetor mapeado onde há
%números -1 ou qualquer outro valor.
%Retorna true se o elemento atual for diferente de -1.

filtro(Retorno) :-
    (number(Retorno)
        -> Retorno =\= -1
    ; true).

%Recebe um elemento da matriz de entrada, um elemento
%da matriz de região correspondente e um ID da região.
%Se o elemento da matriz de região for igual
%ao ID da região retorna o elemento da matriz de entrada
%caso contrario retorna -1.

mapFuncRegiao(RegiaoID,ElementoMatrizEntrada,ElementoMatrizRegiao,Retorno):-
    (ElementoMatrizRegiao == RegiaoID
        -> Retorno = ElementoMatrizEntrada
        ; Retorno is -1).

%Recebe um vetor da matriz de entrada, um vetor da matriz de região
%e um ID da região.
%Faz um filtro do vetor da matriz de entrada para conter apenas os valores
%da região com o ID da região.
%Com esse filtro define um bloco onde é aplicado uma restrição
%Todos os elementos desse bloco precisam ter valores diferentes.

mapFuncBlockRegiao(VetorEntrada,VetorRegiao,RegiaoID) :-
    maplist(mapFuncRegiao(RegiaoID),VetorEntrada,VetorRegiao, MapReturn),
    include(filtro, MapReturn, FilterReturn),
    all_distinct(FilterReturn),
    true.

%Recebe a matriz de entrada como input, percorre duplas de linhas
%e chama a função blockLines para cada dupla de linhas.
%Como exemplo, formam blocos de linhas:
%[A,B], [B,C], [C,D]... A segunda linha da dupla é a primeira linha
%da proxima dupla.

blockMatriz([]).
blockMatriz([_]).
blockMatriz([N1,N2|Na]) :-
    blockLines(N1, N2),
    blockMatriz([N2|Na]).

%Recebe duas linhas sequenciais da matriz de entrada como input.
%Define que os 2 primeiros elementos de cada linha tenham valores diferentes.
%Como exemplo, sejam as linhas P = [A,B,C] e Q = [D,E,F]:
%Os blocos [A,B,D,E], [B,C,E,F] terão valores diferentes.

blockLines([],[]).
blockLines([N1,N2], [N3,N4]) :- 
    all_distinct([N1,N2,N3,N4]).
blockLines([N1,N2|Na], [N3,N4|Nb]) :-
    all_distinct([N1,N2,N3,N4]),
    blockLines([N2|Na], [N4|Nb]).

%Recebe uma matriz de Entrada, uma matriz de Regiao e uma matriz de Limites.
%Utiliza restrições para definir os valores possiveis em cada elemento da matriz
%de entrada, utilizando a matriz de limites para definir o valor máximo possivel.
%A matriz de região é utilizada para definir blocos onde os valores precisam ser diferentes.

solve(MatrizEntrada, MatrizRegiao, MatrizLimites) :-
    append(MatrizEntrada, VetorEntrada),
    append(MatrizRegiao, VetorRegiao),
    Regiao = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21],
    maplist(mapFuncBlockRegiao(VetorEntrada,VetorRegiao), Regiao),
    maplist(maplist(mapFuncLimite), MatrizEntrada, MatrizLimites),
    blockMatriz(MatrizEntrada),
    
    write(MatrizEntrada),
    !.


%8x8
entrada8([[_,_,_,3,_,_,2,_],
         [4,_,_,_,_,_,_,_],
         [_,2,_,_,_,_,_,_],
         [_,1,5,_,_,1,5,_],
         [_,2,_,_,_,_,_,_],
         [_,_,_,_,4,_,_,4],
         [_,_,_,_,_,3,_,_],
         [_,5,_,_,_,5,_,_]]).


regiao8([[0,0,0,3,4,4,5,5],
         [0,2,2,3,4,4,5,5],
         [2,2,3,3,4,6,6,5],
         [2,7,7,3,8,8,6,6],
         [10,10,7,7,8,9,9,6],
         [11,10,10,7,8,13,9,9],
         [11,11,10,12,8,13,13,9],
         [11,11,12,12,12,12,13,13]]).

limites8([[4,4,4,5,5,5,5,5],
    [4,5,5,5,5,5,5,5],
    [5,5,5,5,5,5,5,5],
    [5,5,5,5,5,5,5,5],
    [5,5,5,5,5,5,5,5],
    [5,5,5,5,5,5,5,5],
    [5,5,5,5,5,5,5,5],
    [5,5,5,5,5,5,5,5]]).

%7x7

%6x6

%5x5

entrada5([[_,_,4,_,_],
         [4,_,_,_,4],
         [_,_,_,_,3],
         [1,_,_,_,_],
         [_,_,_,_,_]]).

regiao5([[0,0,1,4,4],
         [0,1,1,1,4],
         [0,2,1,5,4],
         [3,2,2,5,4],
         [3,2,5,5,5]]).

limites5([[4,4,5,5,5],
         [4,5,5,5,5],
         [4,4,5,5,5],
         [2,4,4,5,5],
         [2,4,5,5,5]]).
