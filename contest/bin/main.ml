open Core
open Contest.Json_j

let get_problem problem_id =
  let json = In_channel.read_all ("../problems/problem-" ^ problem_id ^ ".json")
in
json_problem_of_string json

let dump_solution () =
  let solution: json_solution = {
    solution_placement = [
      {
        placement_x = 1.;
        placement_y = 2.5;
      }
    ]
  }
  in
  print_endline (string_of_json_solution solution)

let () =
let problem = get_problem "1"
in
print_endline (string_of_json_problem problem);
dump_solution ()
