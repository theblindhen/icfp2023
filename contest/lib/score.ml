open Core
open Types
open Misc

let is_blocked (s : solution) (a : attendee) (m : musician) : bool =
  let within_distance = Geometry.within_distance 5.0 (a.pos, m.pos) in
  Array.exists ~f:(fun candidate -> m.id <> candidate.id && within_distance candidate.pos) s

let score_I (s : solution) (a : attendee) (m : musician) : float =
  if is_blocked s a m then 0.0
  else
    let d = distance a.pos m.pos in
    Float.round_up (1_000_000.0 *. a.tastes.(m.instrument) /. (d *. d))

let score_attendee (s : solution) (a : attendee) : float =
  Array.sum (module Float) ~f:(score_I s a) s

let score_musician (p : problem) (m : musician) : float =
  List.fold_left (fun sum attendee -> sum +. score_I attendee m) 0.0 p.attendees

let score_solution (p : problem) (s : solution) : float =
  List.sum (module Float) ~f:(score_attendee s) p.attendees
