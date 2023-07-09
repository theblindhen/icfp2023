open Core
open Types

let random_placement (p : problem) : position =
  let x_offset = Random.float (p.stage_width -. 20.0) in
  let y_offset = Random.float (p.stage_height -. 20.0) in
  { x = x_offset +. 10.0 +. p.stage_bottom_left.x; y = y_offset +. 10.0 +. p.stage_bottom_left.y }

let random_placement_around_locus (p : problem) (locus : position) : position =
  let legal_rect = Misc.legal_musician_rect p in
  let sample_scale = 2.5 in
  let rec loop () =
    let delta_x =
      sample_scale *. Statistics.sample_min_abs Statistics.poor_mans_gaussian (7.5 /. sample_scale)
    in
    let delta_y =
      sample_scale *. Statistics.sample_min_abs Statistics.poor_mans_gaussian (7.5 /. sample_scale)
    in
    let pos = { x = locus.x +. delta_x; y = locus.y +. delta_y } in
    if Geometry.within_rect legal_rect pos then pos else loop ()
  in
  loop ()

let is_valid_placement (_ : problem) (placed : position list) (potential : position) : bool =
  placed |> List.for_all ~f:(fun x -> Float.(Geometry.distance x potential >= 10.0))

let random_placements (p : problem) (placer : unit -> position) (count : int)
    (already_placed : position list) : position list =
  Random.self_init ();
  let rec random (already_placed : position list) (placement : position list) (count : int)
      (fuel : int) =
    if count = 0 then placement
    else
      let potential = placer () in
      if is_valid_placement p already_placed potential then
        random (potential :: already_placed) (potential :: placement) (count - 1) fuel
      else if fuel = 0 then failwith "ran out of fuel"
      else random already_placed placement count (fuel - 1)
  in
  random already_placed [] count 10_000

let honey_comb_positions (init_pos : position) =
  let rec snake (position : position) (ring_number : int) (ring_count : int) (direction : int) :
      position Seq.t =
    let next_pos direction =
      let x = position.x in
      let y = position.y in
      match direction with
      | 0 -> { x = x +. 10.0; y = y +. 0.0 }
      | 1 -> { x = x +. 5.0; y = y +. 8.66 }
      | 2 -> { x = x -. 5.0; y = y +. 8.66 }
      | 3 -> { x = x -. 10.0; y = y +. 0.0 }
      | 4 -> { x = x -. 5.0; y = y -. 8.66 }
      | 5 -> { x = x +. 5.0; y = y -. 8.66 }
      | _ -> failwith "direction must be between 0 and 5"
    in
    if ring_count >= (ring_number * 6) - 1 then
      Seq.cons position (snake (next_pos direction) (ring_number + 1) 0 ((direction + 1) mod 6))
    else if ring_count % ring_number = ring_number - 1 then
      Seq.cons position
        (snake (next_pos (direction + 1)) ring_number (ring_count + 1) ((direction + 1) mod 6))
    else Seq.cons position (snake (next_pos direction) ring_number (ring_count + 1) direction)
  in
  snake init_pos 0 0 0

let random_solution_from_instrument_locii (p : problem) (instruments : position array) : solution =
  let musicians =
    p.musicians
    |> Array.of_list
    |> Array.mapi ~f:(fun id instrument -> { id; instrument; pos = { x = 0.; y = 0. } })
  in
  Misc.musician_group_by_instrument p
  |> Array.foldi ~init:[] ~f:(fun inst already_placed group ->
         let locus = instruments.(inst) in
         match group with
         | [] -> already_placed
         | hd :: tl ->
             (* TODO: MAY BE ILLEGAL *)
             let to_place, already_placed =
               if is_valid_placement p already_placed locus then (
                 musicians.(hd) <- { (musicians.(hd)) with pos = locus };
                 (tl, musicians.(hd).pos :: already_placed))
               else (hd :: tl, already_placed)
             in
             let placements =
               random_placements
                 (p : problem)
                 (fun () -> random_placement_around_locus p locus)
                 (List.length to_place) already_placed
             in
             List.iter2_exn placements to_place ~f:(fun pos musician ->
                 musicians.(musician) <- { (musicians.(musician)) with pos });
             placements @ already_placed)
  |> ignore;
  musicians

let random_placement_solution (p : problem) (already_placed : position list) : solution =
  let count = List.length p.musicians - List.length already_placed in
  random_placements p (fun () -> random_placement p) count already_placed
  |> Misc.solution_of_positions p
