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

(* Approximating the nth ring of the ith musician. The precise is i/3 = n(n+1) *)
let max_q (inl : int list) : float =
  let ring_approx (i : int) = Float.(max (round_up (sqrt (of_int i / 3.)) - 1.) 0.) in
  let min_dl = List.mapi inl ~f:(fun i _ -> ring_approx i *. 10.) in
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

let newton_score_I (a : attendee) (i : Physics.placed_instrument) : float =
  if Float.(a.tastes.(i.instrument) < 0.0) then 0.0
  else
    let d_sq = distance_squared a.pos i.pos in
    Float.round_up (1_000_000.0 *. a.tastes.(i.instrument) /. d_sq)

let newton_score_instrument_without_q (p : problem) (i : Physics.placed_instrument) : float =
  List.sum (module Float) ~f:(fun a -> newton_score_I a i) p.attendees

(* Uses Newton simulation until stable, then ignores negative scores and assumes no musicians or
   pillars are blocking the view. *)
let newton_score_problem (p : problem) : float =
  let placements = Physics.init_placements p in
  let rec loop iteration last_instability =
    if iteration > 100 && (Float.(last_instability < 0.00000000001) || iteration > 5000) then
      iteration
    else
      let att_heat = Physics.att_heat_from_iteration_stage1 p iteration in
      (* Printf.printf "Iteration %d, heat %f\n%!" iteration att_heat; *)
      let last_instability = Physics.simulate_step_stage1 p ~att_heat placements in
      loop (iteration + 1) last_instability
  in
  let _ = loop 0 Float.max_value in
  let in_groups : instrument list list = List.sort_and_group p.musicians ~compare:Int.compare in
  List.fold in_groups ~init:0.0 ~f:(fun acc inl ->
      let q = max_q inl in
      let base_score = newton_score_instrument_without_q p placements.(List.hd_exn inl) in
      let score = if p.problem_id > 55 then base_score *. q else base_score in
      acc +. (score *. float (List.length inl)))
