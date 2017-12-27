father(orville, abe).
father(abe, homer).
father(homer, bart).
father(homer, lisa).
father(homer, maggie).
grandfather(X, Y) :-
  father(X, Z),
  father(Z, Y).