module Js exposing (Code, Error, eval)

import Json.Decode as D exposing (Decoder)
import Json.Encode as E


type alias Interop =
    D.Value


type alias Error =
    D.Error


type alias Code =
    String


interop =
    D.decodeValue
        (D.at [ "__Please_install_the_js_library_for_the_application_to_work", "__elm_interop" ]
            D.value
        )
        (E.object [])


eval : Code -> Decoder a -> Result Error a
eval code decoder =
    interop |> Result.andThen (\i -> D.decodeValue (D.field code decoder) i)
