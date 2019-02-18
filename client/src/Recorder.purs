module Recorder
       ( Query(..)
       , State
       , Message(..)
       , component
       ) where

import Prelude

import Effect.Aff (Aff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Data.Maybe (Maybe(..))
import Web.File.Blob (Blob)
import Data.Array (snoc) as A
import MediaRecorder as MR
import Web.File.Url (createObjectURL)

data Query a = Start a
             | Stop a
             | Started (H.SubscribeStatus -> a)
             | Stopped (H.SubscribeStatus -> a)
             | Initialize a
             | DataAvailable Blob (H.SubscribeStatus -> a)

type State = { mediaRecorder :: Maybe MR.MediaRecorder
             , error :: Maybe String
             , recording :: Boolean
             , blobs :: Array Blob
             , url :: Maybe String
             }

data Message = GotRecording Blob

initialState :: State
initialState = { mediaRecorder: Nothing
               , error: Nothing
               , recording: false
               , blobs: []
               , url: Nothing
               }

component :: H.Component HH.HTML Query Unit Message Aff
component =
  H.lifecycleComponent
  { initialState: const initialState
  , render
  , eval
  , receiver: const Nothing
  , initializer: Just (H.action Initialize)
  , finalizer: Nothing
  }

render :: State -> H.ComponentHTML Query
render state =
    HH.div_
      [ if state.recording
        then HH.text "we are recording"
        else HH.text "we are not recording"
      , case state.error of
            Nothing -> HH.text "No error"
            Just err -> HH.text err
      , case state.url of
            Nothing -> HH.text "no url"
            Just url ->
              HH.audio
              [ HP.src url
              , HP.controls true
              ]
              []
      , case state.mediaRecorder of
          Nothing -> HH.text "Recorder not available"
          Just mediaRecorder ->
            HH.button
            [ HE.onClick (HE.input_ Start) ]
            [ HH.text "Start" ]
      , HH.button
          [ HE.onClick (HE.input_ Stop) ]
          [ HH.text "Stop" ]
      ]

eval :: Query ~> H.ComponentDSL State Query Message Aff
eval = case _ of
    Initialize next -> do
      maybeMediaSource <- H.liftAff $ MR.getUserMedia { what: "" }
      case maybeMediaSource of
        Nothing -> do
          _ <- H.modify (_ { error = Just "Can't get mic" })
          pure next
        Just mediaSource -> do
          let mr = MR.mediaRecorder mediaSource
          _ <- H.modify (_ { mediaRecorder = Just mr })
          H.subscribe $ H.eventSource (MR.onDataAvailable mr) (Just <<< H.request <<< DataAvailable)
          H.subscribe $ H.eventSource_ (MR.onStart mr) (H.request Started)
          H.subscribe $ H.eventSource_ (MR.onStop mr) (H.request Stopped)
          pure next
    DataAvailable blob f -> do
      void $ H.modify (\s -> s { blobs = s.blobs `A.snoc` blob })
      url <- H.liftEffect $ createObjectURL blob
      void $ H.modify (_ { url = Just url })
      H.raise $ GotRecording blob
      pure (f H.Listening)
    Start next -> do
      void $ H.modify (_ { blobs = [] })
      maybeRecorder <- H.gets _.mediaRecorder
      case maybeRecorder of
        Nothing ->
          pure unit
        Just mediaRecorder -> 
          H.liftEffect $ MR.start mediaRecorder
      pure next
    Stop next -> do
      maybeRecorder <- H.gets _.mediaRecorder
      case maybeRecorder of
        Nothing ->
          pure unit
        Just mediaRecorder ->
          H.liftEffect $ MR.stop mediaRecorder
      pure next
    Started reply -> do
      void $ H.modify (_ { recording = true })
      pure $ reply H.Listening
    Stopped reply -> do
      void $ H.modify (_ { recording = false })
      pure $ reply H.Listening

  

