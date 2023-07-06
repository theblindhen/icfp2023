(* Auto-generated from "punting.atd" *)
[@@@ocaml.warning "-27-32-33-35-39"]

type title_msg = Punting_t.title_msg = { title_title (*atd title *) : string }
type start_msg = Punting_t.start_msg = { start_game_id (*atd game_id *) : int }
type deep_b = Punting_t.deep_b = { deep_c (*atd c *) : bool; deep_d (*atd d *) : int list }
type deep_msg = Punting_t.deep_msg = { deep_a (*atd a *) : int; deep_b (*atd b *) : deep_b }

let write_title_msg : _ -> title_msg -> _ =
 fun ob (x : title_msg) ->
  Buffer.add_char ob '{';
  let is_first = ref true in
  if !is_first then is_first := false else Buffer.add_char ob ',';
  Buffer.add_string ob "\"title\":";
  Yojson.Safe.write_string ob x.title_title;
  Buffer.add_char ob '}'

let string_of_title_msg ?(len = 1024) x =
  let ob = Buffer.create len in
  write_title_msg ob x;
  Buffer.contents ob

let read_title_msg p lb =
  Yojson.Safe.read_space p lb;
  Yojson.Safe.read_lcurl p lb;
  let field_title_title = ref None in
  try
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_object_end lb;
    Yojson.Safe.read_space p lb;
    let f s pos len =
      if pos < 0 || len < 0 || pos + len > String.length s then
        invalid_arg
          (Printf.sprintf
             "out-of-bounds substring position or length: string = %S, requested position = %i, \
              requested length = %i"
             s pos len);
      if
        len = 5
        && String.unsafe_get s pos = 't'
        && String.unsafe_get s (pos + 1) = 'i'
        && String.unsafe_get s (pos + 2) = 't'
        && String.unsafe_get s (pos + 3) = 'l'
        && String.unsafe_get s (pos + 4) = 'e'
      then 0
      else -1
    in
    let i = Yojson.Safe.map_ident p f lb in
    Atdgen_runtime.Oj_run.read_until_field_value p lb;
    (match i with
    | 0 -> field_title_title := Some (Atdgen_runtime.Oj_run.read_string p lb)
    | _ -> Yojson.Safe.skip_json p lb);
    while true do
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_sep p lb;
      Yojson.Safe.read_space p lb;
      let f s pos len =
        if pos < 0 || len < 0 || pos + len > String.length s then
          invalid_arg
            (Printf.sprintf
               "out-of-bounds substring position or length: string = %S, requested position = %i, \
                requested length = %i"
               s pos len);
        if
          len = 5
          && String.unsafe_get s pos = 't'
          && String.unsafe_get s (pos + 1) = 'i'
          && String.unsafe_get s (pos + 2) = 't'
          && String.unsafe_get s (pos + 3) = 'l'
          && String.unsafe_get s (pos + 4) = 'e'
        then 0
        else -1
      in
      let i = Yojson.Safe.map_ident p f lb in
      Atdgen_runtime.Oj_run.read_until_field_value p lb;
      match i with
      | 0 -> field_title_title := Some (Atdgen_runtime.Oj_run.read_string p lb)
      | _ -> Yojson.Safe.skip_json p lb
    done;
    assert false
  with
  | Yojson.End_of_object ->
      ({
         title_title =
           (match !field_title_title with
           | Some x -> x
           | None -> Atdgen_runtime.Oj_run.missing_field p "title_title");
       }
        : title_msg)

let title_msg_of_string s = read_title_msg (Yojson.Safe.init_lexer ()) (Lexing.from_string s)

let write_start_msg : _ -> start_msg -> _ =
 fun ob (x : start_msg) ->
  Buffer.add_char ob '{';
  let is_first = ref true in
  if !is_first then is_first := false else Buffer.add_char ob ',';
  Buffer.add_string ob "\"game_id\":";
  Yojson.Safe.write_int ob x.start_game_id;
  Buffer.add_char ob '}'

let string_of_start_msg ?(len = 1024) x =
  let ob = Buffer.create len in
  write_start_msg ob x;
  Buffer.contents ob

let read_start_msg p lb =
  Yojson.Safe.read_space p lb;
  Yojson.Safe.read_lcurl p lb;
  let field_start_game_id = ref None in
  try
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_object_end lb;
    Yojson.Safe.read_space p lb;
    let f s pos len =
      if pos < 0 || len < 0 || pos + len > String.length s then
        invalid_arg
          (Printf.sprintf
             "out-of-bounds substring position or length: string = %S, requested position = %i, \
              requested length = %i"
             s pos len);
      if
        len = 7
        && String.unsafe_get s pos = 'g'
        && String.unsafe_get s (pos + 1) = 'a'
        && String.unsafe_get s (pos + 2) = 'm'
        && String.unsafe_get s (pos + 3) = 'e'
        && String.unsafe_get s (pos + 4) = '_'
        && String.unsafe_get s (pos + 5) = 'i'
        && String.unsafe_get s (pos + 6) = 'd'
      then 0
      else -1
    in
    let i = Yojson.Safe.map_ident p f lb in
    Atdgen_runtime.Oj_run.read_until_field_value p lb;
    (match i with
    | 0 -> field_start_game_id := Some (Atdgen_runtime.Oj_run.read_int p lb)
    | _ -> Yojson.Safe.skip_json p lb);
    while true do
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_sep p lb;
      Yojson.Safe.read_space p lb;
      let f s pos len =
        if pos < 0 || len < 0 || pos + len > String.length s then
          invalid_arg
            (Printf.sprintf
               "out-of-bounds substring position or length: string = %S, requested position = %i, \
                requested length = %i"
               s pos len);
        if
          len = 7
          && String.unsafe_get s pos = 'g'
          && String.unsafe_get s (pos + 1) = 'a'
          && String.unsafe_get s (pos + 2) = 'm'
          && String.unsafe_get s (pos + 3) = 'e'
          && String.unsafe_get s (pos + 4) = '_'
          && String.unsafe_get s (pos + 5) = 'i'
          && String.unsafe_get s (pos + 6) = 'd'
        then 0
        else -1
      in
      let i = Yojson.Safe.map_ident p f lb in
      Atdgen_runtime.Oj_run.read_until_field_value p lb;
      match i with
      | 0 -> field_start_game_id := Some (Atdgen_runtime.Oj_run.read_int p lb)
      | _ -> Yojson.Safe.skip_json p lb
    done;
    assert false
  with
  | Yojson.End_of_object ->
      ({
         start_game_id =
           (match !field_start_game_id with
           | Some x -> x
           | None -> Atdgen_runtime.Oj_run.missing_field p "start_game_id");
       }
        : start_msg)

let start_msg_of_string s = read_start_msg (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write__int_list = Atdgen_runtime.Oj_run.write_list Yojson.Safe.write_int

let string_of__int_list ?(len = 1024) x =
  let ob = Buffer.create len in
  write__int_list ob x;
  Buffer.contents ob

let read__int_list = Atdgen_runtime.Oj_run.read_list Atdgen_runtime.Oj_run.read_int
let _int_list_of_string s = read__int_list (Yojson.Safe.init_lexer ()) (Lexing.from_string s)

let write_deep_b : _ -> deep_b -> _ =
 fun ob (x : deep_b) ->
  Buffer.add_char ob '{';
  let is_first = ref true in
  if !is_first then is_first := false else Buffer.add_char ob ',';
  Buffer.add_string ob "\"c\":";
  Yojson.Safe.write_bool ob x.deep_c;
  if !is_first then is_first := false else Buffer.add_char ob ',';
  Buffer.add_string ob "\"d\":";
  write__int_list ob x.deep_d;
  Buffer.add_char ob '}'

let string_of_deep_b ?(len = 1024) x =
  let ob = Buffer.create len in
  write_deep_b ob x;
  Buffer.contents ob

let read_deep_b p lb =
  Yojson.Safe.read_space p lb;
  Yojson.Safe.read_lcurl p lb;
  let field_deep_c = ref None in
  let field_deep_d = ref None in
  try
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_object_end lb;
    Yojson.Safe.read_space p lb;
    let f s pos len =
      if pos < 0 || len < 0 || pos + len > String.length s then
        invalid_arg
          (Printf.sprintf
             "out-of-bounds substring position or length: string = %S, requested position = %i, \
              requested length = %i"
             s pos len);
      if len = 1 then
        match String.unsafe_get s pos with
        | 'c' -> 0
        | 'd' -> 1
        | _ -> -1
      else -1
    in
    let i = Yojson.Safe.map_ident p f lb in
    Atdgen_runtime.Oj_run.read_until_field_value p lb;
    (match i with
    | 0 -> field_deep_c := Some (Atdgen_runtime.Oj_run.read_bool p lb)
    | 1 -> field_deep_d := Some (read__int_list p lb)
    | _ -> Yojson.Safe.skip_json p lb);
    while true do
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_sep p lb;
      Yojson.Safe.read_space p lb;
      let f s pos len =
        if pos < 0 || len < 0 || pos + len > String.length s then
          invalid_arg
            (Printf.sprintf
               "out-of-bounds substring position or length: string = %S, requested position = %i, \
                requested length = %i"
               s pos len);
        if len = 1 then
          match String.unsafe_get s pos with
          | 'c' -> 0
          | 'd' -> 1
          | _ -> -1
        else -1
      in
      let i = Yojson.Safe.map_ident p f lb in
      Atdgen_runtime.Oj_run.read_until_field_value p lb;
      match i with
      | 0 -> field_deep_c := Some (Atdgen_runtime.Oj_run.read_bool p lb)
      | 1 -> field_deep_d := Some (read__int_list p lb)
      | _ -> Yojson.Safe.skip_json p lb
    done;
    assert false
  with
  | Yojson.End_of_object ->
      ({
         deep_c =
           (match !field_deep_c with
           | Some x -> x
           | None -> Atdgen_runtime.Oj_run.missing_field p "deep_c");
         deep_d =
           (match !field_deep_d with
           | Some x -> x
           | None -> Atdgen_runtime.Oj_run.missing_field p "deep_d");
       }
        : deep_b)

let deep_b_of_string s = read_deep_b (Yojson.Safe.init_lexer ()) (Lexing.from_string s)

let write_deep_msg : _ -> deep_msg -> _ =
 fun ob (x : deep_msg) ->
  Buffer.add_char ob '{';
  let is_first = ref true in
  if !is_first then is_first := false else Buffer.add_char ob ',';
  Buffer.add_string ob "\"a\":";
  Yojson.Safe.write_int ob x.deep_a;
  if !is_first then is_first := false else Buffer.add_char ob ',';
  Buffer.add_string ob "\"b\":";
  write_deep_b ob x.deep_b;
  Buffer.add_char ob '}'

let string_of_deep_msg ?(len = 1024) x =
  let ob = Buffer.create len in
  write_deep_msg ob x;
  Buffer.contents ob

let read_deep_msg p lb =
  Yojson.Safe.read_space p lb;
  Yojson.Safe.read_lcurl p lb;
  let field_deep_a = ref None in
  let field_deep_b = ref None in
  try
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_object_end lb;
    Yojson.Safe.read_space p lb;
    let f s pos len =
      if pos < 0 || len < 0 || pos + len > String.length s then
        invalid_arg
          (Printf.sprintf
             "out-of-bounds substring position or length: string = %S, requested position = %i, \
              requested length = %i"
             s pos len);
      if len = 1 then
        match String.unsafe_get s pos with
        | 'a' -> 0
        | 'b' -> 1
        | _ -> -1
      else -1
    in
    let i = Yojson.Safe.map_ident p f lb in
    Atdgen_runtime.Oj_run.read_until_field_value p lb;
    (match i with
    | 0 -> field_deep_a := Some (Atdgen_runtime.Oj_run.read_int p lb)
    | 1 -> field_deep_b := Some (read_deep_b p lb)
    | _ -> Yojson.Safe.skip_json p lb);
    while true do
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_sep p lb;
      Yojson.Safe.read_space p lb;
      let f s pos len =
        if pos < 0 || len < 0 || pos + len > String.length s then
          invalid_arg
            (Printf.sprintf
               "out-of-bounds substring position or length: string = %S, requested position = %i, \
                requested length = %i"
               s pos len);
        if len = 1 then
          match String.unsafe_get s pos with
          | 'a' -> 0
          | 'b' -> 1
          | _ -> -1
        else -1
      in
      let i = Yojson.Safe.map_ident p f lb in
      Atdgen_runtime.Oj_run.read_until_field_value p lb;
      match i with
      | 0 -> field_deep_a := Some (Atdgen_runtime.Oj_run.read_int p lb)
      | 1 -> field_deep_b := Some (read_deep_b p lb)
      | _ -> Yojson.Safe.skip_json p lb
    done;
    assert false
  with
  | Yojson.End_of_object ->
      ({
         deep_a =
           (match !field_deep_a with
           | Some x -> x
           | None -> Atdgen_runtime.Oj_run.missing_field p "deep_a");
         deep_b =
           (match !field_deep_b with
           | Some x -> x
           | None -> Atdgen_runtime.Oj_run.missing_field p "deep_b");
       }
        : deep_msg)

let deep_msg_of_string s = read_deep_msg (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
