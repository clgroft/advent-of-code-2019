main = getContents >>= print . sum . map totalFuelCost . map read . lines

basicFuelCost :: Integer -> Integer
basicFuelCost n = (n `div` 3) - 2

totalFuelCost :: Integer -> Integer
totalFuelCost = sum . takeWhile (>0) . iterate basicFuelCost . basicFuelCost
