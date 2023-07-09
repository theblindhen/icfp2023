open Core
open Bogue
open Contest
module W = Widget
module L = Layout

let draw_concert (area : Sdl_area.t) (problem : Types.problem) (solution : Types.solution option)
    (selected_instrument : int option) =
  (* Determine a scale factor to ensure that the max dimension of the room is
   * exactly 1000. *)
  let scale = 1000. /. Float.max problem.room_width problem.room_height in
  (* The tr function translates problem sizes to screen sizes *)
  let tr length = Float.to_int (scale *. length) in
  (* The xy function translates problem coordinates to screen coordinates *)
  let xy (x, y) = (Float.to_int (scale *. x), 1000 - Float.to_int (scale *. y)) in

  let room_width, room_height = (tr problem.room_width, tr problem.room_height) in
  let stage_left, stage_top =
    xy (problem.stage_bottom_left.x, problem.stage_bottom_left.y +. problem.stage_height)
  in
  let stage_width, stage_height = (tr problem.stage_width, tr problem.stage_height) in

  (* Draw the room *)
  Sdl_area.draw_rectangle area
    ~color:Draw.(opaque black)
    ~thick:1 ~w:room_width ~h:room_height
    (0, 1000 - room_height);
  Sdl_area.draw_rectangle area
    ~color:Draw.(opaque red)
    ~thick:1 ~w:stage_width ~h:stage_height (stage_left, stage_top);
  List.iter problem.attendees ~f:(fun attendee ->
      let attendee_pos = xy (attendee.pos.x, attendee.pos.y) in
      let color =
        match selected_instrument with
        | None -> Draw.(opaque blue)
        | Some instrument ->
            if instrument >= 0 && instrument < Array.length attendee.tastes then
              if Float.is_positive attendee.tastes.(instrument) then Draw.(darker (opaque green))
              else Draw.(opaque red)
            else Draw.(opaque grey)
      in
      Sdl_area.draw_circle area ~color ~thick:2 ~radius:1 attendee_pos);

  (* Draw the solution if it's there. *)
  match solution with
  | None -> ()
  | Some solution ->
      let radius = tr 5.0 in
      Array.iter solution ~f:(fun musician ->
          let musician_pos = xy (musician.pos.x, musician.pos.y) in
          let color =
            match selected_instrument with
            | None -> Draw.(opaque blue)
            | Some instrument ->
                if instrument = musician.instrument then Draw.(darker (opaque green))
                else Draw.(opaque red)
          in
          Sdl_area.draw_circle area ~radius ~thick:1 ~color musician_pos)

let () =
  let problem_widget =
    W.text_input ~text:"" ~prompt:"Problem number" ~filter:Text_input.uint_filter ()
  in
  let problem_text_input = W.get_text_input problem_widget in
  let a_widget = W.sdl_area ~w:1000 ~h:1000 () in
  let area = W.get_sdl_area a_widget in

  (* GUI model *)

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
    | Some problem ->
        cur_solution :=
          Some
            (Improver.improve problem ~round:0
               (Random_solver.random_placement_solution problem
                  (Edge_placer.place_edges problem [ South; East ])))
  in

  let solve_button =
    W.button
      ~action:(fun _ ->
        random_solve ();
        redraw ())
      "Random solve"
  in

  let score_and_save () =
    match (!cur_problem, !cur_solution) with
    | Some problem, Some solution -> (
        match Misc.validate_solution problem solution with
        | exception _ -> eprintf "Error validating solution\n%!"
        | () ->
            eprintf "Scoring solution\n%!";
            let score = Score.score_solution problem solution in
            Json_util.write_solution_if_best score problem solution)
    | _, _ -> eprintf "No solution to score\n%!"
  in

  let score_button = W.button ~action:(fun _ -> score_and_save ()) "Score and save" in

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
      L.flat_of_w [ problem_widget; solve_button; score_button ];
      L.flat_of_w [ instrument_widget; instrument_prev; instrument_next; instrument_clear ];
      a_layout;
    ]
  |> Bogue.of_layout ~connections
  |> Bogue.run
