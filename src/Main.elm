module Main exposing (main)

import Browser
import Html exposing (Html, div, text)
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


type Msg
    = GotSession (Result Http.Error Session)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, requestSession )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        GotSession (Ok session) ->
            ( Authorised session, Cmd.none )

        GotSession (Err (Http.BadStatus 401)) ->
            ( Unauthorised { username = "", password = "" }, Cmd.none )

        GotSession (Err _) ->
            ( ApiUnavailable , Cmd.none )


view : Model -> Html Msg
view model =
    case model of
        Loading ->
            div [] [ text "Loading" ]

        Unauthorised _ ->
            div [] [ text "Unauthorised" ]

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
