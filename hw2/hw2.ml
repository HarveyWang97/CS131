type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal


let rec convert rules nt = match rules with 
  		| [] -> []
  		| hd::tl -> match hd with
  						(a,b) -> if a = nt then b::(convert tl nt)
  								 else (convert tl nt)


let rec convert_grammar gram1 = match gram1 with
 	(a,b) -> (a,(convert b))


let rec and_check_rhs gram rhs acc derivation frag = match rhs with
		[] -> acc derivation frag
	| 	hd::tl -> match frag with
				[] -> None
			| 	f_head::f_tail -> match hd with
								 (N nt) -> let new_acc = (and_check_rhs gram tl acc) in
												(or_check_rhs gram nt (gram nt) new_acc derivation frag)
							  |  (T ter) -> if f_head = ter
							  				then (and_check_rhs gram tl acc derivation f_tail)
							  				else None


and or_check_rhs gram start rhs acc derivation frag = match rhs with
	| [] -> None
	| hd::tl -> let check_new = and_check_rhs gram hd acc (derivation@[(start,hd)]) frag
					in match check_new with
						| None -> or_check_rhs gram start tl acc derivation frag
						| other -> other


let rec parse_prefix gram acc frag = match gram with
						| (nt, rules) -> or_check_rhs rules nt (rules nt) acc [] frag