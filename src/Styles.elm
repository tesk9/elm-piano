module Styles
    exposing
        ( Classes(..)
        , css
        , class
        , id
        , for
        , classList
        , snippets
        )

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Html
import Html.Attributes
import Html.CssHelpers exposing (Namespace, withNamespace)


type Classes
    = Container
    | Piano
    | Key
    | NonNatural
    | CurrentlyPlaying


snippets : List Snippet
snippets =
    [ (.) Container
        [ descendants
            [ everything
                [ boxSizing borderBox ]
            ]
        ]
    , (.) Piano
        [ displayFlex
        , position relative
        , border3 (px 1) solid (hex "#4A4A4A")
        , width (px 162)
        ]
    , (.) Key
        [ height (px 200)
        , width (px 20)
        , border3 (px 1) solid (hex "#4A4A4A")
        , borderTopWidth (px 0)
        , backgroundColor (hex "#fffff0")
        , hover [ keyEmphasis (hex "#FFDAB9") ]
        , withClass CurrentlyPlaying [ keyEmphasis (hex "#fffef0") ]
        , focus [ outline none ]
        ]
    , (.) NonNatural
        [ height (px 140)
        , width (px 15)
        , position absolute
        , backgroundColor (hex "#2A1E1B")
        , hover [ keyEmphasis (hex "#400000") ]
        , withClass CurrentlyPlaying [ keyEmphasis (hex "#000000") ]
        ]
    ]


keyEmphasis : ColorValue compatible -> Mixin
keyEmphasis color =
    mixin
        [ backgroundColor color
        , property "border-image" ("linear-gradient(to top, " ++ color.value ++ ", #4A4A4A) 1 100%")
        , cursor pointer
        ]


{ class, classList } =
    currentNamespace


id : String -> Html.Attribute msg
id value =
    Html.Attributes.id (namespace_ ++ value)


for : String -> Html.Attribute msg
for value =
    Html.Attributes.for (namespace_ ++ value)


namespace_ : String
namespace_ =
    "elm-piano-"


currentNamespace : Html.CssHelpers.Namespace String a b c
currentNamespace =
    withNamespace namespace_


css : String
css =
    snippets
        |> namespace currentNamespace.name
        |> stylesheet
        |> (\x -> [ x ])
        |> compile
        |> .css
