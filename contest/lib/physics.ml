open Core
open Geometry

type force = { x : float; y : float }
type placed_instrument = { instrument : Types.instrument; pos : Types.position }

let from_points (a : Types.position) (b : Types.position) : force =
  { x = a.x -. b.x; y = a.y -. b.y }

let add (a : force) (b : force) : force = { x = a.x +. b.x; y = a.y +. b.y }
let scale (c : float) (v : force) : force = { x = c *. v.x; y = c *. v.y }
let length (v : force) : float = sqrt ((v.x *. v.x) +. (v.y *. v.y))

let scale_to_len (l : float) (v : force) : force =
  let lenv = length v in
  if Float.(lenv = 0.) then { x = 0.; y = 0. } else scale (l /. lenv) v

let length_sq (v : force) : float = (v.x *. v.x) +. (v.y *. v.y)
let move (p : Types.position) (f : force) : Types.position = { x = p.x +. f.x; y = p.y +. f.y }

let placement_score_raw (p : Types.problem) (placement : placed_instrument array) : float =
  let instrument_valency =
    List.sort_and_group p.musicians ~compare:Int.compare |> List.map ~f:List.length |> Array.of_list
  in
  placement
  |> Array.sum
       (module Float)
       ~f:(fun i ->
         List.sum
           (module Float)
           p.attendees
           ~f:(fun a ->
             let v = from_points a.pos i.pos in
             let d = length v (* TODO: This is dumb *) in
             float_of_int instrument_valency.(i.instrument)
             *. Float.max 0. (Float.round_up (1_000_000. *. a.tastes.(i.instrument) /. (d *. d)))))

let force_I (i : placed_instrument) (a : Types.attendee) : force =
  let d_sq = length_sq (from_points a.pos i.pos) in
  {
    x = -2. *. a.tastes.(i.instrument) /. (d_sq *. d_sq) *. (i.pos.x -. a.pos.x);
    y = -2. *. a.tastes.(i.instrument) /. (d_sq *. d_sq) *. (i.pos.y -. a.pos.y);
  }

let force_over_attendees (p : Types.problem) (i : placed_instrument) : force =
  List.fold p.attendees ~init:{ x = 0.; y = 0. } ~f:(fun acc a -> add acc (force_I i a))

(* Cull a force move to be within the bounds of the stage *)
let safe_move (p : Types.problem) (pos : Types.position) (f : force) : Types.position * force =
  let open Float in
  let new_pos : Types.position =
    {
      x =
        min
          (p.stage_bottom_left.x + p.stage_width - 10.)
          (max (p.stage_bottom_left.x + 10.) (pos.x + f.x));
      y =
        min
          (p.stage_bottom_left.y + p.stage_height - 10.)
          (max (p.stage_bottom_left.y + 10.) (pos.y + f.y));
    }
  in
  (new_pos, from_points new_pos pos)

(* Simulate a step of the placement algorithm. Returns the maximum distance moved
   by any instrument. *)
let simulate_step (p : Types.problem) ~(att_heat : float) (placements : placed_instrument array) :
    (* let simulate_step (p : Types.problem) ~(att_heat : float) (placements : placed_instrument array) : *)
    float =
  let forces = Array.map placements ~f:(fun i -> force_over_attendees p i) in
  let max_truncated_force =
    Array.fold2_exn placements forces ~init:Float.min_value ~f:(fun max_move i f ->
        (*TODO: Could this be a bit more efficient? *)
        let desired_move = scale_to_len att_heat f in
        let pos, _ = safe_move p i.pos desired_move in
        let _, truncated_force = safe_move p i.pos f in
        placements.(i.instrument) <- { instrument = i.instrument; pos };
        Float.max max_move (length_sq truncated_force))
  in
  max_truncated_force

let att_heat_from_iteration_stage1 (problem : Types.problem) (iteration : int) : float =
  let iter_denom = Float.round_up (Float.of_int iteration /. 100.) in
  let att_heat_force : force =
    { x = problem.stage_width /. iter_denom; y = problem.stage_height /. iter_denom }
  in
  length att_heat_force /. 10.

(* STAGE 1: Placing the instruments *)
let simulate_step_stage1 (p : Types.problem) ~(att_heat : float)
    (placements : placed_instrument array) : float =
  simulate_step p ~att_heat placements

(* TODO: let simulate_stage1 (p : Types.problem)  *)

let init_placements (p : Types.problem) : placed_instrument array =
  (* Place instruments at center stage *)
  let center : Types.position =
    {
      x = (p.stage_width /. 2.) +. p.stage_bottom_left.x;
      y = (p.stage_height /. 2.) +. p.stage_bottom_left.y;
    }
  in
  let num_instruments = Misc.instrument_count p in
  Array.init num_instruments ~f:(fun i -> { instrument = i; pos = center })

let solution_of_placement_stage1 (placements : placed_instrument array) : Types.solution =
  placements
  |> Array.mapi ~f:(fun idx i : Types.musician ->
         { id = idx; instrument = i.instrument; pos = i.pos })

let simulate_step_sol_stage1 (p : Types.problem) (solution : Types.solution) ~(round : int) :
    Types.solution =
  (* Pretend we have a solution, but actually we're only placing the instruments
  *)
  ignore round;
  let att_heat = att_heat_from_iteration_stage1 p round in
  (* let att_heat = 0.1 /. Float.int_pow (float_of_int round +. 10.) 2 in *)
  (* let att_heat = 0.1 /. ((float_of_int round +. 10.) ** 1.75) in *)
  let placements = Array.map solution ~f:(fun m -> { instrument = m.instrument; pos = m.pos }) in
  let max_actual_move = simulate_step_stage1 p ~att_heat placements in
  Printf.printf "Score: %s (max move %e)\n%!"
    (placement_score_raw p placements |> Misc.string_of_score)
    max_actual_move;
  solution_of_placement_stage1 placements

let init_solution_sol (p : Types.problem) : Types.solution =
  init_placements p |> solution_of_placement_stage1

let simulate_step_sol (p : Types.problem) (solution : Types.solution) ~(round : int) :
    Types.solution =
  if round < 1000 then simulate_step_sol_stage1 p solution ~round
  else if round = 1000 then
    (* switch from stage 1 to stage 2: Expand instrument locii to musicians *)
    let placements = Array.map solution ~f:(fun m -> m.pos) in
    Random_solver.random_solution_from_instrument_locii p placements
  else (* NOOP *)
    solution
