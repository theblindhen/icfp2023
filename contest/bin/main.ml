open Core
open Contest

let random_solution (p : Types.problem) = Random_solver.random_placement_solution p

type assignment = LP | Swap | Random [@@deriving sexp]
type invocation = { problem_id : int; assignment : assignment } [@@deriving sexp]

let run_invocation inv =
  match Json_util.get_problem inv.problem_id with
  | None -> failwith "Failed to parse problem"
  | Some problem ->
      print_endline (List.length problem.musicians |> string_of_int);
      let solution = random_solution problem in
      print_endline "Scoring solution...";
      let score = Score.score_solution problem solution in
      printf "Random solution score: %f\n%!" score;
      let optimized_solution =
        match inv.assignment with
        | Random -> solution
        | Swap -> Improver.improve problem solution
        | LP -> Lp_solver.lp_optimize_solution problem solution
      in
      let optimised_score = Score.score_solution problem optimized_solution in
      printf "Improved score: %f\n%!" optimised_score;
      Json_util.write_solution_if_best inv.problem_id problem optimized_solution;
      (* write solution_json to file *)
      print_endline "Done"

let command =
  Command.basic ~summary:"Run our solver on a problem"
    (let%map_open.Command lp = flag "--lp" no_arg ~doc:"Use the LP solver after placement"
     and swapper = flag "--swap" no_arg ~doc:"Use swap optimization after placement"
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
       run_invocation { problem_id; assignment })

let () = Command_unix.run command
