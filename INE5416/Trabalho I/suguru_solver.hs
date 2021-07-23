-- Trabalho 1 - Suguru Solver
-- Alunos: José Luiz de Souza - 19100533
--         Samuel Cardoso - 19100544
--         Thiago Zimmermann Loureiro Chaves - 19100547

-- Define as subregões de cada regiao, onde para cada índices (x,y)
-- existe um value definindo qual a subregião que aquela coordenada
-- pertence, esta função será um função auxiliar para definir as
-- subregiões de cada região definida na função 'entrada'
regiao::Int -> [[Int]]
regiao 5 = [
    [0,1,2,2,2],
    [0,1,1,2,2],
    [3,1,4,4,4],
    [3,3,3,4,4],
    [3,5,5,5,5]]

regiao 6 = [
    [0,0,0,2,2,2],
    [1,1,0,0,2,2],
    [3,3,3,4,4,4],
    [7,3,6,4,4,5],
    [7,7,6,6,5,5],
    [7,7,6,6,5,5]]

regiao 7 = [
    [0,0,1,1,2,2,2],
    [0,0,3,3,3,2,2],
    [0,4,4,3,5,6,6],
    [7,4,4,5,5,5,6],
    [7,7,4,8,5,9,6],
    [7,7,8,8,8,9,6],
    [10,10,10,8,9,9,9]]

regiao 8 = [
    [0,0,0,3,4,4,5,5],
    [0,2,2,3,4,4,5,5],
    [2,2,3,3,4,6,6,5],
    [2,7,7,3,8,8,6,6],
    [10,10,7,7,8,9,9,6],
    [11,10,10,7,8,13,9,9],
    [11,11,10,12,8,13,13,9],
    [11,11,12,12,12,12,13,13]]

-- Armazena os valores inciais da matriz, servido
-- de entrada. Este seria o puzzle base que deverá
-- ser resolvido
entrada::Int -> [[Int]]
entrada 5 = [
    [0,0,0,0,0],
    [0,0,1,0,4],
    [0,0,0,0,0],
    [4,0,0,0,0],
    [0,0,0,0,0]]

entrada 6 = [
    [0,5,0,0,0,0],
    [0,0,0,0,4,5],
    [0,0,0,0,0,0],
    [5,1,0,3,0,0],
    [0,0,0,0,0,2],
    [4,0,2,0,0,0]]

entrada 7 = [
    [1,0,0,0,0,1,0],
    [0,0,3,0,0,0,0],
    [0,0,0,0,5,0,0],
    [3,0,2,0,2,0,2],
    [2,0,0,0,0,0,0],
    [0,0,5,0,0,5,0],
    [1,0,0,0,1,0,0]]

entrada 8 = [
    [0,0,0,3,0,0,2,0],
    [4,0,0,0,0,0,0,0],
    [0,2,0,0,0,0,0,0],
    [0,1,5,0,0,1,5,0],
    [0,2,0,0,0,0,0,0],
    [0,0,0,0,4,0,0,4],
    [0,0,0,0,0,3,0,0],
    [0,5,0,0,0,5,0,0]]

---------------------------------Setar valor na Matriz----------------------------------

-- Percorre um linha da Matriz que aqui está como um vetor
-- até encontrar o índice certo, quando o encontra, seta
-- o valor para 'value'
setaValorNaLinhaDaMatriz::[Int] -> Int -> Int -> Int -> [Int]
setaValorNaLinhaDaMatriz [] _ _ _= []
setaValorNaLinhaDaMatriz (a:b) value y at | (at == y) = value:b
                                    | otherwise = a:(setaValorNaLinhaDaMatriz b value y (at+1))

-- Percorre a matriz até a linha onde o valor deve ser de-
-- finido, e ali chama a função setaValorNaLinhaDaMatriz,
-- para que a mesma defina o valor na matriz
buscaCoordenada::[[Int]] -> Int -> Int -> Int -> Int -> [[Int]]
buscaCoordenada [] _ _ _ _ = []
buscaCoordenada (a:b) value x y at | (x == at) = (setaValorNaLinhaDaMatriz a value y 0):b
                                   | otherwise = a:(buscaCoordenada b value x y (at + 1))
-----------------------------------------------------------------------------------------


--------------------------------Funções auxiliares---------------------------------------

-- Como no nome do bloco diz, essa função vai ser respon-
-- sável por retornar elementos de uma matriz, podendo
-- ela ser a entrada ou a regiao, então servindo para
-- inúmeros propósitos
retornaElementoMatriz::[[Int]] -> Int -> Int -> Int
retornaElementoMatriz matrix x y = (matrix !! x) !! y

-- Nesta função é importante definir quais serão as entradas,
-- pois elas mudam total o sentido do que é feito, nela, a 
-- matriz que será passada será a matriz de regiões, portanto
-- nela está guardado em cada coordenada, qual a região que
-- a coordenada pertence, já no vetor teremos os pesos de
-- cada região armazenados em índices respectivos, portanto
-- a operação realizada é vetor[matriz[x][y]]
retornaPesoDaRegiao::[[Int]] -> [Int] -> Int -> Int -> Int
retornaPesoDaRegiao matrix vector x y = vector !! (retornaElementoMatriz matrix x y)
-----------------------------------------------------------------------------------------

----------------------Funções de retorno de Qntd Região----------------------------------

-- Retorna o maior número encontrado na linha
retornaMaiorValorNaLinha::[Int] -> Int -> Int
retornaMaiorValorNaLinha [] max = max
retornaMaiorValorNaLinha (a:b) max | (a > max) = retornaMaiorValorNaLinha b a
                        | otherwise = retornaMaiorValorNaLinha b max

-- Retorna o maior valor encontrado nas linhas da matriz
retornaMaiorValorNaMatriz::[[Int]] -> Int -> Int
retornaMaiorValorNaMatriz [] max = max
retornaMaiorValorNaMatriz (a:b) max | (retornaMaiorValorNaLinha a 0 > max) = retornaMaiorValorNaMatriz b (retornaMaiorValorNaLinha a 0)
                        | otherwise = retornaMaiorValorNaMatriz b max

-- Retorna o maior valor encontrado na matrix + 1, pois
-- na matriz os valores começam em 0
retornaQntdRegioes::[[Int]] -> Int
retornaQntdRegioes [] = 0
retornaQntdRegioes matrix = 1 + (retornaMaiorValorNaMatriz matrix 0)
-----------------------------------------------------------------------------------------

--------------------------------------------------------

-- Verifica quantas vezes o value aparece na linha
-- e retorna o total de vezes
retornaVezesNaLinha::[Int] -> Int -> Int
retornaVezesNaLinha [] _ = 0
retornaVezesNaLinha (a:b) value | (value == a) = 1 + retornaVezesNaLinha b value
                                  | otherwise = retornaVezesNaLinha b value

-- Verifica quantas vezes o value aparece na matriz
-- usando com função auxiliar a função retornaVezesNaLinha
retornaVezesNaMatriz::[[Int]] -> Int -> Int
retornaVezesNaMatriz [] _ = 0
retornaVezesNaMatriz (a:b) value = (retornaVezesNaLinha a value) + (retornaVezesNaMatriz b value)

-- Função auxiliar da responsável por criar o vetor em si
defineVetorDePesos::[[Int]] -> Int -> Int -> [Int]
defineVetorDePesos matrix regionValue qntRegions | (regionValue == qntRegions) = []
                                                     | otherwise = (retornaVezesNaMatriz matrix regionValue):[] ++ (defineVetorDePesos matrix (regionValue+1) qntRegions)

-- Define o vetor onde os índices representam o peso da
-- região, então se vetor[0] = 5, significa que o tamanho
-- da região 1 é 5.
retornaVetorDePesos::[[Int]] -> [Int]
retornaVetorDePesos [] = []
retornaVetorDePesos matrix = do
                          let x = retornaQntdRegioes matrix
                          defineVetorDePesos matrix 0 x
-----------------------------------------------------------------------------------------


-------------------Funções para determinar o tamanho-------------------------------------

-- Percorre a linha a fim de determinar o tamanho da linha que se encontra
retornaTamanhoLinha::[Int] -> Int
retornaTamanhoLinha [] = 0
retornaTamanhoLinha (a:b) = 1 + retornaTamanhoLinha b

-- Utiliza da função anterior , para determinar o tamanho da matriz
retornaTamanhoMatriz::[[Int]] -> Int
retornaTamanhoMatriz (a:b) = retornaTamanhoLinha a

------------------------------------------------------------------------------------------

---------------------- Funções para comparação -------------------------------------------

-- Verifica se o elemento e válido e caso verdadeiro compara dois elementos, retornando um Booleano
comparaElementos::[[Int]] -> Int -> Int -> Int -> Bool
comparaElementos matrix value x y | (x < 0) = False
                                 | (y < 0) = False
                                 | (x == retornaTamanhoMatriz matrix) = False
                                 | (y == retornaTamanhoMatriz matrix) = False
                                 | (value == (retornaElementoMatriz matrix x y)) = True
                                 | otherwise = False

-- Verifica os 8 vizinhos do elementos, comparando os atraves da funçao compareElementos
temVizinhos::[[Int]] -> Int -> Int -> Int -> Bool
temVizinhos matrix value x y = do
                               let a = comparaElementos matrix value x (y-1)
                               let b = comparaElementos matrix value x (y+1)
                               let c = comparaElementos matrix value (x-1) y
                               let d = comparaElementos matrix value (x+1) y
                               let e = comparaElementos matrix value (x-1) (y-1)
                               let f = comparaElementos matrix value (x-1) (y+1)
                               let g = comparaElementos matrix value (x+1) (y-1)
                               let h = comparaElementos matrix value (x+1) (y+1)
                               a || b || c || d || e || f || g || h

-- Verifica se tem o mesmo elemento na linha na região
temMesmoValorNaRegiaoLinha::[Int] -> [Int] -> Int -> Int -> Bool
temMesmoValorNaRegiaoLinha [] [] _ _ = False
temMesmoValorNaRegiaoLinha (a:b) (c:d) regionValue dataValue| (c == regionValue) && (a == dataValue) = True
                        | otherwise = temMesmoValorNaRegiaoLinha b d regionValue dataValue

--verifica se tem o mesmo elemento na matriz da região
temMesmoValorNaRegiaoMatriz::[[Int]] -> [[Int]] -> Int -> Int -> Bool
temMesmoValorNaRegiaoMatriz [] [] _ _ = False
temMesmoValorNaRegiaoMatriz (a:b) (c:d) regionValue dataValue | (temMesmoValorNaRegiaoLinha a c regionValue dataValue ) = True
                          | otherwise = temMesmoValorNaRegiaoMatriz b d regionValue dataValue

---------------------------Validação para o Backtracking---------------------------------

-- Verifica um elemento (x,y) da matriz de entrada, se ele for 0
-- então significa que ali pode-se testar um novo valor, então
-- verifica-se se o valor 'currentValue' é encontrado nos vizinhos
-- e se aquele valor é encontrado na região da coordenada atual
-- se for encontrado significa que aquele valor é inválido para a
-- posição naquele instante (já que em uma outra tentativa ele po-
-- de ser válido sim)
validaPonto::[[Int]] -> [[Int]] -> Int -> Int -> Int -> Bool
validaPonto inputMatrix regionMatrix x y currentValue | ((retornaElementoMatriz inputMatrix  x y) == 0) = do
                                                                            if (temVizinhos inputMatrix currentValue x y) || (temMesmoValorNaRegiaoMatriz inputMatrix regionMatrix (retornaElementoMatriz regionMatrix x y) currentValue) then
                                                                                False
                                                                            else
                                                                                True
                                                                        | otherwise = False
------------------------------------------------------------------------------------------

-- Verifica se as linhas são iguais
comparaLinha::[Int] -> [Int] -> Bool
comparaLinha [] [] = True
comparaLinha (a:b) (c:d) | (a == c) = comparaLinha b d
                        | otherwise = False

--Compara se as Matrizes são iguais atraves da chamada da função comparaLinha
comparaMatriz::[[Int]] -> [[Int]] -> Bool
comparaMatriz [] [] = True
comparaMatriz [] _ = False
comparaMatriz _ [] = False
comparaMatriz (a:b) (c:d) | (comparaLinha a c) = comparaMatriz b d
                          | otherwise = False

-- Compara duas matrizes, se forem iguais um novo número é testado,
-- caso contrário a matriz com valor alterado é retornada
solverCompare::[[Int]] -> [[Int]] -> [[Int]] -> [[Int]] -> [Int] -> Int -> Int -> Int-> [[Int]]
solverCompare matrix inputMatrix newInputMatrix regionMatrix regionVector x y currentValue | (comparaMatriz newInputMatrix matrix) = solverSuguru inputMatrix regionMatrix regionVector x y (currentValue+1) 
                    | otherwise = matrix

-- Verifica a próxima linha chamando a função auxiliar solverCompare
-- mantendo o X fixo
solverSuguruItemCompareX::[[Int]] -> [[Int]] -> [[Int]] -> [Int] -> Int -> Int -> Int-> [[Int]]
solverSuguruItemCompareX inputMatrix newInputMatrix regionMatrix regionVector x y currentValue = solverCompare (solverSuguru newInputMatrix regionMatrix regionVector 0 (y+1) 1) inputMatrix newInputMatrix regionMatrix regionVector x y currentValue

-- Verifica a próxima linha chamando a função auxiliar solverCompare
-- mantendo o Y fixo
solverSuguruItemCompareY::[[Int]] -> [[Int]] -> [[Int]] -> [Int] -> Int -> Int -> Int-> [[Int]]
solverSuguruItemCompareY inputMatrix newInputMatrix regionMatrix regionVector x y currentValue = solverCompare (solverSuguru newInputMatrix regionMatrix regionVector (x+1) y 1) inputMatrix newInputMatrix regionMatrix regionVector x y currentValue

-- Verifica se chegou no final da matriz e retorna a matriz em questão,
-- caso contrário continua as verificações indo em outras direções
solverSuguruItem::[[Int]] -> [[Int]] -> [[Int]] -> [Int] -> Int -> Int -> Int-> [[Int]]
solverSuguruItem inputMatrix newInputMatrix regionMatrix regionVector x y currentValue | ((x+1) == retornaTamanhoMatriz inputMatrix) && ((y+1) == retornaTamanhoMatriz inputMatrix) = newInputMatrix
                                                                                    | ((x+1) == retornaTamanhoMatriz inputMatrix) = solverSuguruItemCompareX inputMatrix newInputMatrix regionMatrix regionVector x y currentValue
                                                                                    | otherwise = solverSuguruItemCompareY inputMatrix newInputMatrix regionMatrix regionVector x y currentValue

-- Passa para a próxima coordenada da matriz
solverSuguruItemOtherwise::[[Int]] -> [[Int]] -> [Int] -> Int -> Int -> Int-> [[Int]]
solverSuguruItemOtherwise inputMatrix regionMatrix regionVector x y currentValue | ((x+1) == retornaTamanhoMatriz inputMatrix) && ((y+1) == retornaTamanhoMatriz inputMatrix) = inputMatrix
                                                                                    | ((x+1) == retornaTamanhoMatriz inputMatrix) = solverSuguru inputMatrix regionMatrix regionVector 0 (y+1) 1
                                                                                    | otherwise = solverSuguru inputMatrix regionMatrix regionVector (x+1) y 1

-- Função principal responsável pelo backtracking, encaminhando
-- as verificações e setando valores
solverSuguru::[[Int]] -> [[Int]] -> [Int] -> Int -> Int -> Int-> [[Int]]
solverSuguru inputMatrix regionMatrix regionVector x y currentValue | (currentValue > ((retornaPesoDaRegiao regionMatrix regionVector x y))) = inputMatrix
                                                                    | (validaPonto inputMatrix regionMatrix x y currentValue) = do
                                                                        let newInputMatrix = buscaCoordenada inputMatrix currentValue x y 0
                                                                        solverSuguruItem inputMatrix newInputMatrix regionMatrix regionVector x y currentValue

                                                                    | ((retornaElementoMatriz inputMatrix x y) == 0) = solverSuguru inputMatrix regionMatrix regionVector x y (currentValue+1) 
                                                                    | otherwise = solverSuguruItemOtherwise inputMatrix regionMatrix regionVector x y currentValue
                                                                        

-- Inicia a solução por backtracking, disponibilizando para a função
-- solverSuguru a matriz de entrada, a matriz de regiões, o vetor de
-- pesos, o valor de (x,y) inicial e um primeiro chute de valor
solver::[[Int]] -> [[Int]]
solver matrix = do
                let regiaoDaMatriz = regiao (retornaTamanhoMatriz matrix)
                let vetorDePesos = retornaVetorDePesos regiaoDaMatriz
                solverSuguru matrix regiaoDaMatriz vetorDePesos 0 0 1

main = do
    print (solver (entrada 5))
    print (solver (entrada 6))
    print (solver (entrada 7))
    print (solver (entrada 8))
