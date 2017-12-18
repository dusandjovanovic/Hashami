(defvar dimension 0)
(defvar states nil)
(defvar states-vertical nil)

(defun start()
  (format t "~% Izaberite mod igre [mod]..")
  (format t "~% [1] Covek-racunar :: x o")
  (format t "~% [2] Racunar-covek :: x o")
  (format t "~% [3] Covek-covek :: x o")
  (format t "~% [exit] Izlaz ~%")
  
  (let 
   ((mode (read)))
    (cond
     ((equalp mode 1)
      (progn 
        (form-matrix)
        (show-output (states-to-matrix 1 dimension states))
        (make-move t))
     )
     ((equalp mode 2) nil)
     ((equalp mode 3) 
      (progn 
         (form-matrix)
         (show-output (states-to-matrix 1 dimension states))
         (make-move t)
      ))
     ((string-equal mode "exit") #+sbcl (sb-ext:quit))
     (t (format t "~% Nepravilan mod ~%~%") (start))
)))

(defun form-matrix ()
  (format t "~% Unesite dimenziju table za Hashami igru, dimenzija treba da bude u opsegu 9-11~%")
  (setq dimension (read))
  (cond
   ((< dimension 9) (format t "~% Dimenzija table je premala") (form-matrix))
   ((> dimension 11) (format t "~% Dimenzija table je prevelika") (form-matrix))
   (t (progn (setq states-vertical (initial-states-vertical dimension)) (setq states (initial-states dimension))))
  )
)

(defun make-move (xo)  ; xo true : x | false: o za zaizmenicne poteze
  (format t "~%~%~A: unesite potez oblika ((x y) (n m)): " (if xo #\x #\o))
  (let* ((input (read)) 
         (current (form-move (car input))) 
         (move (form-move (cadr input))) 
         (player (if xo #\x #\o))
         (horizontal (states-to-matrix 1 dimension states))
         (vertical (states-to-matrix 1 dimension states-vertical))
         )
    (cond
     ((string-equal (caar input) "exit") #+sbcl (sb-ext:quit))
     ((or (null current) (null move) (> (car current) dimension) (> (cadr current) dimension) (> (car move) dimension) (> (cadr move) dimension)) (format t "~%~%Nepravilan format ili granice polja..~%") (make-move xo)) ; nepravilno formatiran unos poteza rezultuje ponovnim unosom istog poteza
     (t (if (or (and (not (equal (cadr current) (cadr move))) (validate-state current move (generate-states horizontal 1 xo)))
                (and (not (equal (car current) (car move))) (validate-state (list (cadr current) (car current)) (list (cadr move) (car move)) (generate-states vertical 1 xo)))) 
          (progn 
          (change-state (car current) (cadr current) (car move) (cadr move) xo)
          (let*
          ((horizontal-coded (states-to-matrix 1 dimension states))
           (vertical-coded (states-to-matrix 1 dimension states-vertical)))
           ; matrice kodiranja koje mogu da se pre povlacenja poteza prolsedjuju (validate-move ..))    
            (cond

              ((or (and xo (< (length (cadr states)) 4)) (and (not xo) (< (length (car states)) 4)) (check-winner-state-horizontal (nth (1- (car move)) horizontal-coded) (car move) xo 0) (check-winner-state-vertical (nth (1- (cadr move)) vertical-coded) (cadr move) xo 0) (check-winner-state-diagonal 1 horizontal-coded (if xo 'x 'o) nil -1) (check-winner-state-diagonal 1 horizontal-coded (if xo 'x 'o) nil 1)) (progn (show-output horizontal-coded) (format t "~%~%Pobednik je ~A ~%~%" (if xo #\x #\o)) #+sbcl (sb-ext:quit)))

             (t (show-output horizontal-coded) (make-move (not xo)))))
           )  
          (progn (format t "~%~%nedozvoljen potez, pokusajte ponovo..~%") (make-move xo)))
))))

(defun form-move (move)
  (if (and (member (car move) '(A B C D E F G H I J K)) (member (cadr move) '(1 2 3 4 5 6 7 8 9 10 11)))
      (cond 
       ((equal (car move) 'a) (list '1 (cadr move)))
       ((equal (car move) 'b) (list '2 (cadr move)))
       ((equal (car move) 'c) (list '3 (cadr move)))
       ((equal (car move) 'd) (list '4 (cadr move)))
       ((equal (car move) 'e) (list '5 (cadr move)))
       ((equal (car move) 'f) (list '6 (cadr move)))
       ((equal (car move) 'g) (list '7 (cadr move)))
       ((equal (car move) 'h) (list '8 (cadr move)))
       ((equal (car move) 'i) (list '9 (cadr move)))
       ((equal (car move) 'j) (list '10 (cadr move)))
       ((equal (car move) 'k) (list '11 (cadr move)))
       (t '())
      )
    '()
    ))

; parametri su states/states-vertical vraca listu ((new states) (new states-vertical)) :: integrisano u generator stanja (make-all-states)
(defun check-sandwich (states-ptr states-vertical-ptr move xo)
  (let* ( 
         (to-delete-horizontal (check-row-sandwich (list (extract-row-column (car states-ptr) (car move)) (extract-row-column (cadr states-ptr) (car move))) (car move) xo))
         (to-delete-vertical (check-column-sandwich (list (extract-row-column (car states-vertical-ptr) (cadr move)) (extract-row-column (cadr states-vertical-ptr) (cadr move))) (cadr move) xo))
        )
     (list
      (list
       (remove-from-states (remove-from-states (car states-ptr) to-delete-horizontal) (inverse-all to-delete-vertical))
       (remove-from-states (remove-from-states (cadr states-ptr) to-delete-horizontal) (inverse-all to-delete-vertical))
      )
      (list
       (remove-from-states (remove-from-states (car states-vertical-ptr) to-delete-vertical) (inverse-all to-delete-horizontal))
       (remove-from-states (remove-from-states (cadr states-vertical-ptr) to-delete-vertical) (inverse-all to-delete-horizontal))
      )
     )    
   )
)

(defun extract-row-column (states-ptr num)
  (cond
   ((null states-ptr) nil)
   ((< (caar states-ptr) num) (extract-row-column (cdr states-ptr) num))
   ((> (caar states-ptr) num) nil)
   (t (cons (car states-ptr) (extract-row-column (cdr states-ptr) num)))
  )
)

; sledece dve funkcije vracaju elemente koji treba da budu obrisani (x y)
(defun check-row-sandwich (states-ptr row xo) 
  (let* 
      (
       (player (if xo (car states-ptr) (cadr states-ptr)))
       (opponent (if xo (cadr states-ptr) (car states-ptr)))
      ) 
    (to-remove player opponent)
  )
)

(defun check-column-sandwich (states-vertical-ptr column xo) 
  (let* 
      (
       (player (if xo (car states-vertical-ptr) (cadr states-vertical-ptr)))
       (opponent (if xo (cadr states-vertical-ptr) (car states-vertical-ptr)))
      ) 
    (to-remove player opponent)
  )
)

(defun to-remove (player opponent)
  (let* 
      (
       (left-bound (car player))
       (right-bound (nth 1 player))
      ) 
    (cond
     ((null player) nil)
     (t (append (in-between left-bound right-bound (list (car left-bound) (1+ (cadr left-bound))) nil opponent) (to-remove (cdr player) opponent)))
    )
  )
)

(defun in-between (left-bound right-bound current sublist opponent)
  (cond
   ((equalp current right-bound) sublist)
   ((not (member current opponent :test 'equal)) nil)
   (t (in-between left-bound right-bound (list (car current) (1+ (cadr current))) (cons current sublist) opponent))
  )
)

(defun remove-from-states (states-ptr elto-remove) 
  (cond
   ((null elto-remove) states-ptr)
   (t (remove-from-states (remove (car elto-remove) states-ptr :test 'equal) (cdr elto-remove)))
  )
)

(defun inverse-all (uninversed)
  (cond
   ((null uninversed) nil)
   (t (cons (append (cdar uninversed) (list (caar uninversed))) (inverse-all (cdr uninversed))))
  )
)

(defun check-winner-state-horizontal (coded-row rownum xo counter) ; rownum za broj vrste | coded-row (nth rownum-1 horizontal-matrix)
  (cond
   ((null coded-row) nil)
   ((and xo (<= rownum 2)) nil)
   ((and (not xo) (> rownum (- dimension 2))) nil)
   ((equalp counter 5) t)
   ((and (listp (car coded-row)) (equalp (cadar coded-row) (if xo 'x 'o))) (check-winner-state-horizontal (cdr coded-row) rownum xo (1+ counter)))
   (t (check-winner-state-horizontal (cdr coded-row) rownum xo 0))
  )
)

(defun check-winner-state-vertical (coded-column rownum xo counter) ; rownum za broj vrste i uvek se prosledjuje 1 i inkrementira se kroz funkciju
  (cond
   ((null coded-column) nil)
   ((and (not xo) (> rownum (- dimension 2))) nil)
   ((equalp counter 5) t)
   ((and (listp (car coded-column)) (equalp (cadar coded-column) (if xo 'x 'o)) (and xo (> rownum 2))) (check-winner-state-vertical (cdr coded-column) (1+ rownum) xo (1+ counter)))
   ((listp (car coded-column)) (check-winner-state-vertical (cdr coded-column) (1+ rownum) xo 0))
   (t (check-winner-state-vertical (cdr coded-column) (+ rownum (car coded-column)) xo 0))
  )
)

(defun check-winner-state-diagonal (lvl encoded-list xo res lr)

    (cond
      ((null encoded-list) (cond ((>= (longest-sublist res 0) 5)  T)
                                 (t NIL)))
      (t (check-winner-state-diagonal (+ lvl 1) (cdr encoded-list) xo (check-row-for-diagonal lvl
                                                                                        (cond
                                                                                          ((or(and (equalp xo 'x) (<= lvl 2)) (and (equalp xo 'o) (>= lvl (- dimension 2))))NIL)
                                                                                          (t (car encoded-list))) xo res lr) lr))
      )
    )


(defun longest-sublist (all longest)
  (cond
    ((null all) longest)
    ((> (length (car all)) longest) (longest-sublist (cdr all) (length (car all))))
    (t (longest-sublist (cdr all) longest))
    )
  )

(defun remove-atoms (lvl list res)
  (cond
    ((null list) (reverse res))
    ((and (atom (caar list))(equalp (caar list) lvl) ) (remove-atoms lvl (cdr list) res))
    (t (remove-atoms lvl (cdr list) (cond
                                      ((null res) (list (car list)))
                                      (t(cons (car list) res )))))
    )
  )

(defun check-row-for-diagonal (lvl row xo current lr)
  (cond
    ((null row) (remove-atoms (- lvl 1) current NIL))
    ((listp (encode-element (car row) xo)) (check-row-for-diagonal lvl (cdr row) xo (check-if-element-diagonal (list lvl (caar row)) current NIL lr) lr))
     (t (check-row-for-diagonal lvl (cdr row) xo current lr))
     )
    )


(defun check-if-element-diagonal (element current res lr)

  (cond
    ((null current)
         (cond
           ((null res) (list element))
           (t (append res (list element)))
           ))
    (t (let* ((value (car current)))
         (cond
           ((equalp value (check-if-appends element value lr)) (check-if-element-diagonal element (cdr current) (cond
                                                                                                               ((null res) (list (car current)))
                                                                                                               (t(append res (list(car current))))) lr))
           (t  (append res (list(check-if-appends element value lr)) (cdr current)) )
           )
         )
       )
    )
  )

(defun check-if-appends (element element-or-atom lr)

  (let*
      ((value (car (last element-or-atom))))
    (cond
      ((listp value)(cond
                      ((and (equalp (cadr element) (+ (cadr value) lr)) (cond ((equalp lr -1) T)
                                                                              (t (equalp(car element) (+ (car value) lr))))) (append element-or-atom (list element)))
                      (t element-or-atom)))
      ((and (equalp (cadr element) (+ (cadr element-or-atom) lr)) (cond
                                                                    ((equalp lr -1) T)
                                                                    (t (equalp(car element) (+ (car element-or-atom) lr))))) (list element-or-atom element))
      (t element-or-atom)
      )
    )
  )

(defun merge-all-states (horizontal-matrix vertical-matrix xo)
  (append
   (make-all-states (generate-states horizontal-matrix 1 xo) xo nil)
   (make-all-states (generate-states vertical-matrix 1 xo) xo t)
  )
)

(defun make-all-states (all-states xo invert)
  (cond
   ((null all-states) nil)
   ((not (null (cadar all-states))) (append (make-states (caaar all-states) (cadaar all-states) (cadar all-states) xo invert) (make-all-states (cdr all-states) xo invert)))
   (t (make-all-states (cdr all-states) xo invert))
  )
)

(defun make-states (x y possible xo invert)
  (cond
   ((null possible) nil)
   ((atom (car possible)) (make-state x y (car possible) (cadr possible) xo invert))
   (t (cons (make-state x y (caar possible) (cadar possible) xo invert) (make-states x y (cdr possible) xo invert)))
  )
)

(defun make-state (x y x-new y-new xo invert)
  (cond
   ((and (not invert) xo) (progn 
         (check-sandwich
         (list (insert-state x-new y-new (remove-state x y (car states))) (cadr states))
         (list (insert-state y-new x-new (remove-state y x (car states-vertical))) (cadr states-vertical))
         (list x-new y-new)
         t
         )))
   ((and (not invert) (not xo)) (progn
         (check-sandwich 
         (list (car states) (insert-state x-new y-new (remove-state x y (cadr states))))
         (list (car states-vertical) (insert-state y-new x-new (remove-state y x (cadr states-vertical))))
         (list x-new y-new)
         nil
         )))
   ((and invert xo) (progn 
         (check-sandwich 
         (list (insert-state y-new x-new (remove-state y x (car states))) (cadr states))
         (list (insert-state x-new y-new (remove-state x y (car states-vertical))) (cadr states-vertical))
         (list y-new x-new)
         t
         )))
   ((and invert (not xo)) (progn
         (check-sandwich 
         (list (car states) (insert-state y-new x-new (remove-state y x (cadr states))))  
         (list (car states-vertical) (insert-state x-new y-new (remove-state x y (cadr states-vertical))))
         (list y-new x-new)
         nil
         )))
  )
)

(defun validate-state (source destination all-states)
  (cond
   ((null all-states) nil)
   ((and (equalp source (caar all-states)) (or (member destination (cadar all-states) :test 'equal) (equal destination (cadar all-states)))) t)
   (t (validate-state source destination (cdr all-states)))
  )
)


(defun generate-states (matrix lvl xo)
  (cond
   ((null matrix) nil)
   (t (append (generate-moves-for-row lvl nil nil (if xo 'x 'o) (car matrix) nil) (generate-states (cdr matrix) (1+ lvl) xo)))
  )
)

;funkcija za generisanje poteza u jednom redu, ulazni parametri - lvl (koji red evaluiramo), seclst (predzadnji element), lst (prethodni element), xo (kog igra?a evaluiramo), row - (kodirani red), res (rezultat), izlaz - lista sa u formatu (((trenutna figura - koordinate)((moguca nova pozicija 1) (moguca nova pozicija 2)...))(...))
(defun generate-moves-for-row (lvl seclst lst xo row res)

  (let* ((value (encode-element (car row) xo)))
    (cond
      ((and (null seclst) (null lst)) (generate-moves-for-row lvl lst value xo (cdr row) res))
      ((null row) res)
;      ((zerop value) (generate-moves-for-row lvl lst 0 xo (cdr row) res ))
      ((atom value) (cond
                      ((zerop value) (generate-moves-for-row lvl lst 0 xo (cdr row) res ))
                      ((listp lst) (generate-moves-for-row lvl lst value xo (cdr row) (append res (append-moves-for-row lvl lst value NIL))))
                      ((zerop lst)(cond
                                    ((and (not(null seclst)) (listp seclst))(generate-moves-for-row lvl lst value xo (cdr row) (append res (append-moves-for-row lvl seclst 0 T))))
                                    (t (generate-moves-for-row lvl lst value xo (cdr row) res))))
                      ))
      ((and(atom lst) (not (zerop lst))) (generate-moves-for-row lvl lst value xo (cdr row) (append res (append-moves-for-row lvl value lst T))))
       (t (generate-moves-for-row lvl lst value xo (cdr row) res))
       )
    )
)

;pomo?na funkcija za generate-moves for row, ulazni parametri - el (element koji ispitujemo), xo (kog igra?a evaluiramo), izlaz - ako je element koordinata igra?a koji nas interesuje onda vra?amo tu koordinatu, ako je od protivnika - vra?amo nulu, ako je broj slobodnih mesta - vra?amo ga takvog kakav je
(defun encode-element (el xo)

  (cond
    ((listp el)(cond
                 ((equalp (cadr el) xo) el)
                 (t 0)))
    (t el)
    )
)

(defun append-moves-for-row (lvl el size prev)
    (list(cons (list lvl (car el)) (list (cond
                                        ((zerop size) (list lvl (+ (car el) 2)))
                                        (t (loop for x from 1 to size collect (list lvl (cond
                                                                                          ((null prev)(+ (car el) x))
                                                                                          (t (- (car el) x))))))))))
)

(defun insert-state (x y rearanged-states)
  (cond
   ((null rearanged-states) (list (list x y)))
   ((or (and (equalp (caar rearanged-states) x) (< y (cadar rearanged-states))) (< x (caar rearanged-states))) (cons (list x y) rearanged-states))
   (t (cons (car rearanged-states) (insert-state x y (cdr rearanged-states))))
  )
)

(defun remove-state (x y changed-states)
  (cond
   ((null changed-states) nil)
   ((and (equalp (caar changed-states) x) (equalp y (cadar changed-states))) (cdr changed-states))
   (t (cons (car changed-states) (remove-state x y (cdr changed-states))))
  )
)

(defun change-state (x y x-new y-new xo)
  (cond
   (xo (progn 
         (setq states-vertical (list (insert-state y-new x-new (remove-state y x (car states-vertical))) (cadr states-vertical)))
         (setq states (list (insert-state x-new y-new (remove-state x y (car states))) (cadr states)))
         (let* ((new-state (check-sandwich states states-vertical (list x-new y-new) t)))
           (progn
             (setq states (car new-state))
             (setq states-vertical (cadr new-state))
           )
         )
         ))
   ((not xo) (progn
         (setq states-vertical (list (car states-vertical) (insert-state y-new x-new (remove-state y x (cadr states-vertical)))))
         (setq states (list (car states) (insert-state x-new y-new (remove-state x y (cadr states)))))
         (let* ((new-state (check-sandwich states states-vertical (list x-new y-new) nil)))
           (progn
             (setq states (car new-state))
             (setq states-vertical (cadr new-state))
           )
         )
         ))
  )
)

(defun initial-row (row column) 
  (cond
    ((zerop row) nil)
    (t (append (initial-row (- row 1) column) (list (list column row))))
    )
)

;;funkcija koja defnise inicijalno stanje table u formi
;;((lista figura prvog igraca) (lista figura drugog igraca))
(defun initial-states (dim)
  (list (append (initial-row dim 1) (initial-row dim 2)) (append (initial-row dim (- dim 1)) (initial-row dim dim)) )
)

(defun initial-states-vertical (dim)
  (list (initial-column dim) (initial-column-extend dim))
)

(defun initial-column (dim)
  (cond
   ((zerop dim) nil)
   (t (append (initial-column (- dim 1)) (list (list dim 1) (list dim 2))))
  )
)

(defun initial-column-extend (dim)
  (cond
   ((zerop dim) nil)
   (t (append (initial-column-extend (- dim 1)) (List (list dim (- dimension 1)) (list dim dimension))))
  )
)

(defun show-initial-matrix (dim)
  (print-matrix(states-to-matrix 1 dim  (initial-states dim)))
)

(defun print-matrix (mat indices)
  (cond
    ((null mat) NIL)
    (t (format t "~a " (car indices)) (print-row (car mat)) (print-matrix (cdr mat) (cdr indices)))
  )
)

(defun show-output (matrix)
  (format t "~%  ") 
  (show-indices dimension '(1 2 3 4 5 6 7 8 9 10 11))
  (print-matrix matrix '(A B C D E F G H I J K L))
)


(defun show-indices (ith lst)
  (cond
   ((equalp ith 1) (format t " ~a ~%" (car lst)))
   ((not (zerop ith)) (format t " ~a " (car lst)) (show-indices (1- ith) (cdr lst)))
   (t nil)
  )
)

;; funkcija za stampanje reda matrice, prosledjenog u formi liste atoma, gde
;; pozitivna vrednost oznacava prazna polja a sama velicina vrednosti
;; broj uzastopnih blanko polja, negativna vrednost oznacava "o", a nula "x"
(defun print-row (row)
  (cond
    ((null row) (fresh-line))
    ((atom (car row)) (print-blank (car row)) (print-row (cdr row)) )
   ;; ((zerop (car row)) (format t "x ") (print-row (cdr row)))
    (t (format t " ~a " (cadar row)) (print-row (cdr row)))
    )
)

;; Pomocna funkcija za stampanje reda,koristi se za uzastopno stampanje
;; blanko znaka.
(defun print-blank (blanks)
  (cond
    ((zerop blanks) nil)
    (t (format t " - ") (print-blank (- blanks 1)) )
  )
)

(defun states-to-matrix (lvl dim states)
  (cond
    ((> lvl dim ) nil)
    (t (let* ((value (encode-row lvl dim (car states) (cadr states) nil 0))) (append (list (car value)) (states-to-matrix (+ lvl 1) dim (cadr value)))))
    )
)

(defun encode-row (lvl dim fst sec res sum)
  (cond
    ((null (next-value lvl fst sec)) (cond
                                       ((equalp dim sum) (list res (list fst sec)))
                                       (t (list (append res (list(- dim sum))) (list fst sec)))))
    (t (let* ((value (next-value lvl fst sec)))
         (cond
           ((equalp dim (caar value))  (list (append res (cond ((equalp (- (caar value) 1) sum )(list (car value)))
                                                               (t (list (- (caar value) sum 1) (car value))))) (list (cadr value) (caddr value))))
           ((null res)(encode-row lvl dim (cadr value) (caddr value) (cond ((equalp (caar value) 1) (list(car value)))
                                                                           (t (list (- (caar value) 1) (car value)))) (caar value) ))
           ((equalp (- (caar value) 1) sum) (encode-row lvl dim (cadr value) (caddr value) (append res (list(car value))) (caar value)) )
           (t (encode-row lvl dim (cadr value) (caddr value) (append res (list (- (caar value) sum 1) (car value))) (caar value)))
           ))
       )
    )
)

(defun next-value (lvl fst sec)
  (cond
    ((equalp (caar fst) lvl) (cond
                                   ((equalp (caar sec) lvl) (cond
                                                              ((< (cadar fst) (cadar sec)) (list (list (cadar fst) 'x) (cdr fst) sec))
                                                             (t (list (list (cadar sec) 'o) fst (cdr sec)))))
                                   (t (list (list (cadar fst) 'x) (cdr fst) sec))))
    ((equalp (caar sec) lvl) (list (list (cadar sec) 'o) fst (cdr sec)))
    (t nil)
    )
)
