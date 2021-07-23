soma([],0).
soma([H|T],S) :- soma(T,ST), S is ST + H.