open Core
open Bogue
open Contest
module W = Widget
module L = Layout

let draw_concert (area : Sdl_area.t) (problem : Types.problem) (solution : Types.solution option)
    (selected_instrument : int option) =
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
      let color =
        match selected_instrument with
        | None -> Draw.(opaque blue)
        | Some instrument ->
            if instrument >= 0 && instrument < Array.length attendee.tastes then
              if Float.is_positive attendee.tastes.(instrument) then Draw.(darker (opaque green))
              else Draw.(opaque red)
            else Draw.(opaque grey)
      in
      Sdl_area.draw_circle area ~color ~thick:2 ~radius:1 (x, y));

  (* Draw the solution if it's there. *)
  match solution with
  | None -> ()
  | Some solution ->
      let radius = Float.to_int (scale *. 5.0) in
      Array.iter solution ~f:(fun musician ->
          let x = Float.to_int (musician.pos.x *. scale) in
          let y = Float.to_int (musician.pos.y *. scale) in
          let color =
            match selected_instrument with
            | None -> Draw.(opaque blue)
            | Some instrument ->
                if instrument = musician.instrument then Draw.(darker (opaque green))
                else Draw.(opaque red)
          in
          Sdl_area.draw_circle area ~radius ~thick:1 ~color (x, y))

let () =
  let problem_widget =
    W.text_input ~text:"" ~prompt:"Problem number" ~filter:Text_input.uint_filter ()
  in
  let problem_text_input = W.get_text_input problem_widget in
  let a_widget = W.sdl_area ~w:1000 ~h:1000 () in
  let area = W.get_sdl_area a_widget in

  (* GUI model state *)
  let cur_instrument = ref None in
  let cur_problem = ref None in
  let cur_solution = ref None in

  let instrument_widget = W.text_display "No instrument" in
  let instrument_text_display = W.get_text_display instrument_widget in

  let redraw_instrument_display () =
    match !cur_instrument with
    | None -> Text_display.update_verbatim instrument_text_display "No instrument"
    | Some instrument ->
        Text_display.update_verbatim instrument_text_display (Int.to_string instrument)
  in

  let load_problem id =
    eprintf "Loading problem %s\n%!" id;
    let problem_id = Int.of_string id in
    match Json_util.get_problem problem_id with
    | None -> ()
    | Some problem ->
        cur_problem := Some problem;
        cur_solution := None
  in

  let redraw () =
    Sdl_area.clear area;
    match !cur_problem with
    | None -> ()
    | Some problem ->
        redraw_instrument_display ();
        draw_concert area problem !cur_solution !cur_instrument
  in

  let instrument_prev =
    W.button
      ~action:(fun _ ->
        (match !cur_instrument with
        | None -> cur_instrument := Some 0
        | Some instrument -> cur_instrument := Some (instrument - 1));
        redraw ())
      "Prev"
  in
  let instrument_next =
    W.button
      ~action:(fun _ ->
        (match !cur_instrument with
        | None -> cur_instrument := Some 0
        | Some instrument -> cur_instrument := Some (instrument + 1));
        redraw ())
      "Next"
  in
  let instrument_clear =
    W.button
      ~action:(fun _ ->
        cur_instrument := None;
        redraw ())
      "Clear"
  in

  let random_solve () =
    match !cur_problem with
    | None -> eprintf "No problem loaded\n%!"
    | Some problem -> cur_solution := Some (Random_solver.random_placement_solution problem)
  in

  let solve_button =
    W.button
      ~action:(fun _ ->
        random_solve ();
        redraw ())
      "Random solve"
  in

  let connections =
    [
      W.connect_main problem_widget problem_widget
        (fun _ _ _ ->
          load_problem (Text_input.text problem_text_input);
          redraw ())
        [ Trigger.text_input ];
    ]
  in
  let a_layout = L.resident a_widget in
  L.tower
    [
      L.flat_of_w [ problem_widget; solve_button ];
      L.flat_of_w [ instrument_widget; instrument_prev; instrument_next; instrument_clear ];
      a_layout;
    ]
  |> Bogue.of_layout ~connections
  |> Bogue.run
