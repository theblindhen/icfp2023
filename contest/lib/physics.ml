open Core
open Geometry

type force = { x : float; y : float }
type placed_instrument = { instrument : Types.instrument; pos : Types.position } [@@deriving sexp]

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

let honeycomb_solution_from_instrument_locii (p : Types.problem)
    (instruments : Types.position array) : Types.solution =
  let open Types in
  let musicians : musician array =
    p.musicians
    |> Array.of_list
    |> Array.mapi ~f:(fun id instrument -> { id; instrument; pos = instruments.(instrument) })
  in
  musicians
  |> Array.fold ~init:[] ~f:(fun already_placed musician ->
         let locus = instruments.(musician.instrument) in
         let comb = Geometry.honey_comb_positions locus in
         let rec iter (comb : Types.position Seq.t) already_placed =
           match Seq.uncons comb with
           | None -> already_placed
           | Some (hd, tl) ->
               if Random_solver.is_valid_placement p already_placed hd then (
                 Printf.printf "placing at (%f, %f)\n%!" hd.x hd.y;
                 musicians.(musician.id) <- { musician with pos = hd };
                 hd :: already_placed)
               else iter tl already_placed
         in
         iter comb already_placed)
  |> ignore;
  musicians

let instrument_placement_to_stage2 ?(placer = `Honeycomb) (p : Types.problem)
    (placements : placed_instrument array) : placed_instrument array =
  let placements = Array.map placements ~f:(fun i -> i.pos) in
  (match placer with
  | `Random -> Random_solver.random_solution_from_instrument_locii p placements
  | `Honeycomb -> honeycomb_solution_from_instrument_locii p placements)
  |> Array.map ~f:(fun m -> { pos = m.pos; instrument = m.instrument })

let solution_of_placement (problem : Types.problem) (placements : placed_instrument array) :
    Types.solution =
  let musicians : Types.solution =
    problem.musicians
    |> Array.of_list
    |> Array.mapi ~f:(fun id instrument : Types.musician ->
           { id; instrument; pos = { x = 0.; y = 0. } })
  in
  let musician_pool = Misc.musician_group_by_instrument problem in
  placements
  |> Array.iter ~f:(fun { instrument; pos } ->
         let musician = List.hd_exn musician_pool.(instrument) in
         musicians.(musician) <- { (musicians.(musician)) with pos };
         musician_pool.(instrument) <- List.tl_exn musician_pool.(instrument));
  musicians

let att_heat_from_iteration_stage1 (problem : Types.problem) (iteration : int) : float =
  let iter_denom = Float.round_up (Float.of_int iteration /. 100.) in
  let att_heat_force : force =
    { x = problem.stage_width /. iter_denom; y = problem.stage_height /. iter_denom }
  in
  length att_heat_force /. 10.

let att_heat_from_iteration_stage2 = att_heat_from_iteration_stage1

let stay_stage1 last_instability iteration =
  (* The condition to stay at stage 1 *)
  iteration < 100 || (Float.(last_instability > 0.0001) && iteration < 500)

let stay_stage2 last_instability iteration =
  (* The condition to stay at stage 2 *)
  iteration < 100 || (Float.(last_instability > 0.0001) && iteration < 1000)

(* Take a single step in Newton Stage 1. Return the instability *)
let step_stage1 problem placements iteration =
  let att_heat = att_heat_from_iteration_stage1 problem iteration in
  simulate_step problem placements ~att_heat

(* Take a single step in Newton Stage 2. Return the instability *)
let step_stage2 problem placements iteration =
  let att_heat = att_heat_from_iteration_stage2 problem iteration in
  simulate_step problem placements ~att_heat

(* Run Newton Stage 1, updating the placements imperatively.
   Return the total number of iterations *)
let newton_run_stage stay_stage step problem placements : int -> int =
  let rec loop (last_instability : float) (iteration : int) =
    if stay_stage last_instability iteration then
      let last_instability = step problem placements iteration in
      loop last_instability (iteration + 1)
    else iteration
  in
  let ret iteration = loop Float.max_value iteration in
  ret

(* Main entry point *)
let newton_solver (problem : Types.problem) : Types.solution =
  let inst_placements = init_placements problem in
  let run_stage1 = newton_run_stage stay_stage1 step_stage1 in
  let iterations = run_stage1 problem inst_placements 0 in
  Printf.printf "Problem %d converged in %d iterations." problem.problem_id iterations;
  Printf.printf " Fake ideal score: %s \n%!"
    (placement_score_raw problem inst_placements |> Misc.string_of_score);
  Printf.printf " Going to Stage 2 %!";
  let run_stage2 = newton_run_stage stay_stage2 step_stage2 in
  let music_placements = instrument_placement_to_stage2 problem inst_placements in
  Printf.printf " - DONE\n%!";
  let iterations = run_stage2 problem music_placements iterations in
  Printf.printf "Stage 2 done by %d iterations.\n%!" iterations;
  let sol = solution_of_placement problem music_placements in
  sol

(* GUI Entry points *)
let gui_init_solution (p : Types.problem) : Types.solution * string =
  (init_placements p |> solution_of_placement p, "stage1")

let placements_of_solution (solution : Types.solution) =
  Array.map solution ~f:(fun m -> { pos = m.pos; instrument = m.instrument })

let gui_newton_solver_step (problem : Types.problem) ((solution, state) : Types.solution * string)
    ~(round : int) : Types.solution * string =
  let iteration = round in
  let placements = placements_of_solution solution in
  if Stdlib.(state = "stage1") then
    (* Stage 1 *)
    let last_instability = step_stage1 problem placements iteration in
    if stay_stage1 last_instability (iteration + 1) then
      (solution_of_placement problem placements, "stage1")
    else
      let music_placements = instrument_placement_to_stage2 problem placements in
      (solution_of_placement problem music_placements, "stage2")
  else if Stdlib.(state = "stage2") then (* Stage 2 *)
    (solution, "stage3")
    (* let last_instability = step_stage2 problem placements iteration in
       if stay_stage2 last_instability (iteration + 1) then
         (solution_of_placement problem placements, "stage2")
       else (solution_of_placement problem placements, "stage3") *)
  else (
    print_endline "I'm done";
    (solution, "stage3"))
