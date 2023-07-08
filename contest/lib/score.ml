open Core
open Types

type scoring_env = {
  problem : problem;
  solution : solution;
  (* hearable_sets: int list array; *)
  qfactors : float array;
}

let is_blocked_by_musicians (env : scoring_env) (a : attendee) (self_id : int) (pos : position) :
    bool =
  let within_distance = Geometry.within_distance (a.pos, pos) 5.0 in
  Array.exists
    ~f:(fun candidate -> self_id <> candidate.id && within_distance candidate.pos)
    env.solution

let is_blocked_by_pillars (env : scoring_env) (a : attendee) (pos : position) : bool =
  let within = Geometry.within_distance (a.pos, pos) in
  List.exists ~f:(fun (pillar : pillar) -> within pillar.radius pillar.center) env.problem.pillars

let is_blocked (env : scoring_env) (a : attendee) (self_id : int) (pos : position) : bool =
  is_blocked_by_musicians env a self_id pos || is_blocked_by_pillars env a pos

let score_I (env : scoring_env) (a : attendee) (m : musician) : float =
  if is_blocked env a m.id m.pos then 0.0
  else
    let d_sq = Geometry.distance_squared a.pos m.pos in
    Float.round_up
      (env.qfactors.(m.id) *. Float.round_up (1_000_000.0 *. a.tastes.(m.instrument) /. d_sq))

let score_I_partial (env : scoring_env) (a : attendee) (self_id : int) (pos : position) : float =
  if is_blocked env a self_id pos then 0.0
  else
    let d_sq = Geometry.distance_squared a.pos pos in
    1_000_000.0 /. d_sq

let score_attendee (env : scoring_env) (a : attendee) : float =
  Array.sum (module Float) ~f:(score_I env a) env.solution

let score_musician (env : scoring_env) (m : musician) : float =
  List.sum (module Float) ~f:(fun attendee -> score_I env attendee m) env.problem.attendees

let compute_qfactors (p : problem) (s : solution) : float array =
  let arr = Array.create ~len:(Array.length s) 1.0 in
  if p.problem_id <= 55 then arr
  else
    let ms_by_inst =
      s
      |> Array.to_list
      |> List.sort_and_group ~compare:(fun a b -> Int.compare a.instrument b.instrument)
    in
    List.iter ms_by_inst ~f:(fun ms ->
        (* Each of these musicians increase each other's qfactor *)
        List.iter ms ~f:(fun m ->
            List.iter ms ~f:(fun m' ->
                if m.id <> m'.id then
                  arr.(m.id) <- arr.(m.id) +. (1. /. Geometry.distance m.pos m'.pos))));
    arr

let get_scoring_env (p : problem) (s : solution) : scoring_env =
  { problem = p; solution = s; qfactors = compute_qfactors p s }

let score_solution (p : problem) (s : solution) : float =
  List.sum (module Float) ~f:(score_attendee (get_scoring_env p s)) p.attendees

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
          let d_sq = Geometry.distance_squared a.pos m.pos in
          sum +. Float.round_up (1_000_000.0 *. a.tastes.(m.instrument) /. d_sq)))
