module Model exposing (..)

import Flags exposing (Flags)
import WebAudio


type alias Model =
    { currentlyPlaying : List WebAudio.Stream }


init : Flags -> Model
init flags =
    { currentlyPlaying = [] }
