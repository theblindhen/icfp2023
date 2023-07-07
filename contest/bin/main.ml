open Core
open Contest
open Contest.Types

let get_solution (p : problem) = Random_solver.random_placements p

let () =
  let args = Sys.get_argv () in
  let problem_id = args.(1) |> Int.of_string in
  match Json_util.get_problem problem_id with
  | None -> failwith "Failed to parse problem"
  | Some problem ->
      print_endline (List.length problem.musicians |> string_of_int);
      let solution = get_solution problem in
      let submission = Json_util.make_submission problem_id solution in
      let score = Score.score_solution problem solution in
      printf "Expected score: %f\n" score;
      let out_file = "solution.json" in
      (* write solution_json to file *)
      Out_channel.write_all out_file ~data:(Json_j.string_of_json_submission_post submission);
      print_endline "Done"
