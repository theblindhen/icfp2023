open Core
open Contest
open Contest.Types

let problem_count = 45

type stats = { room_dim : string; stage_dim : string; musicians_count : int; attendees_count : int }

let problem_stats problem =
  {
    room_dim =
      sprintf "%d x %d" (int_of_float problem.room_width) (int_of_float problem.room_height);
    stage_dim =
      sprintf "%d x %d" (int_of_float problem.stage_width) (int_of_float problem.stage_height);
    musicians_count = List.length problem.musicians;
    attendees_count = List.length problem.attendees;
  }

let stats_to_string (problem_stats : stats) =
  "room: "
  ^ problem_stats.room_dim
  ^ "\n"
  ^ "stage: "
  ^ problem_stats.stage_dim
  ^ "\n"
  ^ "musicians: "
  ^ string_of_int problem_stats.musicians_count
  ^ "\n"
  ^ "attendees: "
  ^ string_of_int problem_stats.attendees_count

let () =
  for i = 1 to problem_count do
    match Json_util.get_problem i with
    | None -> print_endline (sprintf "Problem %02d: not found" i)
    | Some problem ->
        let stats = problem |> problem_stats |> stats_to_string in
        print_endline (sprintf "Problem %02d:\n%s\n" i stats)
  done
