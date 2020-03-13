module Main exposing (main)

import Browser
import Html exposing (Html, button, div, input, label, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode



-- Model --


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type Model
    = Loading
    | Unauthorised LoginData
    | Authorised Session
    | ApiUnavailable


mapLoginData : (LoginData -> LoginData) -> Model -> Model
mapLoginData f model =
    case model of
        Unauthorised loginData ->
            Unauthorised (f loginData)

        _ ->
            model


type alias LoginData =
    { username : String
    , password : String
    }


type alias Session =
    { id : Int
    , username : String
    }



-- Messages --


type Msg
    = GotSession (Result Http.Error Session)
    | UpdateUsername String
    | UpdatePassword String
    | SignIn LoginData



-- Init --


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, requestSession )



-- Update --


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

        SignIn loginData ->
            ( model, signIn loginData )



-- View --


view : Model -> Html Msg
view model =
    case model of
        Loading ->
            div [] [ text "Loading" ]

        Unauthorised loginData ->
            div []
                [ label [ for "login" ] [ text "Username" ]
                , input [ type_ "text", id "login", value loginData.username, onInput UpdateUsername ] []
                , label [ for "password" ] [ text "Password" ]
                , input [ type_ "password", id "password", value loginData.password, onInput UpdatePassword ] []
                , button [ onClick (SignIn loginData) ] [ text "Sign In" ]
                ]

        Authorised _ ->
            div [] [ text "Authorised" ]

        ApiUnavailable ->
            div [] [ text "API Unavailable" ]



-- Subscriptions --


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


signIn : LoginData -> Cmd Msg
signIn loginData =
    Http.post
        { url = apiUrl ++ "/auth/login"
        , body = Http.jsonBody (encodeLoginData loginData)
        , expect = Http.expectJson GotSession sessionDecoder
        }



-- Encoders/Decoders --


sessionDecoder : Decoder Session
sessionDecoder =
    Decode.map2 Session
        (Decode.field "id" Decode.int)
        (Decode.field "username" Decode.string)


encodeLoginData : LoginData -> Encode.Value
encodeLoginData loginData =
    Encode.object
        [ ( "username", Encode.string loginData.username )
        , ( "password", Encode.string loginData.password )
        ]
