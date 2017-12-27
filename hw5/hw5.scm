;#lang racket

(define (null-ld? obj)
  (cond ( (null? obj) #f)
	( (not (pair? obj)) #f)
	( else (eq? (car obj) (cdr obj)))
	)
  )


(define (listdiff? obj)
  (cond ( (null? obj) #f)
	( (not (pair? obj)) #f)
	( (null-ld? obj) #t)
	( else (let* ([L (car obj)])
		 (cond ( (not (pair? L)) #f)
		       ( else (listdiff? (cons (cdr L) (cdr obj))))
		       )
		 )
	       )
	)
  )


(define (cons-ld obj listdiff)
  (cons (cons obj (car listdiff)) (cdr listdiff))
  )



(define (car-ld listdiff)
  (cond ( (not (listdiff? listdiff)) "error")
	( (null-ld? listdiff) "error")
	(else (car (car listdiff)))
	)
  )

(define (cdr-ld listdiff)
  (cond ( (not (listdiff? listdiff)) "error")
        ( (null-ld? listdiff) "error")
	( else (cons (cdr (car listdiff)) (cdr listdiff)))
	)
  )

(define (listdiff obj . arg)
  (cons (cons obj arg) '())
  )

(define (length-ld listdiff)
  (cond ( (not (listdiff? listdiff)) "error")
	( else
	  (let helper ( (x (car listdiff)))
	    (if (eq? x (cdr listdiff)) 0
		(+ 1 (helper (cdr x)))
		)
	    )
	  )
	)
  )

(define (append-ld listdiff . arg)
  (cond ( (null? arg) listdiff)
	( else (let nest ((x (cons listdiff arg)))
		 (cond ( (null? (cdr x)) (car x))
		       ( else (let sub ((y (listdiff->list (car x))))
				(cond ( (null? y) (nest (cdr x)))
				      ( else ( cons-ld (car y) (sub (cdr y))))
				      )
				)
			      )
		       )
		 )
	       )
	)
  )
		    

(define (list-tail-ld listdiff k)
  (cond ( (equal? k 0) listdiff)
	( else (list-tail-ld (cons (cdr (car listdiff)) (cdr listdiff)) (- k 1)))
	)
  )

(define (list->listdiff list)
  (cons list '())
  )
	       


(define (listdiff->list listdiff)
  (cond ( (null-ld? listdiff) null)
	( else
	  (cons (car (car listdiff)) (listdiff->list (cons (cdr (car listdiff)) (cdr listdiff))))
	)
	)
  )


(define (expr-returning listdiff)
 (if (listdiff? listdiff)
  `(cons ',(take (car listdiff) (length-ld listdiff)) '())
  (error "error")
 )
)
  
  


;(define ils (append '(a e i o u) 'y))
;(define d1 (cons ils (cdr (cdr ils))))
;(define d2 (cons ils ils))
;(define d3 (cons ils (append '(a e i o u) 'y)))
;(define d4 (cons '() ils))
;(define d5 0)
;(define d6 (listdiff ils d1 37))
;(define d7 (append-ld d1 d2 d6))
;(define kv1 (cons d1 'a))
;(define kv2 (cons d2 'b))
;(define kv3 (cons d3 'c))
;(define kv4 (cons d1 'd))
;(define d8 (listdiff kv1 kv2 kv3 kv4))
;(define d9 (listdiff kv3 kv4))
;(define d10 (cons ils (cdr (cdr (cdr ils)))))
;(define d11 (cons ils (cdr (cdr (cdr (cdr ils))))))
;(define e1 (expr-returning d1))
;(define ns (make-base-namespace))

;(listdiff? d1)  
;(listdiff? d2)
;(listdiff? d3)  
;(listdiff? d4)
;(listdiff? d5)
;(listdiff? d6)
;(listdiff? d7)

;(null-ld? d1)                         
;(null-ld? d2)                         
;(null-ld? d3)                         
;(null-ld? d6)  

;(car-ld d1)
;(car-ld d2)
;(car-ld d3)
;(car-ld d6)

;(length-ld d1)
;(length-ld d2)
;(length-ld d3)
;(length-ld d3)
;(length-ld d6)
;(length-ld d7)


;(list->listdiff '(5 6 ))

;(listdiff->list d1)
;(listdiff->list d2)


;(eq? d8 (list-tail-ld d8 0))

;(equal? (listdiff->list (list-tail-ld d8 2))
 ;       (listdiff->list d9))

;(null-ld? (list-tail-ld d8 4))


;(equal? (listdiff->list (eval e1 ns))

;(eq? (car-ld d6) ils)                 
;(eq? (car-ld (cdr-ld d6)) d1)          
;(eqv? (car-ld (cdr-ld (cdr-ld d6))) 37)
;(equal? (listdiff->list d6)
 ;       (list ils d1 37))              
;(eq? (list-tail (car d6) 3) (cdr d6))  

;(listdiff->list (eval e1 ns))            ; ===>  (a e)
;(equal? (listdiff->list (eval e1 ns))
 ;       (listdiff->list d1))          ; ===>  #t

;(listdiff->list d1))



;(list->listdiff null)



