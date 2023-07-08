open Core
open Contest
open Contest.Types

let problem_count = 90

type pillar_radii_stats = { min : float; max : float; uniq : int }

type stats = {
  room_dim : string;
  stage_dim : string;
  musicians_count : int;
  attendees_count : int;
  instrument_count : int; (* instrument_count_per_instrument : int array; *)
  pillar_count : int;
  pillar_radii_stats : pillar_radii_stats option;
  theoretical_max_score : float;
}

let problem_stats problem =
  let instrument_count =
    match List.max_elt problem.musicians ~compare:Int.compare with
    | None -> 0
    | Some x -> x + 1
  in
  {
    room_dim =
      sprintf "%d x %d" (int_of_float problem.room_width) (int_of_float problem.room_height);
    stage_dim =
      sprintf "%d x %d" (int_of_float problem.stage_width) (int_of_float problem.stage_height);
    musicians_count = List.length problem.musicians;
    attendees_count = List.length problem.attendees;
    instrument_count;
    (* instrument_count_per_instrument =
       List.fold problem.musicians ~init:(Array.create ~len:instrument_count 0) ~f:(fun acc i ->
           acc.(i) <- acc.(i) + 1;
           acc); *)
    pillar_count = List.length problem.pillars;
    pillar_radii_stats =
      (if List.is_empty problem.pillars then None
       else
         let radii = problem.pillars |> List.map ~f:(fun p -> p.radius) in
         let min = List.min_elt radii ~compare:Float.compare |> Option.value_exn in
         let max = List.max_elt radii ~compare:Float.compare |> Option.value_exn in
         let uniq = radii |> Set.of_list (module Float) |> Set.length in
         Some { min; max; uniq });
    theoretical_max_score = Approximations.max_score_problem problem;
  }

let solution_stats (problem_id : int) total_score =
  let best_score = int_of_float @@ Json_util.best_solution_score problem_id in
  Printf.printf "Best score: %s\n  %% of our score: %2.2f\n\n" (Int.to_string_hum best_score)
    (100. *. float_of_int best_score /. total_score)

let stats_to_string (problem_stats : stats) =
  "room: "
  ^ problem_stats.room_dim
  ^ "\n stage: "
  ^ problem_stats.stage_dim
  ^ "\n musicians: "
  ^ string_of_int problem_stats.musicians_count
  ^ "\n instruments total: "
  ^ string_of_int problem_stats.instrument_count
  (* ^ "\n"
     ^ String.concat
         (List.map (List.init problem_stats.instrument_count ~f:Fn.id) ~f:(fun i ->
              sprintf "  instrument %d: %d\n" i problem_stats.instrument_count_per_instrument.(i))) *)
  ^ "\n attendees: "
  ^ string_of_int problem_stats.attendees_count
  ^ "\n pillars: "
  ^ string_of_int problem_stats.pillar_count
  ^ (if Option.is_none problem_stats.pillar_radii_stats then ""
     else
       let stats = Option.value_exn problem_stats.pillar_radii_stats in
       sprintf "\n    %d radii between %2.2f and %2.2f" stats.uniq stats.min stats.max)
  ^ "\n theoretical max score: "
  ^ Int.to_string_hum (int_of_float problem_stats.theoretical_max_score)

let () =
  let total_score = ref 0. in
  for i = 1 to problem_count do
    total_score := !total_score +. Json_util.best_solution_score i
  done;
  for i = 1 to problem_count do
    match Json_util.get_problem i with
    | None -> print_endline (sprintf "Problem %02d: not found" i)
    | Some problem ->
        let stats = problem |> problem_stats |> stats_to_string in
        print_endline (sprintf "Problem %02d:\n%s" i stats);
        solution_stats i !total_score
  done;
  Printf.printf "\n\nTotal score: %s\n" (Int.to_string_hum @@ int_of_float !total_score)
