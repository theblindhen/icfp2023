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

import Bootstrap.CDN as CDN
import Bootstrap.Button as BButton
import Bootstrap.Form.Input as BInput
import Bootstrap.Grid as Grid

type alias Musician = Int

type alias Attendee =
    { x : Float
    , y : Float
    , tastes : List Float 
    }

type alias Pillar =
    { center : (Float, Float)
    , radius : Float
    }

type alias Problem = 
    { roomWidth : Float
    , roomHeight: Float
    , stageWidth: Float
    , stageHeight: Float
    , stageBottomLeft : (Float, Float)
    , musicians: List Musician
    , attendees: List Attendee
    , pillars: List Pillar
    }

type alias Model =
    { count : Float
    , error : Maybe String
    , problemId : String
    , problem : Maybe Problem
    , solution : Maybe Solution }

type alias Placement =
    { x : Float
    , y : Float
    }

type alias Solution =
    { placements : List Placement }

type Msg
    = Frame Float
    | ProblemFieldUpdated String
    | LoadProblem String
    | LoadedProblem (Result Http.Error String)
    | PlaceRandomly
    | SolutionReturned (Result Http.Error String)

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

decodeCenter : Decoder (Float, Float)
decodeCenter =
    map (\l ->
        case l of
            [x, y] -> (x, y)
            _ -> (0, 0)
        ) (list float)

decodePillar : Decoder Pillar
decodePillar =
    map2 Pillar
        (field "center" decodeCenter)
        (field "radius" float)

decodeProblem : Decoder Problem
decodeProblem =
    map8 Problem
        (field "room_width" float)
        (field "room_height" float)
        (field "stage_width" float)
        (field "stage_height" float)
        (field "stage_bottom_left" decodeStageBottomLeft)
        (field "musicians" (list decodeMusicians))
        (field "attendees" (list decodeAttendee))
        (field "pillars" (list decodePillar))

decodePlacement : Decoder Placement
decodePlacement =
    map2 Placement
        (field "x" float)
        (field "y" float)

decodeSolution : Decoder Solution
decodeSolution =
    map Solution
        (field "placements" (list decodePlacement))

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
    LoadedProblem (Err _) -> ( { model | error = Just "Failed" }, Cmd.none )
    PlaceRandomly -> ( model, Cmd.batch [
        Http.post 
            { body = Http.emptyBody
            , url = "http://localhost:3000/place_randomly"
            , expect = Http.expectString SolutionReturned
            }
        ] )
    SolutionReturned (Ok res) -> (
        case decodeString decodeSolution res of
            Ok solution -> { model | solution = Just solution }
            Err err -> { model | error = Just ("Failed to decode solution: " ++ errorToString err) }
        , Cmd.none )
    SolutionReturned (Err _) -> ( { model | error = Just "Failed" }, Cmd.none )

main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( { count = 0, error = Nothing, problemId = "", problem = Nothing, solution = Nothing }, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \model -> onAnimationFrameDelta Frame
        }

viewLoadProblem : Model -> Html Msg
viewLoadProblem m =
    Grid.container []         -- Responsive fixed width container
        [ CDN.stylesheet      -- Inlined Bootstrap CSS for use with reactor
        ,  div [
                style "margin" "20px"
            ] [
                text "Problem Id: ",
                BInput.text [ BInput.onInput ProblemFieldUpdated ],
                BButton.button [ BButton.onClick (LoadProblem m.problemId), BButton.primary ] [ text "Load problem" ]
            ]
        ]
   
viewProblem : Model -> Problem -> Html Msg
viewProblem m p =
    div [
        style "margin" "20px"
    ] [
        div [ style "display" "flex"
            , style "height" "auto"
            , style "align-items" "center" ] 
            [ text "Attendes: "
            , text (String.fromInt (List.length p.attendees))
            , text "; musicians: "
            , text (String.fromInt (List.length p.musicians)) ],
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
                , renderProblem p m.solution
                ]
            ],
        div [ ] [
            BButton.button [ BButton.onClick (PlaceRandomly), BButton.primary ] [ text "Random solve" ]
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

renderProblem : Problem -> Maybe Solution -> Canvas.Renderable
renderProblem p s =
    let scale = 1000 / (max p.roomHeight p.roomWidth) in
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
        , shapes
            [ fill Color.gray ]
            (List.map (\pillar -> circle (Tuple.first pillar.center * scale, Tuple.second pillar.center * scale) (pillar.radius * scale)) p.pillars)
        , shapes
            [ stroke Color.red ]
            (case s of
                Nothing -> []
                Just solution -> 
                    (List.map (\placement -> circle (placement.x * scale, placement.y * scale) (5.0 * scale)) solution.placements)
            )
        ]
