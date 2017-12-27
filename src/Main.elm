port module Main exposing (main)

import AllDict
import Html exposing (..)
import Html.Attributes exposing (autofocus, style)
import Html.CssHelpers
import Html.Events exposing (onMouseDown, onMouseLeave, onMouseUp)
import Keyboard
import Note exposing (Frequency, Note, Octave, notes)
import NoteSet exposing (Set)
import Platform.Sub as Sub
import Styles exposing (..)
import Time


main : Program Never Model Msg
main =
    Html.program
        { init =
            ( { currentlyPlaying = AllDict.empty Note.toFrequency
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



-- MODEL


type alias Model =
    { currentlyPlaying : NoteSet.Set
    , played : List (List Frequency)
    , octave : Octave
    , time : Time.Time
    , debouncer : Maybe Time.Time
    }



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class [ Container ]
        ]
        [ Html.CssHelpers.style css
        , h1 [] [ text "Elm Piano" ]
        , viewPiano model.currentlyPlaying model.octave
        , h2 [] [ text "Playing the Elm Piano" ]
        , p [] [ text "Play the piano via point-and-click or via your keyboard." ]
        , h3 [] [ text "Keyboard interaction:" ]
        , p []
            [ text
                """
                Your current octave is marked in the interface by a blue line. Change the octave with your number keys.
                The row of keys (on a QWERTY keyboard) from 'A' through 'J' play the natural notes 'A' through 'G'.
                Flats & sharps are available (where they exist) one row up.
            """
            ]
        , h4 [] [ text "Currently playing:" ]
        , viewPlayingNotes model.currentlyPlaying
        ]


viewPiano : Set -> Octave -> Html Msg
viewPiano currentlyPlaying selectedOctave =
    div [ class [ Piano ] ]
        (List.repeat 7 ()
            |> List.indexedMap (\index _ -> viewOctave currentlyPlaying selectedOctave index)
        )


viewOctave : Set -> Octave -> Octave -> Html Msg
viewOctave currentlyPlaying selectedOctave octave =
    div [ classList [ ( SelectedOctave, selectedOctave == octave ) ] ] <|
        List.indexedMap (\index note -> viewKey currentlyPlaying index ( octave, note )) notes


viewKey : Set -> Int -> ( Octave, Note ) -> Html Msg
viewKey currentlyPlaying noteInd noteWithOctave =
    let
        maybeNonNatural =
            Note.getNonNaturalIndex (Tuple.first noteWithOctave) noteInd

        leftPosition =
            Maybe.map (\n -> 20 * n - 15 / 2) maybeNonNatural
                |> Maybe.withDefault 0
    in
    button
        [ classList
            [ ( Key, True )
            , ( NonNatural, maybeNonNatural /= Nothing )
            , ( CurrentlyPlaying, NoteSet.member noteWithOctave currentlyPlaying )
            ]
        , style [ ( "left", toString leftPosition ++ "px" ) ]
        , onMouseDown (Play noteWithOctave)
        , onMouseLeave (Stop noteWithOctave)
        , onMouseUp (Stop noteWithOctave)
        ]
        []


viewPlayingNotes : Set -> Html Msg
viewPlayingNotes currentlyPlaying =
    currentlyPlaying
        |> NoteSet.keys
        |> List.map
            (\( octave, note ) ->
                div []
                    [ text <| "Octave: " ++ toString octave ++ " | " ++ "Note: " ++ toString note
                    ]
            )
        |> div []



-- UPDATE


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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ always (Time.every Time.millisecond Tick) model
        , Keyboard.downs (Debounce << HandleKeyDown)
        , Keyboard.ups (withNote (\note -> Stop ( model.octave, note )))
        ]
