open Core
open Contest
open Opium
open Physics

let current_problem = ref None
let current_solution = ref None
let current_round = ref 0
let read_file path = In_channel.create path |> In_channel.input_all |> String.strip

let returnJson json_str =
  Lwt.return
    (Response.make ~status:`OK
       ~headers:(Headers.of_list [ ("content-type", "application/json") ])
       ~body:(Body.of_string json_str) ())

let returnError msg =
  Lwt.return
    (Response.make ~status:`I_m_a_teapot
       ~headers:(Headers.of_list [ ("content-type", "text/plain") ])
       ~body:(Body.of_string msg) ())

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
  current_solution := None;
  current_round := 0;
  returnJson problem

let solutions_handler req =
  let id = Router.param req "id" in
  let solutions_dir = sprintf "../problems/solutions-%s" id in
  match Sys_unix.is_directory solutions_dir with
  | `Yes ->
      let solution_files =
        Sys_unix.ls_dir solutions_dir
        |> List.filter ~f:(fun s -> String.is_suffix ~suffix:".json" s)
        |> List.map ~f:(fun s -> String.chop_suffix_exn ~suffix:".json" s)
      in
      let result = String.concat ~sep:"," solution_files in
      returnJson result
  | _ -> returnError "No solutions found"

let solution_handler req =
  let id = Router.param req "id" in
  let solution_file = Router.param req "name" ^ ".json" in
  match !current_problem with
  | None -> returnError "No problem selected; cannot load solution"
  | Some problem ->
      if int_of_string id = problem.problem_id then
        match Json_util.get_solution problem solution_file with
        | Some solution ->
            current_solution := Some solution;
            current_round := 0;
            let solution_json =
              solution |> Types.json_solution_of_solution |> Json_j.string_of_json_solution
            in
            printf "solution loaded: %s\n%!" solution_json;
            returnJson solution_json
        | None -> returnError "Failed to load solution"
      else returnError "Problem id mismatch"

let init_solution_handler f _ =
  match !current_problem with
  | None -> returnError "No problem selected; cannot initialize solution"
  | Some p ->
      let solution = f p in
      let solution_json =
        solution |> Types.json_solution_of_solution |> Json_j.string_of_json_solution
      in
      current_solution := Some solution;
      current_round := 0;
      returnJson solution_json

let optimiser_handler f req =
  let n = Router.param req "n" |> int_of_string in
  match (!current_problem, !current_solution) with
  | Some p, Some s ->
      Printf.printf "Optimization round %d\n" !current_round;
      let solution' =
        let rec repeat fp n s =
          if n = 0 then s
          else (
            current_round := !current_round + 1;
            repeat fp (n - 1) (fp s ~round:!current_round))
        in
        repeat (f p) n s
      in
      let solution_json =
        solution' |> Types.json_solution_of_solution |> Json_j.string_of_json_solution
      in
      current_solution := Some solution';
      returnJson solution_json
  | _ -> returnError "No problem or solution selected; cannot optimize solution"

let save_handler _ =
  match (!current_problem, !current_solution) with
  | Some p, Some s ->
      let solution_json = s |> Types.json_solution_of_solution |> Json_j.string_of_json_solution in
      let score = Score.score_solution p s in
      Misc.validate_solution p s;
      Json_util.write_solution_if_best score p.problem_id s;
      returnJson solution_json
  | _ -> returnError "No problem or solution selected; cannot save solution"

let _ =
  App.empty
  |> App.get "/" index_handler
  |> App.get "/elm.js" js_handler
  |> App.get "/problem/:id" problem_handler
  |> App.get "/solutions/:id" solutions_handler
  |> App.post "/solution/:id/:name" solution_handler
  |> App.post "/place_randomly"
       (init_solution_handler (fun p -> Random_solver.random_placement_solution p []))
  |> App.post "/swap/:n" (optimiser_handler Improver.improve)
  |> App.post "/lp/:n" (optimiser_handler Lp_solver.lp_optimize_solution)
  |> App.post "/init_sim" (init_solution_handler init_solution_sol)
  |> App.post "/step_sim/:n" (optimiser_handler simulate_step_sol)
  |> App.post "/save" save_handler
  |> App.run_command
