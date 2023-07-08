open Core
open Opium

let read_file path = In_channel.create path |> In_channel.input_all |> String.strip

let index_handler _ =
  let index = read_file "../frontend/index.html" in
  Lwt.return
    (Response.make ~status:`OK ~body:(Body.of_string index) ()
       ~headers:(Headers.of_list [ ("Access-Control-Allow-Origin", "*") ]))

let js_handler _ =
  let index = read_file "../frontend/elm.js" in
  Lwt.return
    (Response.make ~status:`OK ~body:(Body.of_string index) ()
       ~headers:(Headers.of_list [ ("Access-Control-Allow-Origin", "*") ]))

let problem_handler req =
  let id = Router.param req "id" in
  let problem = In_channel.read_all (sprintf "../problems/problem-%s.json" id) in
  Lwt.return
    (Response.make ~status:`OK ~body:(Body.of_string problem) ()
       ~headers:(Headers.of_list [ ("Access-Control-Allow-Origin", "*") ]))

let _ =
  App.empty
  |> App.get "/" index_handler
  |> App.get "/elm.js" js_handler
  |> App.get "/problem/:id" problem_handler
  |> App.run_command
