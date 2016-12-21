module Update exposing (update, Msg(..))

import Model
import WebAudio


type Msg
    = NoOp
    | Play Model.Note
    | Stop Int


update : Msg -> Model.Model -> ( Model.Model, Cmd c )
update msg model =
    case msg of
        NoOp ->
            model ! []

        Play note ->
            let
                newNote =
                    WebAudio.play <| Model.toFrequency note
            in
                { model
                    | currentlyPlaying = newNote :: model.currentlyPlaying
                }
                    ! []

        Stop keycode ->
            let
                perhapsStopPlaying ( ind, stream ) =
                    --TODO: stop the correct note
                    if ind == 0 then
                        WebAudio.stop stream
                            |> always Nothing
                    else
                        Just stream

                newCurrentlyPlaying =
                    model.currentlyPlaying
                        |> List.indexedMap (,)
                        |> List.filterMap perhapsStopPlaying
            in
                { model | currentlyPlaying = newCurrentlyPlaying } ! []
