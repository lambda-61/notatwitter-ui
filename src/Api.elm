module Api exposing
    ( requestPosts
    , requestSession
    , signIn
    , signUp
    )

import Http
import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Messages exposing (Msg(..))
import Model exposing (Model)
import Time


apiUrl : String
apiUrl =
    "/api"


requestSession : Cmd Msg
requestSession =
    Http.get
        { url = apiUrl ++ "/auth/session"
        , expect = Http.expectJson GotSession sessionDecoder
        }


signIn : Model.LoginData -> Cmd Msg
signIn loginData =
    Http.post
        { url = apiUrl ++ "/auth/login"
        , body = Http.jsonBody (encodeLoginData loginData)
        , expect = Http.expectJson GotSession sessionDecoder
        }


signUp : Model.LoginData -> Cmd Msg
signUp loginData =
    Http.post
        { url = apiUrl ++ "/auth/register"
        , body = Http.jsonBody (encodeLoginData loginData)
        , expect = Http.expectJson GotSession sessionDecoder
        }


requestPosts : Int -> (Result Http.Error (List Model.Post) -> msg) -> Cmd msg
requestPosts userId fn =
    Http.get
        { url = apiUrl ++ "/users/" ++ String.fromInt userId ++ "/posts"
        , expect = Http.expectJson fn postsDecoder
        }


sessionDecoder : Decoder Model.Session
sessionDecoder =
    D.map2 Model.Session
        (D.field "id" D.int)
        (D.field "username" D.string)


postDecoder : Decoder Model.Post
postDecoder =
    D.map4 Model.Post
        (D.field "id" D.int)
        (D.field "userid" D.int)
        (D.field "createdAt" timeDecoder)
        (D.field "text" D.string)


postsDecoder : Decoder (List Model.Post)
postsDecoder =
    D.list postDecoder


timeDecoder : Decoder Time.Posix
timeDecoder =
    D.map Time.millisToPosix D.int


encodeLoginData : Model.LoginData -> E.Value
encodeLoginData loginData =
    E.object
        [ ( "username", E.string loginData.username )
        , ( "password", E.string loginData.password )
        ]
