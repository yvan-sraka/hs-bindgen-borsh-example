{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE UndecidableInstances #-}

module Main where

import Codec.Borsh
import Foreign
import BestPet
import Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Lazy as BS
import Foreign.C
import qualified GHC.Generics as GHC
import qualified Generics.SOP as SOP

data Pet = Cat | Dog
        deriving (Show, Eq, Ord, GHC.Generic, SOP.Generic, SOP.HasDatatypeInfo)
        deriving (BorshSize, ToBorsh, FromBorsh) via AsEnum Pet

peekByteString :: Int -> Ptr CUChar -> IO ByteString
{-# INLINEABLE peekByteString #-}
peekByteString size ptr
        | size <= 0 = return BS.empty
        | otherwise = f (size - 1) BS.empty
    where
        f 0 acc = do (CUChar e) <- peekElemOff ptr 0; return (BS.cons e acc)
        f n acc = do (CUChar e) <- peekElemOff ptr n; f (n - 1) (BS.cons e acc)

main :: IO ()
main = do
        bs <- best_pet
        (CUChar size) <- peekElemOff bs 0
        bstr <- peekByteString (fromIntegral size) (plusPtr bs 1)
        let result = deserialiseBorsh bstr :: Either DeserialiseFailure Pet
        print result
