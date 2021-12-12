{-# LANGUAGE OverloadedStrings #-}

import qualified Data.Map as M
import Data.Map (Map)
import qualified Data.Set as S
import Data.Set (Set)
import qualified Data.Text as T
import System.IO

type Node = T.Text

type NodeSet = Set Node

type EdgeMap = Map Node NodeSet

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
          node1 = head nodes
          node2 = head $ tail nodes
       in addEdge node1 node2 (addEdge node2 node1 edges)

type DoubleVisited = Bool

type PathPermitted = Bool

checkPath ::
     Node -> Node -> NodeSet -> DoubleVisited -> (PathPermitted, DoubleVisited)
checkPath _ "start" _ doubleVisited = (False, doubleVisited)
checkPath from to visited doubleVisited =
  let isSmall = T.toLower to == to
      revisiting = S.member to visited
   in if isSmall && revisiting
        then ((not doubleVisited), True)
        else (True, doubleVisited)

findPaths :: EdgeMap -> Node -> NodeSet -> DoubleVisited -> Int
findPaths _ "end" _ _ = 1
findPaths edges from visited doubleVisited =
  let neighbours = M.findWithDefault S.empty from edges
   in foldr count 0 neighbours
  where
    count :: Node -> Int -> Int
    count node acc =
      let (permission, newDoubleVisited) =
            checkPath from node visited doubleVisited
          newVisited = S.insert node visited
       in if (not permission)
            then acc
            else acc + (findPaths edges node newVisited newDoubleVisited)

findPathsFromStart :: EdgeMap -> Int
findPathsFromStart edges = findPaths edges "start" S.empty False

main :: IO ()
main = do
  input <- readFile "12input.txt"
  let edges = getEdges input
  putStrLn $ show $ findPathsFromStart edges
