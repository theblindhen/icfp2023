open Core

type position = { x : float; y : float } [@@deriving compare, sexp]
type attendee = { pos : position; tastes : float array } [@@deriving compare, sexp]

type problem = {
  room_width : float;
  room_height : float;
  stage_width : float;
  stage_height : float;
  stage_bottom_left : position;
  musicians : int list;
  attendees : attendee list;
}
[@@deriving sexp]

let position_from_json_tuple (x, y) = { x; y }

let problem_of_json_problem (json_problem : Json_j.json_problem) =
  {
    room_width = json_problem.room_width;
    room_height = json_problem.room_height;
    stage_width = json_problem.stage_width;
    stage_height = json_problem.stage_height;
    stage_bottom_left = position_from_json_tuple json_problem.stage_bottom_left;
    musicians = json_problem.musicians;
    attendees =
      json_problem.attendees
      |> List.map ~f:(fun (json_attendee : Json_j.json_attendee) ->
             {
               pos = { x = json_attendee.x; y = json_attendee.y };
               tastes = Array.of_list json_attendee.tastes;
             });
  }

type instrument = int [@@deriving sexp]
type musician = { id : int; pos : position; instrument : instrument } [@@deriving sexp]
type solution = musician array [@@deriving sexp]

let validate_solution (p : problem) (s : solution) =
  let musician_ids = Array.map s ~f:(fun m -> m.id) in
  (* Musician 0 is the first used *)
  let min_musician = Array.min_elt musician_ids ~compare:Int.compare |> Option.value_exn in
  assert (min_musician = 0);
  (* Musician max is the number of musician *)
  let max_musician = Array.max_elt musician_ids ~compare:Int.compare |> Option.value_exn in
  assert (max_musician = Array.length musician_ids - 1);
  (* All musician ids are distinct *)
  assert (Array.length musician_ids = Array.length (Set.to_array (Int.Set.of_array musician_ids)));
  (* Musicians' instruments correspond to those in the problem *)
  List.iteri p.musicians ~f:(fun m_id inst ->
      match Array.find s ~f:(fun m' -> m'.id = m_id) with
      | None -> assert false
      | Some m' -> assert (m'.instrument = inst))
(* TODO: Musicians are within the stage, including stage margin *)
(* TODO: Musicians are appropriately spaced from each other *)

let json_solution_of_solution (solution : solution) : Json_j.json_solution =
  {
    placements =
      solution
      |> Array.to_list
      |> List.sort ~compare:(fun m1 m2 -> Poly.compare m1.id m2.id)
      |> List.map ~f:(fun { pos = { x; y }; id = _; instrument = _ } : Json_j.json_placement ->
             { x; y });
  }
