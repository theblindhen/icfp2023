open Core
open Contest
open Opium

let current_problem = ref None
let current_solution = ref None
let read_file path = In_channel.create path |> In_channel.input_all |> String.strip

let index_handler _ =
  let index = read_file "../frontend/index.html" in
  Lwt.return (Response.make ~status:`OK ~body:(Body.of_string index) ())

let js_handler _ =
  let index = read_file "../frontend/elm.js" in
  Lwt.return (Response.make ~status:`OK ~body:(Body.of_string index) ())

let problem_handler req =
  let id = Router.param req "id" in
  let problem = In_channel.read_all (sprintf "../problems/problem-%s.json" id) in
  current_problem := Json_util.get_problem (int_of_string id);
  Lwt.return (Response.make ~status:`OK ~body:(Body.of_string problem) ())

let place_randomly_handler _ =
  match !current_problem with
  | None -> Lwt.return (Response.make ~status:`OK ~body:(Body.of_string "No problem") ())
  | Some p ->
      let solution = Random_solver.random_placement_solution p [] in
      let solution_json =
        solution |> Types.json_solution_of_solution |> Json_j.string_of_json_solution
      in
      current_solution := Some solution;
      Lwt.return (Response.make ~status:`OK ~body:(Body.of_string solution_json) ())

let swap_handler _ =
  match (!current_problem, !current_solution) with
  | Some p, Some s ->
      let solution' = Improver.improve p s in
      let solution_json =
        solution' |> Types.json_solution_of_solution |> Json_j.string_of_json_solution
      in
      current_solution := Some solution';
      Lwt.return (Response.make ~status:`OK ~body:(Body.of_string solution_json) ())
  | _ -> Lwt.return (Response.make ~status:`OK ~body:(Body.of_string "No problem") ())

let _ =
  App.empty
  |> App.get "/" index_handler
  |> App.get "/elm.js" js_handler
  |> App.get "/problem/:id" problem_handler
  |> App.post "/place_randomly" place_randomly_handler
  |> App.post "/swap" swap_handler
  |> App.run_command
