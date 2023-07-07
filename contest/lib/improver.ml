open Types
open Score

type musician_score = { mutable score : float; mutable musician : musician }

let scores_of_musicians (p : problem) (s : solution) : musician_score array =
  Array.map (fun m -> { score = score_musician p s m; musician = m }) s

let improve (p : problem) (s : solution) : solution =
  let scores = scores_of_musicians p s in
  for i = 0 to Array.length scores - 1 do
    Core.printf "%d\n" i;
    Core.flush_all ();
    for j = i + 1 to Array.length scores - 1 do
      let musician_i = scores.(i).musician in
      let musician_j = scores.(j).musician in
      let musician_i' = { musician_i with pos = musician_j.pos } in
      let musician_j' = { musician_j with pos = musician_i.pos } in
      let solution = Array.map (fun s -> s.musician) scores in
      solution.(i) <- musician_i';
      solution.(j) <- musician_j';
      let score_i' = score_musician p solution musician_i' in
      let score_j' = score_musician p solution musician_j' in
      if score_i' +. score_j' > scores.(i).score +. scores.(j).score then (
        scores.(i) <- { score = score_i'; musician = musician_i' };
        scores.(j) <- { score = score_j'; musician = musician_j' })
    done
  done;
  scores |> Array.map (fun s -> s.musician)
