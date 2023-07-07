(* Auto-generated from "json.atd" *)
[@@@ocaml.warning "-27-32-33-35-39"]

type solution_placement = {
  placement_x (*atd x *): float;
  placement_y (*atd y *): float
}

type solution = {
  solution_placement (*atd placement *): solution_placement list
}

type attendee = {
  attendee_x (*atd x *): float;
  attendee_y (*atd y *): float;
  attendee_tastes (*atd tastes *): float list
}

type problem = {
  problem_room_width (*atd room_width *): float;
  problem_room_height (*atd room_height *): float;
  problem_stage_width (*atd stage_width *): float;
  problem_stage_height (*atd stage_height *): float;
  problem_stage_bottom_left (*atd stage_bottom_left *): (float * float);
  problem_musicians (*atd musicians *): int list;
  problem_attendees (*atd attendees *): attendee list
}
