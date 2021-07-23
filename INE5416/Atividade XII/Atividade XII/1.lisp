(defun soma (lista1)
    (if (null lista1)
        0
        (+ (car lista1) (soma (cdr lista1))))
)

(defun main()
    (write-line (write-to-string (soma '(1 2 3 4 5))))
)

(main)