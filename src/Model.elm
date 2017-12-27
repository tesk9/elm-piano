module Model exposing (..)

import Note exposing (Frequency, Octave)
import NoteSet
import Time


type alias Model =
    { currentlyPlaying : NoteSet.Set
    , played : List (List Frequency)
    , octave : Octave
    , time : Time.Time
    , debouncer : Maybe Time.Time
    }
