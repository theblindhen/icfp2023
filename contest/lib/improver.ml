open Types
open Score

type musician_score = { mutable score : float; mutable musician : musician }

let scores_of_musicians (p : problem) (s : solution) : musician_score array =
  Array.map (fun m -> { score = score_musician p m; musician = m }) s

let score_swap (p : problem) (s : musician_score array) (i : int) (j : int) : musician_score array =
  let s' = Array.copy s in
  let tmp = s'.(i) in
  s'.(i) <- s'.(j);
  s'.(j) <- tmp;
  s'.(i).score <- score_musician p s'.(i).musician;
  s'.(j).score <- score_musician p s'.(j).musician;
  s'

let improve (p : problem) (s : solution) : solution =
  let scores = scores_of_musicians p s in
  for i = 0 to Array.length scores - 1 do
    for j = i + 1 to Array.length scores - 1 do
      let musician_i = scores.(i).musician in
      let musician_j = scores.(j).musician in
      let musician_i' = { musician_i with pos = musician_j.pos } in
      let musician_j' = { musician_j with pos = musician_i.pos } in
      let score_i' = score_musician p musician_i' in
      let score_j' = score_musician p musician_j' in
      if score_i' +. score_j' > scores.(i).score +. scores.(j).score then (
        scores.(i) <- { score = score_i'; musician = musician_i' };
        scores.(j) <- { score = score_j'; musician = musician_j' })
    done
  done;
  scores |> Array.map (fun s -> s.musician)
