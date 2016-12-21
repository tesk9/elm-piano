module Update exposing (update, Msg(..))

import Model
import WebAudio


type Msg
    = NoOp
    | Play Int
    | Stop Int


update : Msg -> Model.Model -> ( Model.Model, Cmd c )
update msg model =
    case msg of
        NoOp ->
            model ! []

        Play keycode ->
            let
                newNote =
                    WebAudio.play <| toFrequency keycode
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


toFrequency : Int -> Float
toFrequency keycode =
    case keycode of
        65 ->
            {- a -}
            220

        66 ->
            {- b -}
            246.942

        67 ->
            {- c -}
            261.626

        68 ->
            {- d -}
            293.665

        69 ->
            {- e -}
            329.228

        70 ->
            {- f -}
            349.228

        71 ->
            {- g -}
            391.995

        _ ->
            0
