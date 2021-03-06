module Deck where

import System.Random
import Data.Array.IO
import Control.Monad
import Data.Map

data Card = Card {
    value :: Value
  , suit :: Suit
  }
  deriving (Eq)

instance Ord Card where
  compare (Card v1 s1) (Card v2 s2)
    | s1 == s2 = compare v1 v2
    | otherwise = compare s1 s2

instance Show Card where
  show (Card v s) = show v ++ " of " ++ show s ++ "s"

data Suit = 
    Club
  | Diamond 
  | Heart 
  | Spade
  deriving (Show, Enum, Eq, Ord, Bounded)

allSuits :: [Suit]
allSuits = [ (minBound :: Suit) .. ]

data Value =
    Ace | Two | Three | Four | Five | Six | Seven | Eight | Nine | Ten
  | Jack | Queen | King
  deriving (Enum, Eq, Ord, Bounded)

instance Show Value where
  show Ace = "A"
  show Jack = "J"
  show Queen = "Q"
  show King = "K"
  show n = show $ 1 + fromEnum n

allValues :: [Value]
allValues = [ (minBound :: Value) .. ]

-- |An unshuffled deck of all possible cards
pack :: [Card]
pack = Card <$> allValues <*> allSuits

-- Props to https://wiki.haskell.org/Random_shuffle
shuffle :: [a] -> IO [a]
shuffle xs = do
    ar <- newArray len xs
    forM [1..len] $ \i -> do
      j <- randomRIO (i,len)
      vi <- readArray ar i
      vj <- readArray ar j
      writeArray ar j vi
      return vj
  where
    len = length xs
    newArray :: Int -> [a] -> IO (IOArray Int a)
    newArray len = newListArray (1, len)

shuffleGen' :: RandomGen g => (Map Int a, g) -> (Int, a) -> (Map Int a, g)
shuffleGen' (m, gen) (i, x) = ((insert j x . insert i (m ! j)) m, gen') where
  (j, gen') = randomR (0, i) gen

shuffleGen :: RandomGen g => g -> [a] -> ([a], g)
shuffleGen gen [] = ([], gen)
shuffleGen gen xs =
  toElems $ Prelude.foldl shuffleGen' (initial (head xs) gen) (numerate (tail xs)) where
    toElems (x, y) = (elems x, y)
    numerate = zip [1..]
    initial x gen = (singleton 0 x, gen)

