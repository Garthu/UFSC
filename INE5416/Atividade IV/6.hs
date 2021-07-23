validTriangle :: Int -> Int -> Int -> String
validTriangle a b c |
    (((b - c) < a && a < (b + c)) ||
     ((a - b) < b && b < (a + c)) ||
     ((a - b) < c && c < (a + b))) = "Pode ser um."
    | otherwise = "Nao pode ser um."

main = do
    firstSideString <- getLine
    let firstSide = (read firstSideString :: Int)
    secondSideString <- getLine
    let secondSide = (read secondSideString :: Int)
    thirdSideString <- getLine
    let thirdSide = (read thirdSideString :: Int)
    print (validTriangle firstSide secondSide thirdSide)
