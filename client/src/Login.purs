module Login
       ( State
       , Query(..)
       , Message(..)
       , component
       ) where

import Prelude
import Effect.Aff (Aff)
import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import Api as Api

type State = { email :: String
             , password :: String
             , message :: Maybe String
             }


data Query a = SetEmail String a
             | SetPassword String a
             | Submit a

data Message = GotToken String

component :: H.Component HH.HTML Query Unit Message Aff
component =
  H.component
    { initialState: const initialState
    , render
    , eval
    , receiver: const Nothing
    }

initialState :: State
initialState =
  { email: ""
  , password: ""
  , message: Nothing
  }

render :: State -> H.ComponentHTML Query
render state =
  HH.div_
  [ case state.message of
       Nothing -> HH.text ""
       Just message -> HH.text message
  , HH.div_
    [ HH.input
      [ HE.onValueChange (HE.input SetEmail)
      , HP.placeholder "Email"
      ]
    , HH.input
      [ HE.onValueChange (HE.input SetPassword)
      , HP.placeholder "Password"
      ]
    , HH.button
      [ HE.onClick (HE.input_ Submit) ]
      [ HH.text "Login" ]
    ]
  ]


eval :: Query ~> H.ComponentDSL State Query Message Aff
eval = case _ of
  SetEmail email next -> do
    _ <- H.modify (_ { email = email })
    pure next
  SetPassword password next -> do
    _ <- H.modify (\state -> state { password = password })
    pure next
  Submit next -> do
    email <- H.gets _.email
    password <- H.gets _.password
    response <- H.liftAff $ Api.login email password
    _ <- case response of
      Nothing -> H.modify (_ { message = Just "Email/password incorrect" })
      Just token -> do
        H.raise $ GotToken token
        H.modify (_ { message = Nothing })
    pure next
