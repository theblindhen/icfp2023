open Core
open Warmup

let rec try_until ~difficulty ~seed =
  let h = Icfpennies.hash_block ~seed in
  let score = Icfpennies.count_zero_nybbles h in
  if score >= difficulty then (h, seed) else try_until ~difficulty ~seed:(seed + 1)

let () =
  let difficulty = 5 in
  (* At seed 1,582,887, we find a hash with difficulty 5. The search takes 32
     seconds on Jonas's laptop. *)
  (* TODO: make this code parallel and run benchmarks. *)
  let h, seed = try_until ~difficulty ~seed:0 in
  Printf.printf "%2d %s\n%!" seed h
