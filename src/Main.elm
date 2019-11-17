module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (..)



-- MAIN


main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }



-- MODEL


type alias Model =
  {}


init : () -> (Model, Cmd Msg)
init _ =
  ( {}
  , Cmd.none
  )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
      NoOp ->
          ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  div [] [text "Hello"]
