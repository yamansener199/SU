(define get-operator (lambda (op-symbol env) 
  (cond 
    ((equal? op-symbol '+) +)
    ((equal? op-symbol '-) -)
    ((equal? op-symbol '*) *)
    ((equal? op-symbol '/) /)
    (else  (display "cs305: ERROR\n") (repl env)))))

(define define-stmt? (lambda (exp)
    (and (list? exp) (= (length exp) 3) (equal? (car exp) 'define) (symbol? (cadr exp)))))

(define let-param-correct? (lambda (exp)
	(if (list? exp)
		(if (null? exp) 
			#t
			(if (= (length (car exp)) 2)
				(let-param-correct? (cdr exp)) 
				#f
			)
		)
		#f
	)
))

(define cond-param-correct? (lambda (exp)
(if (null? exp) #f
	(if (and (list? (car exp)) (= (length (car exp)) 2))
		(if (equal? (caar exp) 'else)
			(if (null? (cdr exp)) #t #f)
		       	(cond-param-correct? (cdr exp))
		)
		#f
	))
))

(define if-stmt? (lambda (exp)
	(and (list? exp) (equal? (car exp) 'if) (= (length exp) 4))))

(define cond-stmt? (lambda (exp)
	(and (list? exp) (equal? (car exp) 'cond) (> (length exp) 2) (cond-param-correct? (cdr exp)))))

(define let-stmt? (lambda (exp)
	(and (list? exp) (equal? (car exp) 'let) (= (length exp) 3) (let-param-correct? (cadr exp)))))

(define letstar-stmt? (lambda (exp)
	(and (list? exp) (equal? (car exp) 'let*) (= (length exp) 3) (let-param-correct? (cadr exp)))))

(define get-value (lambda (var old-env new-env)
    (cond
      ((null? new-env) (display "cs305: ERROR\n") (repl old-env))

      ((equal? (caar new-env) var) (cdar new-env))

      (else (get-value var old-env (cdr new-env))))))

(define extend-env (lambda (var val old-env)
      (cons (cons var val) old-env)))

(define repl (lambda (env)
  (let* (
        
         (dummy1 (display "cs305> "))
         (expr (read))

         (new-env (if (define-stmt? expr)
                      (extend-env (cadr expr) (s7-interpret (caddr expr) env) env)
                      env))

         (val (if (define-stmt? expr)
                  (cadr expr)
                  (s7-interpret expr env)))

         (dummy2 (display "cs305: "))
         (dummy3 (display val))

         (dummy4 (newline))
         (dummy4 (newline)))
     (repl new-env))))

(define s7-interpret (lambda (e env)
  (cond 

    ((number? e) e)

    ((symbol? e) (get-value e env env))

    ((not (list? e)) 
	(display "cs305: ERROR\n") (repl env) )

    ((null? e) e)

    ((if-stmt? e) (if (eq? (s7-interpret (cadr e) env) 0)
            ( s7-interpret (cadddr e) env)
                ( s7-interpret (caddr e) env)))
  
    ((cond-stmt? e) 
	(if (eq? (length e) 3) 
		(if (eq? (s7-interpret (caadr e) env) 0) (s7-interpret (car (cdaddr e)) env)
		(s7-interpret (cadadr e) env))
		(let ((if-cond  (caadr e)) (then (cadadr e)) (else-part (cons 'cond (cddr e))) ) 
			(let ((c (list 'if if-cond then else-part))) (s7-interpret c env)))))

    ((let-stmt? e)
      (let ((names (map car  (cadr e)))
            (exprs (map cadr (cadr e))))
           (let ((vals (map (lambda (expr) (s7-interpret expr env)) exprs)))
           	(let ((new-env (append (map cons names vals) env)))
            	(s7-interpret (caddr e) new-env)))))

    ((letstar-stmt? e) (if (<= (length (cadr e)) 1)
			 (let ((l (list 'let (cadr e) (caddr e))))   
			    (let ((names (map car  (cadr e)))
	            		(exprs (map cadr (cadr e))))
        	   		(let ((vals (map (lambda (expr) (s7-interpret expr env)) exprs)))
                		(let ((new-env (append (map cons names vals) env)))
                		(s7-interpret (caddr e) new-env)))))

			(let ((first (list 'let (list (caadr e)))) (rest (list 'let* (cdadr e) (caddr e))))
     								(let ((l (append first (list rest)))) (let ((names (map car (cadr l))) (inits (map cadr (cadr l))))
     									(let ((vals (map (lambda (init) (s7-interpret init env)) inits)))
     										(let ((new-env (append (map cons names vals) env)))
												(s7-interpret (caddr l) new-env))))))
			))
			 

    (else 
       (let ((operands (map s7-interpret (cdr e) (make-list (length (cdr e)) env)))
             (operator (get-operator (car e) env)))

         (apply operator operands))))))

(define cs305 (lambda () (repl '())))