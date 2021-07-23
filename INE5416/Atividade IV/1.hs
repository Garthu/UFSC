raise :: Int -> Int -> Int
raise numberX numberY = numberX ^ numberY

main = do
    xString <- getLine
    let x = (read xString :: Int)
    yString <- getLine
    let y = (read yString :: Int)
    print (raise x y)