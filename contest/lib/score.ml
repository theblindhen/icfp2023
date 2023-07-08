open Core
open Types
open Misc

let is_blocked (s : solution) (a : attendee) (self_id : int) (pos : position) : bool =
  let within_distance = Geometry.within_distance 5.0 (a.pos, pos) in
  Array.exists ~f:(fun candidate -> self_id <> candidate.id && within_distance candidate.pos) s

let score_I (s : solution) (a : attendee) (m : musician) : float =
  if is_blocked s a m.id m.pos then 0.0
  else
    let d_sq = distance_squared a.pos m.pos in
    Float.round_up (1_000_000.0 *. a.tastes.(m.instrument) /. d_sq)

let score_I_partial (s : solution) (a : attendee) (self_id : int) (pos : position) : float =
  if is_blocked s a self_id pos then 0.0
  else
    let d_sq = distance_squared a.pos pos in
    1_000_000.0 /. d_sq

let score_attendee (s : solution) (a : attendee) : float =
  Array.sum (module Float) ~f:(score_I s a) s

let score_musician (p : problem) (s : solution) (m : musician) : float =
  List.sum (module Float) ~f:(fun attendee -> score_I s attendee m) p.attendees

let score_solution (p : problem) (s : solution) : float =
  List.sum (module Float) ~f:(score_attendee s) p.attendees
