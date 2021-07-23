triangleArea :: Float -> Float -> Float
triangleArea height base = height * base / 2

main = do
    heightString <- getLine
    let height = (read heightString :: Float)
    baseString <- getLine
    let base = (read baseString :: Float)
    print (triangleArea height base)