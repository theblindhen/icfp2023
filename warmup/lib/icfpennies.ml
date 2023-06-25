open Core
(** This file manages computations for something that works a bit like a
 * cryptocurrency. Let's call them ICFPennies. *)

(** A block is a record containing a seed and a hash. *)

let rec sillyhash ~rounds s =
  match rounds with
  | 0 -> s
  | _ -> sillyhash ~rounds:(rounds - 1) (Md5.digest_string s |> Md5.to_hex)

let hash_block ~(seed : int) =
  let s = string_of_int seed ^ "ICFP!!!11" in
  let h = sillyhash ~rounds:1000 s in
  h

let%test_unit "seed1" =
  let message = hash_block ~seed:1 in
  [%test_eq: string] message "a355a66b178e713bab17cc0a660adf57"
