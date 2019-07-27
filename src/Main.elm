module Main exposing (main)

import Browser
import Html exposing (Html, br, div, p, text)
import Js exposing (..)
import Json.Decode as D exposing (Decoder)
import Json.Encode as E


type alias Model =
    { msgs : List ( String, String ) }


init : Flags -> ( Model, Cmd Msg )
init () =
    let
        msgs =
            [ ( "window.confirm"
              , eval "confirm(\"wot\")" D.bool
                    |> Result.map boolToString
                    |> resultToString
              )
            , ( "navigator.onLine"
              , eval "navigator.onLine" D.bool
                    |> Result.map boolToString
                    |> resultToString
              )
            , ( "navigator.languages"
              , eval "navigator.languages" (D.list D.string)
                    |> Result.map (String.join ", ")
                    |> resultToString
              )
            , ( "relative date (Intl.RelativeTimeFormat)"
              , eval """(() => {
                    var rtf = new Intl.RelativeTimeFormat('ca', { style: 'narrow' });
                    return [
                        rtf.format(-2, 'day'),
                        rtf.format(-3, 'quarter')
                    ];
                })()
                """ (D.list D.string)
                    |> Result.map (String.join ", ")
                    |> resultToString
              )
            ]
    in
    ( { msgs = msgs }, Cmd.none )


type Msg
    = Noop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div [] <|
        List.map (\( m1, m2 ) -> p [] [ text m1, br [] [], text m2 ]) model.msgs


type alias Flags =
    ()


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


resultToString : Result Js.Error String -> String
resultToString r =
    case r of
        Ok result ->
            result

        Err err ->
            "ERROR" ++ D.errorToString err


boolToString : Bool -> String
boolToString b =
    if b then
        "true"

    else
        "false"
