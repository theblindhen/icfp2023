open Core

let num_instruments (problem : Types.problem) =
  1 + (List.max_elt problem.musicians ~compare:Int.compare |> Option.value_exn)

(* Create the variables we'll need, returning [musician_idx][instrument] *)
let lp_vars (problem : Types.problem) (positions : Types.position list) =
  let num_positions = List.length positions in
  let num_instruments = num_instruments problem in
  Array.init num_positions ~f:(fun m ->
      Array.init num_instruments ~f:(fun i -> Lp.var (Printf.sprintf "I_%d_%d" m i)))

let lp_of_problem (problem : Types.problem) (positions : Types.position list)
    (vars : Lp.Poly.t array array) =
  let open Lp in
  let positions_arr = Array.of_list positions in
  let num_instruments = num_instruments problem in
  let instrument_count =
    Array.init num_instruments ~f:(fun i -> List.count problem.musicians ~f:(fun m -> m = i))
  in
  let assignment_scores =
    let fake_solution = Misc.solution_of_positions problem positions in
    Improver.score_cache (Score.get_scoring_env problem fake_solution)
  in
  let objective =
    maximize
      (Array.foldi vars ~init:(c 0.0) ~f:(fun pos_idx obj_i pvars ->
           Array.foldi pvars ~init:obj_i ~f:(fun instrument obj_i var ->
               let score =
                 Hashtbl.find_exn assignment_scores (positions_arr.(pos_idx), instrument)
               in
               obj_i ++ (c score *~ var))))
  in
  let constraints_one_instrument =
    (* each position plays one instrument *)
    vars
    |> List.of_array
    |> List.map ~f:(fun pvars ->
           let sum = Array.fold pvars ~init:(c 0.0) ~f:(fun sum var -> sum ++ var) in
           [ sum <~ c 1.0; sum >~ c 1.0 ])
    |> List.concat
  in
  let constraints_total_instruments =
    (* the number of each instrument is bounded *)
    instrument_count
    |> Array.mapi ~f:(fun i count ->
           let pvars = Array.map vars ~f:(fun pvars -> pvars.(i)) in
           Array.fold pvars ~init:(c 0.0) ~f:(fun sum var -> sum ++ var) <~ c (float_of_int count))
    |> List.of_array
  in
  make objective (constraints_one_instrument @ constraints_total_instruments)

let solution_of_lp_solution (problem : Types.problem) (positions : Types.position list)
    (vars : Lp.Poly.t array array) (obj, xs) : Types.solution =
  Printf.printf "Objective: %.2f\n" obj;
  (* extract for each pos_idx the instrument it is assigned *)
  let assignments = Array.create ~len:(List.length positions) (-1) in
  Array.iteri vars ~f:(fun p pvars ->
      Array.iteri pvars ~f:(fun i var ->
          let value = Lp.PMap.find var xs in
          if Float.( > ) value 0.0 then
            if assignments.(p) = -1 then assignments.(p) <- i
            else failwith "Multiple instruments assigned to one position");
      if assignments.(p) = -1 then failwith ("No instrument assigned to position" ^ Int.to_string p));
  (* initialize a lookup of musicians yet to be assigned *)
  let musician_pool = Array.create ~len:(num_instruments problem) [] in
  List.iteri problem.musicians ~f:(fun m inst -> musician_pool.(inst) <- m :: musician_pool.(inst));
  (* assign instruments to positions *)
  let musician_instruments = Array.of_list problem.musicians in
  let musician_for_posidx = Array.create ~len:(List.length positions) (-1) in
  Array.iteri assignments ~f:(fun pos_idx instrument ->
      let musician = List.hd_exn musician_pool.(instrument) in
      musician_for_posidx.(pos_idx) <- musician;
      musician_pool.(instrument) <- List.tl_exn musician_pool.(instrument));
  (* convert to solution *)
  positions
  |> List.mapi ~f:(fun idx p ->
         let musician = musician_for_posidx.(idx) in
         Types.{ id = musician; pos = p; instrument = musician_instruments.(musician) })
  |> Array.of_list

let lp_assign_positions (problem : Types.problem) (positions : Types.position list) =
  let vars = lp_vars problem positions in
  let lp_problem = lp_of_problem problem positions vars in
  if Lp.validate lp_problem then
    match Lp_glpk.solve lp_problem with
    | Ok (obj, xs) -> solution_of_lp_solution problem positions vars (obj, xs)
    | Error msg -> failwith (sprintf "Error in running LP solver: %s\n" msg)
  else failwith "Oops, LP problem is broken."

(** Completely disregards the placement in the given solution and reassigns all
  placements *)
let lp_optimize_solution (problem : Types.problem) (solution : Types.solution) =
  lp_assign_positions problem (solution |> List.of_array |> List.map ~f:(fun { pos; _ } -> pos))
