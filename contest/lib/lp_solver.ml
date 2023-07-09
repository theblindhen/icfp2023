open Core

let num_instruments (problem : Types.problem) =
  1 + (List.max_elt problem.musicians ~compare:Int.compare |> Option.value_exn)

(* Create the variables we'll need, returning [position_idx][instrument] *)
let lp_vars (problem : Types.problem) (prev_solution : Types.solution) =
  let num_positions = Array.length prev_solution in
  let num_instruments = num_instruments problem in
  Array.init num_positions ~f:(fun m ->
      Array.init num_instruments ~f:(fun i -> Lp.var (Printf.sprintf "I_%d_%d" m i)))

let lp_of_problem (problem : Types.problem) (prev_solution : Types.solution)
    (fixed_musician_indexes : int list) (vars : Lp.Poly.t array array) =
  let open Lp in
  let num_instruments = num_instruments problem in
  let instrument_count =
    Array.init num_instruments ~f:(fun i -> List.count problem.musicians ~f:(fun m -> m = i))
  in
  let assignment_scores = Improver.score_cache (Score.get_scoring_env problem prev_solution) in
  let objective =
    maximize
      (Array.foldi vars ~init:(c 0.0) ~f:(fun pos_idx obj_i pvars ->
           Array.foldi pvars ~init:obj_i ~f:(fun instrument obj_i var ->
               let score =
                 Hashtbl.find_exn assignment_scores (prev_solution.(pos_idx).pos, instrument)
               in
               (c score *~ var) ++ obj_i)))
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
    |> Array.mapi ~f:(fun instrument count ->
           let instrument_vars = Array.map vars ~f:(fun pvars -> pvars.(instrument)) in
           let instrument_sum =
             Array.fold instrument_vars ~init:(c 0.0) ~f:(fun sum var -> sum ++ var)
           in
           instrument_sum <~ c (float_of_int count))
    |> List.of_array
  in
  let constraints_fixed_instruments =
    (* fixed musicians are assigned to the instrument from solution *)
    List.concat_map fixed_musician_indexes ~f:(fun fixed_musician_idx ->
        let instrument = prev_solution.(fixed_musician_idx).instrument in
        [
          vars.(fixed_musician_idx).(instrument) <~ c 1.0;
          c 1.0 <~ vars.(fixed_musician_idx).(instrument);
        ])
  in
  make objective
    (constraints_one_instrument @ constraints_total_instruments @ constraints_fixed_instruments)

let solution_of_lp_solution (problem : Types.problem) (prev_solution : Types.solution)
    (vars : Lp.Poly.t array array) (obj, xs) : Types.solution =
  Printf.printf "Objective: %.2f\n" obj;
  (* extract for each pos_idx the instrument it is assigned *)
  let assignments = Array.create ~len:(Array.length prev_solution) (-1) in
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
  let musician_for_posidx = Array.create ~len:(Array.length prev_solution) (-1) in
  Array.iteri assignments ~f:(fun pos_idx instrument ->
      let musician = List.hd_exn musician_pool.(instrument) in
      musician_for_posidx.(pos_idx) <- musician;
      musician_pool.(instrument) <- List.tl_exn musician_pool.(instrument));
  (* convert to solution *)
  prev_solution
  |> Array.mapi ~f:(fun idx p ->
         let musician = musician_for_posidx.(idx) in
         Types.{ id = musician; pos = p.pos; instrument = musician_instruments.(musician) })

let lp_assign_positions (problem : Types.problem) (prev_solution : Types.solution) =
  printf "Generating and validating LP problem.\n%!";
  let vars = lp_vars problem prev_solution in
  let lp_problem = lp_of_problem problem prev_solution [] vars in
  if Lp.validate lp_problem then (
    printf "LP problem is valid; starting solver.\n%!";
    match Lp_glpk.solve lp_problem with
    | Ok (obj, xs) -> solution_of_lp_solution problem prev_solution vars (obj, xs)
    | Error msg -> failwith (sprintf "Error in running LP solver: %s\n" msg))
  else failwith "Oops, LP problem is broken."

(** Completely disregards the placement in the given solution and reassigns all
  placements *)
let lp_optimize_solution (problem : Types.problem) (prev_solution : Types.solution) ~(round : int) =
  ignore round;
  lp_assign_positions problem prev_solution
