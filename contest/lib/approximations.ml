open Core
open Types
open Geometry

let min_distance_to_instrument_sq (p : problem) (a : attendee) : float =
  let inner_rect : rectangle =
    ( { x = p.stage_bottom_left.x +. 10.0; y = p.stage_bottom_left.y +. 10. },
      p.stage_width -. 20.,
      p.stage_height -. 20. )
  in
  point_to_rect_squared a.pos inner_rect

let max_score_I (p : problem) (a : attendee) (i : instrument) : float =
  if Float.(a.tastes.(i) < 0.0) then 0.0
  else
    let d_sq = min_distance_to_instrument_sq p a in
    Float.round_up (1_000_000.0 *. a.tastes.(i) /. d_sq)

let max_score_instrument_without_q (p : problem) (i : instrument) : float =
  List.sum (module Float) ~f:(fun a -> max_score_I p a i) p.attendees

let max_q (inl : int list) : float =
  (* TODO: Correctly account for the increasing size of outer rings *)
  let min_dl = List.mapi inl ~f:(fun i _ -> Float.round_up (float i /. 6.) *. 10.) in
  1.0 +. List.sum (module Float) ~f:(fun d -> if Float.(d = 0.) then 0. else 1. /. d) min_dl

(* Assumes all positive instruments are as close on the plane as possible
   and not blocked, that all musicians with the same instrument are as close
   as possible and that no pillars are blocking the view. *)
let max_score_problem (p : problem) : float =
  let in_groups : instrument list list = List.sort_and_group p.musicians ~compare:Int.compare in
  List.fold in_groups ~init:0.0 ~f:(fun acc inl ->
      let q = max_q inl in
      let base_score = max_score_instrument_without_q p (List.hd_exn inl) in
      let score = if p.problem_id > 55 then base_score *. q else base_score in
      acc +. (score *. float (List.length inl)))
