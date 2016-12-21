module Events exposing (..)

import Html
import Html.Events exposing (..)
import Json.Decode exposing (..)


{-| `onKeyDown`
-}
onKeyDown : (Int -> msg) -> Html.Attribute msg
onKeyDown tagger =
    on "keydown" (map tagger keyCode)


{-| `onKeyUp`
-}
onKeyUp : (Int -> msg) -> Html.Attribute msg
onKeyUp tagger =
    on "keyup" (map tagger keyCode)
