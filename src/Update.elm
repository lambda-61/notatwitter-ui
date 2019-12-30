module Update exposing (update)

import Api
import Http as Http
import Messages exposing (Msg(..))
import Model as Model exposing (Model(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession (Ok session) ->
            ( Authorised session { posts = Model.PostsLoading }
            , Api.requestPosts session.id GotPosts
            )

        GotSession (Err (Http.BadStatus 401)) ->
            ( Unauthorized { username = "", password = "" }
            , Cmd.none
            )

        GotSession (Err _) ->
            ( ApiUnavailable
            , Cmd.none
            )

        GotPosts (Err err) ->
            ( Model.mapUserData (\ud -> { ud | posts = Model.PostsError err }) model
            , Cmd.none
            )

        GotPosts (Ok posts) ->
            ( Model.mapUserData (\ud -> { ud | posts = Model.PostsReady posts }) model
            , Cmd.none
            )

        UpdateUsername username ->
            ( Model.mapLoginData (\ld -> { ld | username = username }) model
            , Cmd.none
            )

        UpdatePassword password ->
            ( Model.mapLoginData (\ld -> { ld | password = password }) model
            , Cmd.none
            )

        SignIn ->
            case model of
                Unauthorized loginData ->
                    ( Loading, Api.signIn loginData )

                _ ->
                    ( model, Cmd.none )

        SignUp ->
            case model of
                Unauthorized loginData ->
                    ( Loading, Api.signUp loginData )

                _ ->
                    ( model, Cmd.none )
