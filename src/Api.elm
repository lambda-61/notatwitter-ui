module Api exposing (requestSession, signIn, signUp)

import Http
import Json.Decode as D exposing (Decoder)
import Json.Encode as E
import Messages exposing (Msg(..))
import Model exposing (Model)


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


sessionDecoder : Decoder Model.Session
sessionDecoder =
    D.map2 Model.Session
        (D.field "id" D.int)
        (D.field "username" D.string)


encodeLoginData : Model.LoginData -> E.Value
encodeLoginData loginData =
    E.object
        [ ( "username", E.string loginData.username )
        , ( "password", E.string loginData.password )
        ]
