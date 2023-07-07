open Types
open Misc

let score_I (a : attendee) (m : musician) : float =
  let d = distance a.pos m.pos in
  ceil (1_000_000.0 *. a.tastes.(m.instrument) /. (d *. d))

let score_attendee (p : problem) (s : solution) (a : attendee) : float =
  List.fold_left (fun sum m -> sum +. score_I a m) 0.0 (musicians_of_solution p s)

let score_solution (p : problem) (s : solution) : float =
  List.fold_left (fun sum attendee -> sum +. score_attendee p s attendee) 0.0 p.attendees
