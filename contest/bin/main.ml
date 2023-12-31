open Core
open Contest

let random_solution (p : Types.problem) (already_placed : Types.position list) =
  Random_solver.random_placement_solution p already_placed

type initialization = Random | Newton | Edge of Edge_placer.edges | LoadBest [@@deriving sexp]
type optimizer = LP | Swap | Newton | Packaway | Drop [@@deriving sexp]

type invocation = {
  problem_id : int;
  initialization : initialization;
  optimizers : optimizer list;
  scale_height : float;
  scale_width : float;
  save_file : string option;
}
[@@deriving sexp]

let run_invocation inv =
  match Json_util.get_problem inv.problem_id with
  | None -> failwith "Failed to parse problem"
  | Some problem ->
      let validate_and_save ?(label : string = "") solution =
        (match inv.save_file with
        | None -> ()
        | Some file -> Json_util.write_solution_to_file problem solution file);
        printf "Validating %s solution...\n%!" label;
        Misc.validate_solution problem solution;
        let score = Score.score_solution problem solution in
        printf "Problem %d: %s solution has score: %s\n%!" inv.problem_id label
          (Misc.string_of_score score);
        Json_util.write_solution_if_best score problem solution
      in
      Printf.printf "\nSolving problem %d\n%!" inv.problem_id;
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
      printf "Initial solution score: %s\n%!" (Misc.string_of_score score);
      let _ =
        inv.optimizers
        |> List.fold ~init:solution ~f:(fun solution opt_flag ->
               let optimizer =
                 match opt_flag with
                 | Swap -> Improver.swapper problem ~round:0
                 | LP -> Lp_solver.lp_optimize_solution problem ~round:0
                 | Newton -> Physics.newton_optimizer problem ~max_iterations:1000
                 | Packaway -> Packaway.pack_bad_musicians problem ~cutoff:0.
                 | Drop -> Random_solver.random_dropper problem ~relative_max_score_threshold:0.1
               in
               let solution = optimizer solution in
               validate_and_save ~label:"optimized" solution;
               solution)
      in
      print_endline "All done"

let parse_scale scale_width : float = Option.value scale_width ~default:1.0

let parse_optimizer string : optimizer =
  match string with
  | "lp" -> LP
  | "swap" -> Swap
  | "newton" -> Newton
  | "packaway" -> Packaway
  | "drop" -> Drop
  | _ -> failwith "Invalid optimizer"

let command =
  Command.basic ~summary:"Run our solver on a problem"
    (let%map_open.Command save =
       flag "-s" (optional string)
         ~doc:
           "Save the solution to a file (in addition to saving globally better solutions in our \
            database)"
     and loadBest = flag "--loadBest" no_arg ~doc:"Load the previous best solution"
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
         match (loadBest, newton, Edge_placer.parse_edges_flag edges) with
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
           save_file = save;
         })

let () = Command_unix.run command
