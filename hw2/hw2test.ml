let accept_all derivation string = Some (derivation, string)
let accept_empty_suffix derivation = function
   | [] -> Some (derivation, [])
   | _ -> None



type awksub_nonterminals =
  | Expr | Term | Lvalue | Incrop | Binop | Num


type nonterminals = | Eggert | Paul | Ksm | David | Smallberg | Wang | Li | Zhang | Zhu | Sun

let my_grammar1 = 
(Eggert,
  function
    | Eggert ->
        [[N Paul; N Smallberg];
          [N Ksm];
          [T"5"]]
    | Paul ->
          [[T"1"]]
    | Ksm -> 
          [  [N Paul]; [T"4"]]
    | David ->
          [ [ T"2"]; [N Paul]]
    | Smallberg ->
          [ [T"2"]] )

let test_1 = ((parse_prefix my_grammar1 accept_all ["1";"2";"3"]) = Some
   ([(Eggert, [N Paul; N Smallberg]); (Paul, [T "1"]); (Smallberg, [T "2"])],
    ["3"]))


let test_2 = ((parse_prefix my_grammar1 accept_all ["2"]) = None)






