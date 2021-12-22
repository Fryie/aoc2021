import qualified Data.Map as M

singleRolls :: [Integer]
singleRolls = [1, 2, 3]

possibleRolls :: [[Integer]]
possibleRolls = do
  a <- singleRolls
  b <- singleRolls
  c <- singleRolls

  return [a, b, c]

type RollValues = M.Map Integer Integer
possibleRollValues :: RollValues

possibleRollValues = foldr reduce M.empty possibleRolls
  where reduce :: [Integer] -> RollValues -> RollValues
        reduce roll values =
          let rollSum = sum roll
              oldVal = M.findWithDefault 0 rollSum values
              newVal = oldVal + 1
          in M.insert rollSum newVal values

move :: Integer -> Integer -> Integer
move a b = ((a-1+b) `mod` 10) + 1

data Player = PlayerA | PlayerB
other :: Player -> Player
other PlayerA = PlayerB
other PlayerB = PlayerA

data PlayerValues = PlayerValues Integer Integer
get :: PlayerValues -> Player -> Integer
get (PlayerValues a _) PlayerA = a
get (PlayerValues _ b) PlayerB = b

set :: PlayerValues -> Player -> Integer -> PlayerValues
set (PlayerValues _ b) PlayerA a = PlayerValues a b
set (PlayerValues a _) PlayerB b = PlayerValues a b

add :: PlayerValues -> PlayerValues -> PlayerValues
add (PlayerValues a1 b1) (PlayerValues a2 b2) = PlayerValues (a1+a2) (b1+b2)

mult :: Integer -> PlayerValues -> PlayerValues
mult c (PlayerValues a b) = PlayerValues (c * a) (c * b)

nulls :: PlayerValues
nulls = PlayerValues 0 0

max' :: PlayerValues -> Integer
max' (PlayerValues a b) = max a b

type Scores = PlayerValues
type Positions = PlayerValues
type Wins = PlayerValues

play :: Player -> Positions -> Scores -> Wins
play player positions scores
  | get scores PlayerA >= 21 = set nulls PlayerA 1
  | get scores PlayerB >= 21 = set nulls PlayerB 1
  | otherwise = M.foldrWithKey reduce nulls possibleRollValues
  where
    reduce :: Integer -> Integer -> PlayerValues -> PlayerValues
    reduce rollVal count wins =
      let playerPos = move (get positions player) rollVal
          newPos = set positions player playerPos
          playerScore = (get scores player) + playerPos
          newScores = set scores player playerScore

          subWins = play (other player) newPos newScores
      in  add wins (mult count subWins)

startPlayer = PlayerA
startPos = PlayerValues 6 3

main :: IO ()
main = do
  let wins = play startPlayer startPos nulls
  putStrLn $ show $ max' wins
