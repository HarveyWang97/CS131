type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

let rec contain element l = match l with
	| [] -> false
	| hd::tl -> if element = hd then true else (contain element tl)

let rec subset a b = match a with
	| [] -> true
	| hd::tl -> if (contain hd b) = false then false 
			  else (subset tl b)

let rec equal_sets a b = 
	if (subset a b) = true then (subset b a)
	else false

let rec set_union a b = a@b

let rec set_intersection a b = match a with 
	| [] -> []
	| hd::tl -> if(contain hd b) = true then hd::(set_intersection tl b) 
				else (set_intersection tl b) 

let rec set_diff a b = match a with
	| [] -> []
	| hd::tl -> if(contain hd b) = true  then (set_diff tl b)
				else hd::(set_diff tl b)

let rec computed_fixed_point eq f x = 
	let value = f x in 
	if(eq value x) then x
    else (computed_fixed_point eq f value)

(* a helper function to do p times calculation *)
let rec run_p_time f p x = match p with
	| 1 -> (f x)
	| _ -> (run_p_time f (p-1) (f x))     


let rec computed_periodic_point eq f p x = match p with
	| 0 -> x
	| 1 -> (computed_fixed_point eq f x)
	| _ -> if (eq (run_p_time f p x) x) then x
			else (computed_periodic_point eq f p (f x))


let rec while_away s p x = 
	if (p x) = false then []
	else x::(while_away s p (s x))

let rec generate (x,y) = match x with
	| 0 -> []
	| _ -> y:: generate (x-1,y)

let rec rle_decode lp = match lp with
	| [] -> []
	| hd::tl -> (generate hd)@(rle_decode tl)





(* the final part *)
let rec is_terminal a = match a with
	| [] -> true
	| hd::tl -> match hd with
			| (N a) -> false
			| (T b) -> is_terminal tl


let rec generate_terminal_list orig_rule = match orig_rule with
	| []-> []
	| hd::tl -> if (is_terminal (snd hd)) then (fst hd)::(generate_terminal_list tl)
				else generate_terminal_list tl

let rec is_safe rule terminal_list = match rule with
	| [] -> true
	| hd::tl -> match hd with 
				| (T a) -> is_safe tl terminal_list
				| (N b) -> if (contain b terminal_list) then is_safe tl terminal_list
							else false

let rec generate_safe_list orig_rule terminal_list = match orig_rule with
	| [] -> terminal_list
	| hd::tl -> if (contain (fst hd) terminal_list) then generate_safe_list tl terminal_list
				else if (is_safe (snd hd) terminal_list) then (fst hd)::(generate_safe_list tl terminal_list)
			    else generate_safe_list tl terminal_list

let rec final_list orig_rule safe_list = 
		if (equal_sets safe_list (generate_safe_list orig_rule safe_list)) then safe_list
	else generate_safe_list orig_rule safe_list

let rec build orig_rule = final_list orig_rule (generate_safe_list orig_rule (generate_terminal_list orig_rule))

let rec filter_rules orig_rule safe_list = 
	match orig_rule with
	| [] -> []
	| hd::tl -> if is_safe (snd hd) safe_list then hd::(filter_rules tl safe_list)
				else filter_rules tl safe_list

let rec filter_blind_alleys g = 
	let orig_rules = (snd g) in 
		(fst g), (filter_rules orig_rules (build orig_rules))



















