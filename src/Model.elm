module Model exposing
    ( LoginData
    , Model(..)
    , Post
    , Posts(..)
    , Session
    , UserData
    , mapLoginData
    , mapUserData
    )

import Http
import Time


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


type alias Post =
    { id : Int
    , userId : Int
    , createdAt : Time.Posix
    , text : String
    }


type Posts
    = PostsLoading
    | PostsError Http.Error
    | PostsReady (List Post)


type alias UserData =
    { posts : Posts
    }


mapLoginData : (LoginData -> LoginData) -> Model -> Model
mapLoginData f model =
    case model of
        Unauthorized loginData ->
            Unauthorized (f loginData)

        _ ->
            model


mapUserData : (UserData -> UserData) -> Model -> Model
mapUserData f model =
    case model of
        Authorised session userData ->
            Authorised session (f userData)

        _ ->
            model
