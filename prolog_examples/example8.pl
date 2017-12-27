compress([], []).
compress([X,X|R], Ans) :-
  compress([X|R], Ans).
compress([X,Y|R], [X|Ans]) :-
  X \== Y,
  compress([Y|R], Ans).