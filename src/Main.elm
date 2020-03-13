module Main exposing (main)

import Browser
import Html exposing (Html, div, text)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    ()


type alias Msg =
    ()


init : () -> ( Model, Cmd Msg )
init _ =
    ( (), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update _ _ =
    ( (), Cmd.none )


view : Model -> Html Msg
view _ =
    div [] [ text "Nothing yet" ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
