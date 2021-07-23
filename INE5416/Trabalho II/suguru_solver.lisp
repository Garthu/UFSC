; Trabalho 2 - Suguru Solver
; Alunos: José Luiz de Souza - 19100533
;         Samuel Cardoso - 19100544
;         Thiago Zimmermann Loureiro Chaves - 19100547

; Define as subregões de cada regiao, onde para cada índices (x,y)
; existe um value definindo qual a subregião que aquela coordenada
; pertence, esta função será um função auxiliar para definir as
; subregiões de cada região definida na função 'entrada'

(defstruct matriz
    regiao
    entrada
)

; Armazena os valores inciais da matriz, servido
; de entrada. Este seria o puzzle base que deverá
; ser resolvido

(setq matriz5
    (make-matriz
        :regiao (list '(0 1 2 2 2)
                      '(0 1 1 2 2)
                      '(3 1 4 4 4)
                      '(3 3 3 4 4)
                      '(3 5 5 5 5))
        :entrada (list '(0 0 0 0 0)
                       '(0 0 1 0 4)
                       '(0 0 0 0 0)
                       '(4 0 0 0 0)
                       '(0 0 0 0 0))
    )
)

(setq matriz6
    (make-matriz
        :regiao (list '(0 0 0 2 2 2)
                      '(1 1 0 0 2 2)
                      '(3 3 3 4 4 4)
                      '(7 3 6 4 4 5)
                      '(7 7 6 6 5 5)
                      '(7 7 6 6 5 5))
        :entrada (list '(0 5 0 0 0 0)
                       '(0 0 0 0 4 5)
                       '(0 0 0 0 0 0)
                       '(5 1 0 3 0 0)
                       '(0 0 0 0 0 2)
                       '(4 0 2 0 0 0))
    )
)

(setq matriz7
    (make-matriz
        :regiao (list '(0 0 1 1 2 2 2)
                      '(0 0 3 3 3 2 2)
                      '(0 4 4 3 5 6 6)
                      '(7 4 4 5 5 5 6)
                      '(7 7 4 8 5 9 6)
                      '(7 7 8 8 8 9 6)
                      '(10 10 10 8 9 9 9))
        :entrada (list '(1 0 0 0 0 1 0)
                       '(0 0 3 0 0 0 0)
                       '(0 0 0 0 5 0 0)
                       '(3 0 2 0 2 0 2)
                       '(2 0 0 0 0 0 0)
                       '(0 0 5 0 0 5 0)
                       '(1 0 0 0 1 0 0))
    )
)

(setq matriz8
    (make-matriz
        :regiao (list '(0 0 0 3 4 4 5 5)
                      '(0 2 2 3 4 4 5 5)
                      '(2 2 3 3 4 6 6 5)
                      '(2 7 7 3 8 8 6 6)
                      '(10 10 7 7 8 9 9 6)
                      '(11 10 10 7 8 13 9 9)
                      '(11 11 10 12 8 13 13 9)
                      '(11 11 12 12 12 12 13 13))
        :entrada (list '(0 0 0 3 0 0 2 0)
                       '(4 0 0 0 0 0 0 0)
                       '(0 2 0 0 0 0 0 0)
                       '(0 1 5 0 0 1 5 0)
                       '(0 2 0 0 0 0 0 0)
                       '(0 0 0 0 4 0 0 4)
                       '(0 0 0 0 0 3 0 0)
                       '(0 5 0 0 0 5 0 0 ))
    )
)

;;;;;;;;;;;;;;;;-Setar valor na Matriz;;;;;;;;;;;;;;;;;

; Percorre um linha da Matriz que aqui está como um vetor
; até encontrar o índice certo, quando o encontra, seta
; o valor para 'value'
(defun setaValorNaLinhaDaMatriz(lista value y at)
    (if (null lista)
        (list '())
        (if (= at y)
            (cons value (cdr lista))
            (cons (car lista) (setaValorNaLinhaDaMatriz (cdr lista) value y (+ at 1)))
        )
    )
)


; Percorre a matriz até a linha onde o valor deve ser de-
; finido, e ali chama a função setaValorNaLinhaDaMatriz,
; para que a mesma defina o valor na matriz
(defun buscaCoordenada(matriz_value value x y at)
    (if (null matriz_value)
        (list '())
        (if (= x at)
            (cons (setaValorNaLinhaDaMatriz (car matriz_value) value y 0) (cdr matriz_value))
            (cons (car matriz_value) (buscaCoordenada (cdr matriz_value) value x y (+ at 1)))
        )
    )
)

;;;;;;;;;;;;;;;;Funções auxiliares;;;;;;;;;;;;;;;;;;;-

; Como no nome do bloco diz, essa função vai ser respon-
; sável por retornar elementos de uma matriz, podendo
; ela ser a entrada ou a regiao, então servindo para
; inúmeros propósitos
(defun retornaElementoDaLinha(lista y at)
    (if (null lista)
        -1
        (if (= y at)
            (car lista)
            (retornaElementoDaLinha (cdr lista) y (+ 1 at))
        )
    )
)

(defun retornaElementoMatriz(matriz_value x y at)
    (if (null matriz_value)
        -1
        (if (= x at)
            (retornaElementoDaLinha (car matriz_value) y 0)
            (retornaElementoMatriz (cdr matriz_value) x y (+ at 1))
        )
    )
)

; Nesta função é importante definir quais serão as entradas,
; pois elas mudam total o sentido do que é feito, nela, a 
; matriz que será passada será a matriz de regiões, portanto
; nela está guardado em cada coordenada, qual a região que
; a coordenada pertence, já no vetor teremos os pesos de
; cada região armazenados em índices respectivos, portanto
; a operação realizada é vetor[matriz[x][y]]
(defun retornaPesoDaRegiao(matriz_value vetor_de_pesos x y)
    (if (null matriz_value)
        -1
        (if (null vetor_de_pesos)
            -1
            (retornaElementoDaLinha vetor_de_pesos (retornaElementoMatriz matriz_value x y 0) 0)
        )
    )
)

;;;;;;;;;;;Funções de retorno de Qntd Região;;;;;;;;;;;;;;;;;

; Retorna o maior número encontrado na linha
(defun retornaMaiorValorNaLinha(lista maximo)
    (if (null lista)
        maximo
        (if (> (car lista) maximo)
            (retornaMaiorValorNaLinha (cdr lista) (car lista))
            (retornaMaiorValorNaLinha (cdr lista) maximo)
        )
    )
)

; Retorna o maior valor encontrado nas linhas da matriz
(defun retornaMaiorValorNaMatriz(matriz_value maximo)
    (if (null matriz_value)
        maximo
        (if (> (retornaMaiorValorNaLinha (car matriz_value) 0) maximo)
            (retornaMaiorValorNaMatriz (cdr matriz_value) (retornaMaiorValorNaLinha (car matriz_value) 0))
            (retornaMaiorValorNaMatriz (cdr matriz_value) maximo)
        )
    )
)

; Retorna o maior valor encontrado na matrix + 1, pois
; na matriz os valores começam em 0
(defun retornaQntdRegioes(matriz_value)
    (if (null matriz_value)
        0
        (+ 1 (retornaMaiorValorNaMatriz matriz_value 0))
    )
)

; Verifica quantas vezes o value aparece na linha
; e retorna o total de vezes
(defun retornaVezesNaLinha(lista value)
    (if (null lista)
        0
        (if (= value (car lista))
            (+ 1 (retornaVezesNaLinha (cdr lista) value))
            (retornaVezesNaLinha (cdr lista) value)
        )
    )
)

; Verifica quantas vezes o value aparece na matriz
; usando com função auxiliar a função retornaVezesNaLinha
(defun retornaVezesNaMatriz(matriz_value value)
    (if (null matriz_value)
        0
        (+ (retornaVezesNaLinha (car matriz_value) value) (retornaVezesNaMatriz (cdr matriz_value) value))
    )
)

; Função auxiliar da responsável por criar o vetor em si
(defun defineVetorDePesos(matriz_value region_value qnt_regions)
    (if (= qnt_regions region_value)
        NIL
        (cons (retornaVezesNaMatriz matriz_value region_value) (defineVetorDePesos matriz_value (+ 1 region_value) qnt_regions))
    )
)

; Define o vetor onde os índices representam o peso da
; região, então se vetor[0] = 5, significa que o tamanho
; da região 1 é 5.
(defun retornaVetorDePesos(matriz_value)
    (if (null matriz_value)
        NIL
        (defineVetorDePesos matriz_value 0 (retornaQntdRegioes matriz_value))
    )
)

;;;;;;;;;Funções para determinar o tamanho;;;;;;;;;;;;;;;;;;

; Percorre a linha a fim de determinar o tamanho da linha que se encontra
(defun retornaTamanhoLinha(lista)
    (if (null lista)
        0
        (+ 1 (retornaTamanhoLinha (cdr lista)))
    )
)
; Utiliza da função anterior , para determinar o tamanho da matriz
(defun retornaTamanhoMatriz(matriz_value)
    (if (null matriz_value)
        0
        (retornaTamanhoLinha (car matriz_value))
    )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;; Funções para comparação ;;;;;;;;;;;;;;;;;;;;;

; Verifica se o elemento e válido e caso verdadeiro compara dois elementos, retornando um Booleano
(defun comparaElementos(matriz_value value x y)
    (if (< x 0)
        NIL
        (if (< y 0)
            NIL
            (if (= x (retornaTamanhoMatriz matriz_value))
                NIL
                (if (= y (retornaTamanhoMatriz matriz_value))
                    NIL
                    (if (= value (retornaElementoMatriz matriz_value x y 0))
                        T
                        NIL
                    )
                )
            )
        )
    )
)

; Verifica os 8 vizinhos do elementos, comparando os atraves da funçao compareElementos
(defun temVizinhos(matriz_value value x y)
    (or (comparaElementos matriz_value value x (- y 1))
    (or (comparaElementos matriz_value value x (+ y 1))
    (or (comparaElementos matriz_value value (- x 1) y)
    (or (comparaElementos matriz_value value (+ x 1) y)
    (or (comparaElementos matriz_value value (- x 1) (- y 1))
    (or (comparaElementos matriz_value value (- x 1) (+ y 1))
    (or (comparaElementos matriz_value value (+ x 1) (- y 1))
    (or (comparaElementos matriz_value value (+ x 1) (+ y 1))
    ))))))))
)

; Verifica se tem o mesmo elemento na linha na região
(defun temMesmoValorNaRegiaoLinha(lista1 lista2 region_value data_value)
    (if (and (null lista1) (null lista2))
        NIL
        (if (and (= (car lista2) region_value) (= (car lista1) data_Value))
            T
            (temMesmoValorNaRegiaoLinha (cdr lista1) (cdr lista2) region_value data_value)
        )
    )
)

;verifica se tem o mesmo elemento na matriz da região
(defun temMesmoValorNaRegiaoMatriz(matriz1 matriz2 region_value data_value)
    (if (and (null matriz1) (null matriz2))
        NIL
        (if (temMesmoValorNaRegiaoLinha (car matriz1) (car matriz2) region_value data_value)
            T
            (temMesmoValorNaRegiaoMatriz (cdr matriz1) (cdr matriz2) region_value data_value)
        )
    )
)

; Verifica um elemento (x,y) da matriz de entrada, se ele for 0
; então significa que ali pode-se testar um novo valor, então
; verifica-se se o valor 'currentValue' é encontrado nos vizinhos
; e se aquele valor é encontrado na região da coordenada atual
; se for encontrado significa que aquele valor é inválido para a
; posição naquele instante (já que em uma outra tentativa ele po-
; de ser válido sim)
(defun validaPonto(input_matriz region_matriz x y current_value)
    (if (= (retornaElementoMatriz input_matriz x y 0) 0)
        (if (or (temVizinhos input_matriz current_value x y) (temMesmoValorNaRegiaoMatriz input_matriz region_matriz (retornaElementoMatriz region_matriz x y 0) current_value))
            NIL
            T
        )
        NIL
    )
)

; Verifica se as linhas são iguais
(defun comparaLinha(lista1 lista2)
    (if (and (null lista1) (null lista2))
        T
        (if (= (car lista1) (car lista2))
            (comparaLinha (cdr lista1) (cdr lista2))
            NIL
        )
    )
)

;Compara se as Matrizes são iguais atraves da chamada da função comparaLinha
(defun comparaMatriz(matriz1 matriz2)
    (if (and (null matriz1) (null matriz2))
        T
        (if (and (not (null matriz1)) (null matriz2))
            NIL
            (if (and (null matriz1) (not (null matriz2)))
                NIL
                (if (comparaLinha (car matriz1) (car matriz2))
                    (comparaMatriz (cdr matriz1) (cdr matriz2))
                    NIL
                )
            )
        )
    )
)

; Compara duas matrizes, se forem iguais um novo número é testado,
; caso contrário a matriz com valor alterado é retornada
(defun solverCompare(matriz_value input_matriz new_input_matriz region_matriz region_vector x y  current_value)
    (if (comparaMatriz new_input_matriz matriz_value)
        (solverSuguru input_matriz region_matriz region_vector x y (+ current_value 1))
        matriz_value
    )
)

; Verifica a próxima linha chamando a função auxiliar solverCompare
; mantendo o X fixo
(defun solverSuguruItemCompareX(input_matriz new_input_matriz region_matriz region_vector x y current_value)
    (solverCompare (solverSuguru new_input_matriz region_matriz region_vector 0 (+ 1 y) 1) input_matriz new_input_matriz region_matriz region_vector x y current_value)
)

; Verifica a próxima linha chamando a função auxiliar solverCompare
; mantendo o Y fixo
(defun solverSuguruItemCompareY(input_matriz new_input_matriz region_matriz region_vector x y current_value)
    (solverCompare (solverSuguru new_input_matriz region_matriz region_vector (+ 1 x) y 1) input_matriz new_input_matriz region_matriz region_vector x y current_value)
)

; Verifica se chegou no final da matriz e retorna a matriz em questão,
; caso contrário continua as verificações indo em outras direções
(defun solverSuguruItem(input_matriz new_input_matriz region_matriz region_vector x y current_value)
    (if (and (= (+ 1 x) (retornaTamanhoMatriz input_matriz)) (= (+ 1 y) (retornaTamanhoMatriz input_matriz)))
        new_input_matriz
        (if (= (+ 1 x) (retornaTamanhoMatriz input_matriz))
            (solverSuguruItemCompareX input_matriz new_input_matriz region_matriz region_vector x y current_value)
            (solverSuguruItemCompareY input_matriz new_input_matriz region_matriz region_vector x y current_value)
        )
    )
)

; Passa para a próxima coordenada da matriz
(defun solverSuguruItemOtherwise(input_matriz region_matriz region_vector x y current_value)
    (if (and (= (+ 1 x) (retornaTamanhoMatriz input_matriz)) (= (+ 1 y) (retornaTamanhoMatriz input_matriz)))
        input_matriz
        (if (= (+ 1 x) (retornaTamanhoMatriz input_matriz))
            (solverSuguru input_matriz region_matriz region_vector 0 (+ 1 y) 1)
            (solverSuguru input_matriz region_matriz region_vector (+ 1 x) y 1)
        )
    )
)

; Função principal responsável pelo backtracking, encaminhando
; as verificações e setando valores
(defun solverSuguru(input_matriz region_matriz region_vector x y current_value)
    (if (> current_value (retornaPesoDaRegiao region_matriz region_vector x y))
        input_matriz
        (if (validaPonto input_matriz region_matriz x y current_value)
            (solverSuguruItem input_matriz (buscaCoordenada input_matriz current_value x y 0) region_matriz region_vector x y current_value)
            (if (= 0 (retornaElementoMatriz input_matriz x y 0))
                (solverSuguru input_matriz region_matriz region_vector x y (+ 1 current_value))
                (solverSuguruItemOtherwise input_matriz region_matriz region_vector x y current_value)
            )
        )
    )
)

; Inicia a solução por backtracking, disponibilizando para a função
; solverSuguru a matriz de entrada, a matriz de regiões, o vetor de
; pesos, o valor de (x,y) inicial e um primeiro chute de valor
(defun solver(matriz_value region_value)
    (solverSuguru matriz_value region_value (retornaVetorDePesos region_value) 0 0 1)
)

(defun main()
    (write-line "Solução suguru de tamanho 5")
    (write-line "")
    (write-line (write-to-string (solver (matriz-entrada matriz5) (matriz-regiao matriz5))))
    (write-line "")
    (write-line "Solução suguru de tamanho 6")
    (write-line "")
    (write-line (write-to-string (solver (matriz-entrada matriz6) (matriz-regiao matriz6))))
    (write-line "")
    (write-line "Solução suguru de tamanho 7")
    (write-line "")
    (write-line (write-to-string (solver (matriz-entrada matriz7) (matriz-regiao matriz7))))
    (write-line "")
    (write-line "Solução suguru de tamanho 8")
    (write-line "")
    (write-line (write-to-string (solver (matriz-entrada matriz8) (matriz-regiao matriz8))))
)

(main)
