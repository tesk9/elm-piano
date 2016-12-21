module Model exposing (..)

import AllDict
import Flags exposing (Flags)
import Time
import WebAudio


type alias Model =
    { currentlyPlaying : AllDict.AllDict Note WebAudio.Stream Float
    , time : Time.Time
    , debouncer : Maybe Time.Time
    }


init : Flags -> Model
init flags =
    { currentlyPlaying = AllDict.empty toFrequency
    , time = 0
    , debouncer = Nothing
    }


notes : List Note
notes =
    [ A, AB, B, C, CD, D, DE, E, F, FG, G, GA, NextA ]


type Note
    = A
    | AB
    | B
    | C
    | CD
    | D
    | DE
    | E
    | F
    | FG
    | G
    | GA
    | NextA


toNote : Int -> Maybe Note
toNote keycode =
    case keycode of
        65 ->
            {- a -}
            Just A

        87 ->
            {- w -}
            Just AB

        83 ->
            {- s -}
            Just B

        68 ->
            {- d -}
            Just C

        82 ->
            {- r -}
            Just CD

        70 ->
            {- f -}
            Just D

        84 ->
            {- t -}
            Just DE

        85 ->
            {- u -}
            Just DE

        74 ->
            {- j -}
            Just E

        75 ->
            {- k -}
            Just F

        79 ->
            {- o -}
            Just FG

        76 ->
            {- l -}
            Just G

        80 ->
            {- p -}
            Just GA

        186 ->
            {- ; -}
            Just NextA

        _ ->
            Nothing


toFrequency : Note -> Float
toFrequency note =
    case note of
        A ->
            {- a -}
            220

        AB ->
            {- a#, bb -}
            233.082

        B ->
            {- b -}
            246.942

        C ->
            {- c -}
            261.626

        CD ->
            {- c#, db -}
            277.183

        D ->
            {- d -}
            293.665

        DE ->
            {- d#, eb -}
            311.127

        E ->
            {- e -}
            329.228

        F ->
            {- f -}
            349.228

        FG ->
            {- f#, gb -}
            369.994

        G ->
            {- g -}
            391.995

        GA ->
            {- g#, ab -}
            415.305

        NextA ->
            {- a -}
            440
