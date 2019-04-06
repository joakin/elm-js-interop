module JsInterop exposing (Code, Error, Interop, eval)

import Json.Decode as D exposing (Decoder)


type alias Interop =
    D.Value


type alias Error =
    D.Error


type alias Code =
    String


eval : Interop -> Code -> Decoder a -> Result Error a
eval interop code decoder =
    D.decodeValue (D.field code decoder) interop
