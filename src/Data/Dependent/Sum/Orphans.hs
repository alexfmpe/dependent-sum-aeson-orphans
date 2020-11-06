{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}

module Data.Dependent.Sum.Orphans where

import Data.Aeson
import Data.Constraint.Forall
import Data.Constraint.Extras
import Data.Dependent.Map (DMap)
import qualified Data.Dependent.Map as DMap
import Data.Dependent.Sum
import Data.GADT.Compare (GCompare)
import Data.Some (Some(Some))
import qualified Data.Some as Some

instance (ForallF ToJSON f, Has' ToJSON f g) => ToJSON (DSum f g) where
  toJSON ((f :: f a) :=> (g :: g a))
    = whichever @ToJSON @f @a (has' @ToJSON @g f (toJSON (f, g)))

instance (ForallF ToJSON f, Has' ToJSON f g) => ToJSON (DMap f g) where
    toJSON = toJSON . DMap.toList

instance (FromJSON (Some f), Has' FromJSON f g) => FromJSON (DSum f g) where
  parseJSON x = do
    (jf, jg) <- parseJSON x
    Some.Some (f :: f a) <- parseJSON jf
    g <- has' @FromJSON @g f (parseJSON jg)
    return $ f :=> g

instance (FromJSON (Some f), GCompare f, Has' FromJSON f g) => FromJSON (DMap f g) where
    parseJSON = fmap DMap.fromList . parseJSON

instance (ForallF ToJSON r) => ToJSON (Some r) where
  toJSON (Some (x :: r a)) = whichever @ToJSON @r @a (toJSON x)
