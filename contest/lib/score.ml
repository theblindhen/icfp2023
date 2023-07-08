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
  let attendees = List.to_array p.attendees in
  let hearable_sets =
    Timer.run_print "precompute_hearable" (fun () ->
        Geometry.precompute_hearable
          ~attendees:(attendees |> Array.map ~f:(fun a -> a.pos))
          ~musicians:(Array.map s ~f:(fun m -> m.pos))
          ~block_radius:5.0)
  in
  (*
  (* For debugging, count how many pairs can hear each other. *)
  eprintf "  hearable pairs: %d\n" (Array.sum (module Int) hearable_sets ~f:Array.length);
  eprintf "  not blocked pairs: %d\n"
    (Array.sum
       (module Int)
       s
       ~f:(fun m -> Array.count attendees ~f:(fun a -> not (is_blocked s a m.id m.pos))));
  (* For debugging, determine if the same pairs can hear each other in the two
   * variations of the calculation. *)
  let hearable_matrix =
    let num_attendees = List.length p.attendees in
    Array.map hearable_sets ~f:(fun hearable ->
        let tmp = Array.create ~len:num_attendees false in
        Array.iteri hearable ~f:(fun a_id _ -> tmp.(a_id) <- true);
        tmp)
  in
  let not_blocked_matrix =
    Array.map s ~f:(fun m -> Array.map attendees ~f:(fun a -> not (is_blocked s a m.id m.pos)))
  in
  (* Print all the entries from hearable_matrix that aren't in
   * not_blocked_matrix. *)
  Array.iteri hearable_matrix ~f:(fun m_id attendee_matrix ->
      Array.iteri attendee_matrix ~f:(fun a_id can_hear ->
          if Bool.(not_blocked_matrix.(m_id).(a_id) <> can_hear) then
            eprintf "  (m %d, a %d) %b %b\n" m_id a_id can_hear not_blocked_matrix.(m_id).(a_id)));
   *)
  (* Sum over all musicians *)
  Array.fold2_exn s hearable_sets ~init:0.0 ~f:(fun sum m hearable ->
      (* Sum over all attendees that can hear this musician *)
      sum
      +. Array.sum
           (module Float)
           hearable
           ~f:(fun attendee_index ->
             let a = attendees.(attendee_index) in
             let d_sq = Geometry.distance_squared a.pos m.pos in
             Float.round_up (1_000_000.0 *. a.tastes.(m.instrument) /. d_sq)))
