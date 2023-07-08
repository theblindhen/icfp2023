module Main exposing (main)

import Browser
import Browser.Events exposing (onAnimationFrameDelta)
import Canvas exposing (rect, shapes, circle, group)
import Canvas.Settings exposing (stroke, fill)
import Color
import Http
import Html exposing (Html, div, button, text, input)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (style)
import Json.Decode exposing (..)
import Html exposing (table)

type alias Musician = Int

type alias Attendee =
    { x : Float
    , y : Float
    , tastes : List Float 
    }

type alias Problem = 
    { roomWidth : Float
    , roomHeight: Float
    , stageWidth: Float
    , stageHeight: Float
    , stageBottomLeft : (Float, Float)
    , musicians: List Musician
    , attendees: List Attendee
    }

type alias Model =
    { count : Float
    , error : Maybe String
    , problemId : String
    , problem : Maybe Problem }

type Msg
    = Frame Float
    | ProblemFieldUpdated String
    | LoadProblem String
    | LoadedProblem (Result Http.Error String)

decodeMusicians : Decoder Musician
decodeMusicians =
    int

decodeAttendee : Decoder Attendee
decodeAttendee =
    map3 Attendee
        (field "x" float)
        (field "y" float)
        (field "tastes" (list float))

decodeStageBottomLeft : Decoder (Float, Float)
decodeStageBottomLeft =
    map (\l -> 
        case l of
            [x, y] -> (x, y)
            _ -> (0, 0)
        ) (list float)

decodeProblem : Decoder Problem
decodeProblem =
    map7 Problem
        (field "room_width" float)
        (field "room_height" float)
        (field "stage_width" float)
        (field "stage_height" float)
        (field "stage_bottom_left" decodeStageBottomLeft)
        (field "musicians" (list decodeMusicians))
        (field "attendees" (list decodeAttendee))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    Frame _ -> ( { model | count = model.count + 1 }, Cmd.none )
    ProblemFieldUpdated problemId -> ( { model | problemId = problemId }, Cmd.none )
    LoadProblem problemId -> ( model, Cmd.batch [
        Http.get 
            { url = "http://localhost:3000/problem/" ++ problemId
            , expect = Http.expectString LoadedProblem
            }
        ])
    LoadedProblem (Ok res) -> (
        case decodeString decodeProblem res of
            Ok problem -> { model | problem = Just problem }
            Err err -> { model | error = Just ("Failed to decode problem: " ++ errorToString err) }
        , Cmd.none )
    LoadedProblem (Err _) -> ( model, Cmd.none )

main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( { count = 0, error = Nothing, problemId = "", problem = Nothing }, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \model -> onAnimationFrameDelta Frame
        }

viewLoadProblem : Model -> Html Msg
viewLoadProblem m =
    div [] [
        text "Problem Id: ",
        input [ onInput ProblemFieldUpdated ] [],
        button [ onClick (LoadProblem m.problemId) ] [ text "Load problem" ]
    ]

viewProblem : Model -> Problem -> Html Msg
viewProblem m p =
    div
        [ style "display" "flex"
        , style "justify-content" "center"
        , style "align-items" "center"
        ]
        [ 
        Canvas.toHtml
            ( 1000, 1000 )
            [ ]
            [ clearScreen
            , renderProblem p
            ]
        ]   

view : Model -> Html Msg
view m =
    case m.error of
        Nothing ->
            case m.problem of
                Nothing -> viewLoadProblem m
                Just problem -> viewProblem m problem
        Just err ->
            div [] [ text err ]




clearScreen =
    shapes [ fill Color.white ] [ rect ( 0, 0 ) 1000 1000 ]

renderProblem : Problem -> Canvas.Renderable
renderProblem p =
    let scale = 1000 / (max p.roomHeight p.roomWidth) in
    let _ = Debug.log "Problem" (p.roomHeight, p.roomWidth, scale) in
    group []
        [ shapes
            [ stroke Color.black ]
            [ rect (0, 0) (p.roomWidth * scale) (p.roomHeight * scale) ]
        , shapes
            [ fill Color.gray ]
            [ rect (Tuple.first p.stageBottomLeft * scale, Tuple.second p.stageBottomLeft * scale) (p.stageWidth * scale) (p.stageHeight * scale)] 
        , shapes
            [ stroke Color.blue ]
            (List.map (\a -> circle (a.x * scale, a.y * scale) (3.0 * scale)) p.attendees)
        ]

