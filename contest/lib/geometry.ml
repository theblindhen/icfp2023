open Core
open Float

type point = Types.position
(** a point in 2D space *)

type segment = point * point
(** a line seg  ment in 2D space *)

type line = float * float * float [@@deriving sexp]
(** A line in 2D space.
  * the line ax + by + c = 0 *)

let point_to_line_squared ({ x; y } : point) ((a, b, c) : line) : float =
  let numerator = (a *. x) +. (b *. y) +. c in
  let denominator = (a *. a) +. (b *. b) in
  numerator *. numerator /. denominator

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
  res

(** Returns a function that computes whether a point is within a given distance of a line segment.
  * 
  * WARNING: This method has inaccurate behaviour around the endpoints of the line
  * segments, due to efficiency. When all the given points are assumed to be at
  * least distance `distance` away from the endpoints, the behaviour is correct. *)
let within_distance (distance : float) ((p1, p2) : segment) =
  let rotator = point_rotator (-.angle_of p1 p2) in
  let delta : point = { x = -.p1.x; y = -.p1.y } in
  let transformer p = p |> translate delta |> rotator in
  let t_p2_x, _t_p2_y = transformer p2 in
  let f (p : point) =
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

(* TESTS *)

let to_point (x, y) : point = { x; y }

let%test_unit "angle_of" =
  let is (a : float) (b : float) = a < b +. 0.001 && a > b -. 0.001 in
  [%test_eq: bool] (angle_of { x = 0.; y = 0. } { x = 10.; y = 0. } |> is 0.) true;
  [%test_eq: bool] (angle_of { x = 0.; y = 0. } { x = 10.; y = 0. } |> is 0.) true;
  [%test_eq: bool] (angle_of { x = 0.; y = 0. } { x = 0.; y = 10. } |> is (pi / 2.)) true;
  [%test_eq: bool] (angle_of { x = 10.; y = 0. } { x = 0.; y = 0. } |> is pi) true;
  [%test_eq: bool] (angle_of { x = 0.; y = 10. } { x = 0.; y = 0. } |> is (-.pi / 2.)) true;
  ()

let test_rotations distance p1 p2 inside outside =
  for rot = 0 to 3 do
    let inside = List.map inside ~f:(hat_iter ~count:rot) in
    let outside = List.map outside ~f:(hat_iter ~count:rot) in
    let p1, p2 = (hat_iter ~count:rot p1, hat_iter ~count:rot p2) in
    List.iter inside ~f:(fun p -> [%test_eq: bool] (within_distance distance (p1, p2) p) true);
    List.iter outside ~f:(fun p -> [%test_eq: bool] (within_distance distance (p1, p2) p) false)
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
