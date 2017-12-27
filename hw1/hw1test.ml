let my_subtest_test0 = not (subset [1;1;2]  [2;2])

let my_subtest_test1 = not (subset [1;1] [])

let my_subtest_test2 = subset [1;1;2] [1;1;1;1;2;2;3]

let my_equal_sets_test0 = equal_sets [1;2] [1;1;1;2]

let my_equal_sets_test1 = not (equal_sets [] [1])

let my_equal_sets_test2 = equal_sets [] []

let my_set_union_test0 = equal_sets (set_union [1;2] [2;2;2;3]) [1;2;3]

let my_set_union_test1 = equal_sets (set_union [] []) []

let my_set_intersection_test0 = not (equal_sets (set_intersection [1;1;2] [2;2;3]) [1;2;3])

let my_set_intersection_test1 = equal_sets (set_intersection [1;1;2] []) []

let my_set_diff_test0 = equal_sets (set_diff [1;3;5] [3;5]) [1]

let my_set_diff_test1 = equal_sets (set_diff [] [1;2]) []

let my_set_diff_test2 = equal_sets (set_diff [1;2] []) [1;2]

let my_computed_fixed_point_test0 = computed_fixed_point (=) (fun x -> x*x+3*x) (-2) = (-2)

let my_computed_fixed_point_test1 = computed_fixed_point (=) (fun x -> sqrt x) 50. = 1.

let my_computed_periodic_point_test0 = computed_periodic_point (=) (fun x -> x*x) 2 1 = 1

let my_computed_periodic_point_test1 = computed_periodic_point (=) (fun x -> -x) 2 1 = 1 


let my_while_away_test0 = equal_sets (while_away (fun x -> x+3) ((>) 10) 0) [0;3;6;9]

let my_rle_decode_test0 = equal_sets (rle_decode [2,0; 1,6]) [0;0;6]

let my_rle_decode_test1 = equal_sets (rle_decode [0,2;5,3]) [3;3;3;3;3]

type test_nonterminals = 
	| Eggert | Paul | David | Smallberg | Wang

let test_rules = 
	[ Eggert,[T"(";N David;N Eggert];
	  Eggert,[T"0"];
	  Paul, [];
	  David, [N Paul];
	  Smallberg, [N Smallberg; T"0";N David];
	  Wang, [N David]
	]

let test_grammar = Eggert, test_rules

let my_filter_blind_alleys_test0 = filter_blind_alleys test_grammar = (Eggert,
	[ Eggert,[T"(";N David;N Eggert];
	  Eggert,[T"0"];
	  Paul, [];
	  David, [N Paul];
	  Wang, [N David]
	])



