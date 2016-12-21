module WebAudio exposing (..)

import Native.WebAudio


audioContext : a -> b
audioContext =
    Native.WebAudio.audioContext
