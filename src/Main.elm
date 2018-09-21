port module Main exposing (main)

--import Keyboard

import Browser
import Css exposing (..)
import Css.Global exposing (descendants, everything)
import Html.Attributes exposing (autofocus, style)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onMouseDown, onMouseLeave, onMouseUp)
import Note exposing (Frequency, Note, Octave, notes)
import NoteSet exposing (Set)
import Platform.Sub as Sub
import Time


main =
    Browser.element
        { init =
            \() ->
                ( { currentlyPlaying = NoteSet.empty
                  , played = []
                  , octave = 4
                  , time = Time.millisToPosix 0
                  , debouncer = Nothing
                  }
                , Cmd.none
                )
        , update = update
        , subscriptions = subscriptions
        , view = \model -> view model |> toUnstyled
        }



-- MODEL


type alias Model =
    { currentlyPlaying : NoteSet.Set
    , played : List (List Frequency)
    , octave : Octave
    , time : Time.Posix
    , debouncer : Maybe Time.Posix
    }



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ css [ descendants [ everything [ boxSizing borderBox ] ] ] ]
        [ h1 [] [ text "Elm Piano" ]
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
    div
        [ css
            [ displayFlex
            , position relative
            , border3 (px 1) solid (hex "#4A4A4A")
            , width (px <| 20 * 7 * 7 + 2)
            ]
        ]
        (List.repeat 7 ()
            |> List.indexedMap (\index _ -> viewOctave currentlyPlaying selectedOctave index)
        )


viewOctave : Set -> Octave -> Octave -> Html Msg
viewOctave currentlyPlaying selectedOctave octave =
    div
        [ css
            (if selectedOctave == octave then
                [ borderBottom3 (px 1) solid (hex "#0000FF") ]

             else
                []
            )
        ]
        (List.indexedMap (\index note -> viewKey currentlyPlaying index ( octave, note )) notes)


viewKey : Set -> Int -> ( Octave, Note ) -> Html Msg
viewKey currentlyPlaying noteInd noteWithOctave =
    let
        maybeNonNatural =
            Note.getNonNaturalIndex (Tuple.first noteWithOctave) noteInd

        leftPosition =
            Maybe.map (\n -> 20 * n - 15 / 2) maybeNonNatural
                |> Maybe.withDefault 0

        isCurrentlyPlaying =
            NoteSet.member noteWithOctave currentlyPlaying

        isNonNaturual =
            maybeNonNatural /= Nothing
    in
    button
        [ css
            (List.concat
                [ [ height (px 200)
                  , width (px 20)
                  , border3 (px 1) solid (hex "#4A4A4A")
                  , borderTopWidth (px 0)
                  , backgroundColor (hex "#fffff0")
                  , hover [ keyEmphasis (hex "#FFDAB9") ]
                  , focus [ outline none ]
                  , left (px leftPosition)
                  ]
                , case ( isCurrentlyPlaying, isNonNaturual ) of
                    ( True, False ) ->
                        [ keyEmphasis (hex "#fffef0") ]

                    ( _, True ) ->
                        [ keyEmphasis (hex "#000000")
                        , height (px 140)
                        , width (px 15)
                        , position absolute
                        , backgroundColor (hex "#2A1E1B")
                        , hover [ keyEmphasis (hex "#400000") ]
                        ]

                    ( False, False ) ->
                        []
                ]
            )
        , onMouseDown (Play noteWithOctave)
        , onMouseLeave (Stop noteWithOctave)
        , onMouseUp (Stop noteWithOctave)
        ]
        []


keyEmphasis color =
    batch
        [ backgroundColor color
        , property "border-image" ("linear-gradient(to top, " ++ color.value ++ ", #4A4A4A) 1 100%")
        , cursor pointer
        ]


viewPlayingNotes : Set -> Html Msg
viewPlayingNotes currentlyPlaying =
    currentlyPlaying
        |> NoteSet.keys
        |> List.map
            (\( octave, note ) ->
                div []
                    [ text <| "Octave: " ++ String.fromInt octave ++ " | " ++ "Note: " ++ Note.toString note
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
    | Tick Time.Posix


update : Msg -> Model -> ( Model, Cmd c )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        HandleKeyDown keycode ->
            model
                |> perhapsPlay keycode
                |> Tuple.mapFirst (perhapsChangeOctave keycode)

        Play noteWithOctave ->
            play noteWithOctave model

        Stop noteWithOctave ->
            stop noteWithOctave model

        Debounce subMsg ->
            debounce subMsg model

        Tick time ->
            ( { model | time = time }
            , Cmd.none
            )


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
            if Time.posixToMillis model.time - Time.posixToMillis lastTime > 20 then
                update msg model

            else
                ( model
                , Cmd.none
                )
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
        [ always (Time.every 1000 Tick) model

        --, Keyboard.downs (Debounce << HandleKeyDown)
        --, Keyboard.ups (withNote (\note -> Stop ( model.octave, note )))
        ]
