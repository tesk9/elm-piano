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


snippets : List Snippet
snippets =
    [ (.) Container
        []
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
