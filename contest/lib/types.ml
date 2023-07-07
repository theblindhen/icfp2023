open Core

type position = { x : float; y : float } [@@deriving compare]
type attendee = { pos : position; tastes : float array } [@@deriving compare]

type problem = {
  room_width : float;
  room_height : float;
  stage_width : float;
  stage_height : float;
  stage_bottom_left : position;
  musicians : int list;
  attendees : attendee list;
}

let position_from_json_tuple (x, y) = { x; y }

let problem_of_json_problem (json_problem : Json_j.json_problem) =
  {
    room_width = json_problem.room_width;
    room_height = json_problem.room_height;
    stage_width = json_problem.stage_width;
    stage_height = json_problem.stage_height;
    stage_bottom_left = position_from_json_tuple json_problem.stage_bottom_left;
    musicians = json_problem.musicians;
    attendees =
      json_problem.attendees
      |> List.map ~f:(fun (json_attendee : Json_j.json_attendee) ->
             {
               pos = { x = json_attendee.x; y = json_attendee.y };
               tastes = Array.of_list json_attendee.tastes;
             });
  }

type musician = { id : int; pos : position; instrument : int }
type solution = musician array

let json_solution_of_solution (solution : solution) : Json_j.json_solution =
  {
    placements =
      solution
      |> Array.to_list
      |> List.sort ~compare:(fun m1 m2 -> Poly.compare m1.id m2.id)
      |> List.map ~f:(fun { pos = { x; y }; id = _; instrument = _ } : Json_j.json_placement ->
             { x; y });
  }
