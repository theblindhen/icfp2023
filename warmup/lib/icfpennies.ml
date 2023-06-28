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
  let h = sillyhash ~rounds:100 s in
  h

let count_zero_nybbles s =
  let rec loop i =
    if i >= String.length s then 0 else if Char.equal s.[i] '0' then 1 + loop (i + 1) else 0
  in
  loop 0

let%test_unit "seed1" =
  let message = hash_block ~seed:1 in
  [%test_eq: string] message "b87eeaf1937868b34e44616698a16bdd"

let%test_unit "count_zero_nybbles" =
  [%test_eq: int] (count_zero_nybbles "") 0;
  [%test_eq: int] (count_zero_nybbles "111") 0;
  [%test_eq: int] (count_zero_nybbles "0111") 1;
  [%test_eq: int] (count_zero_nybbles "00AAA") 2;
  [%test_eq: int] (count_zero_nybbles "00") 2
