{-# LANGUAGE OverloadedStrings #-}

import qualified Data.Map as M
import Data.Map (Map)
import qualified Data.Set as S
import Data.Set (Set)
import qualified Data.Text as T
import System.IO

data Node = Small T.Text | Large T.Text deriving (Eq, Ord)
type NodeSet = Set Node
type EdgeMap = Map Node NodeSet

start = Small "start"
end = Small "end"

toEdge :: T.Text -> Node
toEdge t
  | T.toLower t == t = Small t
  | otherwise        = Large t

addEdge :: Node -> Node -> EdgeMap -> EdgeMap
addEdge from to edges =
  let edgeSet = M.findWithDefault S.empty from edges
      newEdgeSet = S.insert to edgeSet
   in M.insert from newEdgeSet edges

getEdges :: String -> EdgeMap
getEdges input =
  let inputText = T.pack input
      lines = T.splitOn "\n" inputText
   in foldr augmentMap M.empty lines
  where
    augmentMap :: T.Text -> EdgeMap -> EdgeMap
    augmentMap "" edges = edges
    augmentMap line edges =
      let nodes = T.splitOn "-" line
          node1 = toEdge $ head nodes
          node2 = toEdge $ head $ tail nodes
       in addEdge node1 node2 (addEdge node2 node1 edges)

type DoubleVisited = Bool

type PathPermitted = Bool

checkPath :: Node -> Node -> NodeSet -> DoubleVisited -> (PathPermitted, DoubleVisited)
checkPath from to@(Small _) visited doubleVisited
  | to == start         = (False, doubleVisited)
  | S.member to visited = ((not doubleVisited), True)
  | otherwise           = (True, doubleVisited)
checkPath _ _ _ doubleVisited = (True, doubleVisited)

findPaths :: EdgeMap -> Node -> NodeSet -> DoubleVisited -> Int
findPaths edges from visited doubleVisited
  | from == end = 1
  | otherwise   =
    let neighbours = M.findWithDefault S.empty from edges
     in foldr count 0 neighbours
    where
      count :: Node -> Int -> Int
      count node acc =
        let (permission, newDoubleVisited) = checkPath from node visited doubleVisited
            newVisited = S.insert node visited
         in if (not permission)
              then acc
              else acc + (findPaths edges node newVisited newDoubleVisited)

findPathsFromStart :: EdgeMap -> Int
findPathsFromStart edges = findPaths edges start S.empty False

main :: IO ()
main = do
  input <- readFile "12input.txt"
  let edges = getEdges input
  putStrLn $ show $ findPathsFromStart edges
