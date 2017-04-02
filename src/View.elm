module View exposing (view)

import AllDict
import Html exposing (..)
import Html.Attributes exposing (autofocus, style)
import Html.CssHelpers
import Html.Events exposing (onMouseDown, onMouseUp, onMouseLeave)
import Model exposing (Model)
import Styles exposing (..)
import Update exposing (Msg(..))


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


viewPiano : AllDict.AllDict ( Model.Octave, Model.Note ) a Float -> Model.Octave -> Html Msg
viewPiano currentlyPlaying selectedOctave =
    div [ class [ Piano ] ]
        (List.repeat 7 () |> List.indexedMap (\index _ -> viewOctave currentlyPlaying selectedOctave index))


viewOctave : AllDict.AllDict ( Model.Octave, Model.Note ) a Float -> Model.Octave -> Model.Octave -> Html Msg
viewOctave currentlyPlaying selectedOctave octave =
    div [ classList [ ( SelectedOctave, selectedOctave == octave ) ] ] <|
        List.indexedMap (\index note -> viewKey currentlyPlaying index ( octave, note )) Model.notes


viewKey : AllDict.AllDict ( Model.Octave, Model.Note ) a Float -> Int -> ( Model.Octave, Model.Note ) -> Html Msg
viewKey currentlyPlaying noteInd noteWithOctave =
    let
        maybeNonNatural =
            Model.getNonNaturalIndex (Tuple.first noteWithOctave) noteInd

        leftPosition =
            Maybe.map (\n -> 20 * n - 15 / 2) maybeNonNatural
                |> Maybe.withDefault 0
    in
        button
            [ classList
                [ ( Key, True )
                , ( NonNatural, maybeNonNatural /= Nothing )
                , ( CurrentlyPlaying, AllDict.member noteWithOctave currentlyPlaying )
                ]
            , style [ ( "left", toString leftPosition ++ "px" ) ]
            , onMouseDown (Update.Play noteWithOctave)
            , onMouseLeave (Update.Stop noteWithOctave)
            , onMouseUp (Update.Stop noteWithOctave)
            ]
            []


viewPlayingNotes : AllDict.AllDict ( Model.Octave, Model.Note ) a Float -> Html Msg
viewPlayingNotes currentlyPlaying =
    currentlyPlaying
        |> AllDict.keys
        |> List.map
            (\( octave, note ) ->
                div []
                    [ text <| "Octave: " ++ toString octave ++ " | " ++ "Note: " ++ toString note
                    ]
            )
        |> div []
