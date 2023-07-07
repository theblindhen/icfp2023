(* Auto-generated from "json.atd" *)
[@@@ocaml.warning "-27-32-33-35-39"]

type json_score = {
  score_failure (*atd failure *): string option;
  score_success (*atd success *): float option
}

type json_submission_get_success_submission = {
  submission_get__id (*atd _id *): string;
  submission_get_problem_id (*atd problem_id *): float;
  submission_get_user_id (*atd user_id *): string;
  submission_get_score (*atd score *): json_score;
  submission_get_submitted_at (*atd submitted_at *): string
}

type json_submission_get_success = {
  submission_get_submission (*atd submission *):
    json_submission_get_success_submission;
  submission_get_contents (*atd contents *): string
}

type json_submission_get = {
  submission_getsuccess (*atd success *): json_submission_get_success option;
  submission_getfailure (*atd failure *): string option
}

type json_placement = {
  placement_x (*atd x *): float;
  placement_y (*atd y *): float
}

type json_solution = {
  solution_placement (*atd placement *): json_placement list
}

type json_attendee = {
  attendee_x (*atd x *): float;
  attendee_y (*atd y *): float;
  attendee_tastes (*atd tastes *): float list
}

type json_problem = {
  problem_room_width (*atd room_width *): float;
  problem_room_height (*atd room_height *): float;
  problem_stage_width (*atd stage_width *): float;
  problem_stage_height (*atd stage_height *): float;
  problem_stage_bottom_left (*atd stage_bottom_left *): (float * float);
  problem_musicians (*atd musicians *): int list;
  problem_attendees (*atd attendees *): json_attendee list
}
