open Core
open Contest
open Contest.Types

let get_solution (p : problem) = Random_solver.random_placements p

let make_submission (problem_id : int) (solution : solution) : Json_j.json_submission_post =
  let solution_json = solution |> json_solution_of_solution |> Json_j.string_of_json_solution in
  let submission : Json_j.json_submission_post = { problem_id; contents = solution_json } in
  submission

let () =
  let args = Sys.get_argv () in
  match Json_util.get_problem 1 with
  | None -> failwith "Failed to parse problem"
  | Some problem ->
      print_endline (List.length problem.musicians |> string_of_int);
      let solution = get_solution problem in
      let submission = make_submission 1 solution in
      let score = Score.score_solution problem solution in
      printf "Expected score: %f\n" score;
      let out_file = args.(1) in
      (* write solution_json to file *)
      Out_channel.write_all out_file ~data:(Json_j.string_of_json_submission_post submission);
      print_endline "Done"
