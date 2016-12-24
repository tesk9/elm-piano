module Update exposing (update, Msg(..), withNote)

import AllDict
import Model
import Time
import WebAudio


type Msg
    = NoOp
    | HandleKeyDown Int
    | Play Model.Note
    | Stop Model.Note
    | Debounce Msg
    | Tick Time.Time


update : Msg -> Model.Model -> ( Model.Model, Cmd c )
update msg model =
    case msg of
        NoOp ->
            model ! []

        HandleKeyDown keycode ->
            (model
                |> perhapsPlay keycode
                |> perhapsChangeOctave keycode
            )
                ! []

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


perhapsChangeOctave : Int -> Model.Model -> Model.Model
perhapsChangeOctave keycode model =
    Model.toOctave keycode
        |> Maybe.map (\newOctave -> { model | octave = newOctave })
        |> Maybe.withDefault model


perhapsPlay : Int -> Model.Model -> Model.Model
perhapsPlay keycode model =
    Model.toNote keycode
        |> Maybe.map ((flip play) model)
        |> Maybe.withDefault model


play : Model.Note -> Model.Model -> Model.Model
play note model =
    let
        frequency =
            WebAudio.play (Model.toFrequency model.octave note)

        newCurrentlyPlaying =
            if not <| AllDict.member note model.currentlyPlaying then
                AllDict.insert note frequency model.currentlyPlaying
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
