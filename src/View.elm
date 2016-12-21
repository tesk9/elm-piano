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
    div [ class [ Piano ] ] (List.map viewKey Model.notes)


viewKey : Model.Note -> Html Msg
viewKey note =
    div [ class [ Key ] ]
        [ text (toString note) ]
