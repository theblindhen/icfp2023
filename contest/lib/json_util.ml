open Core

let get_problem problem_id =
  match In_channel.read_all (sprintf "../problems/problem-%d.json" problem_id) with
  | json -> Some (Types.problem_of_json_problem (Json_j.json_problem_of_string json))
  | exception _ -> None
