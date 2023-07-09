open Core
open Contest

let random_solution (p : Types.problem) (already_placed : Types.position list) =
  Random_solver.random_placement_solution p already_placed

type initialization = Random | Newton | Edge of Edge_placer.edges | LoadBest [@@deriving sexp]
type optimizer = LP | Swap | Newton [@@deriving sexp]

type invocation = {
  problem_id : int;
  initialization : initialization;
  optimizers : optimizer list;
  scale_height : float;
  scale_width : float;
}
[@@deriving sexp]

let run_invocation inv =
  match Json_util.get_problem inv.problem_id with
  | None -> failwith "Failed to parse problem"
  | Some problem ->
      let problem =
        if Float.(inv.scale_height <> 1.0 || inv.scale_width <> 1.0) then (
          printf "Scaling stage with factors %f %f\n%!" inv.scale_width inv.scale_height;
          {
            problem with
            stage_height = problem.stage_height *. inv.scale_height;
            stage_width = problem.stage_width *. inv.scale_width;
          })
        else problem
      in
      let solution =
        match inv.initialization with
        | Random -> random_solution problem []
        | Newton -> Physics.newton_solver problem
        | Edge edges ->
            let edge = Edge_placer.place_edges problem edges in
            random_solution problem edge
        | LoadBest -> (
            match Json_util.get_best_solution problem with
            | None -> failwith "Failed to load best solution (no previous solution?)"
            | Some solution -> solution)
      in
      Misc.validate_solution problem solution;
      print_endline "Scoring solution...";
      let score = Score.score_solution problem solution in
      printf "Initial solution score: %s\n" (Misc.string_of_score score);
      let _ =
        inv.optimizers
        |> List.fold ~init:solution ~f:(fun solution opt_flag ->
               let optimizer =
                 match opt_flag with
                 | Swap -> Improver.swapper_without_q problem ~round:0
                 | LP -> Lp_solver.lp_optimize_solution problem ~round:0
                 | Newton -> Physics.newton_optimizer problem ~max_iterations:1000
               in
               let solution = optimizer solution in
               Misc.validate_solution problem solution;
               let optimised_score = Score.score_solution problem solution in
               printf "Optimized problem %d with score: %s\n%!" inv.problem_id
                 (Misc.string_of_score optimised_score);
               Json_util.write_solution_if_best optimised_score problem solution;
               solution)
      in
      print_endline "All done"

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

let parse_optimizer string : optimizer =
  match string with
  | "lp" -> LP
  | "swap" -> Swap
  | "newton" -> Newton
  | _ -> failwith "Invalid optimizer"

let command =
  Command.basic ~summary:"Run our solver on a problem"
    (let%map_open.Command loadBest = flag "--loadBest" no_arg ~doc:"Load the previous best solution"
     and opt =
       flag "-o" (listed (Arg_type.create parse_optimizer)) ~doc:"Optimizers, comma-separated"
     and newton = flag "--newton" no_arg ~doc:"Use Newton initial placement"
     and edges = flag "--edges" (optional string) ~doc:"Edge placement initialization"
     and scale_width = flag "--scale-width" (optional float) ~doc:"Scale the width of the problem"
     and scale_height =
       flag "--scale-height" (optional float) ~doc:"Scale the height of the problem"
     and problem_id = anon ("problem_id" %: string) in
     fun () ->
       let problem_id = Int.of_string problem_id in
       let initialization =
         match (loadBest, newton, parse_edges_flag edges) with
         | true, false, [] -> LoadBest
         | false, true, [] -> Newton
         | false, false, [] -> Random
         | false, false, edges -> Edge edges
         | _ ->
             failwith
               "Invalid initialization. You must specify at most one of --loadBest, --newton, or \
                --edges"
       in
       print_endline
         ("Initializing with " ^ (sexp_of_initialization initialization |> Sexp.to_string_hum));
       (match opt with
       | [] -> ()
       | _ ->
           print_endline
             ("Optimizing with "
             ^ String.concat ~sep:" -> "
                 (List.map opt ~f:(fun o -> sexp_of_optimizer o |> Sexp.to_string_hum))));
       run_invocation
         {
           problem_id;
           initialization;
           optimizers = opt;
           scale_height = parse_scale scale_height;
           scale_width = parse_scale scale_width;
         })

let () = Command_unix.run command
