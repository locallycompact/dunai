-- | MSFs with a Writer monadic layer.
--
-- This module contains functions to work with MSFs that include a 'Writer'
-- monadic layer. This includes functions to create new MSFs that include an
-- additional layer, and functions to flatten that layer out of the MSF's
-- transformer stack.
module Control.Monad.Trans.MSF.Writer
  ( module Control.Monad.Trans.Writer.Strict
  -- * Writer MSF running \/ wrapping \/ unwrapping
  , writerS
  , runWriterS
  ) where

-- External
import Control.Monad.Trans.Writer.Strict
  hiding (liftCallCC, liftCatch, pass) -- Avoid conflicting exports
import Data.Functor ((<$>))
import Data.Monoid

-- Internal
import Data.MonadicStreamFunction

-- * Writer MSF running/wrapping/unwrapping

-- | Build an MSF in the 'Writer' monad from one that produces the log as an
-- extra output. This is the opposite of 'runWriterS'.
writerS :: (Monad m, Monoid w) => MSF m a (w, b) -> MSF (WriterT w m) a b
writerS = hoistGen $ \f a -> WriterT $ (\((w, b), c) -> ((b, c), w)) <$> f a

-- | Build an MSF that produces the log as an extra output from one on the
-- 'Writer' monad. This is the opposite of 'writerS'.
runWriterS :: Monad m => MSF (WriterT s m) a b -> MSF m a (s, b)
runWriterS = hoistGen $ \f a -> (\((b, c), s) -> ((s, b), c))
         <$> runWriterT (f a)
