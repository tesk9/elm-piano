module Flags exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline exposing (..)


type alias Flags =
    {}


decoder : Decoder Flags
decoder =
    decode Flags
