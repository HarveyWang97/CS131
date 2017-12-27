member(X, [X|XS]).
member(X, [Y|XS]) :-
  X \== Y,
  member(X, XS).

remove_first(X, [X|XS], XS).
remove_first(X, [Y|XS], [Y|Rest]) :-
  X == Y
  remove_first(X, XS, Rest).

permutation([], []).
permutation([A|B], [C|D]) :-
  member(A, [C|D]),
  member(C, [A|B]),
  remove(A, [C|D], L2),
  permutation(B, L2).