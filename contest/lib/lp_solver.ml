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
    (musician_is_fixed : bool array) (vars : Lp.Poly.t array array)
    (assignment_scores : (Types.position * int, float) Hashtbl.t) =
  let open Lp in
  let num_instruments = num_instruments problem in
  let instrument_count =
    Array.init num_instruments ~f:(fun i ->
        Array.counti prev_solution ~f:(fun musician_idx musician ->
            musician.instrument = i && not musician_is_fixed.(musician_idx)))
  in
  let objective =
    maximize
      (Array.foldi vars ~init:(c 0.0) ~f:(fun pos_idx obj_i pvars ->
           if musician_is_fixed.(pos_idx) then obj_i
           else
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
    |> List.mapi ~f:(fun pos_idx pvars ->
           if musician_is_fixed.(pos_idx) then []
           else
             let sum = Array.fold pvars ~init:(c 0.0) ~f:(fun sum var -> var ++ sum) in
             [ sum <~ c 1.0; sum >~ c 1.0 ])
    |> List.concat
  in
  let constraints_total_instruments =
    (* the number of each instrument is bounded *)
    instrument_count
    |> Array.concat_mapi ~f:(fun instrument count ->
           let instrument_vars =
             Array.filter_mapi vars ~f:(fun pos_idx pvars ->
                 if musician_is_fixed.(pos_idx) then None else Some pvars.(instrument))
           in
           if Array.is_empty instrument_vars then [||]
           else
             let instrument_sum =
               Array.fold instrument_vars ~init:(c 0.0) ~f:(fun sum var -> var ++ sum)
             in
             [| instrument_sum <~ c (float_of_int count) |])
    |> List.of_array
  in
  make objective (constraints_one_instrument @ constraints_total_instruments)

let solution_of_lp_solution (problem : Types.problem) (prev_solution : Types.solution)
    (vars : Lp.Poly.t array array) (musician_is_fixed : bool array) (obj, xs) : Types.solution =
  Printf.printf "Objective: %.2f\n" obj;
  (* extract for each pos_idx the instrument it is assigned *)
  let assignments = Array.create ~len:(Array.length prev_solution) (-1) in
  Array.iteri vars ~f:(fun p pvars ->
      if musician_is_fixed.(p) then assignments.(p) <- prev_solution.(p).instrument
      else
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

let lp_assign_positions (problem : Types.problem) (prev_solution : Types.solution)
    (assignment_scores : (Types.position * int, float) Hashtbl.t) (musician_is_fixed : bool array) =
  printf "Generating and validating LP problem.\n%!";
  let vars = lp_vars problem prev_solution in
  let lp_problem = lp_of_problem problem prev_solution musician_is_fixed vars assignment_scores in
  if Lp.validate lp_problem then (
    printf "LP problem is valid; starting solver.\n%!";
    match Lp_glpk.Simplex.solve ~term_output:true lp_problem with
    | Ok (obj, xs) -> solution_of_lp_solution problem prev_solution vars musician_is_fixed (obj, xs)
    | Error msg -> failwith (sprintf "Error in running LP solver: %s\n" msg))
  else failwith "Oops, LP problem is broken."

(** Completely disregards the placement in the given solution and reassigns all
  placements *)
let lp_optimize_solution (problem : Types.problem) (prev_solution : Types.solution) ~(round : int) =
  ignore round;
  let assignment_scores = Improver.score_cache (Score.get_scoring_env problem prev_solution) in
  let no_positions = Array.length prev_solution in
  let no_vars = no_positions * num_instruments problem in
  if no_vars > 10_000 then (
    let subset_factor = float_of_int no_vars /. 10_000.0 in
    let num_fixed_positions =
      int_of_float ((1.0 -. (1.0 /. subset_factor)) *. float_of_int no_positions)
    in
    let current_solution = ref prev_solution in
    let random_position_indexes = Array.init no_positions ~f:(fun i -> i) in
    let iterations = Float.(to_int (round_up (subset_factor * 2.0))) in
    for i = 1 to iterations do
      printf "%d/%d: Optimizing subset of %d positions\n%!" i iterations num_fixed_positions;
      Array.permute random_position_indexes;
      let fixed_musician_indexes =
        Array.sub random_position_indexes ~pos:0 ~len:num_fixed_positions
      in
      let musician_is_fixed = Array.create ~len:(List.length problem.musicians) false in
      Array.iter fixed_musician_indexes ~f:(fun idx -> musician_is_fixed.(idx) <- true);
      current_solution :=
        lp_assign_positions problem !current_solution assignment_scores musician_is_fixed
    done;
    !current_solution)
  else
    let musician_is_fixed = Array.create ~len:(List.length problem.musicians) false in
    lp_assign_positions problem prev_solution assignment_scores musician_is_fixed
