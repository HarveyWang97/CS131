append([], L2, L2).
append([X|XS], L2, [X|Rest]) :-
  append(XS, L2, Rest).

reverse([], []).
reverse([X|XS], Ans) :-
  reverse(XS, Rest),
  append(Rest, [X], Ans).