type nucleotide = A | C | G | T
type fragment = nucleotide list
type acceptor = fragment -> fragment option
type matcher = fragment -> acceptor -> fragment option

type pattern =
  | Frag of fragment
  | List of pattern list
  | Or of pattern list

let accept_empty fragment = match fragment with
| [] -> Some []
| _ -> None

let rec make_nucleotide_matcher nucleotide fragment accept = match fragment with
| [] -> None
| n::ns -> if n = nucleotide
  then accept ns
  else None

and make_fragment_matcher frag fragment accept = match frag with
| [] -> accept fragment
| x::xs -> (match fragment with
  | [] -> None
  | n::ns -> let result = make_nucleotide_matcher x [n] accept_empty in
    match result with
    | Some _ -> make_fragment_matcher xs ns accept
    | None -> None)

and make_list_matcher pats fragment accept = match pats with
| [] -> accept fragment
| p::ps -> make_matcher p fragment (fun f -> make_list_matcher ps f accept)

and make_or_matcher pats fragment accept = match pats with
| [] -> None
| p::ps -> let head_matcher = make_matcher p in
  let tail_matcher = make_or_matcher ps in
  let result = head_matcher fragment (fun f -> match accept f with
    | Some suffix -> Some suffix
    | None -> tail_matcher fragment accept) in
  match result with 
  | Some suffix -> Some suffix
  | None -> tail_matcher fragment accept

and make_matcher = function
| Frag frag -> make_fragment_matcher frag
| List pats -> make_list_matcher pats
| Or pats -> make_or_matcher pats

let n_test1 = make_nucleotide_matcher A [A] accept_empty = Some []
let n_test2 = make_nucleotide_matcher G [A] accept_empty = None

let f_test3 = make_fragment_matcher [A; G; C] [A; G; C] accept_empty = Some []
let f_test4 = make_fragment_matcher [A; G] [A] accept_empty = None

let list_test1 = make_list_matcher [Frag [A; G]; Frag [C]] [A; G; C] accept_empty = Some []
let list_test2 = make_list_matcher [Frag [A; G]; Frag [C]] [A; G; C; A] accept_empty = None

let or_test1 = make_or_matcher [Frag [A; C]; Frag [G]] [G] accept_empty = Some []
let or_test2 = make_or_matcher [Frag [A; C]; Frag [G]] [A;C] accept_empty = Some []
let or_test3 = make_or_matcher [Frag [A; C]; Frag [G]] [T] accept_empty = None