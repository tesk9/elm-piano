module Events exposing (..)

import Html
import Html.Events exposing (..)
import Json.Decode exposing (..)


{-| `onKeyDown` always succeeds, and passes the relevant key's code on.
-}
onKeyDown : (Int -> msg) -> Html.Attribute msg
onKeyDown msg =
    on "keyup"
        (andThen (\k -> succeed (msg k))
            keyCode
        )


{-| `onKeyUp` succeeds when the specified int matches the key that has been released.
-}
onKeyUp : Int -> msg -> Html.Attribute msg
onKeyUp char msg =
    on "keyup"
        (andThen
            (\key ->
                if key == char then
                    succeed msg
                else
                    fail ""
            )
            keyCode
        )
