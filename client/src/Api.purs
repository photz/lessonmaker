module Api where

import Prelude (($), bind, pure, discard, unit, (<>), show, flip)
import Affjax as AX
import Affjax.ResponseFormat as ResponseFormat
import Affjax.RequestBody as RequestBody
import Data.Argonaut.Core as J
import Data.Either (Either(..))
import Simple.JSON as JSON
import Data.HTTP.Method (Method(..))
import Data.MediaType (MediaType(..))
import Affjax.RequestHeader (RequestHeader(..))
import Data.Maybe (Maybe(..))
import Effect.Class.Console (log)
import Effect.Aff (Aff)
import Effect.Class.Console (log)
import Record as R
import Prim.Row as Row
import Type.Prelude (class IsSymbol, RLProxy(RLProxy), SProxy(SProxy), reflectSymbol)


type Session = { token :: String }

singleton :: MediaType
singleton = MediaType "application/vnd.pgrst.object+json"
      

login :: String -> String -> Aff (Maybe String)
login email password = do
  res <- AX.request $ AX.defaultRequest { method = Left POST
                                        , headers = [ Accept singleton
                                                    , ContentType $ MediaType "application/json"
                                                    ]
                                        , url = "/rest/rpc/login"
                                        , content = Just $ RequestBody.string $ JSON.writeJSON { email: email, password: password }
                                        , responseFormat = ResponseFormat.string
                                        }
  case res.body of
    Left err -> pure Nothing

    Right succ -> do
      case JSON.readJSON succ of
        Right (r :: Session) -> do
          pure $ Just r.token
        Left e -> pure Nothing




get :: forall a
       . JSON.ReadForeign a
       => String
       -> String
       -> Aff (Maybe a)
get token resource = do
  res <- AX.request $ AX.defaultRequest { headers = [ ContentType $ MediaType "application/json"
                                                    , RequestHeader "Authorization" ("Bearer " <> token)
                                                    ]
                                        , url = "http://localhost:3000/" <> resource
                                        , responseFormat = ResponseFormat.string
                                        }
  case res.body of
    Left err -> pure Nothing
    Right succ ->
      case JSON.readJSON succ of
        Left e -> pure Nothing
        Right r -> pure $ Just r


one :: forall a
       . JSON.ReadForeign a
       => String
       -> String
       -> Aff (Maybe a)
one token resource = do
  res <- AX.request $ AX.defaultRequest { headers = [ ContentType $ MediaType "application/json"
                                                    , RequestHeader "Authorization" ("Bearer " <> token)
                                                    , Accept singleton
                                                    ]
                                        , url = "http://localhost:3000/" <> resource
                                        , responseFormat = ResponseFormat.string
                                        }
  case res.body of
    Left err -> pure Nothing
    Right succ ->
      case JSON.readJSON succ of
        Left e -> pure Nothing
        Right r -> pure $ Just r

