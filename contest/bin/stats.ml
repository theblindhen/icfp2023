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
  best_score : float;
  theoretical_max_score : float;
  newton_max_score : float;
}

let problem_stats problem =
  let instrument_count = Misc.instrument_count problem in
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
    newton_max_score = Approximations.newton_score_problem problem;
    best_score = Json_util.best_solution_score problem.problem_id;
  }

let stats_to_string total_score (problem_stats : stats) =
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
  ^ "\n Our best score: "
  ^ Misc.string_of_score problem_stats.best_score
  ^ "\n  %% of total score: "
  ^ sprintf "%2.2f%%" (100. *. problem_stats.best_score /. total_score)
  ^ "\n  Theoretical max score: "
  ^ Misc.string_of_score problem_stats.theoretical_max_score
  ^ "\n  Newton-theoretical max score: "
  ^ Misc.string_of_score problem_stats.newton_max_score
  ^ "\n    %% our score / Newton max: "
  ^ sprintf "%2.2f%%" (100. *. problem_stats.best_score /. problem_stats.newton_max_score)
  ^ "\n"

let csv_headline =
  "problem_id,room_dim,stage_dim,musicians_count,instrument_count,attendees_count,pillar_count,radii_num,radii_min,radii_max,best_score,%% \
   of total score,theoretical_max_score,newton_max_score,%% our score / Newton max"

let stats_to_csv total_score (problem_stats : stats) =
  problem_stats.room_dim
  ^ "," (* room_dim *)
  ^ problem_stats.stage_dim
  ^ "," (* stage_dim *)
  ^ string_of_int problem_stats.musicians_count
  ^ "," (* musicians_count *)
  ^ string_of_int problem_stats.instrument_count
  ^ "," (* instrument_count *)
  ^ string_of_int problem_stats.attendees_count
  ^ "," (* attendees_count *)
  ^ string_of_int problem_stats.pillar_count
  ^ "," (* pillar_count *)
  ^ (if Option.is_none problem_stats.pillar_radii_stats then ",,"
     else
       let stats = Option.value_exn problem_stats.pillar_radii_stats in
       sprintf "%d radii, %2.2f, %2.2f" stats.uniq stats.min stats.max)
  ^ "," (* pillar_radii_stats *)
  ^ string_of_float problem_stats.best_score
  ^ "," (* best_score *)
  ^ sprintf "%2.2f" (100. *. problem_stats.best_score /. total_score)
  ^ "," (* %% of total score *)
  ^ string_of_float problem_stats.theoretical_max_score
  ^ "," (* theoretical_max_score *)
  ^ string_of_float problem_stats.newton_max_score
  ^ "," (* newton_max_score *)
  ^ sprintf "%2.2f" (100. *. problem_stats.best_score /. problem_stats.newton_max_score)
(* %% our score / Newton max *)

let () =
  (* read args*)
  let args = Sys.get_argv () in
  let total_score = ref 0. in
  for i = 1 to problem_count do
    total_score := !total_score +. Json_util.best_solution_score i
  done;
  if Stdlib.(args.(1) = "--csv") then (
    print_endline csv_headline;
    for i = 1 to problem_count do
      match Json_util.get_problem i with
      | None -> ()
      | Some problem ->
          print_endline
            (string_of_int i ^ "," ^ stats_to_csv !total_score (problem |> problem_stats))
    done)
  else (
    for i = 1 to problem_count do
      match Json_util.get_problem i with
      | None -> print_endline (sprintf "Problem %02d: not found" i)
      | Some problem ->
          let stats = problem |> problem_stats |> stats_to_string !total_score in
          print_endline (sprintf "Problem %02d:\n%s" i stats)
    done;
    Printf.printf "\n\nTotal score: %s\n" (Int.to_string_hum @@ int_of_float !total_score))
