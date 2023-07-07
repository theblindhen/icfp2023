open Core
open Contest.Json_j
open Bogue
module W = Widget
module L = Layout

let get_problem problem_id =
  let json = In_channel.read_all ("../problems/problem-" ^ problem_id ^ ".json") in
  json_problem_of_string json

let () =
  let problem = get_problem "10" in
  (* Determine a scale factor to ensure that the max dimension of the room is
     exactly 1000. *)
  let scale = 1000. /. Float.max problem.problem_room_width problem.problem_room_height in
  let room_width = Float.to_int (scale *. problem.problem_room_width) in
  let room_height = Float.to_int (scale *. problem.problem_room_height) in
  let stage_xy =
    Tuple2.map ~f:(fun coord -> Float.to_int (scale *. coord)) problem.problem_stage_bottom_left
  in
  let stage_width = Float.to_int (scale *. problem.problem_stage_width) in
  let stage_height = Float.to_int (scale *. problem.problem_stage_height) in

  let a_widget = W.sdl_area ~w:room_width ~h:room_height () in
  let area = W.get_sdl_area a_widget in
  let a_layout = L.resident a_widget in
  Sdl_area.draw_rectangle area
    ~color:Draw.(opaque black)
    ~thick:1 ~w:room_width ~h:room_height (0, 0);
  Sdl_area.draw_rectangle area
    ~color:Draw.(opaque red)
    ~thick:1 ~w:stage_width ~h:stage_height stage_xy;
  List.iter problem.problem_attendees ~f:(fun attendee ->
      let x = Float.to_int (scale *. attendee.attendee_x) in
      let y = Float.to_int (scale *. attendee.attendee_y) in
      Sdl_area.draw_circle area ~color:Draw.(opaque green) ~thick:3 ~radius:2 (x, y));

  let connection =
    W.connect a_widget a_widget
      (fun _ _ event ->
        let x, y = Mouse.button_pos event in
        Printf.eprintf "clicked at %d, %d\n%!" x y;
        let ax, ay = (L.xpos a_layout, L.ypos a_layout) in
        Printf.eprintf " offset by %d, %d\n%!" ax ay;
        let x, y = (x - ax, y - ay) in
        Printf.eprintf " really at %d, %d\n%!" x y;
        let x, y = Sdl_area.to_pixels (x, y) in
        Printf.eprintf " really at %d, %d\n%!" x y;
        Sdl_area.draw_circle area ~color:Draw.(opaque blue) ~thick:4 ~radius:3 (x, y))
      Trigger.buttons_down
  in
  L.tower [ a_layout ] |> Bogue.of_layout ~connections:[ connection ] |> Bogue.run
