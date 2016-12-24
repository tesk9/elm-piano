module Update exposing (update, Msg(..), withNote)

import AllDict
import Model
import Time
import WebAudio


type Msg
    = NoOp
    | HandleKeyDown Int
    | Play ( Model.Octave, Model.Note )
    | Stop ( Model.Octave, Model.Note )
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

        Play noteWithOctave ->
            play noteWithOctave model ! []

        Stop noteWithOctave ->
            stop noteWithOctave model ! []

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
        |> Maybe.map (\note -> play ( model.octave, note ) model)
        |> Maybe.withDefault model


play : ( Model.Octave, Model.Note ) -> Model.Model -> Model.Model
play noteWithOctave model =
    let
        frequency =
            WebAudio.play (Model.toFrequency noteWithOctave)

        newCurrentlyPlaying =
            if not <| AllDict.member noteWithOctave model.currentlyPlaying then
                AllDict.insert noteWithOctave frequency model.currentlyPlaying
            else
                model.currentlyPlaying
    in
        { model | currentlyPlaying = newCurrentlyPlaying }


stop : ( Model.Octave, Model.Note ) -> Model.Model -> Model.Model
stop noteWithOctave model =
    let
        _ =
            AllDict.get noteWithOctave model.currentlyPlaying
                |> Maybe.map WebAudio.stop

        newCurrentlyPlaying =
            AllDict.remove noteWithOctave model.currentlyPlaying
    in
        { model | currentlyPlaying = newCurrentlyPlaying }


debounce : Msg -> Model.Model -> ( Model.Model, Cmd c )
debounce msg model =
    let
        perhapsUpdate lastTime =
            if model.time - lastTime > 20 then
                update msg model
            else
                model ! []
    in
        model.debouncer
            |> Maybe.map perhapsUpdate
            |> Maybe.withDefault (update msg model)
