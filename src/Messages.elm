module Messages exposing (Msg(..))

import Http as Http
import Model


type Msg
    = GotSession (Result Http.Error Model.Session)
    | GotPosts (Result Http.Error (List Model.Post))
      -- Login form event
    | UpdateUsername String
    | UpdatePassword String
    | SignIn
    | SignUp
