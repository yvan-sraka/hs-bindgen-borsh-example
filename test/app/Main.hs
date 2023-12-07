{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingVia #-}
{-# LANGUAGE UndecidableInstances #-}

module Main where

import Codec.Borsh
import Foreign
import Foreign.C.String
import Greetings

import Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Lazy as BS
import Foreign.C
import qualified GHC.Generics as GHC
import qualified Generics.SOP as SOP

-- TODO: Because "y" is a bytestring - the size is variable..
-- And I don't know what the size is for bytestring..
data A = A {x :: Int64, y :: ByteString}
        deriving (Show, Eq, Ord, GHC.Generic, SOP.Generic, SOP.HasDatatypeInfo)
        deriving (BorshSize, ToBorsh, FromBorsh) via AsStruct A

-- Peek an a ptr into a lazy bytestring given a start index
-- Copied from haskell stdlib
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
        withCString "Thanawat!" hello
        -- something
        bs <- greetings
        -- The size is 1 byte
        (CUChar size) <- peekElemOff bs 0
        print size

        bstr <- peekByteString (fromIntegral size) (plusPtr bs 1)
        print bstr
        let a = deserialiseBorsh bstr :: Either DeserialiseFailure A
        print a
