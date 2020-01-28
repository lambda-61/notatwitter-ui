module Main exposing (main)

import Browser
import Html exposing (Html, div, form, input, label, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
import Http
import Json.Decode as Decode exposing (Decoder)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- Model --


type Model
    = Loading
    | Unauthorised LoginData
    | Authorised Session
    | ApiUnavailable


type alias LoginData =
    { username : String
    , password : String
    }


type alias Session =
    { id : Int
    , username : String
    }


mapLoginData : (LoginData -> LoginData) -> Model -> Model
mapLoginData f model =
    case model of
        Unauthorised loginData ->
            Unauthorised (f loginData)

        _ ->
            model



-- Messages --


type Msg
    = GotSession (Result Http.Error Session)
    | UpdateUsername String
    | UpdatePassword String


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, requestSession )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession (Ok session) ->
            ( Authorised session, Cmd.none )

        GotSession (Err (Http.BadStatus 401)) ->
            ( Unauthorised { username = "", password = "" }, Cmd.none )

        GotSession (Err _) ->
            ( ApiUnavailable, Cmd.none )

        UpdateUsername username ->
            ( mapLoginData (\loginData -> { loginData | username = username }) model
            , Cmd.none
            )

        UpdatePassword password ->
            ( mapLoginData (\loginData -> { loginData | password = password }) model
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    case model of
        Loading ->
            div [] [ text "Loading" ]

        Unauthorised _ ->
            let
                loginId =
                    "login"

                passwordId =
                    "password"
            in
            Html.form []
                [ label [ for loginId ] [ text "Username" ]
                , input [ type_ "text", id loginId, onInput UpdateUsername ] []
                , label [ for passwordId ] [ text "Password" ]
                , input [ type_ "password", id passwordId, onInput UpdatePassword ] []
                ]

        Authorised _ ->
            div [] [ text "Authorised" ]

        ApiUnavailable ->
            div [] [ text "API unavailable" ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- Api --


apiUrl : String
apiUrl =
    "/api"


requestSession : Cmd Msg
requestSession =
    Http.get
        { url = apiUrl ++ "/auth/session"
        , expect = Http.expectJson GotSession sessionDecoder
        }


sessionDecoder : Decoder Session
sessionDecoder =
    Decode.map2 Session
        (Decode.field "id" Decode.int)
        (Decode.field "username" Decode.string)
