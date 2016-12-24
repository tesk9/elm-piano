module View exposing (view)

import AllDict
import Events exposing (..)
import Html exposing (..)
import Html.Attributes exposing (autofocus, style)
import Html.CssHelpers
import Html.Events exposing (onMouseDown, onMouseUp)
import Model exposing (Model)
import Styles exposing (..)
import Update exposing (Msg(..))


view : Model -> Html Msg
view model =
    div
        [ class [ Container ]
        ]
        [ Html.CssHelpers.style css
        , viewPiano model.currentlyPlaying
        , label
            [ for "input" ]
            [ text "Play input" ]
        , input
            [ autofocus True
            , onKeyDown (Update.withNote (Update.Debounce << Update.Play))
            , onKeyUp (Update.withNote Update.Stop)
            , id "input"
            ]
            []
        , br [] []
        , h4 [] [ text "Playing:" ]
        , viewPlayingNotes model.currentlyPlaying
        ]


viewPiano : AllDict.AllDict Model.Note a Float -> Html Msg
viewPiano currentlyPlaying =
    div [ class [ Piano ] ] (List.indexedMap (viewKey currentlyPlaying) Model.notes)


viewKey : AllDict.AllDict Model.Note a Float -> Int -> Model.Note -> Html Msg
viewKey currentlyPlaying noteInd note =
    let
        maybeNonNatural =
            Model.getNonNaturalIndex noteInd

        leftPosition =
            Maybe.map (\n -> 20 * n - 15 / 2) maybeNonNatural
                |> Maybe.withDefault 0
    in
        button
            [ classList
                [ ( Key, True )
                , ( NonNatural, maybeNonNatural /= Nothing )
                , ( CurrentlyPlaying, AllDict.member note currentlyPlaying )
                ]
            , style [ ( "left", toString leftPosition ++ "px" ) ]
            , onMouseDown (Update.Play note)
            , onMouseUp (Update.Stop note)
            ]
            []


viewPlayingNotes : AllDict.AllDict Model.Note a Float -> Html Msg
viewPlayingNotes currentlyPlaying =
    currentlyPlaying
        |> AllDict.keys
        |> List.map (\n -> div [] [ text (toString n) ])
        |> div []
