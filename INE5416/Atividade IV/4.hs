xor :: Bool -> Bool -> Bool
xor fB sB = not ((fB && sB) || (not fB && not sB))

main = do
    firstBoolString <- getLine
    let firstBool = (read firstBoolString :: Bool)
    secondBoolString <- getLine
    let secondBool = (read secondBoolString :: Bool)
    print (xor firstBool secondBool)