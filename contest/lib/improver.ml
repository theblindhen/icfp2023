open Core
open Types

type musician_score = { mutable score : float; mutable musician : musician }

let scores_of_musicians (env : Score.scoring_env) : musician_score array =
  Array.map env.solution ~f:(fun m -> { score = Score.score_musician env m; musician = m })

let instrument_count (p : problem) : int =
  p.attendees |> List.hd_exn |> fun attendee -> Array.length attendee.tastes

let score_cache (env : Score.scoring_env) : (position * instrument, float) Hashtbl.Poly.t =
  let cache = Hashtbl.Poly.create () in
  let instrument_count = instrument_count env.problem in
  Array.iteri env.solution ~f:(fun i m ->
      let constants =
        List.map env.problem.attendees ~f:(fun a -> (Score.score_I_partial env a m.id m.pos, a))
      in
      printf "computing cache for %dnth position\n%!" i;
      for i = 0 to instrument_count - 1 do
        let score =
          List.map constants ~f:(fun (c, a) -> Float.round_up (c *. a.tastes.(i)))
          |> List.sum (module Float) ~f:Fn.id
        in
        Hashtbl.Poly.add_exn cache ~key:(m.pos, i) ~data:score
      done);
  cache

let get_score cache scores pos_of_i instrument_of_j =
  Hashtbl.Poly.find_exn cache
    (scores.(pos_of_i).musician.pos, scores.(instrument_of_j).musician.instrument)

let improve (p : problem) (s : solution) : solution =
  (* TODO The env is assumed constant during the swaps, but this violates the qfactor
     computations.
  *)
  if p.problem_id > 55 then failwith "Swap improver doesn't (yet) work for problems with q-factors";
  let env = Score.get_scoring_env p s in
  let cache = score_cache env in
  let scores = scores_of_musicians env in
  let iter = ref true in
  while !iter do
    iter := false;
    for i = 0 to Array.length scores - 1 do
      for j = i + 1 to Array.length scores - 1 do
        let score_i = get_score cache scores i i in
        let score_j = get_score cache scores j j in
        let score_i' = get_score cache scores i j in
        let score_j' = get_score cache scores j i in
        if Float.(score_i' + score_j' > score_i + score_j) then (
          printf "swapping %d and %d\n%!" i j;
          iter := true;
          let musician_i = scores.(i).musician in
          let musician_j = scores.(j).musician in
          scores.(i) <- { score = score_i'; musician = { musician_j with pos = musician_i.pos } };
          scores.(j) <- { score = score_j'; musician = { musician_i with pos = musician_j.pos } })
      done
    done
  done;
  printf "Score should be: %f\n%!" (Array.sum (module Float) scores ~f:(fun s -> s.score));
  Array.map scores ~f:(fun s -> s.musician)
