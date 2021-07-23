absoluteNumber :: Float -> Float
absoluteNumber x | (x < 0) = x * (-1)
                 | otherwise = x

main = do
    xString <- getLine
    let x = (read xString :: Float)
    print (absoluteNumber x)