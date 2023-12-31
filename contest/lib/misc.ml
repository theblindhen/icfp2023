open Core
open Types

let validate_solution (p : problem) (s : solution) =
  let musician_ids = Array.map s ~f:(fun m -> m.id) in
  (* Musician 0 is the first used *)
  let validate_min_musician () =
    let min_musician = Array.min_elt musician_ids ~compare:Int.compare |> Option.value_exn in
    assert (min_musician = 0)
  in
  validate_min_musician ();
  (* Musician max is the number of musician *)
  let validate_max_musician () =
    let max_musician = Array.max_elt musician_ids ~compare:Int.compare |> Option.value_exn in
    assert (max_musician = List.length p.musicians - 1)
  in
  validate_max_musician ();
  (* All musician ids are distinct *)
  let validate_distinct_musicians () =
    assert (Array.length musician_ids = Array.length (Set.to_array (Int.Set.of_array musician_ids)))
  in
  validate_distinct_musicians ();
  (* Musicians' instruments correspond to those in the problem *)
  let validate_musician_instruments () =
    List.iteri p.musicians ~f:(fun m_id inst ->
        match Array.find s ~f:(fun m' -> m'.id = m_id) with
        | None -> assert false
        | Some m' -> assert (m'.instrument = inst))
  in
  validate_musician_instruments ();
  (* Musicians are within the stage, including stage margin *)
  let validate_musicians_onstage () =
    let musician_radius = 10. in
    let within_stage (p : problem) (m : musician) =
      let open Float in
      let { x; y } = m.pos in
      let { x = sx; y = sy } = p.stage_bottom_left in
      x >= sx +. musician_radius
      && x <= sx +. p.stage_width -. musician_radius
      && y >= sy +. musician_radius
      && y <= sy +. p.stage_height -. musician_radius
    in
    Array.iter s ~f:(fun m -> assert (within_stage p m))
  in
  validate_musicians_onstage ();
  (* Musicians are not too close to each other *)
  let validate_musicians_distant () =
    let musician_radius_sq = 100. in
    Array.iter s ~f:(fun m ->
        Array.iter s ~f:(fun m' ->
            if m.id <> m'.id then
              let dist = Float.(Geometry.distance_squared m.pos m'.pos) in
              if Float.(dist < musician_radius_sq) then
                failwithf "Musicians %d and %d are too close (%f < %f)" m.id m'.id dist
                  musician_radius_sq ()))
  in
  validate_musicians_distant ();
  ()

let solution_of_positions (p : problem) (s : position list) : solution =
  match List.zip p.musicians s with
  | Ok l -> List.mapi l ~f:(fun i (instrument, pos) -> { id = i; pos; instrument }) |> Array.of_list
  | Unequal_lengths -> failwith "solution_of_positions: unequal lengths"

let string_of_score (score : float) : string = Int.to_string_hum (Float.to_int score)

let instrument_count (p : problem) : int =
  match List.max_elt p.musicians ~compare:Int.compare with
  | None -> 0
  | Some x -> x + 1

let legal_musician_rect (p : problem) : Geometry.rectangle =
  ( { x = p.stage_bottom_left.x +. 10.0; y = p.stage_bottom_left.y +. 10. },
    p.stage_width -. 20.,
    p.stage_height -. 20. )

let musician_group_by_instrument (problem : problem) : int list array =
  let num_instruments = instrument_count problem in
  let musician_pool = Array.create ~len:num_instruments [] in
  List.iteri problem.musicians ~f:(fun m inst -> musician_pool.(inst) <- m :: musician_pool.(inst));
  musician_pool

let sigmoid (x : float) : float =
  let open Float in
  1. /. (1. +. exp (-.x))

let pole_function (x : float) : float =
  let open Float in
  abs (tan (abs ((x +. 1.) *. pi /. 2.)))
