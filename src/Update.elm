module Update exposing (update, Msg(..), withNote)

import AllDict
import Model
import WebAudio


type Msg
    = NoOp
    | Play Model.Note
    | Stop Model.Note


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
                    | currentlyPlaying = AllDict.insert note newNote model.currentlyPlaying
                }
                    ! []

        Stop note ->
            let
                _ =
                    AllDict.get note model.currentlyPlaying
                        |> Maybe.map WebAudio.stop

                newCurrentlyPlaying =
                    AllDict.remove note model.currentlyPlaying
            in
                { model | currentlyPlaying = newCurrentlyPlaying } ! []


withNote : (Model.Note -> Msg) -> Int -> Msg
withNote msg keycode =
    Maybe.map msg (Model.toNote keycode)
        |> Maybe.withDefault NoOp
