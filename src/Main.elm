module Main exposing (main)

import Api
import Browser
import Messages exposing (Msg)
import Model exposing (Model(..))
import Subscriptions exposing (subscriptions)
import Update exposing (update)
import View exposing (view)


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Api.requestSession
    )
