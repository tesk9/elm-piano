module Main exposing (main)

import Flags exposing (decoder)
import Html
import Json.Decode exposing (Value, decodeString)
import Keyboard
import Model exposing (Model)
import Platform.Sub as Sub
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


subscriptions : Model -> Sub Update.Msg
subscriptions model =
    Sub.batch
        [ always (Time.every Time.millisecond Update.Tick) model
        , Keyboard.downs (Update.Debounce << Update.HandleKeyDown)
        , Keyboard.ups (Update.withNote (\note -> Update.Stop ( model.octave, note )))
        ]
