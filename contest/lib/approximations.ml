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

let max_q (m_count : int) : float =
  if m_count < 1 then failwith "cannot calculate Q for less than 1 musician"
  else
    (* calculate the nth ring of the ith musician in a honeycomb *)
    let ring_of_i (i : int) =
      let rec iter n i = if i < 1 then n else iter (n + 1) (i - ((n + 1) * 6)) in
      iter 0 i
    in
    let min_dl =
      List.range ~start:`inclusive ~stop:`inclusive 0 (m_count - 1)
      |> List.mapi ~f:(fun i _ ->
             let r = ring_of_i i in
             if r < 2 then Float.(of_int r * 10.) else Float.(of_int r * 10. * cos (Float.pi /. 6.)))
    in
    1.0 +. List.sum (module Float) ~f:(fun d -> if Float.(d = 0.) then 0. else 1. /. d) min_dl

(* Assumes all positive instruments are as close on the plane as possible
   and not blocked, that all musicians with the same instrument are as close
   as possible and that no pillars are blocking the view. *)
let max_score_problem (p : problem) : float =
  let in_groups : instrument list list = List.sort_and_group p.musicians ~compare:Int.compare in
  10.
  *. List.fold in_groups ~init:0.0 ~f:(fun acc inl ->
         let q = max_q (List.length inl) in
         let base_score = max_score_instrument_without_q p (List.hd_exn inl) in
         let score = if p.problem_id > 55 then base_score *. q else base_score in
         acc +. (score *. float (List.length inl)))

let newton_score_I (a : attendee) (i : Physics.placed_instrument) : float =
  if Float.(a.tastes.(i.instrument) < 0.0) then 0.0
  else
    let d_sq = distance_squared a.pos i.pos in
    10. *. Float.round_up (1_000_000.0 *. a.tastes.(i.instrument) /. d_sq)

let newton_score_instrument_without_q (p : problem) (i : Physics.placed_instrument) : float =
  List.sum (module Float) ~f:(fun a -> newton_score_I a i) p.attendees

(* Uses Newton simulation until stable, then ignores negative scores and assumes no musicians or
   pillars are blocking the view. *)
let newton_score_problem_per_instrument (p : problem) =
  let placements = Physics.init_placements p in
  let _iters = Physics.(newton_run_stage stay_stage1 step_stage1) p placements 0 in
  let in_groups : instrument list list = List.sort_and_group p.musicians ~compare:Int.compare in
  List.map in_groups ~f:(fun inl ->
      let q = max_q (List.length inl) in
      let base_score = newton_score_instrument_without_q p placements.(List.hd_exn inl) in
      let score = if p.problem_id > 55 then base_score *. q else base_score in
      let i_count = List.length inl in
      (i_count, score))

let newton_score_problem (p : problem) : float =
  let scores = newton_score_problem_per_instrument p in
  List.fold scores ~init:0.0 ~f:(fun acc (count, score) -> acc +. (score *. float count))

(* TESTS *)
let%test_unit "max_q" =
  [%test_eq: float] (max_q 1) 1.;
  [%test_eq: float] (max_q 2) 1.1;
  [%test_eq: float] (max_q 3) 1.2;
  [%test_eq: float] (max_q 7) 1.6;
  [%test_eq: bool] Float.(max_q 18 >= 2.2 && max_q 18 <= 2.4) true;
  [%test_eq: bool] Float.(max_q 36 >= 2.8 && max_q 36 <= 3.0) true;
  [%test_eq: bool] Float.(max_q 60 >= 3.4 && max_q 60 <= 3.7) true;
  ()
