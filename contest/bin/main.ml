open Core
open Contest

let random_solution (p : Types.problem) (already_placed : Types.position list) =
  Random_solver.random_placement_solution p already_placed

type initialization = Random | Newton | Edge of Edge_placer.edges [@@deriving sexp]
type optimizer = LP | Swap [@@deriving sexp]

type invocation = {
  problem_id : int;
  initialization : initialization;
  optimizer : optimizer option;
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
      in
      Misc.validate_solution problem solution;
      print_endline "Scoring solution...";
      let score = Score.score_solution problem solution in
      printf "Initial solution score: %s\n" (Misc.string_of_score score);
      let optimized_solution =
        match inv.optimizer with
        | None -> solution
        | Some Swap -> Improver.improve problem solution ~round:0
        | Some LP -> Lp_solver.lp_optimize_solution problem solution ~round:0
      in
      Misc.validate_solution problem optimized_solution;
      let optimised_score = Score.score_solution problem optimized_solution in
      printf "Optimized problem %d with score: %s\n%!" inv.problem_id
        (Misc.string_of_score optimised_score);
      Json_util.write_solution_if_best optimised_score inv.problem_id optimized_solution;
      (* write solution_json to file *)
      print_endline "Done"

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
     and newton = flag "--newton" no_arg ~doc:"Use Newton initial placement"
     and edges = flag "--edges" (optional string) ~doc:"Edge placement initialization"
     and scale_width = flag "--scale-width" (optional float) ~doc:"Scale the width of the problem"
     and scale_height =
       flag "--scale-height" (optional float) ~doc:"Scale the height of the problem"
     and problem_id = anon ("problem_id" %: string) in
     fun () ->
       let problem_id = Int.of_string problem_id in
       let initialization =
         let edges = parse_edges_flag edges in
         let set_initialization = List.count [ Stdlib.(edges <> []); newton ] ~f:Fn.id in
         assert (set_initialization <= 1);
         if newton then Newton else if Stdlib.(edges <> edges) then Random else Edge edges
       in
       let optimizer =
         let set_optimizer = List.count [ lp; swapper ] ~f:Fn.id in
         assert (set_optimizer <= 1);
         if lp then Some LP else if swapper then Some Swap else None
       in
       print_endline
         ("Initializing with " ^ (sexp_of_initialization initialization |> Sexp.to_string_hum));
       (match optimizer with
       | None -> ()
       | Some optimizer ->
           print_endline ("Optimizing with " ^ (sexp_of_optimizer optimizer |> Sexp.to_string_hum)));
       run_invocation
         {
           problem_id;
           initialization;
           optimizer;
           scale_height = parse_scale scale_height;
           scale_width = parse_scale scale_width;
         })

let () = Command_unix.run command
