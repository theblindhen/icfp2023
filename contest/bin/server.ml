open Core
open Contest
open Opium
open Physics

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

let init_solution_handler f _ =
  match !current_problem with
  | None -> Lwt.return (Response.make ~status:`OK ~body:(Body.of_string "No problem") ())
  | Some p ->
      let solution = f p in
      let solution_json =
        solution |> Types.json_solution_of_solution |> Json_j.string_of_json_solution
      in
      current_solution := Some solution;
      Lwt.return (Response.make ~status:`OK ~body:(Body.of_string solution_json) ())

let rec repeat f n a = if n = 0 then a else repeat f (n - 1) (f a)

let optimiser_handler f req =
  let n = Router.param req "n" |> int_of_string in
  match (!current_problem, !current_solution) with
  | Some p, Some s ->
      let solution' = repeat (f p) n s in
      let solution_json =
        solution' |> Types.json_solution_of_solution |> Json_j.string_of_json_solution
      in
      current_solution := Some solution';
      Lwt.return (Response.make ~status:`OK ~body:(Body.of_string solution_json) ())
  | _ -> Lwt.return (Response.make ~status:`OK ~body:(Body.of_string "No problem") ())

let save_handler _ =
  match (!current_problem, !current_solution) with
  | Some p, Some s ->
      let solution_json = s |> Types.json_solution_of_solution |> Json_j.string_of_json_solution in
      let score = Score.score_solution p s in
      Misc.validate_solution p s;
      Json_util.write_solution_if_best score p.problem_id s;
      Lwt.return (Response.make ~status:`OK ~body:(Body.of_string solution_json) ())
  | _ -> Lwt.return (Response.make ~status:`OK ~body:(Body.of_string "No problem") ())

let _ =
  App.empty
  |> App.get "/" index_handler
  |> App.get "/elm.js" js_handler
  |> App.get "/problem/:id" problem_handler
  |> App.post "/place_randomly"
       (init_solution_handler (fun p -> Random_solver.random_placement_solution p []))
  |> App.post "/swap/:n" (optimiser_handler Improver.improve)
  |> App.post "/lp/:n" (optimiser_handler Lp_solver.lp_optimize_solution)
  |> App.post "/init_sim" (init_solution_handler init_solution_sol_stage1)
  |> App.post "/step_sim/:n" (optimiser_handler simulate_step_sol_stage1)
  |> App.post "/save" save_handler
  |> App.run_command
