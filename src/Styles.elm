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
    | SelectedOctave
    | Key
    | NonNatural
    | CurrentlyPlaying
    | Staff
    | Chord
    | Note


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
        , width (px <| 20 * 7 * 7 + 2)
        ]
    , (.) SelectedOctave
        [ borderBottom3 (px 1) solid (hex "#0000FF") ]
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
    , (.) Staff
        [ backgroundImage (url "./assets/piano_staff.png")
        , backgroundRepeat noRepeat
        , height (px 120)
        , width (px 535)
        , paddingLeft (px 80)
        ]
    , (.) Chord
        [ position relative
        , display inlineBlock
        , height (pct 100)
        , width (px 12)
        ]
    , (.) Note
        [ height (px 4)
        , width (px 5)
        , backgroundColor (hex "#2A1E1B")
        , borderRadius (pct 60)
        , transform (rotate (deg -15))
        , position absolute
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
