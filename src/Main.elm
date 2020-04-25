module Main exposing (main)

import Browser
import Html exposing (Html, br, div, p, pre, span, text)
import Html.Attributes exposing (style)
import Js exposing (..)
import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Task exposing (Task)


confirm : String -> Task Error Bool
confirm msg =
    evalAsync [ E.string msg ] "confirm(args[0])" D.bool


prompt : String -> Task Error String
prompt msg =
    evalAsync [ E.string msg ] "prompt(args[0])" D.string


onLine : () -> Task Error Bool
onLine () =
    evalAsync [] "navigator.onLine" D.bool


languages : () -> Task Error (List String)
languages () =
    evalAsync [] "navigator.languages" (D.list D.string)


type alias Model =
    { onLine : Maybe (Result Error Bool)
    , confirm : Maybe (Result Error Bool)
    , languages : Maybe (Result Error (List String))
    , syntaxError : Maybe (Result Error String)
    , runtimeError : Maybe (Result Error String)
    }


init : Flags -> ( Model, Cmd Msg )
init () =
    ( { onLine = Nothing
      , confirm = Nothing
      , languages = Nothing
      , syntaxError = Nothing
      , runtimeError = Nothing
      }
    , Cmd.batch
        [ confirm "wot" |> Task.attempt GotConfirm
        , onLine () |> Task.attempt GotOnLine
        , languages () |> Task.attempt GotLanguages
        , evalAsync [] "LOL incorrect JS''')" D.string |> Task.attempt GotSyntaxError
        , evalAsync [] "a.b = 'LOL incorrect JS'" D.string |> Task.attempt GotRuntimeError
        ]
    )


type Msg
    = GotConfirm (Result Error Bool)
    | GotOnLine (Result Error Bool)
    | GotLanguages (Result Error (List String))
    | GotSyntaxError (Result Error String)
    | GotRuntimeError (Result Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotConfirm confirm_ ->
            ( { model | confirm = Just confirm_ }, Cmd.none )

        GotOnLine onLine_ ->
            ( { model | onLine = Just onLine_ }, Cmd.none )

        GotLanguages languages_ ->
            ( { model | languages = Just languages_ }, Cmd.none )

        GotSyntaxError syntaxError ->
            ( { model | syntaxError = Just syntaxError }, Cmd.none )

        GotRuntimeError runtimeError ->
            ( { model | runtimeError = Just runtimeError }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        msgs =
            [ ( "Async FFI"
              , ""
              )
            , ( "window.confirm"
              , model.confirm |> maybeResultToString boolToString
              )
            , ( "navigator.onLine"
              , model.onLine |> maybeResultToString boolToString
              )
            , ( "navigator.languages"
              , model.languages |> maybeResultToString (String.join ", ")
              )
            , ( "Syntax error"
              , model.syntaxError |> maybeResultToString identity
              )
            , ( "Runtime error"
              , model.runtimeError |> maybeResultToString identity
              )
            , ( "Sync FFI"
              , ""
              )
            , ( "relative date (Intl.RelativeTimeFormat)"
              , eval [] """(() => {
                    var rtf = new Intl.RelativeTimeFormat('ca', { style: 'narrow' });
                    return [
                        rtf.format(-2, 'day'),
                        rtf.format(-3, 'quarter')
                    ];
                })()
                """ (D.list D.string)
                    |> resultToString (String.join ", ")
              )
            , ( "Incorrect return type, getting an int but expecting a string"
              , eval [] "37 + 5" D.string
                    |> resultToString identity
              )
            , ( "Syntax error"
              , eval [] "LOL incorrect JS')" D.string
                    |> resultToString identity
              )
            , ( "Runtime error"
              , eval [] "a.b = 'LOL incorrect JS'" D.string
                    |> resultToString identity
              )
            ]
    in
    div [] <|
        List.map
            (\( m1, m2 ) ->
                p []
                    [ span [ style "font-weight" "bold" ] [ text m1 ]
                    , br [] []
                    , pre [] [ text m2 ]
                    ]
            )
            msgs


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


maybeResultToString : (a -> String) -> Maybe (Result Js.Error a) -> String
maybeResultToString toString m =
    m
        |> Maybe.map (resultToString toString)
        |> Maybe.withDefault "Loading..."


resultToString : (a -> String) -> Result Js.Error a -> String
resultToString toString r =
    case r of
        Ok result ->
            toString result

        Err err ->
            "ERROR: "
                ++ (case err of
                        TypeError terr ->
                            "Unexpected type: " ++ D.errorToString terr

                        RuntimeError message ->
                            "Execution failed. " ++ message
                   )


boolToString : Bool -> String
boolToString b =
    if b then
        "true"

    else
        "false"
