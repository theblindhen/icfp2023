open Core

(** Sample for the function that is zero outside [-1; 1], and goes linearly to 1
    at 0.
 *)
let poor_mans_gaussian () : float =
  let open Float in
  let open Random in
  let width_dice = Random.float 1. in
  let sample_width =
    let x = 1. /. (width_dice *. width_dice) in
    Float.exp (Float.min x 10.) /. 3.
  in
  let sample = Random.float 1. in
  (sample -. 0.5) *. sample_width

let sample_min_abs sampler min_abs =
  let sample = sampler () in
  Float.(if sample < 0. then sample -. min_abs else sample +. min_abs)
