module Main exposing (main)

import AllDict
import Html
import Keyboard
import Model exposing (Model)
import Platform.Sub as Sub
import Time
import Update exposing (update)
import View exposing (view)


main : Program Never Model Update.Msg
main =
    Html.program
        { init =
            ( { currentlyPlaying = AllDict.empty Model.toFrequency
              , played = []
              , octave = 4
              , time = 0
              , debouncer = Nothing
              }
            , Cmd.none
            )
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


subscriptions : Model -> Sub Update.Msg
subscriptions model =
    Sub.batch
        [ always (Time.every Time.millisecond Update.Tick) model
        , Keyboard.downs (Update.Debounce << Update.HandleKeyDown)
        , Keyboard.ups (Update.withNote (\note -> Update.Stop ( model.octave, note )))
        ]
