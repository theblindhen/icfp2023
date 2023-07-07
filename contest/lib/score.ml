open Types
open Misc

let score_I (a : attendee) (m : musician) : float =
  let d = distance a.pos m.pos in
  ceil (1_000_000.0 *. a.tastes.(m.instrument) /. (d *. d))

let score_attendee (s : solution) (a : attendee) : float =
  Array.fold_left (fun sum m -> sum +. score_I a m) 0.0 s

let score_musician (p : problem) (m : musician) : float =
  List.fold_left (fun sum attendee -> sum +. score_I attendee m) 0.0 p.attendees

let score_solution (p : problem) (s : solution) : float =
  List.fold_left (fun sum attendee -> sum +. score_attendee s attendee) 0.0 p.attendees
