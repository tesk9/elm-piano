module View exposing (view)

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
        , viewPiano
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
        ]


viewPiano : Html Msg
viewPiano =
    div [ class [ Piano ] ] (List.indexedMap viewKey Model.notes)


viewKey : Int -> Model.Note -> Html Msg
viewKey noteInd note =
    let
        maybeNonNatural =
            Model.getNonNaturalIndex noteInd

        leftPosition =
            Maybe.map (\n -> 20 * n - 15 / 2) maybeNonNatural
                |> Maybe.withDefault 0
    in
        button
            [ classList [ ( Key, True ), ( NonNatural, maybeNonNatural /= Nothing ) ]
            , style [ ( "left", toString leftPosition ++ "px" ) ]
            , onMouseDown (Update.Play note)
            , onMouseUp (Update.Stop note)
            ]
            []
