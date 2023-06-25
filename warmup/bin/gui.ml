open Bogue
module W = Widget
module L = Layout

let () =
  let a = W.sdl_area ~w:640 ~h:480 () in
  let area = W.get_sdl_area a in
  let a_layout = L.resident a in
  let top_label = Widget.label "Drawing is below" in
  let bottom_label = Widget.label "Drawing is above" in
  Sdl_area.draw_circle area ~color:Draw.(opaque red) ~thick:10 ~radius:50 (100, 200);

  let connection =
    W.connect a a
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
  L.tower [ L.resident top_label; a_layout; L.resident bottom_label ]
  |> Bogue.of_layout ~connections:[ connection ]
  |> Bogue.run
