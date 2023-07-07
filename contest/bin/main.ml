open Core
open Contest
open Contest.Types

let get_problem problem_id =
  let json = In_channel.read_all ("../problems/problem-" ^ string_of_int problem_id ^ ".json") in
  json |> Json_j.json_problem_of_string |> problem_of_json_problem

let get_solution () =
  let solution : solution = [ { x = 1.; y = 2.5 } ] in
  solution

let make_submission (problem_id : int) (solution : solution) : Json_j.json_submission_post =
  let solution_json = solution |> json_solution_of_solution |> Json_j.string_of_json_solution in
  let submission : Json_j.json_submission_post = { problem_id; contents = solution_json } in
  submission

let () =
  let args = Sys.get_argv () in
  let problem = get_problem 1 in
  print_endline (List.length problem.musicians |> string_of_int);
  let solution = get_solution () in
  let submission = make_submission 1 solution in
  let out_file = args.(1) in
  (* write solution_json to file *)
  Out_channel.write_all out_file ~data:(Json_j.string_of_json_submission_post submission);
  print_endline "Done"