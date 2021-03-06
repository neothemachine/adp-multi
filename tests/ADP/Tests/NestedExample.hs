-- | Grammar for all pseudoknot-free RNA secondary structures 
module ADP.Tests.NestedExample where

import ADP.Multi.All
import ADP.Multi.Rewriting.All
                                 
type Nested_Algebra alphabet answer = (
  [alphabet] -> answer,                              -- nil
  answer   -> answer -> answer,               -- left
  answer   -> answer -> answer,               -- pair
  alphabet -> answer -> alphabet -> answer,   -- basepair
  alphabet -> answer,                         -- base
  [answer] -> [answer]                        -- h
  )
  
infixl ***
(***) :: (Eq b, Eq c) => Nested_Algebra a b -> Nested_Algebra a c -> Nested_Algebra a (b,c)
alg1 *** alg2 = (nil,left,pair,basepair,base,h) where
   (nil',left',pair',basepair',base',h') = alg1
   (nil'',left'',pair'',basepair'',base'',h'') = alg2
   
   nil a = (nil' a, nil'' a)
   left (b1,b2) (s1,s2) = (left' b1 s1, left'' b2 s2)
   pair (p1,p2) (s1,s2) = (pair' p1 s1, pair'' p2 s2)
   basepair a (s1,s2) b = (basepair' a s1 b,  basepair'' a s2 b)
   base a = (base' a, base'' a)
   h xs = [ (x1,x2) |
            x1 <- h'  [ y1 | (y1,_)  <- xs]
          , x2 <- h'' [ y2 | (y1,y2) <- xs, y1 == x1]
          ]

data Start = Nil
           | Left' Start Start
           | Pair Start Start
           | BasePair Char Start Char
           | Base Char
           deriving (Eq, Show)

enum :: Nested_Algebra Char Start
enum = (\_-> Nil,Left',Pair,BasePair,Base,id)
   
maxBasepairs :: Nested_Algebra Char Int
maxBasepairs = (nil,left,pair,basepair,base,h) where
   nil _            = 0
   left _ b         = b
   pair a b         = a + b
   basepair _ s _   = 1 + s
   base _           = 0
   h []             = []
   h xs             = [maximum xs]

-- | left part = dot-bracket; right part = reconstructed input
prettyprint :: Nested_Algebra Char (String,String)
prettyprint = (nil,left,pair,basepair,base,h) where
   nil _ = ("","")
   left (b1,b2) (sl,sr) = (b1 ++ sl, b2 ++ sr)
   pair (pl,pr) (sl,sr) = (pl ++ sl, pr ++ sr)
   basepair b1 (sl,sr) b2 = ("(" ++ sl ++ ")", [b1] ++ sr ++ [b2])
   base b = (".", [b])
   h = id

-- | PSTricks trees using some custom macros 
pstree :: Nested_Algebra Char String
pstree = (nil,left,pair,basepair,base,h) where
   nil _ = "\\emptyword"
   left b s = nonterm "B" b ++ nonterm "S" s
   pair p s = nonterm "P" p ++ nonterm "S" s
   basepair b1 s b2 = base b1 ++ nonterm "S" s ++ base b2
   base b = "\\terminal{" ++ [b] ++ "}"
   h = id
   
   nonterm sym tree = "\\pstree{\\nonterminal{" ++ sym ++ "}}{" ++ tree ++ "}"

-- | terms in tex math 
term :: Nested_Algebra Char String
term = (nil,left,pair,basepair,base,h) where
   nil _ = "\\op{f}_3()"
   left b s = "\\op{f}_2(" ++ b ++ "," ++ s ++ ")"
   pair p s = "\\op{f}_2(" ++ p ++ "," ++ s ++ ")"
   basepair b1 s b2 = "\\op{f}_4(" ++ [b1] ++ "," ++ s ++ "," ++ [b2] ++ ")"
   base b = "\\op{f}_5(" ++ [b] ++ ")"
   h = id

-- | plain terms without markup 
termPlain :: Nested_Algebra Char String
termPlain = (nil,left,pair,basepair,base,h) where
   nil _ = "f_3"
   left b s = "f_2(" ++ b ++ "," ++ s ++ ")"
   pair p s = "f_2(" ++ p ++ "," ++ s ++ ")"
   basepair b1 s b2 = "f_4(" ++ [b1] ++ "," ++ s ++ "," ++ [b2] ++ ")"
   base b = "f_5(" ++ [b] ++ ")"
   h = id
   
nested :: Nested_Algebra Char answer -> String -> [answer]
nested algebra inp =
  let  
  (nil,left,pair,basepair,base,h) = algebra
     
  s = tabulated $
      yieldSize1 (0,Nothing) $
      nil  <<< ""      >>> id1 |||
      left <<< b ~~~ s >>> id1 |||
      pair <<< p ~~~ s >>> id1
      ... h
  
  b = tabulated $
      base <<< 'a' >>> id1 |||
      base <<< 'u' >>> id1 |||
      base <<< 'c' >>> id1 |||
      base <<< 'g' >>> id1
  
  p = tabulated $
      basepair <<< 'a' ~~~ s ~~~ 'u' >>> id1 |||
      basepair <<< 'u' ~~~ s ~~~ 'a' >>> id1 |||
      basepair <<< 'c' ~~~ s ~~~ 'g' >>> id1 |||
      basepair <<< 'g' ~~~ s ~~~ 'c' >>> id1 |||
      basepair <<< 'g' ~~~ s ~~~ 'u' >>> id1 |||
      basepair <<< 'u' ~~~ s ~~~ 'g' >>> id1
      
  z = mk inp
  tabulated = table1 z
  
  in axiom z s
