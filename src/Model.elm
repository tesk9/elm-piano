module Model exposing (..)

import AllDict
import Flags exposing (Flags)
import Time
import WebAudio


type alias Model =
    { currentlyPlaying : AllDict.AllDict ( Octave, Note ) WebAudio.Stream Float
    , octave : Octave
    , time : Time.Time
    , debouncer : Maybe Time.Time
    }


init : Flags -> Model
init flags =
    { currentlyPlaying = AllDict.empty toFrequency
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
        49 ->
            Just 0

        50 ->
            Just 1

        51 ->
            Just 2

        52 ->
            Just 3

        53 ->
            Just 4

        54 ->
            Just 5

        55 ->
            Just 6

        56 ->
            Just 7

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


toFrequency : ( Octave, Note ) -> Float
toFrequency ( octave, note ) =
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


getNonNaturalIndex : Octave -> Int -> Maybe Float
getNonNaturalIndex octave noteInd =
    let
        leftPositioning =
            (toFloat noteInd * 3 / 5)
                |> floor
                |> (+) 1
                |> (+) (octave * 7)

        position =
            noteInd % 5
    in
        Maybe.map toFloat <|
            if position == 1 || position == 4 then
                Just leftPositioning
            else
                Nothing
