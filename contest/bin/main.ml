open Core
open Contest

let random_solution (p : Types.problem) (already_placed : Types.position list) =
  Random_solver.random_placement_solution p already_placed

type assignment = LP | Swap | Random [@@deriving sexp]

type invocation = { problem_id : int; assignment : assignment; edges : Edge_placer.edges }
[@@deriving sexp]

let run_invocation inv =
  match Json_util.get_problem inv.problem_id with
  | None -> failwith "Failed to parse problem"
  | Some problem ->
      print_endline (List.length problem.musicians |> string_of_int);
      let edge = Edge_placer.place_edges problem inv.edges in
      let solution = random_solution problem edge in
      Misc.validate_solution problem solution;
      print_endline "Scoring solution...";
      let score = Score.score_solution problem solution in
      printf "Random solution score: %f\n%!" score;
      let optimized_solution =
        match inv.assignment with
        | Random -> solution
        | Swap -> Improver.improve problem solution
        | LP -> Lp_solver.lp_optimize_solution problem solution
      in
      Misc.validate_solution problem optimized_solution;
      let optimised_score = Score.score_solution problem optimized_solution in
      printf "Improved Problem %d with score: %f\n%!" inv.problem_id optimised_score;
      Json_util.write_solution_if_best optimised_score inv.problem_id optimized_solution;
      (* write solution_json to file *)
      print_endline "Done"

let parse_edges_flag edges : Edge_placer.edges =
  match edges with
  | None -> []
  | Some e ->
      String.split_on_chars e ~on:[ ',' ]
      |> List.map ~f:(fun edge_str ->
             match edge_str with
             | "north" -> Edge_placer.North
             | "south" -> Edge_placer.South
             | "east" -> Edge_placer.East
             | "west" -> Edge_placer.West
             | _ -> failwith "Invalid edge placement")

let command =
  Command.basic ~summary:"Run our solver on a problem"
    (let%map_open.Command lp = flag "--lp" no_arg ~doc:"Use the LP solver after placement"
     and swapper = flag "--swap" no_arg ~doc:"Use swap optimization after placement"
     and edges = flag "--edges" (optional string) ~doc:"Edge placement"
     and problem_id = anon ("problem_id" %: string) in
     fun () ->
       let problem_id = Int.of_string problem_id in
       let assignment =
         if lp && swapper then failwith "Can't use both LP and swap"
         else if lp then (
           print_endline "Optimizing with LP";
           LP)
         else if swapper then (
           print_endline "Optimizing with swap";
           Swap)
         else Random
       in
       run_invocation { problem_id; assignment; edges = parse_edges_flag edges })

let () = Command_unix.run command
