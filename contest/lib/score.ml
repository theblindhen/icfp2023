open Core
open Types

let is_blocked (s : solution) (a : attendee) (self_id : int) (pos : position) : bool =
  let within_distance = Geometry.within_distance 5.0 (a.pos, pos) in
  Array.exists ~f:(fun candidate -> self_id <> candidate.id && within_distance candidate.pos) s

let score_I (s : solution) (a : attendee) (m : musician) : float =
  if is_blocked s a m.id m.pos then 0.0
  else
    let d_sq = Geometry.distance_squared a.pos m.pos in
    Float.round_up (1_000_000.0 *. a.tastes.(m.instrument) /. d_sq)

let score_I_partial (s : solution) (a : attendee) (self_id : int) (pos : position) : float =
  if is_blocked s a self_id pos then 0.0
  else
    let d_sq = Geometry.distance_squared a.pos pos in
    1_000_000.0 /. d_sq

let score_attendee (s : solution) (a : attendee) : float =
  Array.sum (module Float) ~f:(score_I s a) s

let score_musician (p : problem) (s : solution) (m : musician) : float =
  List.sum (module Float) ~f:(fun attendee -> score_I s attendee m) p.attendees

let score_solution (p : problem) (s : solution) : float =
  List.sum (module Float) ~f:(score_attendee s) p.attendees

(* Alternative scoring function, using Geometry.precompute_hearable. *)
let score_solution_wip_broken (p : problem) (s : solution) : float =
  let hearable_sets =
    Geometry.precompute_hearable
      ~attendees:(Array.of_list p.attendees |> Array.map ~f:(fun a -> a.pos))
      ~musicians:(Array.map s ~f:(fun m -> m.pos))
      ~block_radius:5.0
  in
  (* Prepare an array for random access *)
  let attendees = List.to_array p.attendees in
  (* Sum over all musicians *)
  Array.fold2_exn s hearable_sets ~init:0.0 ~f:(fun sum m hearable ->
      (* Sum over all attendees that can hear this musician *)
      (*eprintf "  hearable: %d\n" (Array.length hearable);*)
      Array.sum
        (module Float)
        hearable
        ~f:(fun attendee_index ->
          printf "  %d hears someone\n" attendee_index;
          let a = attendees.(attendee_index) in
          let d_sq = distance_squared a.pos m.pos in
          sum +. Float.round_up (1_000_000.0 *. a.tastes.(m.instrument) /. d_sq)))
