open Core

let get_bad_musicians (problem : Types.problem) (solution : Types.solution) ~(cutoff : float) :
    Types.musician list =
  let env = Score.get_scoring_env problem solution in
  solution
  |> Array.to_list
  |> List.filter ~f:(fun m -> Float.(Score.score_musician ~negative:true env m < cutoff))

(* Adapted from Physics.honeycomb_solution_from_instrument_locii *)
let honeycomb_pack_bad_musicians_here (p : Types.problem) (solution : Types.solution)
    (already_placed : Types.position list) (bad_musicians : Int.Set.t) (locus : Types.position) :
    unit =
  let comb = Geometry.honey_comb_positions locus in
  solution
  |> Array.fold ~init:already_placed ~f:(fun already_placed musician ->
         let rec iter (comb : Types.position Seq.t) already_placed =
           match Seq.uncons comb with
           | None -> already_placed
           | Some (hd, tl) ->
               if Random_solver.is_valid_placement p already_placed hd then (
                 solution.(musician.id) <- { musician with pos = hd };
                 hd :: already_placed)
               else iter tl already_placed
         in
         if Set.mem bad_musicians musician.id then iter comb already_placed else already_placed)
  |> ignore

let pack_bad_musicians (problem : Types.problem) (solution : Types.solution) ~(cutoff : float) :
    Types.solution =
  let bad_musicians =
    get_bad_musicians problem solution ~cutoff |> List.map ~f:(fun m -> m.id) |> Int.Set.of_list
  in
  Printf.printf "=== Packing %d bad musicians ===\n" (Set.length bad_musicians);
  if Set.length bad_musicians = 0 then solution
  else
    let already_placed =
      Array.to_list solution
      |> List.filter ~f:(fun m -> not (Set.mem bad_musicians m.id))
      |> List.map ~f:(fun m -> m.pos)
    in
    let try_point_count = 5 in
    let try_points =
      Random_solver.random_placements problem
        (fun () -> Random_solver.random_placement problem)
        try_point_count already_placed
    in
    let packed_solutions =
      List.map try_points ~f:(fun pos ->
          let solution = Array.copy solution in
          honeycomb_pack_bad_musicians_here problem solution already_placed bad_musicians pos;
          solution)
    in
    let scores =
      List.map packed_solutions ~f:(fun solution -> Score.score_solution problem solution)
    in
    List.zip_exn packed_solutions scores
    |> List.max_elt ~compare:(fun (_, a) (_, b) -> Float.compare a b)
    |> Option.value_exn
    |> fst
