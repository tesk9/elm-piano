module Model exposing (..)

import Flags exposing (Flags)
import WebAudio


type alias Model =
    { currentlyPlaying : List WebAudio.Stream }


init : Flags -> Model
init flags =
    { currentlyPlaying = [] }


type Note
    = A
    | B
    | C
    | D
    | E
    | F
    | G


toNote : Int -> Maybe Note
toNote keycode =
    case keycode of
        65 ->
            {- a -}
            Just A

        83 ->
            {- s -}
            Just B

        68 ->
            {- d -}
            Just C

        70 ->
            {- f -}
            Just D

        74 ->
            {- j -}
            Just E

        75 ->
            {- k -}
            Just F

        76 ->
            {- l -}
            Just G

        _ ->
            Nothing


toFrequency : Note -> Float
toFrequency note =
    case note of
        A ->
            {- a -}
            220

        B ->
            {- b -}
            246.942

        C ->
            {- c -}
            261.626

        D ->
            {- d -}
            293.665

        E ->
            {- e -}
            329.228

        F ->
            {- f -}
            349.228

        G ->
            {- g -}
            391.995
