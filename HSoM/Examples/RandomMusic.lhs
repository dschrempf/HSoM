> module HSoM.Examples.RandomMusic where
> import Euterpea
> import System.Random
> import System.Random.Distributions
> import qualified Data.MarkovChain as M


> sGen :: StdGen
> sGen = mkStdGen 42

> randInts :: StdGen -> [Int]
> randInts g =  let (x,g') = uniform g
>               in x : randInts g'

> randFloats :: [Float]
> randFloats = randomRs (-1,1) sGen

> randIntegers :: [Integer]
> randIntegers = randomRs (0,100) sGen

> randString :: String
> randString = randomRs ('a','z') sGen

> randIO :: IO Float
> randIO = randomRIO (0,1)

> randIO' :: IO ()
> randIO' = do  r1 <- randomRIO (0,1) :: IO Float
>               r2 <- randomRIO (0,1) :: IO Float
>               print (r1 == r2)

> toAbsP1    :: Float -> AbsPitch
> toAbsP1 x  = round (40*x + 30)

> mkNote1  :: AbsPitch -> Music Pitch
> mkNote1  = note tn . pitch

> mkLine1        :: [AbsPitch] -> Music Pitch
> mkLine1 rands  = line (take 32 (map mkNote1 rands))

uniform distribution

> m1 :: Music Pitch
> m1 = mkLine1 (randomRs (30,70) sGen)

linear distribution

> m2 :: Music Pitch
> m2 =  let rs1 = rands linear sGen
>       in mkLine1 (map toAbsP1 rs1)

exponential distribution

> m3      :: Float -> Music Pitch
> m3 lam  =  let rs1 = rands (exponential lam) sGen
>            in mkLine1 (map toAbsP1 rs1)

Gaussian distribution

> m4 :: Float -> Float -> Music Pitch
> m4 sig mu   =  let rs1 = rands (gaussian sig mu) sGen
>                in mkLine1 (map toAbsP1 rs1)


Gaussian distribution with mean set to 0

> m5      :: Float -> Music Pitch
> m5 sig  =  let rs1 = rands (gaussian sig 0) sGen
>            in mkLine2 50 (map toAbsP2 rs1)

exponential distribution with mean adjusted to 0

> m6      :: Float -> Music Pitch
> m6 lam  =  let rs1 = rands (exponential lam) sGen
>            in mkLine2 50 (map (toAbsP2 . subtract (1/lam)) rs1)

> toAbsP2     :: Float -> AbsPitch
> toAbsP2 x   = round (5*x)

> mkLine2 :: AbsPitch -> [AbsPitch] -> Music Pitch
> mkLine2 start rands = 
>    line (take 64 (map mkNote1 (scanl (+) start rands)))

> m2' = let rs1 = rands linear sGen
>       in sum (take 1000 rs1) / 1000 :: Float

> m5' sig = let rs1 = rands (gaussian sig 0) sGen
>           in sum (take 1000 rs1)

> m6' lam = let rs1 = rands (exponential lam) sGen
>               rs2 = map (subtract (1/lam)) rs1
>           in sum (take 1000 rs2)

some sample training sequences

> ps0,ps1,ps2 :: [Pitch]
> ps0  = [(C,4), (D,4), (E,4)]
> ps1  = [(C,4), (D,4), (E,4), (F,4), (G,4), (A,4), (B,4)]
> ps2  = [  (C,4), (E,4), (G,4), (E,4), (F,4), (A,4), (G,4), (E,4),
>           (C,4), (E,4), (G,4), (E,4), (F,4), (D,4), (C,4)]

functions to package up run and runMulti

> mc    ps   n = mkLine3 (M.run n ps 0 (mkStdGen 42))
> mcm   pss  n = mkLine3 (concat (M.runMulti  n pss 0 
>                                             (mkStdGen 42)))

music-making functions

> mkNote3     :: Pitch -> Music Pitch
> mkNote3     = note tn

> mkLine3     :: [Pitch] -> Music Pitch
> mkLine3 ps  = line (take 64 (map mkNote3 ps))

testing the Markov output directly

> lc  ps n    = take 1000 (M.run n ps 0 (mkStdGen 42))
> lcl pss n m = take 1000 (M.runMulti n pss 0 (mkStdGen 42) !! m)
