module Messages exposing (Msg(..))

import Http as Http
import Model


type Msg
    = GotSession (Result Http.Error Model.Session)
      -- Login form event
    | UpdateUsername String
    | UpdatePassword String
    | SignIn
    | SignUp
