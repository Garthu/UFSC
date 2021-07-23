xor :: Bool -> Bool -> Bool
xor x y = ((\x y -> x /= y) x y)

main = do
    xString <- getLine
    let x = (read xString :: Bool)
    yString <- getLine
    let y = (read yString :: Bool)
    print((xor x y)