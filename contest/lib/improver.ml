open Core
open Types
open Score

type musician_score = { mutable score : float; mutable musician : musician }

let scores_of_musicians (p : problem) (s : solution) : musician_score array =
  Array.map s ~f:(fun m -> { score = score_musician p s m; musician = m })

let instrument_count (p : problem) : int =
  p.attendees |> List.hd_exn |> fun attendee -> Array.length attendee.tastes

let score_cache (p : problem) (s : solution) : (position * instrument, float) Hashtbl.Poly.t =
  let cache = Hashtbl.Poly.create () in
  let instrument_count = instrument_count p in
  Array.iteri s ~f:(fun i m ->
      printf "computing cache for %dnth position\n%!" i;
      for i = 0 to instrument_count - 1 do
        Hashtbl.Poly.add_exn cache ~key:(m.pos, i)
          ~data:(score_musician p s { m with instrument = i })
      done);
  cache

let get_score cache scores pos_of_i instrument_of_j =
  Hashtbl.Poly.find_exn cache
    (scores.(pos_of_i).musician.pos, scores.(instrument_of_j).musician.instrument)

let improve (p : problem) (s : solution) : solution =
  let cache = score_cache p s in
  let scores = scores_of_musicians p s in
  for i = 0 to Array.length scores - 1 do
    Core.printf "%d\n%!" i;
    for j = i + 1 to Array.length scores - 1 do
      let score_i = get_score cache scores i i in
      let score_j = get_score cache scores j j in
      let score_i' = get_score cache scores i j in
      let score_j' = get_score cache scores j i in
      if Float.(score_i' + score_j' > score_i + score_j) then (
        let musician_i = scores.(i).musician in
        let musician_j = scores.(j).musician in
        scores.(i) <- { score = score_i'; musician = { musician_j with pos = musician_i.pos } };
        scores.(j) <- { score = score_j'; musician = { musician_i with pos = musician_j.pos } })
    done
  done;
  printf "Score should be: %f\n%!" (Array.sum (module Float) scores ~f:(fun s -> s.score));
  Array.map scores ~f:(fun s -> s.musician)
