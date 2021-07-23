fibonacci :: Int -> Int
fibonacci x | (x == 0) = 0
            | (x == 1) = 1
            | otherwise = fibonacci (x - 1) + fibonacci (x - 2)

main = do
    xString <- getLine
    let x = (read xString :: Int)
    print(fibonacci x)