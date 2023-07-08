open Core
open Types
open Geometry

type force = { x : float; y : float }

(* let force_I (p : problem) (a : attendee) (i : instrument) : float =
   let d_sq = p a in
   Float.round_up (1_000_000.0 *. a.tastes.(i) /. d_sq) *)
