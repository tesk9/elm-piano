port module Update exposing (Msg(..), update, withNote)

import Model exposing (Model)
import Note exposing (Frequency, Note, Octave)
import NoteSet
import Time


type Msg
    = NoOp
    | HandleKeyDown Int
    | Play ( Octave, Note )
    | Stop ( Octave, Note )
    | Debounce Msg
    | Tick Time.Time


update : Msg -> Model -> ( Model, Cmd c )
update msg model =
    case msg of
        NoOp ->
            model ! []

        HandleKeyDown keycode ->
            model
                |> perhapsPlay keycode
                |> Tuple.mapFirst (perhapsChangeOctave keycode)

        Play noteWithOctave ->
            play noteWithOctave model

        Stop noteWithOctave ->
            stop noteWithOctave model

        Debounce msg ->
            debounce msg model

        Tick time ->
            { model | time = time } ! []


withNote : (Note -> Msg) -> Int -> Msg
withNote msg keycode =
    Maybe.map msg (Note.toNote keycode)
        |> Maybe.withDefault NoOp


perhapsChangeOctave : Int -> Model -> Model
perhapsChangeOctave keycode model =
    Note.toOctave keycode
        |> Maybe.map (\newOctave -> { model | octave = newOctave })
        |> Maybe.withDefault model


perhapsPlay : Int -> Model -> ( Model, Cmd c )
perhapsPlay keycode model =
    Note.toNote keycode
        |> Maybe.map
            (\note ->
                play ( model.octave, note ) model
            )
        |> Maybe.withDefault ( model, Cmd.none )


play : ( Octave, Note ) -> Model -> ( Model, Cmd c )
play noteWithOctave model =
    let
        isAlreadyPlaing =
            NoteSet.member noteWithOctave model.currentlyPlaying
    in
    if isAlreadyPlaing then
        ( model, Cmd.none )
    else
        ( { model
            | currentlyPlaying = NoteSet.insert noteWithOctave model.currentlyPlaying
          }
        , playNote (Note.toFrequency noteWithOctave)
        )


stop : ( Octave, Note ) -> Model -> ( Model, Cmd msg )
stop noteWithOctave model =
    let
        frequency =
            Note.toFrequency noteWithOctave
    in
    ( { model
        | currentlyPlaying = NoteSet.remove noteWithOctave model.currentlyPlaying
        , played = [ frequency ] :: model.played
      }
    , stopNote frequency
    )


debounce : Msg -> Model -> ( Model, Cmd c )
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



-- PORTS


port playNote : Float -> Cmd msg


port stopNote : Float -> Cmd msg
