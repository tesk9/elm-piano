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
            play note model ! []

        Stop note ->
            stop note model ! []

        Debounce msg ->
            debounce msg model

        Tick time ->
            { model | time = time } ! []


withNote : (Model.Note -> Msg) -> Int -> Msg
withNote msg keycode =
    Maybe.map msg (Model.toNote keycode)
        |> Maybe.withDefault NoOp


play : Model.Note -> Model.Model -> Model.Model
play note model =
    let
        playingNote =
            note
                |> Model.toFrequency model.octave
                |> WebAudio.play

        newCurrentlyPlaying =
            if not <| AllDict.member note model.currentlyPlaying then
                model.currentlyPlaying
                    |> AllDict.insert note playingNote
            else
                model.currentlyPlaying
    in
        { model | currentlyPlaying = newCurrentlyPlaying }


stop : Model.Note -> Model.Model -> Model.Model
stop note model =
    let
        _ =
            AllDict.get note model.currentlyPlaying
                |> Maybe.map WebAudio.stop

        newCurrentlyPlaying =
            AllDict.remove note model.currentlyPlaying
    in
        { model | currentlyPlaying = newCurrentlyPlaying }


debounce : Msg -> Model.Model -> ( Model.Model, Cmd c )
debounce msg model =
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
