open Core
open Contest

let random_solution (p : Types.problem) (already_placed : Types.position list) =
  Random_solver.random_placement_solution p already_placed

type assignment = LP | Swap | Random | Newton [@@deriving sexp]

type invocation = {
  problem_id : int;
  assignment : assignment;
  edges : Edge_placer.edges;
  scale_height : float;
  scale_width : float;
}
[@@deriving sexp]

let run_newton (problem : Types.problem) =
  let placements = Physics.init_placements problem in
  let rec stage1 iteration last_instability =
    if iteration > 100 && (Float.(last_instability < 0.00001) || iteration > 200) then iteration
    else
      let att_heat = Physics.att_heat_from_iteration_stage1 problem iteration in
      (* Printf.printf "Iteration %d, heat %f\n%!" iteration att_heat; *)
      let last_instability = Physics.simulate_step_stage1 problem ~att_heat placements in
      stage1 (iteration + 1) last_instability
  in
  let iterations = stage1 0 Float.max_value in
  Printf.printf "Problem %d converged in %d iterations." problem.problem_id iterations;
  Printf.printf " Score: %s \n%!"
    (Physics.placement_score_raw problem placements |> Misc.string_of_score);
  Printf.printf " Going to Stage 2 %!";
  let solution = Physics.instrument_placement_to_stage2 problem placements in
  Printf.printf " - DONE%!";
  Misc.validate_solution problem solution;
  ()

let run_invocation inv =
  match Json_util.get_problem inv.problem_id with
  | None -> failwith "Failed to parse problem"
  | Some problem ->
      if Stdlib.(inv.assignment = Newton) then run_newton problem
      else (
        printf "Scaling stage with factors %f %f\n%!" inv.scale_width inv.scale_height;
        let problem =
          {
            problem with
            stage_height = problem.stage_height *. inv.scale_height;
            stage_width = problem.stage_width *. inv.scale_width;
          }
        in
        print_endline (List.length problem.musicians |> string_of_int);
        let edge = Edge_placer.place_edges problem inv.edges in
        let solution = random_solution problem edge in
        Misc.validate_solution problem solution;
        print_endline "Scoring solution...";
        let score = Score.score_solution problem solution in
        printf "Random solution score: %s\n" (Misc.string_of_score score);
        let optimized_solution =
          match inv.assignment with
          | Random -> solution
          | Swap -> Improver.improve problem solution ~round:0
          | LP -> Lp_solver.lp_optimize_solution problem solution ~round:0
          | Newton -> failwith "Should not happen"
        in
        Misc.validate_solution problem optimized_solution;
        let optimised_score = Score.score_solution problem optimized_solution in
        printf "Improved Problem %d with score: %s\n%!" inv.problem_id
          (Misc.string_of_score optimised_score);
        Json_util.write_solution_if_best optimised_score inv.problem_id optimized_solution;
        (* write solution_json to file *)
        print_endline "Done")

let parse_edges_flag edges : Edge_placer.edges =
  match edges with
  | None -> []
  | Some "" -> []
  | Some e ->
      String.split_on_chars e ~on:[ ',' ]
      |> List.map ~f:(fun edge_str ->
             match edge_str with
             | "north" -> Edge_placer.North
             | "south" -> Edge_placer.South
             | "east" -> Edge_placer.East
             | "west" -> Edge_placer.West
             | _ -> failwith "Invalid edge placement")

let parse_scale scale_width : float = Option.value scale_width ~default:1.0

let command =
  Command.basic ~summary:"Run our solver on a problem"
    (let%map_open.Command lp = flag "--lp" no_arg ~doc:"Use the LP solver after placement"
     and swapper = flag "--swap" no_arg ~doc:"Use swap optimization after placement"
     and newton = flag "--newton" no_arg ~doc:"Use Newton placement"
     and edges = flag "--edges" (optional string) ~doc:"Edge placement"
     and scale_width = flag "--scale-width" (optional float) ~doc:"Scale the width of the problem"
     and scale_height =
       flag "--scale-height" (optional float) ~doc:"Scale the height of the problem"
     and problem_id = anon ("problem_id" %: string) in
     fun () ->
       let problem_id = Int.of_string problem_id in
       let assignment =
         let set_assignment = List.count [ lp; swapper; newton ] ~f:Fn.id in
         assert (set_assignment <= 1);
         if newton then Newton else if lp then LP else if swapper then Swap else Random
       in
       if Stdlib.(assignment <> Random) then
         (* print_endline ("Optimizing with " ^ (sexp_of_assignment assignment |> Sexp.to_string_hum)); *)
         run_invocation
           {
             problem_id;
             assignment;
             edges = parse_edges_flag edges;
             scale_height = parse_scale scale_height;
             scale_width = parse_scale scale_width;
           })

let () = Command_unix.run command
