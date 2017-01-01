module View exposing (view)

import AllDict
import Events exposing (..)
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
        , viewPiano model.currentlyPlaying model.octave
        , label
            [ for "input" ]
            [ text "Play input" ]
        , input
            [ autofocus True
            , onKeyDown (Update.Debounce << Update.HandleKeyDown)
            , onKeyUp (Update.withNote (\note -> Update.Stop ( model.octave, note )))
            , id "input"
            ]
            []
        , br [] []
        , h4 [] [ text "Record:" ]
        , viewPlayedNotes (Debug.log "played" model.played)
        , h4 [] [ text "Playing:" ]
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


viewPlayedNotes : List (List ( Model.Octave, Model.Note )) -> Html msg
viewPlayedNotes played =
    div [ class [ Staff ] ] <|
        List.map viewChord <|
            List.reverse played


viewChord : List ( Model.Octave, Model.Note ) -> Html msg
viewChord notes =
    div [ class [ Chord ] ] <|
        List.map viewNote notes


viewNote : ( Model.Octave, Model.Note ) -> Html msg
viewNote noteWithOctave =
    div
        [ class [ Note ]
        , style [ ( "bottom", toString (Model.toStaffPosition noteWithOctave) ++ "px" ) ]
        ]
        []
