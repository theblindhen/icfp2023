open Types

let distance (p1 : position) (p2 : position) : float =
  sqrt (((p1.x -. p2.x) ** 2.0) +. ((p1.y -. p2.y) ** 2.0))

let solution_of_positions (p : problem) (s : position list) : solution =
  List.combine p.musicians s
  |> List.mapi (fun i (instrument, pos) -> { id = i; pos; instrument })
  |> Array.of_list
