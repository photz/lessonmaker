module Minio (upload) where

import Prelude (($), bind, pure, (==))
import Affjax as AX
import Affjax.RequestBody as RequestBody
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.ResponseFormat as ResponseFormat
import Affjax.StatusCode (StatusCode(..))
import Data.Either (Either(..))
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Data.MediaType (MediaType(..))
import Effect.Aff (Aff)
import Effect.Class.Console (log)
import Web.File.Blob (Blob)

type PresignedURL = String

ok :: StatusCode -> Boolean
ok (StatusCode 200) = true
ok _                = false

upload :: PresignedURL -> Blob -> Aff Boolean
upload url blob = do
  { status } <- AX.request r
  pure $ ok status
  where
    r = AX.defaultRequest { content = Just $ RequestBody.blob blob
                          , method = Left PUT
                          , url = url
                          , headers = [ Accept $ MediaType "application/json" ]
                          }
