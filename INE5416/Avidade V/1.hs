soma :: [Int] -> Int
soma [] = 0
soma (a:b) = a + (soma b)

read_list :: IO [Int]
read_list = fmap(map read.words) getLine

main = do
    listString <- read_list
    print(soma listString)