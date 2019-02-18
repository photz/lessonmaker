module Component where

import Prelude

import Effect.Aff (Aff)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.Component.ChildPath as CP
import Recorder as Recorder
import Login as Login
import Data.Maybe (Maybe(..))
import Data.Either.Nested (Either2)
import Data.Functor.Coproduct.Nested (Coproduct2)

data Query a = HandleLogin Login.Message a
             | HandleRecorder Recorder.Message a

type State = { token :: Maybe String }

type ChildQuery = Coproduct2 Recorder.Query Login.Query

type ChildSlot = Either2 Unit Unit

component :: H.Component HH.HTML Query Unit Void Aff
component =
  H.lifecycleParentComponent
    { initialState: const initialState
    , render
    , eval
    , receiver: const Nothing
    , initializer: Nothing
    , finalizer: Nothing
    }
  where

  initialState :: State
  initialState = { token: Nothing }

  render :: State -> H.ParentHTML Query ChildQuery ChildSlot Aff
  render state =
    HH.div_
      [ HH.h1_
          [ HH.text "Drills" ]
      , case state.token of
            Nothing -> 
              HH.slot' CP.cp2 unit Login.component unit (HE.input HandleLogin)
            Just _ ->
              HH.text "You are logged in!"
      , HH.slot' CP.cp1 unit Recorder.component unit (HE.input HandleRecorder)
      ]

  eval :: Query ~> H.ParentDSL State Query ChildQuery ChildSlot Void Aff
  eval = case _ of
    HandleLogin (Login.GotToken token) next -> do
      _ <- H.modify (_ { token = Just token })
      pure next

    HandleRecorder (Recorder.GotRecording blob) next -> do
      pure next
