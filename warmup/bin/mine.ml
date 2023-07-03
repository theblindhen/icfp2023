open Core
open Domainslib
open Warmup

let rec try_until ~difficulty ~seed =
  let h = Icfpennies.hash_block ~seed in
  let score = Icfpennies.count_zero_nybbles h in
  if score >= difficulty then (h, seed) else try_until ~difficulty ~seed:(seed + 1)

let () =
  let threads =
    match Sys.get_argv () with
    | [| _; threads |] -> Int.of_string threads
    | _ ->
        eprintf "Using one thread. Give integer on on command line for more.\n%!";
        1
  in
  let difficulty = 5 in
  (* At seed 1,582,887, we find a hash with difficulty 5. The search takes 32
     seconds on Jonas's laptop. *)
  let h, seed =
    match threads <= 1 with
    | true -> try_until ~difficulty ~seed:0
    | false ->
        let i_found_it = Chan.make_bounded threads in
        let stop_searching = Chan.make_bounded threads in
        let rec search ~seed ~iterations =
          let h = Icfpennies.hash_block ~seed in
          let score = Icfpennies.count_zero_nybbles h in
          if score >= difficulty then Chan.send i_found_it (h, seed)
          else if iterations mod 1_000 = 0 then
            match Chan.recv_poll stop_searching with
            | None -> search ~seed:(seed + threads) ~iterations:(iterations + 1)
            | Some () -> eprintf ".%!"
          else search ~seed:(seed + threads) ~iterations:(iterations + 1)
        in
        eprintf "Creating domains\n%!";
        let domains =
          Array.init threads ~f:(fun i -> Domain.spawn (fun () -> search ~seed:i ~iterations:0))
        in
        eprintf "Waiting for result\n%!";
        let result = Chan.recv i_found_it in
        eprintf "Sending stop signal to threads\n%!";
        for _ = 1 to threads - 1 do
          Chan.send stop_searching ()
        done;
        Array.iter domains ~f:Domain.join;
        eprintf "\n%!";
        eprintf "Threads stopped\n%!";
        result
  in
  Printf.printf "%2d %s\n%!" seed h
