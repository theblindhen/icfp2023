open Core
open Bogue
open Contest
module W = Widget
module L = Layout

let get_problem problem_id =
  match In_channel.read_all ("../problems/problem-" ^ problem_id ^ ".json") with
  | json -> Some (Types.problem_of_json_problem (Json_j.json_problem_of_string json))
  | exception _ -> None

let () =
  let problem_widget =
    W.text_input ~text:"" ~prompt:"Problem number" ~filter:Text_input.uint_filter ()
  in
  let problem_text_input = W.get_text_input problem_widget in
  let a_widget = W.sdl_area ~w:1000 ~h:1000 () in
  let area = W.get_sdl_area a_widget in

  let draw_problem id =
    eprintf "Drawing problem %s\n%!" id;
    match get_problem id with
    | None -> ()
    | Some problem ->
        Sdl_area.clear area;
        (* Determine a scale factor to ensure that the max dimension of the room is
           exactly 1000. *)
        let scale = 1000. /. Float.max problem.room_width problem.room_height in
        let room_width = Float.to_int (scale *. problem.room_width) in
        let room_height = Float.to_int (scale *. problem.room_height) in
        let stage_x = Float.to_int (scale *. problem.stage_bottom_left.x) in
        let stage_y = Float.to_int (scale *. problem.stage_bottom_left.y) in
        let stage_width = Float.to_int (scale *. problem.stage_width) in
        let stage_height = Float.to_int (scale *. problem.stage_height) in

        Sdl_area.draw_rectangle area
          ~color:Draw.(opaque black)
          ~thick:1 ~w:room_width ~h:room_height (0, 0);
        Sdl_area.draw_rectangle area
          ~color:Draw.(opaque red)
          ~thick:1 ~w:stage_width ~h:stage_height (stage_x, stage_y);
        List.iter problem.attendees ~f:(fun attendee ->
            let x = Float.to_int (scale *. attendee.pos.x) in
            let y = Float.to_int (scale *. attendee.pos.y) in
            Sdl_area.draw_circle area ~color:Draw.(opaque blue) ~thick:3 ~radius:2 (x, y))
  in

  let connections =
    [
      W.connect_main problem_widget problem_widget
        (fun _ _ _ -> draw_problem (Text_input.text problem_text_input))
        [ Trigger.text_input ];
    ]
  in
  let a_layout = L.resident a_widget in
  L.tower [ L.resident problem_widget; a_layout ] |> Bogue.of_layout ~connections |> Bogue.run
