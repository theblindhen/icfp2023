open Types
open Misc

let random_placement (p : problem) : position =
  let x_offset = Random.float (p.stage_width -. 20.0) in
  let y_offset = Random.float (p.stage_height -. 20.0) in
  { x = x_offset +. 10.0 +. p.stage_bottom_left.x; y = y_offset +. 10.0 +. p.stage_bottom_left.y }

let is_valid_placement (_ : problem) (placed : position list) (potential : position) : bool =
  placed |> List.for_all (fun x -> distance x potential >= 10.0)

let random_placements (p : problem) : position list =
  Random.self_init ();
  let rec random (acc : position list) (toPlace : int list) (fuel : int) =
    match toPlace with
    | [] -> acc
    | _ :: t ->
        let potential = random_placement p in
        if is_valid_placement p acc potential then random (potential :: acc) t fuel
        else if fuel == 0 then failwith "ran out of fuel"
        else random acc toPlace (fuel - 1)
  in
  random [] p.musicians 10_000

let random_placement_solution (p : problem) : solution =
  random_placements p |> solution_of_positions p
