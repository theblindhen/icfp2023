open Core

type t = { mutable acc : Time_ns.Span.t }

let create () = { acc = Time_ns.Span.zero }

let run_acc t f =
  let start = Time_ns.now () in
  let result = f () in
  let stop = Time_ns.now () in
  t.acc <- Time_ns.Span.(t.acc + Time_ns.diff stop start);
  result

let print_acc name t = printf "Computed %s in %s\n%!" name (Time_ns.Span.to_string_hum t.acc)

(** Run function f and print time *)
let run_print name f =
  let t = create () in
  let result = run_acc t f in
  print_acc name t;
  result
