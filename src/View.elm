module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Messages exposing (Msg(..))
import Model exposing (Model(..))


view : Model -> Html Msg
view model =
    case model of
        Loading ->
            text "Loading..."

        Unauthorized loginData ->
            div []
                [ input
                    [ value loginData.username
                    , onInput UpdateUsername
                    ]
                    []
                , input
                    [ type_ "password"
                    , value loginData.password
                    , onInput UpdatePassword
                    ]
                    []
                , button [ onClick SignIn ] [ text "Sign In" ]
                , button [ onClick SignUp ] [ text "Sign Up" ]
                ]

        Authorised session userData ->
            div []
                [ h1 [] [ text ("Hello " ++ session.username ++ "!") ]
                , Html.form [ onSubmit CreatePost ]
                       [ input [ type_ "text", onInput UpdateDraft ][]
                       ]
                ]

        ApiUnavailable ->
            text "Something went wrong, please try again later"
