module Js exposing (Code, Error(..), eval, evalAsync, log, logValue)

import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Process
import Task exposing (Task)


type alias Interop =
    D.Value


type Error
    = TypeError D.Error
    | RuntimeError String


type alias Code =
    String


eval : List D.Value -> Code -> Decoder a -> Result Error a
eval params code decoder =
    E.object [ ( "__elm_interop", E.list identity (E.string code :: params) ) ]
        |> D.decodeValue (D.field "__elm_interop" (decodeEvalResult decoder))
        |> Result.mapError TypeError
        |> Result.andThen identity


evalAsync : List D.Value -> Code -> Decoder a -> Task Error a
evalAsync params code decoder =
    let
        token =
            E.object []
    in
    Task.succeed ()
        |> Task.andThen
            (\_ ->
                let
                    _ =
                        E.object [ ( "__elm_interop_async", E.list identity (token :: E.string code :: params) ) ]
                in
                Process.sleep -666
            )
        |> Task.andThen
            (\_ ->
                case
                    E.object [ ( "token", token ) ]
                        |> D.decodeValue (D.field "__elm_interop_async" (decodeEvalResult decoder))
                        |> Result.mapError TypeError
                        |> Result.andThen identity
                of
                    Ok result ->
                        Task.succeed result

                    Err error ->
                        Task.fail error
            )


log : String -> a -> a
log msg a =
    let
        _ =
            eval [ E.string msg ] "console.log(args[0])" (D.null D.int)
    in
    a


logValue : String -> E.Value -> E.Value
logValue msg value =
    let
        _ =
            eval [ E.string msg, value ] "console.log(args[0], args[1])" (D.null D.int)
    in
    value


decodeEvalResult : Decoder a -> Decoder (Result Error a)
decodeEvalResult decodeResult =
    D.field "tag" D.string
        |> D.andThen
            (\tag ->
                case tag of
                    "Ok" ->
                        D.value
                            |> D.andThen
                                (\value ->
                                    D.decodeValue (D.field "result" decodeResult) value
                                        |> Result.mapError TypeError
                                        |> D.succeed
                                )

                    "Error" ->
                        D.field "error" decodeRuntimeError
                            |> D.map Err

                    _ ->
                        D.value
                            |> D.andThen
                                (\value ->
                                    D.succeed
                                        (D.Failure ("`tag` field must be one of Ok/Error, instead found `" ++ tag ++ "`") value
                                            |> TypeError
                                            |> Err
                                        )
                                )
            )


decodeRuntimeError : Decoder Error
decodeRuntimeError =
    D.field "message" D.string |> D.map RuntimeError
