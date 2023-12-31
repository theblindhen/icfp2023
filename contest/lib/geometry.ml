open Core
open Float

type point = Types.position [@@deriving sexp]
(** a point in 2D space *)

type segment = point * point
(** a line seg  ment in 2D space *)

type line = float * float * float [@@deriving sexp]
(** A line in 2D space.
  * the line ax + by + c = 0 *)

type rectangle = point * float * float [@@deriving sexp]
(** A line in 2D space.
    * the rectangle with lower left corner (x,y) width w and height h *)

let distance_squared (p1 : point) (p2 : point) : float =
  ((p1.x -. p2.x) ** 2.0) +. ((p1.y -. p2.y) ** 2.0)

let distance (p1 : point) (p2 : point) : float = sqrt (distance_squared p1 p2)

let point_to_line_squared ({ x; y } : point) ((a, b, c) : line) : float =
  let numerator = (a *. x) +. (b *. y) +. c in
  let denominator = (a *. a) +. (b *. b) in
  numerator *. numerator /. denominator

let point_to_rect_squared ({ x; y } : point) (({ x = x_r; y = y_r }, w_r, h_r) : rectangle) : float
    =
  let dx = max (x_r - x) (max 0.0 (x - x_r - w_r)) in
  let dy = max (y_r - y) (max 0.0 (y - y_r - h_r)) in
  (dx ** 2.0) + (dy ** 2.0)

let within_rect (({ x = x_r; y = y_r }, w_r, h_r) : rectangle) ({ x; y } : point) : bool =
  x >= x_r && x <= x_r +. w_r && y >= y_r && y <= y_r +. h_r

let translate (delta : point) (p : point) : point = { x = p.x +. delta.x; y = p.y +. delta.y }

let point_rotator (theta : float) =
  let cos_theta = cos theta in
  let sin_theta = sin theta in
  let rotator (p : point) =
    ((p.x *. cos_theta) -. (p.y *. sin_theta), (p.x *. sin_theta) +. (p.y *. cos_theta))
  in
  rotator

let angle_of (p1 : point) (p2 : point) =
  let vx, vy = (p2.x -. p1.x, p2.y -. p1.y) in
  let res = atan2 vy vx in
  if res = pi then -.pi else res

(** Normalize an angle to be between -pi and pi. *)
let angle_norm angle =
  let open Float in
  let angle = mod_float angle (2.0 *. pi) in
  if angle >= pi then angle -. (2.0 *. pi) else angle

(** Returns a function that computes whether a point is within a given distance of a line segment.
  * 
  * WARNING: This method has inaccurate behaviour around the endpoints of the line
  * segments, due to efficiency. When all the given points are assumed to be at
  * least distance `distance` away from the endpoints, the behaviour is correct. *)
let within_distance ((p1, p2) : segment) =
  let rotator = point_rotator (-.angle_of p1 p2) in
  let delta : point = { x = -.p1.x; y = -.p1.y } in
  let transformer p = p |> translate delta |> rotator in
  let t_p2_x, _t_p2_y = transformer p2 in
  let f (distance : float) (p : point) =
    let tx, ty = transformer p in
    tx >= 0. && tx <= t_p2_x && ty >= -.distance && ty <= distance
  in
  f

(** Hat a vector an iterated number of times.
  * Hatting a vector means rotating it 90 degrees counterclockwise.  *)
let hat_iter (p : point) ~count:n : point =
  match n with
  | 0 -> { x = p.x; y = p.y }
  | 1 -> { x = -.p.y; y = p.x }
  | 2 -> { x = -.p.x; y = -.p.y }
  | 3 -> { x = p.y; y = -.p.x }
  | _ -> failwith "hat_iter: count must be between 0 and 3"

(** Determine, for each musician, which attendees can hear that musician. The
 * output is an array indexed by musicians, containing an array of the attendee
 * indexes that can hear the musician. *)
let precompute_hearable ~(attendees : Types.position array) ~(musicians : Types.position array)
    ~(block_radius : float) : int array array =
  let angles_time = Timer.create () in
  let sort_time = Timer.create () in
  let sweep_time = Timer.create () in
  let create_events_time = Timer.create () in
  (* Process each musician independently. *)
  let result =
    Array.mapi musicians ~f:(fun base_idx base_musician ->
        (* Map the attendees to their angle from the base musician *)
        let attendee_angles =
          Timer.run_acc angles_time (fun () ->
              Array.mapi attendees ~f:(fun i pos -> (angle_of base_musician pos, `attendee i)))
        in
        let musician_start_stop_angles =
          Timer.run_acc angles_time (fun () ->
              Array.filter_mapi musicians ~f:(fun idx musician ->
                  if Int.equal idx base_idx then None
                  else
                    let angle_to_center = angle_of base_musician musician in
                    let opposite = block_radius in
                    let hypotenuse = distance base_musician musician in
                    let delta_angle = asin (opposite /. hypotenuse) in
                    Some
                      ( angle_norm (angle_to_center -. delta_angle),
                        angle_norm (angle_to_center +. delta_angle) )))
        in
        let events =
          Timer.run_acc create_events_time (fun () ->
              Array.append attendee_angles
                (Array.concat_map musician_start_stop_angles ~f:(fun (start, stop) ->
                     [| (start, `start); (stop, `stop) |])))
        in
        Timer.run_acc sort_time (fun () ->
            Array.sort events ~compare:(fun (angle1, type1) (angle2, type2) ->
                let angle_cmp = Float.compare angle1 angle2 in
                if Int.equal angle_cmp 0 then
                  (* In case of ties, sort the type in order of `start, `attendee, `stop. *)
                  match (type1, type2) with
                  | `start, `start -> 0
                  | `start, _ -> -1
                  | `attendee i1, `attendee i2 -> Int.compare i1 i2 (* just for determinism *)
                  | `attendee _, `start -> 1
                  | `attendee _, `stop -> -1
                  | `stop, `stop -> 0
                  | `stop, _ -> 1
                else angle_cmp));
        (* Our starting angle is always -pi, and then we sweep around counter-clockwise. *)
        (* Compute the number of blockades at angle -pi so we have something to start with.  *)
        let blockades_at_west : int =
          Array.count musician_start_stop_angles ~f:(fun (start, stop) ->
              (* A musician is blocking at angle 0 if their start angle is in the
               * bottom half of the circle while their stop angle is in the top half. *)
              Float.(stop < start))
        in
        (* Sweep around the list of events counter-clockwise, appending to the
         * list of attendees who can hear this musician and updating the current
         * number of blockades. *)
        let attendees_hearable, _ =
          Timer.run_acc sweep_time (fun () ->
              let open Int in
              Array.fold events ~init:([], blockades_at_west)
                ~f:(fun (attendees_hearable, blockades) (_angle, event_type) ->
                  assert (blockades >= 0);
                  match event_type with
                  | `start -> (attendees_hearable, blockades + 1)
                  | `attendee i ->
                      if blockades = 0 then (i :: attendees_hearable, blockades)
                      else (attendees_hearable, blockades)
                  | `stop -> (attendees_hearable, blockades - 1)))
        in
        (* sorted for determinism *)
        List.sort attendees_hearable ~compare:Int.compare |> Array.of_list)
  in
  Timer.print_acc "angles" angles_time;
  Timer.print_acc "create events" create_events_time;
  Timer.print_acc "sort" sort_time;
  Timer.print_acc "sweep" sweep_time;
  result

let comb_y = Float.sin (Float.pi /. 3.) *. 10.
let epsilon = 0.0001

(** Generate the positions of the honeycombs. *)

(** Generate the positions of the honeycombs. *)

let honey_comb_positions (init_pos : Types.position) =
  let rec snake (position : Types.position) (ring_number : int) (ring_count : int) (direction : int)
      () =
    let next_pos direction : Types.position =
      let x = position.x in
      let y = position.y in
      match direction with
      | 0 -> { x = x +. 10. +. epsilon; y }
      | 1 -> { x = x +. 5. +. epsilon; y = y +. comb_y + epsilon }
      | 2 -> { x = x -. 5. -. epsilon; y = y +. comb_y + epsilon }
      | 3 -> { x = x -. 10. -. epsilon; y }
      | 4 -> { x = x -. 5. -. epsilon; y = y -. comb_y -. epsilon }
      | 5 -> { x = x +. 5. +. epsilon; y = y -. comb_y -. epsilon }
      | _ -> failwith "direction must be between 0 and 5"
    in
    let open Int in
    if ring_count >= (ring_number * 6) - 1 then
      (* printf "ring: (%f, %f)\n%!" position.x position.y; *)
      Seq.Cons (position, snake (next_pos direction) Int.(ring_number + 1) 0 ((direction + 1) mod 6))
    else if ring_count % ring_number = ring_number - 1 then
      (* printf "count: (%f, %f)\n%!" position.x position.y; *)
      Seq.Cons
        ( position,
          snake
            (next_pos ((direction + 1) mod 6))
            ring_number (ring_count + 1)
            ((direction + 1) mod 6) )
    else
      (* printf "else: (%f, %f)\n%!" position.x position.y; *)
      Seq.Cons (position, snake (next_pos direction) ring_number (ring_count + 1) direction)
  in
  (* printf "init_pos: (%f, %f)\n%!" init_pos.x init_pos.y; *)
  snake init_pos 0 0 0

(* TESTS *)

let to_point (x, y) : point = { x; y }

let%test_unit "angle_norm" =
  [%test_eq: float] (angle_norm 0.) 0.;
  [%test_eq: float] (angle_norm pi) (-.pi);
  [%test_eq: float] (angle_norm (2. *. pi)) 0.;
  [%test_eq: float] (angle_norm (3. *. pi)) (-.pi);
  [%test_eq: float] (angle_norm (-.pi)) (-.pi);
  [%test_eq: float] (angle_norm (-2. *. pi)) 0.;
  [%test_eq: float] (angle_norm (-3. *. pi)) (-.pi);
  [%test_eq: float] (angle_norm (pi /. 2.)) (pi /. 2.);
  [%test_eq: float] (angle_norm ((pi /. 2.) +. (2. *. pi))) (pi /. 2.);
  [%test_eq: float] (angle_norm ((pi /. 2.) +. (3. *. pi))) (-.pi /. 2.);
  [%test_eq: float] (angle_norm (-.pi /. 2.)) (-.pi /. 2.);
  [%test_eq: float] (angle_norm ((-.pi /. 2.) +. (2. *. pi))) (-.pi /. 2.);
  [%test_eq: float] (angle_norm ((-.pi /. 2.) +. (3. *. pi))) (pi /. 2.);
  ()

let%test_unit "precompute_hearable 1" =
  let attendees =
    Array.map ~f:to_point
      [|
        (* to the east of the origin *)
        (10., 0.);
        (* even further to the east *)
        (100., 1.);
        (* straight north *)
        (0., 100.);
        (* straight south *)
        (0., -100.);
        (* to the west of the origin *)
        (-10., 0.);
      |]
  in
  let musicians =
    Array.map ~f:to_point
      [|
        (* main musician, at origin *)
        (0., 0.);
        (* blocking to the east *)
        (2., 0.);
        (* same, slightly above the horizon *)
        (2., 0.1);
        (* same, slightly below the horizon *)
        (2., -0.1);
      |]
  in
  let block_radius = 1. in
  let hearable = precompute_hearable ~attendees ~musicians ~block_radius in
  [%test_eq: int array array] hearable
    [| [| 2; 3; 4 |]; [| 0; 1; 2; 3 |]; [| 0; 1; 2; 3 |]; [| 0; 1; 2; 3 |] |]

let%test_unit "precompute_hearable edge" =
  let attendees = Array.map ~f:to_point [| (10., 0.); (0., 10.) |] in
  let musicians = Array.map ~f:to_point [| (0., 0.); (2., 1.) |] in
  let block_radius = 1. in
  let hearable = precompute_hearable ~attendees ~musicians ~block_radius in
  [%test_eq: int array array] hearable [| [| 1 |]; [| 0; 1 |] |]

let%test_unit "angle_of" =
  let is (a : float) (b : float) = a < b +. 0.001 && a > b -. 0.001 in
  [%test_eq: bool] (angle_of { x = 0.; y = 0. } { x = 10.; y = 0. } |> is 0.) true;
  [%test_eq: bool] (angle_of { x = 0.; y = 0. } { x = 10.; y = 0. } |> is 0.) true;
  [%test_eq: bool] (angle_of { x = 0.; y = 0. } { x = 0.; y = 10. } |> is (pi / 2.)) true;
  [%test_eq: bool] (angle_of { x = 10.; y = 0. } { x = 0.; y = 0. } |> is (-.pi)) true;
  [%test_eq: bool] (angle_of { x = 0.; y = 10. } { x = 0.; y = 0. } |> is (-.pi / 2.)) true;
  [%test_eq: bool] (angle_of { x = 0.; y = 0. } { x = -10.; y = -10. } |> is (-.pi *. 3. / 4.)) true;
  ()

let test_rotations distance p1 p2 inside outside =
  for rot = 0 to 3 do
    let inside = List.map inside ~f:(hat_iter ~count:rot) in
    let outside = List.map outside ~f:(hat_iter ~count:rot) in
    let p1, p2 = (hat_iter ~count:rot p1, hat_iter ~count:rot p2) in
    List.iter inside ~f:(fun p -> [%test_eq: bool] (within_distance (p1, p2) distance p) true);
    List.iter outside ~f:(fun p -> [%test_eq: bool] (within_distance (p1, p2) distance p) false)
  done

let%test_unit "within_distance straight" =
  let p1 = to_point (0., 0.) in
  let p2 = to_point (10., 0.) in
  let inside : point list = List.map ~f:to_point [ (1., 1.); (9., 1.); (1., -1.); (9., -1.) ] in
  let outside : point list =
    List.map ~f:to_point [ (1., 1.1); (9., 1.1); (1., -1.1); (9., -1.1) ]
  in
  test_rotations 1.01 p1 p2 inside outside

let%test_unit "within_distance diag1" =
  let p1 = to_point (0., 0.) in
  let p2 = to_point (10., 20.) in
  let inside = List.map ~f:to_point [ (2.9, 1.); (4.9, 5.); (7., 9.2); (11., 17.3) ] in
  let outside = List.map ~f:to_point [ (3.1, 1.); (5.1, 5.); (7., 8.9); (11., 17.) ] in
  test_rotations 2.2 p1 p2 inside outside

let%test_unit "point_to_rect" =
  let is (a : float) (b : float) = a < b +. 0.001 && a > b -. 0.001 in
  [%test_eq: bool]
    (point_to_rect_squared { x = 0.; y = 0. } ({ x = 10.; y = 10. }, 10., 10.) |> is 200.)
    true;
  [%test_eq: bool]
    (point_to_rect_squared { x = 30.; y = 0. } ({ x = 10.; y = 10. }, 10., 10.) |> is 200.)
    true;
  [%test_eq: bool]
    (point_to_rect_squared { x = 0.; y = 30. } ({ x = 10.; y = 10. }, 10., 10.) |> is 200.)
    true;
  [%test_eq: bool]
    (point_to_rect_squared { x = 30.; y = 30. } ({ x = 10.; y = 10. }, 10., 10.) |> is 200.)
    true;
  [%test_eq: bool]
    (point_to_rect_squared { x = 15.; y = 30. } ({ x = 10.; y = 10. }, 10., 10.) |> is 100.)
    true;
  [%test_eq: bool]
    (point_to_rect_squared { x = 15.; y = 0. } ({ x = 10.; y = 10. }, 10., 10.) |> is 100.)
    true;
  [%test_eq: bool]
    (point_to_rect_squared { x = 0.; y = 15. } ({ x = 10.; y = 10. }, 10., 10.) |> is 100.)
    true;
  [%test_eq: bool]
    (point_to_rect_squared { x = 30.; y = 15. } ({ x = 10.; y = 10. }, 10., 10.) |> is 100.)
    true;
  ()
