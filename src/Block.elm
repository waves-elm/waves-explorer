module Block exposing (..)

import Helpers exposing (timestampToTime)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as JD exposing (Decoder, field, int, string)
import Transactions exposing (Transaction, transactionDecoder, viewTransactions)


type alias Block =
    { height : Int
    , id : String
    , version : Int
    , timestamp : Int
    , parentBlock : String
    , generator : String
    , signature : String
    , transactions : List Transaction
    }


initBlock : Block
initBlock =
    { height = 0
    , id = ""
    , version = 0
    , timestamp = 0
    , parentBlock = ""
    , generator = ""
    , signature = ""
    , transactions = []
    }


blockDecoder : Decoder Block
blockDecoder =
    JD.map8 Block
        (field "height" int)
        (field "id" string)
        (field "version" int)
        (field "timestamp" int)
        (field "reference" string)
        (field "generator" string)
        (field "signature" string)
        (field "transactions" (JD.list transactionDecoder))


getBlock : Int -> (Result Http.Error Block -> msg) -> Cmd msg
getBlock height msg =
    let
        url =
            "https://nodes.wavesnodes.com/blocks/at/" ++ String.fromInt height
    in
    Http.get
        { url = url
        , expect = Http.expectJson msg blockDecoder
        }


viewBlock : (String -> msg) -> (String -> msg) -> Block -> Html msg
viewBlock getTransaction getBalance block =
    div [ class "block" ]
        [ div [ class "block__title" ]
            [ p [] [ text "Block" ]
            , p [] [ text ("/ " ++ String.fromInt block.height) ]
            ]
        , div [ class "block__items" ]
            [ div []
                [ p [] [ text "Height" ]
                , p [] [ text (String.fromInt block.height) ]
                ]
            , div []
                [ p [] [ text "ID" ]
                , p [] [ text block.id ]
                ]
            , div []
                [ p [] [ text "Version" ]
                , p [] [ text (String.fromInt block.version) ]
                ]
            , div []
                [ p [] [ text "Timestamp" ]
                , p [] [ text (timestampToTime block.timestamp) ]
                ]
            , div []
                [ p [] [ text "Transactions" ]
                , p [] [ text (String.fromInt (List.length block.transactions)) ]
                ]
            , div []
                [ p [] [ text "Parent block" ]
                , p [] [ text block.parentBlock ]
                ]
            , div []
                [ p [] [ text "Generator" ]
                , a [ href "#", onClick (getBalance block.generator) ] [ text block.generator ]
                ]
            , div []
                [ p [] [ text "Signature" ]
                , p [] [ text block.signature ]
                ]
            ]
        , div []
            [ viewTransactions getTransaction getBalance block.transactions ]
        ]
