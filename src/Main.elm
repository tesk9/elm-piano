module Main exposing (main)

import Html
import Json.Decode exposing (Value, decodeString)
import Flags exposing (decoder)
import Model exposing (Model)
import Time
import Update exposing (update)
import View exposing (view)


main : Program String Model Update.Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : String -> ( Model, Cmd msg )
init pageData =
    case decodeString decoder pageData of
        Ok flags ->
            Model.init flags ! []

        Err err ->
            Debug.crash err


subscriptions : a -> Sub Update.Msg
subscriptions =
    always (Time.every Time.millisecond Update.Tick)
