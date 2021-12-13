{-# LANGUAGE OverloadedStrings #-}

import qualified Data.Map as M
import Data.Map (Map)
import qualified Data.Set as S
import Data.Set (Set)
import qualified Data.Text as T
import System.IO

data Node = Start | End | Small Int | Large Int deriving (Eq, Ord)
type NodeSet = Set Node
type EdgeMap = Map Node NodeSet
type NodesToNums = Map T.Text Int

toNode :: T.Text -> NodesToNums -> (Node, NodesToNums)
toNode t nodesToNums
  | t == "start"     = (Start, nodesToNums)
  | t == "end"       = (End, nodesToNums)
  | T.toLower t == t = (Small getNum, updateNums)
  | otherwise        = (Large getNum, updateNums)
  where
    getNum :: Int
    getNum = M.findWithDefault increment t nodesToNums

    updateNums :: NodesToNums
    updateNums
      | M.member t nodesToNums = nodesToNums
      | otherwise              = M.insert t increment nodesToNums

    increment :: Int
    increment = (M.size nodesToNums) + 1

addEdge :: Node -> Node -> EdgeMap -> EdgeMap
addEdge from to edges =
  let edgeSet = M.findWithDefault S.empty from edges
      newEdgeSet = S.insert to edgeSet
   in M.insert from newEdgeSet edges

getEdges :: String -> EdgeMap
getEdges input =
  let inputText = T.pack input
      lines = T.splitOn "\n" inputText
   in fst $ foldr augment (M.empty, M.empty) lines
  where
    augment :: T.Text -> (EdgeMap, NodesToNums) -> (EdgeMap, NodesToNums)
    augment "" a = a
    augment line (edges, nodeMap) =
      let nodes             = T.splitOn "-" line
          (node1, nodeMap1) = toNode (head nodes) nodeMap
          (node2, nodeMap2) = toNode (head (tail nodes)) nodeMap1
          newEdges          = addEdge node1 node2 (addEdge node2 node1 edges)
       in (newEdges, nodeMap2)

type DoubleVisited = Bool
type PathPermitted = Bool

checkPath :: Node -> Node -> NodeSet -> DoubleVisited -> (PathPermitted, DoubleVisited)
checkPath _ Start _ doubleVisited     = (False, doubleVisited)
checkPath _ (Large _) _ doubleVisited = (True, doubleVisited)
checkPath from to visited doubleVisited
  | S.member to visited = ((not doubleVisited), True)
  | otherwise           = (True, doubleVisited)

findPaths :: EdgeMap -> Node -> NodeSet -> DoubleVisited -> Int
findPaths _ End _ _ = 1
findPaths edges from visited doubleVisited =
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
findPathsFromStart edges = findPaths edges Start S.empty False

main :: IO ()
main = do
  input <- readFile "12input.txt"
  let edges = getEdges input
  putStrLn $ show $ findPathsFromStart edges
