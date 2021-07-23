% Possiveis cidades
cidade(orlando).
cidade(lasVegas).
cidade(novaYork).
cidade(saoFrancisco).

% Possiveis duracoes
duracao(10).
duracao(15).
duracao(20).
duracao(25).

% Possiveis hoteis
hotel(bestPrice).
hotel(bigPalace).
hotel(gardenFlowers).
hotel(niceSpring).

% Possiveis turistas
turista(cristian).
turista(ederson).
turista(henrique).
turista(rafael).

% Confirma que nenhum elemento esteja repetido na lista
todosDiferentes([]).
todosDiferentes([H|T]) :- not(member(H,T)), todosDiferentes(T).

solucao(ListaSolucao) :-
    ListaSolucao = [
                   reserva(Cidade1,Duracao1,Hotel1,Turista1),
                   reserva(Cidade2,Duracao2,Hotel2,Turista2),
                   reserva(Cidade3,Duracao3,Hotel3,Turista3),
                   reserva(Cidade4,Duracao4,Hotel4,Turista4)
                   ],
    
    % 1. O turista que viajará por 20 dias nos Estados Unidos ficará hospedado no hotel Big Palace.
    member(reserva(_,20,bigPalace,_),ListaSolucao),
    
    % 2. Quem ficará hospedado no hotel Best Price é o o turista Cristian ou o turista que viajará por 10 dias.
    (member(reserva(_,_,bestPrice,cristian),ListaSolucao);
     member(reserva(_,10,bestPrice,_),ListaSolucao)),
    
    % 3. Sobre o turista que vai pra Orlando e o que vai ficar no hotel Nice Springs, um vai viajar durante 20
    % dias e o outro se chama Henrique (não necessariamente nessa ordem). 
    (member(reserva(orlando,20,_,_),ListaSolucao), member(reserva(_,_,niceSpring,henrique),ListaSolucao);
    member(reserva(_,20,niceSpring,_),ListaSolucao),member(reserva(orlando,_,_,henrique),ListaSolucao)),
    
    % 4. O turista que vai para Nova York ficará 10 dias a mais nos Estados Unidos que Rafael.
    (member(reserva(novaYork,20,_,_),ListaSolucao), member(reserva(_,10,_,rafael),ListaSolucao);
    member(reserva(novaYork,25,_,_),ListaSolucao), member(reserva(_,15,_,rafael),ListaSolucao)),
    
    % 5. Henrique viajará 5 dias a menos que o turista que vai para São Francisco.
    (member(reserva(_,20,_,henrique),ListaSolucao),member(reserva(saoFrancisco,25,_,_),ListaSolucao);
    member(reserva(_,15,_,henrique),ListaSolucao),member(reserva(saoFrancisco,20,_,_),ListaSolucao);
    member(reserva(_,10,_,henrique),ListaSolucao),member(reserva(saoFrancisco,15,_,_),ListaSolucao)),
    
    %Todas as possibilidades do desafio
	
    cidade(Cidade1),cidade(Cidade2),cidade(Cidade3),cidade(Cidade4),
	todosDiferentes([Cidade1,Cidade2,Cidade3,Cidade4]),

	duracao(Duracao1),duracao(Duracao2),duracao(Duracao3),duracao(Duracao4),
	todosDiferentes([Duracao1,Duracao2,Duracao3,Duracao4]),

	hotel(Hotel1),hotel(Hotel2),hotel(Hotel3),hotel(Hotel4),
	todosDiferentes([Hotel1,Hotel2,Hotel3,Hotel4]),
    
    turista(Turista1),turista(Turista2),turista(Turista3),turista(Turista4),
	todosDiferentes([Turista1,Turista2,Turista3,Turista4]).
	
% Resposta ao executar 'solucao(Lista)'
% Lista = [reserva(orlando, 20, bigPalace, ederson), reserva(novaYork, 25, bestPrice, cristian),
% reserva(lasVegas, 10, niceSpring, henrique), reserva(saoFrancisco, 15, gardenFlowers, rafael)]