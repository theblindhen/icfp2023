open Core
open Types

type musician_score = { mutable score : float; mutable musician : musician }
type musician_score_split = { mutable position_idx : int; instrument : int }

let scores_of_musicians (env : Score.scoring_env) : musician_score array =
  Array.map env.solution ~f:(fun m -> { score = Score.score_musician env m; musician = m })

let instrument_count (p : problem) : int =
  p.attendees |> List.hd_exn |> fun attendee -> Array.length attendee.tastes

let score_cache (env : Score.scoring_env) : (position * instrument, float) Hashtbl.Poly.t =
  printf "computing cache%!";
  let cache = Hashtbl.Poly.create () in
  let instrument_count = instrument_count env.problem in
  Array.iter env.solution ~f:(fun m ->
      let constants =
        List.map env.problem.attendees ~f:(fun a -> (Score.score_I_partial env a m.id m.pos, a))
      in
      printf ".%!";
      for i = 0 to instrument_count - 1 do
        let score =
          List.map constants ~f:(fun (c, a) -> Float.round_up (c *. a.tastes.(i)))
          |> List.sum (module Float) ~f:Fn.id
        in
        let capped_score = Float.max (10. *. score) 0.0 in
        Hashtbl.Poly.add_exn cache ~key:(m.pos, i) ~data:capped_score
      done);
  printf "\n%!";
  cache

let get_score cache scores pos_of_i instrument_of_j =
  Hashtbl.Poly.find_exn cache
    (scores.(pos_of_i).musician.pos, scores.(instrument_of_j).musician.instrument)

let swapper_without_q (p : problem) (s : solution) ~(round : int) : solution =
  ignore round;
  if p.problem_id > 55 then failwith "This function doesn't work for problems with q-factors";
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

let swapper_with_q (p : problem) (s : solution) ~(round : int) : solution =
  ignore round;
  if p.problem_id <= 55 then failwith "This function only works for problems with q-factors";
  (* Sort s by id so there's no confusion. *)
  let s = Array.sorted_copy s ~compare:(fun a b -> Int.compare a.id b.id) in
  (* We introduce the concept of a _musician id_, which refers to the index into
   * `s` (aka the `id` field of items in `s`). *)
  (* A _position index_ is also an index into `s`, denoting the `pos` found
   * there. *)
  let env = Score.get_scoring_env p s in
  let cache = score_cache env in
  (* Indexed by _musician_ id *)
  let scores = Array.mapi s ~f:(fun i m -> { position_idx = i; instrument = m.instrument }) in
  (* Lookup table of _position_ index pairs to q fractions (if these positions
   * should have the same musician on them). *)
  let q_term_map =
    Array.mapi s ~f:(fun i m ->
        Array.mapi s ~f:(fun i' m' -> if i = i' then 0.0 else 1. /. Geometry.distance m.pos m'.pos))
  in
  (* For each _musician_ index, list the _musician_ indexes of other musicians
   * with the same instrument. *)
  let other_musicians = Array.create ~len:(Array.length s) [] in
  Array.to_list s
  |> List.sort_and_group ~compare:(fun a b -> Int.compare a.instrument b.instrument)
  |> List.iter ~f:(fun l ->
         List.iter l ~f:(fun m ->
             other_musicians.(m.id) <-
               List.filter_map l ~f:(fun m' -> if m'.id <> m.id then Some m'.id else None)));
  (* Gets the hypothetical contribution of all musicials with the same
   * instrument as musician i if i were located at the current position of musician
   * j. *)
  let get_score i j =
    let pos_idx = scores.(j).position_idx in
    let instrument = scores.(i).instrument in
    let get_fake_pos_idx i' = if i' = i then pos_idx else scores.(i').position_idx in
    let musicians_with_instrument = i :: other_musicians.(i) in
    List.sum
      (module Float)
      musicians_with_instrument
      ~f:(fun i ->
        (* shadowing i *)
        let audience_contribution =
          Hashtbl.Poly.find_exn cache (s.(get_fake_pos_idx i).pos, instrument)
        in
        let q_factor =
          1.
          +. List.sum
               (module Float)
               other_musicians.(i)
               ~f:(fun i' -> q_term_map.(get_fake_pos_idx i).(get_fake_pos_idx i'))
        in
        q_factor *. audience_contribution)
  in
  let iter = ref true in
  while !iter do
    iter := false;
    for i = 0 to Array.length scores - 1 do
      for j = i + 1 to Array.length scores - 1 do
        if scores.(i).instrument <> scores.(j).instrument then
          let score_i = get_score i i in
          let score_j = get_score j j in
          let score_i' = get_score i j in
          let score_j' = get_score j i in
          if Float.(score_i' + score_j' > score_i + score_j) then (
            printf "swapping %d and %d\n%!" i j;
            iter := true;
            let tmp = scores.(i).position_idx in
            scores.(i).position_idx <- scores.(j).position_idx;
            scores.(j).position_idx <- tmp)
      done
    done
  done;
  Array.map s ~f:(fun m -> { m with pos = s.(scores.(m.id).position_idx).pos })

let swapper (p : problem) (s : solution) ~(round : int) : solution =
  (if p.problem_id <= 55 then swapper_without_q else swapper_with_q) p s ~round
