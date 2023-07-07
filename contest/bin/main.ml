open Core
open Contest

let get_solution (p : Types.problem) = Random_solver.random_placement_solution p

let () =
  let args = Sys.get_argv () in
  let problem_id = args.(1) |> Int.of_string in
  match Json_util.get_problem problem_id with
  | None -> failwith "Failed to parse problem"
  | Some problem ->
      print_endline (List.length problem.musicians |> string_of_int);
      let solution = get_solution problem in
      let score = Score.score_solution problem solution in
      printf "Expected score: %f\n" score;
      let optimised_solution = Improver.improve problem solution in
      let optimised_score = Score.score_solution problem optimised_solution in
      printf "Improved score: %f\n" optimised_score;
      Json_util.write_solution_if_best problem_id problem optimised_solution;
      (* write solution_json to file *)
      print_endline "Done"
