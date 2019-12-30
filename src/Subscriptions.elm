module Subscriptions exposing (subscriptions)

import Messages exposing (Msg)
import Model exposing (Model)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
