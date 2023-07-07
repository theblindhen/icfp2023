open Types

let distance (p1 : position) (p2 : position) : float =
  sqrt (((p1.x -. p2.x) ** 2.0) +. ((p1.y -. p2.y) ** 2.0))

let musicians_of_solution (p : problem) (s : solution) : musician list =
  List.combine p.musicians s |> List.map (fun (instrument, pos) -> { pos; instrument })
