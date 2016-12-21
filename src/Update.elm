module Update exposing (update, Msg(..))

import Model


type Msg
    = NoOp


update : Msg -> Model.Model -> ( Model.Model, Cmd c )
update msg model =
    case msg of
        NoOp ->
            model ! []
