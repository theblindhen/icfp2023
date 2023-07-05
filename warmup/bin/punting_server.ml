open Core
open Opium

let title_handler _ =
  Lwt.return
    (Response.of_json ~status:`OK
       (`Assoc [ ("title", `String "Hello World") ])
       ~headers:(Headers.of_list [ ("Access-Control-Allow-Origin", "*") ]))

let start_handler _ =
  Lwt.return
    (Response.of_json ~status:`OK
       (`Assoc [ ("game_id", `String "Hello World") ])
       ~headers:(Headers.of_list [ ("Access-Control-Allow-Origin", "*") ]))

let _ =
  App.empty |> App.post "/title" title_handler |> App.post "/start" start_handler |> App.run_command
