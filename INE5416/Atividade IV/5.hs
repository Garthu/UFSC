isApproved :: Float -> Float -> Float -> String
isApproved firstGrade secondGrade thirdGrade | 
        (((firstGrade + secondGrade + thirdGrade) / 3) >= 6) = "Aprovado"
        | (((firstGrade + secondGrade + thirdGrade) / 3) < 6) = "Reprovado"

main = do
    firstGradeString <- getLine
    let firstGrade = (read firstGradeString :: Float)
    secondGradeString <- getLine
    let secondGrade = (read secondGradeString :: Float)
    thirdGradeString <- getLine
    let thirdGrade = (read thirdGradeString :: Float)
    print (isApproved firstGrade secondGrade thirdGrade)