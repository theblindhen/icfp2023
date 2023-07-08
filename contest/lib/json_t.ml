(* Auto-generated from "json.atd" *)
[@@@ocaml.warning "-27-32-33-35-39"]

type json_submission_post = { problem_id: int; contents: string }

type json_score = { failure: string option; success: float option }

type json_submission_get_success_submission = {
  _id: string;
  problem_id: float;
  user_id: string;
  score: json_score;
  submitted_at: string
}

type json_submission_get_success = {
  submission: json_submission_get_success_submission;
  contents: string
}

type json_submission_get = {
  success: json_submission_get_success option;
  failure: string option
}

type json_placement = { x: float; y: float }

type json_solution = { placements: json_placement list }

type json_pillar = { center: (float * float); radius: float }

type json_attendee = { x: float; y: float; tastes: float list }

type json_problem = {
  room_width: float;
  room_height: float;
  stage_width: float;
  stage_height: float;
  stage_bottom_left: (float * float);
  musicians: int list;
  attendees: json_attendee list;
  pillars: json_pillar list option
}
