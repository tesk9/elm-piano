module View exposing (view)

import Events exposing (..)
import Html exposing (..)
import Html.Attributes exposing (autofocus)
import Html.CssHelpers
import Model exposing (Model)
import Styles exposing (..)
import Update exposing (Msg(..))


view : Model -> Html Msg
view model =
    div
        [ class [ Container ]
        ]
        [ Html.CssHelpers.style css
        , label
            [ for "input" ]
            [ text "Play input" ]
        , input
            [ autofocus True
            , onKeyDown Update.Play
            , onKeyUp Update.Stop
            , id "input"
            ]
            []
        ]
