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

data Player = PlayerA | PlayerB deriving (Eq, Ord)
other :: Player -> Player
other PlayerA = PlayerB
other PlayerB = PlayerA

data PlayerValues = PlayerValues Integer Integer deriving (Eq, Ord)
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

type MemoKey = (Player, Positions, Scores)
type Memo = M.Map MemoKey Wins

play :: Memo -> Player -> Positions -> Scores -> (Memo, Wins)
play memo player positions scores =
  let memoKey = (player, positions, scores)
      memoVal = M.lookup memoKey memo
      (newMemo, result) = getResult memoVal
  in  (M.insert memoKey result newMemo, result)
  where
    getResult :: Maybe Wins -> (Memo, Wins)
    getResult (Just mv) = (memo, mv)
    getResult Nothing = play' memo player positions scores

play' :: Memo -> Player -> Positions -> Scores -> (Memo, Wins)
play' memo player positions scores
  | get scores PlayerA >= 21 = (memo, set nulls PlayerA 1)
  | get scores PlayerB >= 21 = (memo, set nulls PlayerB 1)
  | otherwise = M.foldrWithKey reduce (memo, nulls) possibleRollValues
  where
    reduce :: Integer -> Integer -> (Memo, Wins) -> (Memo, Wins)
    reduce rollVal count (memoAcc, wins) =
      let playerPos = move (get positions player) rollVal
          newPos = set positions player playerPos
          playerScore = (get scores player) + playerPos
          newScores = set scores player playerScore

          (newMemo, subWins) = play memoAcc (other player) newPos newScores
      in  (newMemo, add wins (mult count subWins))

doPlay :: Player -> Positions -> Wins
doPlay startPlayer startPos = snd $ play M.empty startPlayer startPos nulls

startPlayer = PlayerA
startPos = PlayerValues 6 3

main :: IO ()
main = do
  let wins = doPlay startPlayer startPos
  putStrLn $ show $ max' wins
