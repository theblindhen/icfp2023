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
             musicians.(hd) <- { (musicians.(hd)) with pos = locus };
             let already_placed = musicians.(hd).pos :: already_placed in
             let tl_placements =
               random_placements
                 (p : problem)
                 (fun () -> random_placement_around_locus p locus)
                 (List.length tl) already_placed
             in
             List.iter2_exn tl_placements tl ~f:(fun pos musician ->
                 musicians.(musician) <- { (musicians.(musician)) with pos });
             tl_placements @ already_placed)
  |> ignore;
  musicians

let random_placement_solution (p : problem) (already_placed : position list) : solution =
  let count = List.length p.musicians - List.length already_placed in
  random_placements p (fun () -> random_placement p) count already_placed
  |> Misc.solution_of_positions p
