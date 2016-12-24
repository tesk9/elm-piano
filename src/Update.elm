module Update exposing (update, Msg(..), withNote)

import AllDict
import Model
import Time
import WebAudio


type Msg
    = NoOp
    | ChangeOctave Model.Octave
    | Play Model.Note
    | Stop Model.Note
    | Debounce Msg
    | Tick Time.Time


update : Msg -> Model.Model -> ( Model.Model, Cmd c )
update msg model =
    case msg of
        NoOp ->
            model ! []

        ChangeOctave octave ->
            { model | octave = octave } ! []

        Play note ->
            let
                newCurrentlyPlaying =
                    if not <| AllDict.member note model.currentlyPlaying then
                        model.currentlyPlaying
                            |> AllDict.insert note (WebAudio.play <| Model.toFrequency note)
                    else
                        model.currentlyPlaying
            in
                { model
                    | currentlyPlaying = newCurrentlyPlaying
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

        Debounce msg ->
            let
                perhapsUpdate lastTime =
                    if model.time - lastTime > 10 then
                        update msg model
                    else
                        model ! []
            in
                model.debouncer
                    |> Maybe.map perhapsUpdate
                    |> Maybe.withDefault (update msg model)

        Tick time ->
            { model | time = time } ! []


withNote : (Model.Note -> Msg) -> Int -> Msg
withNote msg keycode =
    Maybe.map msg (Model.toNote keycode)
        |> Maybe.withDefault NoOp
