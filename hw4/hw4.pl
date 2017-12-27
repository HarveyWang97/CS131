% the first number in the list represent the number of occurences
% the second number represents the actual number
trans([1,1],'.').
trans([2,1],'.').
trans([2,1],'-').
trans([3,1],'-').
trans([1,0],'').
trans([2,0],'').
trans([2,0],'^').
trans([3,0],'^').
trans([4,0],'^').
trans([5,0],'^').
trans([5,0],'#').
trans([N,0],'#'):- N>5.

% change the string of numbers to the above style
change([],[]).
change([X],[[1,X]]).
change([X|Rest],[ [Count,X]| T]):- change( Rest,[ [Rcount,X] | T] ), Count is Rcount+1, !.
change( [X|Rest], [ [1,X],[Count,N] | T] ) :-  N\==X, change(Rest, [[Count,N]|T]), ! .    

% generate the actual string   
trans_list([],[]).
trans_list([H|L],Ans):- trans(H,M), M == '',trans_list(L,Ans).    
trans_list([H|L],[M|T]) :- trans(H,M), M \== '',  trans_list(L,T).

signal_morse(X,Y):- change(X,Temp),trans_list(Temp,Y).

morse(a, [.,-]).           % A
morse(b, [-,.,.,.]).	   % B
morse(c, [-,.,-,.]).	   % C
morse(d, [-,.,.]).	   % D
morse(e, [.]).		   % E
morse('e''', [.,.,-,.,.]). % É (accented E)
morse(f, [.,.,-,.]).	   % F
morse(g, [-,-,.]).	   % G
morse(h, [.,.,.,.]).	   % H
morse(i, [.,.]).	   % I
morse(j, [.,-,-,-]).	   % J
morse(k, [-,.,-]).	   % K or invitation to transmit
morse(l, [.,-,.,.]).	   % L
morse(m, [-,-]).	   % M
morse(n, [-,.]).	   % N
morse(o, [-,-,-]).	   % O
morse(p, [.,-,-,.]).	   % P
morse(q, [-,-,.,-]).	   % Q
morse(r, [.,-,.]).	   % R
morse(s, [.,.,.]).	   % S
morse(t, [-]).	 	   % T
morse(u, [.,.,-]).	   % U
morse(v, [.,.,.,-]).	   % V
morse(w, [.,-,-]).	   % W
morse(x, [-,.,.,-]).	   % X or multiplication sign
morse(y, [-,.,-,-]).	   % Y
morse(z, [-,-,.,.]).	   % Z
morse(0, [-,-,-,-,-]).	   % 0
morse(1, [.,-,-,-,-]).	   % 1
morse(2, [.,.,-,-,-]).	   % 2
morse(3, [.,.,.,-,-]).	   % 3
morse(4, [.,.,.,.,-]).	   % 4
morse(5, [.,.,.,.,.]).	   % 5
morse(6, [-,.,.,.,.]).	   % 6
morse(7, [-,-,.,.,.]).	   % 7
morse(8, [-,-,-,.,.]).	   % 8
morse(9, [-,-,-,-,.]).	   % 9
morse(., [.,-,.,-,.,-]).   % . (period)
morse(',', [-,-,.,.,-,-]). % , (comma)
morse(:, [-,-,-,.,.,.]).   % : (colon or division sign)
morse(?, [.,.,-,-,.,.]).   % ? (question mark)
morse('''',[.,-,-,-,-,.]). % ' (apostrophe)
morse(-, [-,.,.,.,.,-]).   % - (hyphen or dash or subtraction sign)
morse(/, [-,.,.,-,.]).     % / (fraction bar or division sign)
morse('(', [-,.,-,-,.]).   % ( (left-hand bracket or parenthesis)
morse(')', [-,.,-,-,.,-]). % ) (right-hand bracket or parenthesis)
morse('"', [.,-,.,.,-,.]). % " (inverted commas or quotation marks)
morse(=, [-,.,.,.,-]).     % = (double hyphen)
morse(+, [.,-,.,-,.]).     % + (cross or addition sign)
morse(@, [.,-,-,.,-,.]).   % @ (commercial at)

% Error.
morse(error, [.,.,.,.,.,.,.,.]). % error - see below

% Prosigns.
morse(as, [.,-,.,.,.]).          % AS (wait A Second)
morse(ct, [-,.,-,.,-]).          % CT (starting signal, Copy This)
morse(sk, [.,.,.,-,.,-]).        % SK (end of work, Silent Key)
morse(sn, [.,.,.,-,.]).          % SN (understood, Sho' 'Nuff)


    
% help delete the ^ in the message
split([],[],[]).
split([],X,[Y]):- morse(Y,X).
split(['^'|T],[],L):- split(T,[],L).
split(['^'|T],X,[Y|L]) :- morse(Y,X),split(T,[],L).    
split(['#'|T],[],['#'|L]):- split(T,[],L).
split(['#'|T],X,[Y,'#'|L]):- morse(Y,X),split(T,[],L).
split([H|T],X,L):- \==(H,'^'), H\=='#',append(X,[H],Temp),split(T,Temp,L).

    
% deal with the error word cases
delete_error([],[],[]).
delete_error([],X,X).
delete_error(['error'|T],[],['error'|L]):- delete_error(T,[],L).
delete_error(['error'|T],X,L):- X\==[],delete_error(T,[],L).
delete_error(['#','error'|T],X,L) :- delete_error(T,[],L).
delete_error(['#'|T],X,L) :- append(X,['#'],Xtemp), append(Xtemp,Ltemp,L), delete_error(T,[],Ltemp). 
delete_error([H|T],X,L) :- \==(H,'#'), \==(H,'error'), append(X,[H],Temp), delete_error(T,Temp,L).    


signal_message(X,Y):- signal_morse(X,Temp),split(Temp,[],Mes),once(delete_error(Mes,[],Y)).
