module WebAudio exposing (..)

import Native.WebAudio


play : Float -> () -> b
play =
    Native.WebAudio.oscillator
