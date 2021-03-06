{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}

module Main (
      main
    ) where

import Control.Concurrent.Lifted (threadDelay)

import Control.Monad.Logger (
    LogLevel(LevelInfo), logDebug, logInfo, logWarn, runStderrLoggingT)

import Network.Jaeger (withJaegerLocal)

import Jaeger.Process (process)
import Jaeger.Sampler (constSampler)

import Control.Monad.Trans.Jaeger (runJaegerT)
import Control.Monad.Trans.JaegerMetrics (runNoJaegerMetricsT)
import Control.Monad.Trans.JaegerTrace (runJaegerTraceT)

import Control.Monad.Logger.Jaeger (runJaegerLoggingT)

main :: IO ()
main = withJaegerLocal $ \sock -> process >>= \p -> runNoJaegerMetricsT $ runJaegerT (runStderrLoggingT act) sock p (constSampler True)
  where
    act = flip runJaegerTraceT "root" $ flip runJaegerLoggingT LevelInfo $ do
        threadDelay 1000
        $(logDebug) "Debug message"
        $(logInfo) "Info message"
        $(logWarn) "Warn message"
        threadDelay 1000
