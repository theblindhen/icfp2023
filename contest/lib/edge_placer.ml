open Types
open Misc
open Core

let grid_size (p : problem) : int * int =
  let w, h = (p.stage_width, p.stage_height) in
  if Float.(w < 20.0) || Float.(h < 20.0) then (0, 0)
  else ((w -. 10.0) /. 10.0 |> int_of_float, (h -. 10.0) /. 10.0 |> int_of_float)

let place_row (x_start : float) (x_no : int) (y : float) : position list =
  List.range 0 (x_no - 1) |> List.map ~f:(fun i -> { x = x_start +. (float_of_int i *. 10.0); y })

let place_col (x : float) (y_start : float) (y_no : int) : position list =
  List.range 0 (y_no - 1) |> List.map ~f:(fun i -> { x; y = y_start +. (float_of_int i *. 10.0) })

(* Place a grid of points *)
let place_grid (x_start : float) (y_start : float) (x_no : int) (y_no : int) (max_placed : int) :
    position list =
  let _remaining_placed, placed =
    List.fold
      (List.range 0 (y_no - 1))
      ~init:(max_placed, [])
      ~f:(fun (remaining_placed, placed) i ->
        if remaining_placed = 0 then (0, placed)
        else
          let row = place_row x_start x_no (y_start +. (float_of_int i *. 10.0)) in
          (remaining_placed - List.length row, placed @ row))
  in
  placed

type edge = North | South | East | West [@@deriving sexp]
type edges = edge list [@@deriving sexp]

let place_edge (p : problem) (already_placed : position list) (e : edge) : position list =
  let w, h = grid_size p in
  let max_musicians = (p.musicians |> List.length) - (already_placed |> List.length) in
  let new_pos =
    match e with
    | North ->
        printf "Placing north edge\n";
        place_row (p.stage_bottom_left.x +. 10.0) (min w max_musicians)
          (p.stage_bottom_left.y +. p.stage_height -. 10.0)
    | South ->
        printf "Placing south edge\n";
        place_row (p.stage_bottom_left.x +. 10.0) (min w max_musicians)
          (p.stage_bottom_left.y +. 10.0)
    | East ->
        printf "Placing east edge\n";
        place_col
          (p.stage_bottom_left.x +. p.stage_width -. 10.0)
          (p.stage_bottom_left.y +. 10.0) (min h max_musicians)
    | West ->
        printf "Placing west edge\n";
        place_col (p.stage_bottom_left.x +. 10.0) (p.stage_bottom_left.y +. 10.0)
          (min h max_musicians)
  in
  (* Remove elements already in already_placed *)
  let already_placed_set = already_placed |> Set.Poly.of_list in
  let new_pos = List.filter new_pos ~f:(fun p -> not (Set.mem already_placed_set p)) in
  printf "\t%d new positions\n" (List.length new_pos);
  new_pos

let place_edges (p : problem) (edges : edges) : position list =
  List.fold edges ~init:[] ~f:(fun acc e -> acc @ place_edge p acc e)

(* CURVY TIME! *)
let epsilon = 0.00001
let curvy_angle = 0.25 *. Float.pi
let curvy_offset = (10.0 *. Float.sin curvy_angle) +. epsilon

let curvy_grid_size (p : problem) : int * int =
  let w, h = (p.stage_width, p.stage_height) in
  if Float.(w < 20.0 + curvy_offset) || Float.(h < 20.0 + curvy_offset) then (0, 0)
  else
    ( 1.0 +. ((w -. 20.0) /. curvy_offset) |> int_of_float,
      1.0 +. ((h -. 20.0) /. curvy_offset) |> int_of_float )

let place_curvy_row (x_start : float) (x_no : int) (y : float) (align : edge) : position list =
  let y_offset =
    match align with
    | North -> curvy_offset *. -1.
    | South -> curvy_offset
    | _ -> failwith "Can only align North or South"
  in
  List.range ~stop:`inclusive 0 (x_no - 1)
  |> List.map ~f:(fun i ->
         {
           x = x_start +. (float_of_int i *. curvy_offset);
           y = y +. (float_of_int (i % 2) *. y_offset);
         })

let place_curvy_col (x : float) (y_start : float) (y_no : int) (align : edge) : position list =
  let x_offset =
    match align with
    | East -> curvy_offset *. -1.
    | West -> curvy_offset
    | _ -> failwith "Can only align East or West"
  in
  List.range ~stop:`inclusive 0 (y_no - 1)
  |> List.map ~f:(fun i ->
         {
           x = x +. (float_of_int (i % 2) *. x_offset);
           y = y_start +. (float_of_int i *. curvy_offset);
         })

let place_curvy_edge (p : problem) (already_placed : position list) (e : edge) : position list =
  let w, h = curvy_grid_size p in
  let max_musicians = (p.musicians |> List.length) - (already_placed |> List.length) in
  let new_pos =
    match e with
    | North ->
        printf "Placing north curvy edge\n";
        place_curvy_row (p.stage_bottom_left.x +. 10.0) (min w max_musicians)
          (p.stage_bottom_left.y +. p.stage_height -. 10.0)
          North
    | South ->
        printf "Placing south curvy edge\n";
        place_curvy_row (p.stage_bottom_left.x +. 10.0) (min w max_musicians)
          (p.stage_bottom_left.y +. 10.0) South
    | East ->
        printf "Placing east curvy edge\n";
        place_curvy_col
          (p.stage_bottom_left.x +. p.stage_width -. 10.0)
          (p.stage_bottom_left.y +. 10.0) (min h max_musicians) East
    | West ->
        printf "Placing west curvy edge\n";
        place_curvy_col (p.stage_bottom_left.x +. 10.0) (p.stage_bottom_left.y +. 10.0)
          (min h max_musicians) West
  in
  (* Remove elements already in already_placed *)
  Printf.printf "\t%d already placed,  %d new positions\n" (List.length already_placed)
    (List.length new_pos);
  let new_pos =
    List.filter new_pos ~f:(fun pos -> Random_solver.is_valid_placement p already_placed pos)
  in
  Printf.printf "\t%d new positions\n" (List.length new_pos);
  new_pos

let place_curvy_edges (p : problem) (edges : edges) : position list =
  List.fold edges ~init:[] ~f:(fun acc e -> acc @ place_curvy_edge p acc e)
