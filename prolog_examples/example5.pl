length(empty, 0).
length(cons(_, XS), Ans) :-
  length(XS, TailLength),
  Ans is TailLength + 1.