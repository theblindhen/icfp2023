open Core

let get_problem problem_id =
  match In_channel.read_all (sprintf "../problems/problem-%d.json" problem_id) with
  | json -> Some (Types.problem_of_json_problem ~problem_id (Json_j.json_problem_of_string json))
  | exception _ -> None

let get_solution (problem : Types.problem) solution_file =
  match
    In_channel.read_all (sprintf "../problems/solutions-%d/%s" problem.problem_id solution_file)
  with
  | json -> Some (Types.solution_of_json_solution problem (Json_j.json_solution_of_string json))
  | exception _ -> None

(** The directory "../problems/solutions-$PROBLEM_ID" contains the solutions to
 * problem. The files are named "$SCORE.json" where $SCORE is the score of the
 * solution in the file. This function returns the score of the highest scoring
 * solution. Returns 0 if there is no existing solution. *)
let best_solution_score problem_id =
  let dir_name = sprintf "../problems/solutions-%d" problem_id in
  match Sys_unix.readdir dir_name with
  | exception Sys_error _ -> 0.
  | files ->
      Array.filter_map files ~f:(fun filename ->
          try Some (Float.of_string (String.chop_suffix_exn filename ~suffix:".json")) with
          | _ -> None)
      |> Array.max_elt ~compare:Float.compare
      |> Option.value ~default:0.

let get_best_solution (problem : Types.problem) =
  let best_score = best_solution_score problem.problem_id in
  let best_solution_file = sprintf "%.0f.json" best_score in
  get_solution problem best_solution_file

(** Write the solution to the "../problems/solutions-%d" directory. Only write a
 * new file if the new score is better than all the previous ones. *)
let write_solution_if_best (score : float) (problem : Types.problem) (solution : Types.solution) :
    unit =
  let best_previous_score = best_solution_score problem.problem_id in
  if Float.(score > best_previous_score) then (
    let volumes = Score.volumes_for_musicians problem solution in
    let solution_json =
      Types.json_solution_of_solution ~volumes solution |> Json_j.string_of_json_solution
    in
    (* Create the directory "../problems/solutions-%d" if it doesn't exist.
     * We're not using mkdir_p here because if there's some kind of problem with
     * our assumptions about directory layout we don't want files to be created
     * under the parent directory. *)
    let dir_name = sprintf "../problems/solutions-%d" problem.problem_id in
    (match Sys_unix.is_directory dir_name with
    | `No -> Caml_unix.mkdir dir_name 0o777
    | _ -> ());
    (* Write the file, omitting decimals (they should be 0). *)
    let filename = sprintf "%s/%.0f.json" dir_name score in
    eprintf "Writing solution to %s\n%!" filename;
    Out_channel.write_all filename ~data:solution_json)
  else
    eprintf "Not writing solution with score %s (< %s)\n%!" (Misc.string_of_score score)
      (Misc.string_of_score best_previous_score)
