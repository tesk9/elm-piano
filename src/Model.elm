module Model exposing (..)

import AllDict
import Flags exposing (Flags)
import Time
import WebAudio


type alias Model =
    { currentlyPlaying : AllDict.AllDict Note WebAudio.Stream Float
    , octave : Octave
    , time : Time.Time
    , debouncer : Maybe Time.Time
    }


init : Flags -> Model
init flags =
    { currentlyPlaying = AllDict.empty (toFrequency 4)
    , octave = 4
    , time = 0
    , debouncer = Nothing
    }


notes : List Note
notes =
    [ A, AB, B, C, CD, D, DE, E, F, FG, G, GA ]


type alias Octave =
    Int


toOctave : Int -> Maybe Octave
toOctave keycode =
    case keycode of
        488 ->
            Just 0

        49 ->
            Just 1

        50 ->
            Just 2

        51 ->
            Just 3

        52 ->
            Just 4

        53 ->
            Just 5

        54 ->
            Just 6

        55 ->
            Just 7

        56 ->
            Just 8

        57 ->
            Just 9

        _ ->
            Nothing


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
            Just A

        _ ->
            Nothing


toFrequency : Octave -> Note -> Float
toFrequency octave note =
    (*) (toFloat (2 ^ octave)) <|
        case note of
            A ->
                {- a -}
                27.5

            AB ->
                {- a#, bb -}
                29.135

            B ->
                {- b -}
                30.868

            C ->
                {- c -}
                32.703

            CD ->
                {- c#, db -}
                34.648

            D ->
                {- d -}
                36.708

            DE ->
                {- d#, eb -}
                38.891

            E ->
                {- e -}
                41.203

            F ->
                {- f -}
                43.654

            FG ->
                {- f#, gb -}
                46.249

            G ->
                {- g -}
                48.999

            GA ->
                {- g#, ab -}
                51.913


getNonNaturalIndex : Int -> Maybe Float
getNonNaturalIndex noteInd =
    let
        halfOctave =
            toFloat noteInd / 5 |> floor

        position =
            noteInd % 5
    in
        Maybe.map toFloat <|
            if position == 1 then
                Just <| (halfOctave * 3) + 1
            else if position == 4 then
                Just <| (halfOctave * 3) + 3
            else
                Nothing
