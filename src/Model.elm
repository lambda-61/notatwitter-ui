module Model exposing (LoginData, Model(..), Session, UserData, mapLoginData)


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
    { id : Int
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
