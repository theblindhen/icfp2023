open Bogue
module W = Widget
module L = Layout

(* initial model *)
let init () = (0, 0)

(* draw current model *)
let draw area (x, y) =
  Sdl_area.clear area;
  Sdl_area.draw_circle area ~color:Draw.(opaque blue) ~thick:4 ~radius:3 (x, y)

(* update model on mouse click *)
let mouse_clicked (mx, my) (_, _) =
  (mx, my)

(* update model on key press *)
let key_pressed scancode (x, y) = 
  match scancode with
  | 80 -> (x - 1, y) (* left *)
  | 79 -> (x + 1, y) (* right *)
  | 82 -> (x, y - 1) (* up *)
  | 81 -> (x, y + 1) (* down *)
  | _  -> (x, y)


let () =
  let a = W.sdl_area ~w:640 ~h:480 () in
  let area = W.get_sdl_area a in
  let a_layout = L.resident a in
  let model = ref (init ()) in
  draw area !model;

  let mouse_con =
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
        model := mouse_clicked (x, y) !model;
        draw area !model)
      Trigger.buttons_down
  in
  let key_con =
    W.connect a a 
      (fun _ _ event -> 
        let keycode = Tsdl.Sdl.Event.get event Tsdl.Sdl.Event.keyboard_scancode in
        Printf.eprintf "key pressed: %d\n%!" keycode;
        model := key_pressed keycode !model; 
        draw area !model) 
      [ Trigger.key_down ]
  in
  L.tower [ a_layout ]
  |> Bogue.of_layout ~connections:[ mouse_con; key_con ]
  |> Bogue.run
