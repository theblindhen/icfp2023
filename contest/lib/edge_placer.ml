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

type edge = North | South [@@deriving sexp]
type edges = edge list [@@deriving sexp]

let place_edge (p : problem) (already_placed : position list) (e : edge) : position list =
  let w, _ = grid_size p in
  let max_musicians = (p.musicians |> List.length) - (already_placed |> List.length) in
  match e with
  | North ->
      place_row (p.stage_bottom_left.x +. 10.0) (min w max_musicians)
        (p.stage_bottom_left.y +. p.stage_height -. 10.0)
  | South ->
      place_row (p.stage_bottom_left.x +. 10.0) (min w max_musicians) (p.stage_bottom_left.y +. 10.0)

let place_edges (p : problem) (edges : edges) : position list =
  List.fold edges ~init:[] ~f:(fun acc e -> acc @ place_edge p acc e)
