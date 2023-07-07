open Core

let get_problem problem_id =
  match In_channel.read_all (sprintf "../problems/problem-%d.json" problem_id) with
  | json -> Some (Types.problem_of_json_problem (Json_j.json_problem_of_string json))
  | exception _ -> None

let make_submission (problem_id : int) (solution : Types.solution) : Json_j.json_submission_post =
  let solution_json =
    solution |> Types.json_solution_of_solution |> Json_j.string_of_json_solution
  in
  let submission : Json_j.json_submission_post = { problem_id; contents = solution_json } in
  submission
