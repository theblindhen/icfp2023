open Core
open Opium
open Warmup.Punting_j

let title_handler _ =
  let response = { title_title = "Hello World" } in
  Lwt.return
    (Response.of_plain_text ~status:`OK (string_of_title_msg response)
       ~headers:(Headers.of_list [ ("Access-Control-Allow-Origin", "*") ]))

let start_handler _ =
  let response = { start_game_id = 123 } in
  Lwt.return
    (Response.of_plain_text ~status:`OK (string_of_start_msg response)
       ~headers:(Headers.of_list [ ("Access-Control-Allow-Origin", "*") ]))

let deep_handler request =
  let deep = Request.to_plain_text request |> Lwt.map deep_msg_of_string in
  (* print out deep *)
  deep |> Lwt.map (fun a -> print_endline (string_of_deep_msg a)) |> ignore;
  Lwt.return (Response.of_plain_text ~status:`OK "OK")

let _ =
  App.empty
  |> App.post "/title" title_handler
  |> App.post "/start" start_handler
  |> App.post "/deep" deep_handler
  |> App.run_command
