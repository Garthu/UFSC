% Camisetas
camiseta(amarela).
camiseta(azul).
camiseta(branco).
camiseta(verde).
camiseta(vermelha).

% Nomes
nome(cicero).
nome(getulio).
nome(joao).
nome(paulo).
nome(sidney).

% Profissões
profissao(carteiro).
profissao(inspetor).
profissao(jardineiro).
profissao(metalurgico).
profissao(pedreiro).

% Idades
idade(29).
idade(34).
idade(41).
idade(46).
idade(53).

% Estados
estado(amapa).
estado(maranhao).
estado(matoGrosso).
estado(parana).
estado(saoPaulo).

% Transportes
transporte(bicicleta).
transporte(carro).
transporte(metro).
transporte(onibus).
transporte(trem).

% Verifica se todos os valores de uma lista são diferentes
% ele faz isso tirando a cabeça da lista e verificando se
% ele faz parte da cauda da lista
todosDiferentes([]).
todosDiferentes([H|T]) :- not(member(H,T)), todosDiferentes(T).

% Verifica se elemento está à esquerda
% usando como base o índice de dois elementos
% dentro da lista
aEsquerda(X,Y,Lista) :- nth0(XIndex,Lista,X), 
                        nth0(YIndex,Lista,Y), 
                        XIndex < YIndex.

% Verifica se elemento está à direita
% usando como base o índice de dois elementos
% dentro da lista
aDireita(X,Y,Lista) :-  nth0(XIndex,Lista,X), 
                        nth0(YIndex,Lista,Y), 
                        XIndex > YIndex.

% Verifica se o 3 elemento enviado tem o índice
% entre os índices de X e de Y
entre(X,Y,Z,Lista) :-   nth0(XIndex,Lista,X), 
                        nth0(YIndex,Lista,Y),
                        nth0(ZIndex,Lista,Z), 
                        XIndex < ZIndex, YIndex > ZIndex.

% X está do lado de Y
doLado(X,Y,Lista) :- nextto(Y,X,Lista);
                     nextto(X,Y,Lista).

% X está na ponta da Lista
ponta(X,Lista) :- last(Lista,X).
ponta(X,[X|_]).

solucao(ListaSolucao) :-
    ListaSolucao = [
                   trabalhador(Camiseta1,Nome1,Profissao1,Idade1,Estado1,Transporte1),
                   trabalhador(Camiseta2,Nome2,Profissao2,Idade2,Estado2,Transporte2),
                   trabalhador(Camiseta3,Nome3,Profissao3,Idade3,Estado3,Transporte3),
                   trabalhador(Camiseta4,Nome4,Profissao4,Idade4,Estado4,Transporte4),
                   trabalhador(Camiseta5,Nome5,Profissao5,Idade5,Estado5,Transporte5)
                   ],
    
    % Paulo está em algum lugar entre João e Getúlio, nessa ordem.
    entre(trabalhador(_,joao,_,_,_,_),trabalhador(_,getulio,_,_,_,_),trabalhador(_,paulo,_,_,_,_),ListaSolucao),
    
    % O homem de Branco está em algum lugar à esquerda do homem de 34 anos.
    aEsquerda(trabalhador(branco,_,_,_,_,_),trabalhador(_,_,_,34,_,_),ListaSolucao),
    
    % Sidney está ao lado do trabalhador de São Paulo.
    doLado(trabalhador(_,sidney,_,_,_,_),trabalhador(_,_,_,_,saoPaulo,_),ListaSolucao),
    
    % O homem de Amarelo está em algum lugar à esquerda de Cícero.
    aEsquerda(trabalhador(amarela,_,_,_,_,_),trabalhador(_,cicero,_,_,_,_),ListaSolucao),
    
    % O trabalhador mais novo está exatamente à direita de quem foi de Carro.
    doLado(trabalhador(_,_,_,29,_,_),trabalhador(_,_,_,_,_,carro),ListaSolucao),
    aDireita(trabalhador(_,_,_,29,_,_),trabalhador(_,_,_,_,_,carro),ListaSolucao),
    
    % O Metalúrgico está em algum lugar à direita do homem de Azul.
    aDireita(trabalhador(_,_,metalurgico,_,_,_),trabalhador(azul,_,_,_,_,_),ListaSolucao),
    
    % O trabalhador do MA está em algum lugar entre o trabalhador de 53 anos e o trabalhador do centro-oeste, nessa ordem.
    aEsquerda(trabalhador(_,_,_,53,_,_),trabalhador(_,_,_,_,maranhao,_),ListaSolucao),
    aEsquerda(trabalhador(_,_,_,_,maranhao,_),trabalhador(_,_,_,_,matoGrosso,_),ListaSolucao),
    
    % Quem foi de Bicicleta está em uma das pontas.
    ponta(trabalhador(_,_,_,_,_,bicicleta),ListaSolucao),
    
    % Getúlio e Cícero estão lado a lado.
    doLado(trabalhador(_,getulio,_,_,_,_),trabalhador(_,cicero,_,_,_,_),ListaSolucao),
    
    % O homem do Mato Grosso está ao lado do homem de 34 anos.
    doLado(trabalhador(_,_,_,_,matoGrosso,_),trabalhador(_,_,_,34,_,_),ListaSolucao),
    
    % O trabalhador de Branco está em algum lugar à esquerda de quem foi de Ônibus.
    aEsquerda(trabalhador(branco,_,_,_,_,_),trabalhador(_,_,_,_,_,onibus),ListaSolucao),
    
    % O trabalhador do Amapá tem 29 anos. O homem de 29 anos foi de Bicicleta.
    member(trabalhador(_,_,_,29,amapa,bicicleta),ListaSolucao),
    
    % Paulo está ao lado de Sidney.
    doLado(trabalhador(_,paulo,_,_,_,_),trabalhador(_,sidney,_,_,_,_),ListaSolucao),
    
    % Os homens de Amarelo e Verde estão lado a lado.
    doLado(trabalhador(amarela,_,_,_,_,_),trabalhador(verde,_,_,_,_,_),ListaSolucao),
    
    % O trabalhador de 41 anos está em algum lugar entre o trabalhador do Paraná e o trabalhador de 46 anos, nessa ordem.
    aEsquerda(trabalhador(_,_,_,_,parana,_),trabalhador(_,_,_,41,_,_),ListaSolucao),
    aEsquerda(trabalhador(_,_,_,41,_,_),trabalhador(_,_,_,46,_,_),ListaSolucao),
    
    % O trabalhador de São Paulo está em algum lugar à direita do trabalhador de Branco.
    aDireita(trabalhador(_,_,_,_,saoPaulo,_),trabalhador(branco,_,_,_,_,_),ListaSolucao),
    
    % O Pedreiro foi de Trem.
    member(trabalhador(_,_,pedreiro,_,_,trem),ListaSolucao),
    
    % O homem de Branco está em algum lugar entre o Inspetor e quem foi de Bicicleta, nessa ordem.
    aEsquerda(trabalhador(_,_,inspetor,_,_,_),trabalhador(branco,_,_,_,_,_),ListaSolucao),
    aEsquerda(trabalhador(branco,_,_,_,_,_),trabalhador(_,_,_,_,_,bicicleta),ListaSolucao),

    % O homem de Azul está em algum lugar entre João e o homem de Amarelo, nessa ordem.
    aEsquerda(trabalhador(_,joao,_,_,_,_),trabalhador(azul,_,_,_,_,_),ListaSolucao),
    aEsquerda(trabalhador(azul,_,_,_,_,_),trabalhador(amarela,_,_,_,_,_),ListaSolucao),
    
    % O Carteiro está ao lado do trabalhador do norte.
    doLado(trabalhador(_,_,carteiro,_,_,_),trabalhador(_,_,_,_,amapa,_),ListaSolucao),
    
    % Sidney está ao lado de quem foi de Carro.
    doLado(trabalhador(_,sidney,_,_,_,_),trabalhador(_,_,_,_,_,carro),ListaSolucao),
    
    % Todas as possibilidades
    
    camiseta(Camiseta1),camiseta(Camiseta2),camiseta(Camiseta3),camiseta(Camiseta4),camiseta(Camiseta5),
    todosDiferentes([Camiseta1,Camiseta2,Camiseta3,Camiseta4,Camiseta5]),
    
    nome(Nome1),nome(Nome2),nome(Nome3),nome(Nome4),nome(Nome5),
    todosDiferentes([Nome1,Nome2,Nome3,Nome4,Nome5]),
    
    profissao(Profissao1),profissao(Profissao2),profissao(Profissao3),profissao(Profissao4),profissao(Profissao5),
    todosDiferentes([Profissao1,Profissao2,Profissao3,Profissao4,Profissao5]),
    
    idade(Idade1),idade(Idade2),idade(Idade3),idade(Idade4),idade(Idade5),
    todosDiferentes([Idade1,Idade2,Idade3,Idade4,Idade5]),
    
    estado(Estado1),estado(Estado2),estado(Estado3),estado(Estado4),estado(Estado5),
    todosDiferentes([Estado1,Estado2,Estado3,Estado4,Estado5]),
    
    transporte(Transporte1),transporte(Transporte2),transporte(Transporte3),transporte(Transporte4),transporte(Transporte5),
    todosDiferentes([Transporte1,Transporte2,Transporte3,Transporte4,Transporte5]).

% Resposta obtida executando 'solucao(Lista).'
% Lista = [trabalhador(vermelha, joao, inspetor, 53, parana, metro), trabalhador(branco, paulo, pedreiro, 41, maranhao, trem),
% trabalhador(azul, sidney, jardineiro, 46, matoGrosso, onibus), trabalhador(amarela, getulio, carteiro, 34, saoPaulo, carro),
% trabalhador(verde, cicero, metalurgico, 29, amapa, bicicleta)]