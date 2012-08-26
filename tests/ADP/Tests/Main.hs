module ADP.Tests.Main where

import System.IO (hSetBuffering, stdout, BufferMode (LineBuffering))
import Data.Char (toLower)
import Control.Monad (forM_)
import qualified ADP.Tests.RGExample as RG


main::IO()
main = do
        hSetBuffering stdout LineBuffering
        
        forM_ result print
        --forM_ result2 print
        --forM_ result3 print
        --forM_ result4 print
        forM_ result5 print
        
        where
            -- http://www.ekevanbatenburg.nl/PKBASE/PKB00279.HTML
            -- struc = ".(((((.[[[))))).]]]."
            -- inp = map toLower "CAAUUUUCUGAAAAUUUUCAC"
            
            -- http://www.ekevanbatenburg.nl/PKBASE/PKB00289.HTML
            -- longer, but produces results earlier
            -- struc = "..((((..[[[[)))).....]]]]..."
            -- inp = map toLower "ACCGUCGUUCCCGACGUAAAAGGGAUGU"
            
            -- https://github.com/neothemachine/rna/wiki/Example
            -- inp = "agcgu"
            
            inp = map toLower "ACGAUUCAACGU"
            
            result = RG.rgknot RG.enum inp
            result2 = RG.rgknot RG.maxBasepairs inp
            result3 = RG.rgknot RG.maxKnots inp
            result4 = RG.rgknot RG.prettyprint inp
            
            result5 = RG.rgknot (RG.enum RG.*** RG.prettyprint) inp