module WebAudio exposing (..)

import Native.WebAudio


play : Float -> () -> b
play =
    Native.WebAudio.oscillator


stop : Stream -> ()
stop stream =
    Native.WebAudio.stop stream


type alias Stream =
    () -> ()
