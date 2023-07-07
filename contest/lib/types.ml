type position = { x : float; y : float }
type attendee = { pos : position; tastes : float list }

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
      |> List.map (fun (json_attendee : Json_j.json_attendee) ->
             { pos = { x = json_attendee.x; y = json_attendee.y }; tastes = json_attendee.tastes });
  }

type solution = position list
