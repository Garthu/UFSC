type Nome = String
type Disciplina = String
type Nota = Float
type Aluno = (Nome, Disciplina, Nota, Nota, Nota)

getNome :: Aluno -> Nome
getNome (nome, _, _, _, _) = nome

alunos = [("Nica", "Brabo", 1, 10, 10),
          ("Fernando", "O", 2, 10, 10),
          ("Roberto", "SO", 7, 7, 2)]
          
getAluno :: Int -> Aluno
getAluno numero = alunos!!numero

getNota :: Aluno -> Int -> Float
getNota (_, _, nota, _, _) 1 = nota
getNota (_, _, _, nota, _) 2 = nota
getNota (_, _, _, _, nota) 3 = nota

getMedia :: Aluno -> Float
getMedia aluno = ((getNota aluno 1) +
                  (getNota aluno 2) +
                  (getNota aluno 3)) / 3
                  
getMediaIndex :: Int -> Float
getMediaIndex numero = getMedia (getAluno numero)

getNotasTurma :: [Aluno] -> Float
getNotasTurma [] = 0 
getNotasTurma (a:b) = getMedia(a) + getNotasTurma(b)

getMediaTurma :: Float -> Float
getMediaTurma numero = (getNotasTurma alunos) / numero

getLength :: [Aluno] -> Float
getLength [] = 0
getLength (a:b) = 1 + getLength(b)



main = do
    print (getAluno 0)
    print (getMediaIndex 0)
    print (getMediaTurma (getLength alunos))