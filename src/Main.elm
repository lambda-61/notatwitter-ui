module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http as Http
import Json.Decode as D exposing (Decoder)
import Json.Encode as E



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Model
    = Loading
    | Unauthorized LoginData
    | Authorised Session UserData
    | ApiUnavailable


type alias LoginData =
    { username : String
    , password : String
    }


type alias Session =
    { id : String
    , username : String
    }


type alias UserData =
    {}


mapLoginData : (LoginData -> LoginData) -> Model -> Model
mapLoginData f model =
    case model of
        Unauthorized loginData ->
            Unauthorized (f loginData)

        _ ->
            model


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , requestSession
    )



-- UPDATE


type Msg
    = GotSession (Result Http.Error Session)
      -- Login form event
    | UpdateUsername String
    | UpdatePassword String
    | SignIn


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession (Ok session) ->
            ( Authorised session {}
            , Cmd.none
            )

        GotSession (Err (Http.BadStatus 401)) ->
            ( Unauthorized { username = "", password = "" }
            , Cmd.none
            )

        GotSession (Err _) ->
            ( ApiUnavailable
            , Cmd.none
            )

        UpdateUsername username ->
            ( mapLoginData (\ld -> { ld | username = username }) model
            , Cmd.none
            )

        UpdatePassword password ->
            ( mapLoginData (\ld -> { ld | password = password }) model
            , Cmd.none
            )

        SignIn ->
            case model of
                Unauthorized loginData ->
                    ( Loading, signIn loginData )

                _ ->
                    ( model, Cmd.none )



-- API


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
        , body =
            Http.jsonBody
                (E.object
                    [ ( "username", E.string loginData.username )
                    , ( "password", E.string loginData.password )
                    ]
                )
        , expect = Http.expectJson GotSession sessionDecoder
        }


sessionDecoder : Decoder Session
sessionDecoder =
    D.map2 Session
        (D.field "id" D.string)
        (D.field "username" D.string)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Loading ->
            text "Loading..."

        Unauthorized loginData ->
            Html.form []
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
                , button [] [ text "Login" ]
                ]

        Authorised session userData ->
            div []
                [ h1 [] [ text ("Hello " ++ session.username ++ "!") ] ]

        ApiUnavailable ->
            text "Something went wrong, please try again later"
