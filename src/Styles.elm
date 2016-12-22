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


snippets : List Snippet
snippets =
    [ (.) Container
        []
    , (.) Piano
        [ displayFlex
        , position relative
        ]
    , (.) Key
        [ height (px 200)
        , width (px 20)
        , backgroundColor (hex "#fffff0")
        , border3 (px 1) solid (hex "#4A4A4A")
        ]
    , (.) NonNatural
        [ height (px 150)
        , width (px 15)
        , backgroundColor (hex "#000000")
        , position relative
        ]
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
