module MediaRecorder
       ( mediaRecorder
       , onStart
       , onStop
       , onDataAvailable
       , start
       , stop
       , getUserMedia
       , MediaStream
       , MediaRecorder
       ) where

import Prelude (Unit, (<<<), unit, pure)
import Effect (Effect)
import Effect.Aff (Aff)
import Data.Maybe (Maybe(..))
import Effect.Aff.Compat (EffectFnAff, fromEffectFnAff)
import Web.File.Blob (Blob)

type MediaStream = String
type MediaRecorder = Int
type Opts = { what :: String }

foreign import _getUserMedia :: (MediaStream -> Maybe MediaStream) -> Opts -> EffectFnAff (Maybe MediaStream)

foreign import mediaRecorder :: MediaStream -> MediaRecorder

foreign import start :: MediaRecorder -> Effect Unit

foreign import stop :: MediaRecorder -> Effect Unit

getUserMedia :: Opts -> Aff (Maybe MediaStream)
getUserMedia = fromEffectFnAff <<< (_getUserMedia Just)

foreign import onDataAvailable :: MediaRecorder
                               -> (Blob -> Effect Unit)
                               -> Effect Unit

foreign import onStart :: MediaRecorder
                       -> Effect Unit
                       -> Effect Unit

foreign import onStop :: MediaRecorder
                      -> Effect Unit
                      -> Effect Unit

