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

(** Write the solution to the "../problems/solutions-%d.json" directory. For
 * now, each file is named "positive.json" because we only write out the file if
 * the score is positive. *)
let write_solution_if_positive (problem_id : int) problem (solution : Types.solution) : unit =
  let score : float = Score.score_solution problem solution in
  if Float.is_positive score then (
    let solution_json =
      solution |> Types.json_solution_of_solution |> Json_j.string_of_json_solution
    in
    (* Create the directory "../problems/solutions-%d.json" if it doesn't exist. *)
    let dir_name = sprintf "../problems/solutions-%d" problem_id in
    (match Sys_unix.is_directory dir_name with
    | `No -> Caml_unix.mkdir dir_name 0o777
    | _ -> ());
    let filename = sprintf "%s/positive.json" dir_name in
    Out_channel.write_all filename ~data:solution_json)
