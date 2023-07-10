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

import List.Extra as Extra

import Bootstrap.CDN as CDN
import Bootstrap.Button as BButton
import Bootstrap.Form.Input as BInput
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row as Row
import Bootstrap.Utilities.Flex as Flex
import Bootstrap.ButtonGroup as BGroup

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

type alias Focus = Int

type alias Model =
    { count : Float
    , error : Maybe String
    , problemId : String
    , problem : Maybe Problem
    , solution : Maybe Solution
    , focus : Maybe Focus
    , playing : Bool
    , loading : List String
    , edge : String
    , musicianScores : List Float
    , zoom : Int
    }

type alias Placement =
    { x : Float
    , y : Float
    }

type alias Solution =
    { placements : List Placement }

type Msg
    = Frame Float
    | ProblemFieldUpdated String
    | EdgeFieldUpdated String
    | LoadProblem String
    | LoadedProblem (Result Http.Error String)
    | Edge String
    | PlaceRandomly
    | Swap
    | LP
    | InitSim
    | StepSim Int
    | Load
    | LoadSolution String
    | Save
    | FocusOnInstrument Int
    | LoadMusicianScores
    | Zoom Int
    | LoadedMusicianScores (Result Http.Error String)
    | SolutionReturned (Result Http.Error String)
    | FetchSolutions (Result Http.Error String)
    | Play Bool

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

postExpectSolution : String -> Cmd Msg
postExpectSolution url =
    Http.post
        { body = Http.emptyBody
        , url = url
        , expect = Http.expectString SolutionReturned
        }

postExpectSolutionWithBody : String -> Http.Body -> Cmd Msg
postExpectSolutionWithBody url body =
    Http.post
        { body = body
        , url = url
        , expect = Http.expectString SolutionReturned
        }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
    Frame _ -> ( { model | count = model.count + 1 }, Cmd.none )
    ProblemFieldUpdated problemId -> ( { model | problemId = problemId }, Cmd.none )
    EdgeFieldUpdated edge -> ( { model | edge = edge }, Cmd.none )
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
    Edge edge -> ( model, Cmd.batch [ postExpectSolutionWithBody "http://localhost:3000/edge" (Http.stringBody "application/json" edge) ] )
    PlaceRandomly -> ( model, Cmd.batch [ postExpectSolution "http://localhost:3000/place_randomly" ] )
    Swap -> ( model, Cmd.batch [ postExpectSolution "http://localhost:3000/swap/1" ] )
    LP -> ( model, Cmd.batch [ postExpectSolution "http://localhost:3000/lp/1" ] )
    InitSim -> ( model, Cmd.batch [ postExpectSolution "http://localhost:3000/init_sim" ] )
    StepSim i -> ( model, Cmd.batch [ postExpectSolution ("http://localhost:3000/step_sim/" ++ (String.fromInt i)) ] )
    Save -> ( model, Cmd.batch [ postExpectSolution "http://localhost:3000/save" ] )
    Load -> ( model, Cmd.batch [ Http.get 
            { url = "http://localhost:3000/solutions/" ++ model.problemId
            , expect = Http.expectString FetchSolutions
            }])
    Zoom i -> ( { model | zoom = i }, Cmd.none)
    LoadSolution s -> ( model, Cmd.batch [ postExpectSolution ("http://localhost:3000/solution/" ++ model.problemId ++ "/" ++ s) ])
    FocusOnInstrument i -> ( { model | focus = Just i }, Cmd.none )
    SolutionReturned (Ok res) ->
        case decodeString decodeSolution res of
            Ok solution -> ({ model | solution = Just solution, loading = [], musicianScores = [] }, 
                if model.playing then Cmd.batch [ postExpectSolution "http://localhost:3000/step_sim/1" ] else Cmd.none)
            Err err -> ({ model | error = Just ("Failed to decode solution: " ++ errorToString err) }, Cmd.none )
    SolutionReturned (Err err) -> ( { model | error = Just "Failed" }, Cmd.none )
    FetchSolutions (Ok res) -> ( { model | loading = String.split "," res }, Cmd.none)
    FetchSolutions (Err _) -> ( { model | error = Just "Failed" }, Cmd.none )
    LoadMusicianScores -> ( model, Cmd.batch [
        Http.get 
            { url = "http://localhost:3000/musician_scores"
            , expect = Http.expectString LoadedMusicianScores
            }
        ])
    LoadedMusicianScores (Ok res) -> 
        case decodeString (list float) res of
            Ok scores -> ( { model | musicianScores = scores }, Cmd.none )
            Err err -> ({ model | error = Just ("Failed to decode musician scores: " ++ errorToString err) }, Cmd.none )
    LoadedMusicianScores (Err _) -> ( { model | error = Just "Failed" }, Cmd.none )
    Play playing -> ( { model | playing = playing }, Cmd.batch [ postExpectSolution "http://localhost:3000/step_sim/1" ] )


main : Program () Model Msg
main =
    Browser.element
        { init = \() -> ( { count = 0, error = Nothing, problemId = "", problem = Nothing, solution = Nothing, focus = Nothing, playing = False, loading = [], edge = "", musicianScores = [], zoom = 1 }, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \model -> Sub.none
        }

viewLoadProblem : Model -> Html Msg
viewLoadProblem m =
    Grid.container []
        [ CDN.stylesheet
        ,  div [
                style "margin" "20px"
            ] [
                text "Problem Id: ",
                BInput.text [ BInput.onInput ProblemFieldUpdated ],
                BButton.button [ BButton.onClick (LoadProblem m.problemId), BButton.primary ] [ text "Load problem" ]
            ]
        ]

nextFocus : Maybe Focus -> Int -> Msg
nextFocus mFocus i =
    case mFocus of
        Nothing -> FocusOnInstrument 0
        Just focus -> FocusOnInstrument (focus + i)

numberOfInstruments : Problem -> Int
numberOfInstruments p =
    case List.maximum p.musicians of
        Nothing -> 0
        Just i -> i

instrumentDescription : Model -> Problem -> String
instrumentDescription m p =
    case m.focus of
        Nothing -> "No instrument in focus"
        Just i -> 
            let 
                tastes = List.map (\a -> 
                    Maybe.withDefault 0 (Extra.getAt i a.tastes)) p.attendees
                min = Maybe.withDefault 0 (List.minimum tastes)
                max = Maybe.withDefault 0 (List.maximum tastes)
                noMusicians = 
                    List.filter (\musician -> musician == i) p.musicians
                    |> List.length
            in "Focusing on instrument: " ++ (String.fromInt i) ++ "; min: " ++ (String.fromFloat min) ++ "; max: " ++ (String.fromFloat max) ++ "; number of musicians with instrument: " ++ (String.fromInt noMusicians)

viewProblem : Model -> Problem -> Html Msg
viewProblem m p =
    let instruments = numberOfInstruments p in
        div [
            style "margin" "20px"
        ] [
            div [ style "display" "flex"
                , style "height" "auto"
                , style "align-items" "center" ] 
                [ text "Problem: "
                , text m.problemId
                , text "; attendes: "
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
                    ( 1001, 1001 )
                    [ ]
                    [ clearScreen
                    , renderProblem m p m.solution m.focus
                    ]
                ],
            div [ ] 
                [ 
                    BButton.button [ BButton.onClick (PlaceRandomly), BButton.primary ] [ text "Random solve" ],
                    BButton.button [ BButton.onClick (Swap), BButton.primary ] [ text "Swap" ],
                    BButton.button [ BButton.onClick (LP), BButton.primary ] [ text "LP" ],
                    BButton.button 
                        ((if m.focus == Nothing || m.focus == Just 0 then [BButton.disabled True] else []) ++ 
                            [ BButton.onClick (nextFocus m.focus (-1)), BButton.primary ]) [ text "Previous Instrument" ],
                    BButton.button 
                        ((if m.focus == Just instruments then [BButton.disabled True] else []) ++
                            [ BButton.onClick (nextFocus m.focus 1), BButton.primary ]) [ text "Next Instrument" ],
                    BButton.button [ BButton.onClick Load, BButton.primary ] [ text "Load" ],
                    BButton.button [ BButton.onClick Save, BButton.primary ] [ text "Save" ],
                    BButton.button [ BButton.onClick (Zoom (m.zoom + 1)), BButton.primary ] [ text "Zoom in" ],
                    BButton.button [ BButton.onClick (Zoom (m.zoom - 1)), BButton.primary ] [ text "Zoom out" ],
                    BButton.button [ BButton.onClick LoadMusicianScores, BButton.primary ] [ text "Load musician scores" ],
                    BButton.button [ BButton.onClick InitSim, BButton.primary ] [ text "Init Sim" ],
                    BButton.button [ BButton.onClick (StepSim 1), BButton.primary ] [ text "Step Sim" ],
                    BButton.button [ BButton.onClick (StepSim 100), BButton.primary ] [ text "Step Sim 100" ],
                    BButton.button [ BButton.onClick (Play (not m.playing)), BButton.primary ] [ text "Play" ]
                ],
            div [ ]
                [
                    BButton.button [ BButton.onClick (Edge m.edge), BButton.primary ] [ text "Place specified edges" ],
                    BInput.text [ BInput.onInput EdgeFieldUpdated ]
                ],
            div [ ]
                [ 
                    text (instrumentDescription m p)
                ]
        ]

viewLoadSolution : List String -> Html Msg
viewLoadSolution loading =
    let sorted = loading |> List.map (\l -> String.toInt l |> Maybe.withDefault 0) |> List.sort |> List.map String.fromInt |> List.reverse in
    div [ style "margin" "20px" ] 
        (List.map (\l -> BButton.button [ BButton.primary, BButton.onClick (LoadSolution l) ] [text l]) sorted)
        

view : Model -> Html Msg
view m =
    case m.error of
        Nothing ->
            case m.loading of 
                [] -> 
                    case m.problem of
                        Nothing -> viewLoadProblem m
                        Just problem -> viewProblem m problem
                _ -> viewLoadSolution m.loading
        Just err ->
            div [] [ text err ]

clearScreen =
    shapes [ fill Color.white ] [ rect ( 0, 0 ) 1000 1000 ]

renderProblem : Model -> Problem -> Maybe Solution -> Maybe Focus -> Canvas.Renderable
renderProblem m p s f =
    let 
        scale = (1000 * (toFloat m.zoom)) / (max p.roomHeight p.roomWidth)

        musicians = 
            case s of
                Nothing -> []
                Just solution -> Extra.zip solution.placements p.musicians

        unfocusedMusicians =
            case f of
                Nothing -> musicians
                Just focus -> List.filter (\(_, musician) -> musician /= focus) musicians

        focusedMusicians =
            case f of
                Nothing -> []
                Just focus -> List.filter (\(_, musician) -> musician == focus) musicians

        musicianShapes =
            case m.musicianScores of
                [] -> group [] 
                    [ shapes
                        [ stroke Color.red ]
                        (List.map (\(placement, _) -> circle (placement.x * scale, placement.y * scale) (5.0 * scale)) unfocusedMusicians)
                    , shapes
                        [ stroke Color.green ]
                        (List.map (\(placement, _) -> circle (placement.x * scale, placement.y * scale) (5.0 * scale)) focusedMusicians)
                    ]
                scores -> 
                    let max = (List.maximum scores |> Maybe.withDefault 0) * 2/3 in
                        group [] 
                            (List.map (\((placement, _), score) -> shapes [stroke (Color.hsl (score / max) 1.0 0.5)] [ circle (placement.x * scale, placement.y * scale) (5.0 * scale) ]) (Extra.zip musicians scores))

    in
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
            , musicianShapes
            ]

