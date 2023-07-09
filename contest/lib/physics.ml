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
let push (p : Types.position) (f : force) : Types.position = { x = p.x +. f.x; y = p.y +. f.y }

let placement_score_raw (p : Types.problem) (placement : placed_instrument array) : float =
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
             a.tastes.(i.instrument) /. (d *. d)))

let force_I (i : placed_instrument) (a : Types.attendee) : force =
  let d_sq = length_sq (from_points a.pos i.pos) in
  {
    x = -2. *. a.tastes.(i.instrument) /. (d_sq *. d_sq) *. (i.pos.x -. a.pos.x);
    y = -2. *. a.tastes.(i.instrument) /. (d_sq *. d_sq) *. (i.pos.y -. a.pos.y);
  }

let force_over_attendees (p : Types.problem) (i : placed_instrument) : force =
  List.fold p.attendees ~init:{ x = 0.; y = 0. } ~f:(fun acc a -> add acc (force_I i a))

(* Cull a force push to be within the bounds of the stage *)
let safe_push (p : Types.problem) (pos : Types.position) (f : force) : Types.position =
  let open Float in
  let new_x =
    min
      (p.stage_bottom_left.x + p.stage_width - 10.)
      (max (p.stage_bottom_left.x + 10.) (pos.x + f.x))
  in
  let new_y =
    min
      (p.stage_bottom_left.y + p.stage_height - 10.)
      (max (p.stage_bottom_left.y + 10.) (pos.y + f.y))
  in
  { x = new_x; y = new_y }

let simulate_step (p : Types.problem) ~(att_heat : float) (placements : placed_instrument array) :
    unit =
  let forces = Array.map placements ~f:(fun i -> force_over_attendees p i) in
  Array.iter2_exn placements forces ~f:(fun i f ->
      let desired_push = scale_to_len att_heat f in
      (* let desired_push = scale att_heat f in *)
      placements.(i.instrument) <-
        { instrument = i.instrument; pos = safe_push p i.pos desired_push });
  ()

let init_placement (p : Types.problem) : placed_instrument array =
  (* Place instruments at center stage *)
  let center : Types.position =
    {
      x = (p.stage_width /. 2.) +. p.stage_bottom_left.x;
      y = (p.stage_height /. 2.) +. p.stage_bottom_left.y;
    }
  in
  let num_instruments = Misc.instrument_count p in
  Array.init num_instruments ~f:(fun i -> { instrument = i; pos = center })

let solution_of_placement_stage1 (placement : placed_instrument array) : Types.solution =
  placement
  |> Array.mapi ~f:(fun idx i : Types.musician ->
         { id = idx; instrument = i.instrument; pos = i.pos })

let simulate_step_sol_stage1 (p : Types.problem) (solution : Types.solution) ~(round : int) :
    Types.solution =
  (* Pretend we have a solution, but actually we're only placing the instruments
  *)
  ignore round;
  let att_heat = 0.01 in
  (* let att_heat = 0.1 /. Float.int_pow (float_of_int round +. 10.) 2 in *)
  (* let att_heat = 0.1 /. ((float_of_int round +. 10.) ** 1.75) in *)
  let placements = Array.map solution ~f:(fun m -> { instrument = m.instrument; pos = m.pos }) in
  simulate_step p ~att_heat placements;
  Printf.printf "Score: %2.4f\n%!" (placement_score_raw p placements);
  solution_of_placement_stage1 placements

let init_solution_sol_stage1 (p : Types.problem) : Types.solution =
  init_placement p |> solution_of_placement_stage1
