open Types
open Misc
open Core

let random_placement (p : problem) : position =
  let x_offset = Random.float (p.stage_width -. 20.0) in
  let y_offset = Random.float (p.stage_height -. 20.0) in
  { x = x_offset +. 10.0 +. p.stage_bottom_left.x; y = y_offset +. 10.0 +. p.stage_bottom_left.y }

let is_valid_placement (_ : problem) (placed : position list) (potential : position) : bool =
  placed |> List.for_all ~f:(fun x -> Float.(distance x potential >= 10.0))

let random_placements (p : problem) (already_placed : position list) : position list =
  Random.self_init ();
  let rec random (acc : position list) (toPlace : int list) (fuel : int) =
    match toPlace with
    | [] -> acc
    | _ :: t ->
        let potential = random_placement p in
        if is_valid_placement p acc potential then random (potential :: acc) t fuel
        else if fuel = 0 then failwith "ran out of fuel"
        else random acc toPlace (fuel - 1)
  in
  random already_placed (List.drop p.musicians (List.length already_placed)) 10_000

let random_placement_solution (p : problem) (already_placed : position list) : solution =
  random_placements p already_placed |> solution_of_positions p
