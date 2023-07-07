(* Auto-generated from "json.atd" *)
[@@@ocaml.warning "-27-32-33-35-39"]

type json_submission_post = Json_t.json_submission_post = {
  problem_id: int;
  contents: string
}

type json_score = Json_t.json_score = {
  failure: string option;
  success: float option
}

type json_submission_get_success_submission =
  Json_t.json_submission_get_success_submission = {
  _id: string;
  problem_id: float;
  user_id: string;
  score: json_score;
  submitted_at: string
}

type json_submission_get_success = Json_t.json_submission_get_success = {
  submission: json_submission_get_success_submission;
  contents: string
}

type json_submission_get = Json_t.json_submission_get = {
  success: json_submission_get_success option;
  failure: string option
}

type json_placement = Json_t.json_placement = { x: float; y: float }

type json_solution = Json_t.json_solution = {
  placements: json_placement list
}

type json_attendee = Json_t.json_attendee = {
  x: float;
  y: float;
  tastes: float list
}

type json_problem = Json_t.json_problem = {
  room_width: float;
  room_height: float;
  stage_width: float;
  stage_height: float;
  stage_bottom_left: (float * float);
  musicians: int list;
  attendees: json_attendee list
}

let write_json_submission_post : _ -> json_submission_post -> _ = (
  fun ob (x : json_submission_post) ->
    Buffer.add_char ob '{';
    let is_first = ref true in
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"problem_id\":";
    (
      Yojson.Safe.write_int
    )
      ob x.problem_id;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"contents\":";
    (
      Yojson.Safe.write_string
    )
      ob x.contents;
    Buffer.add_char ob '}';
)
let string_of_json_submission_post ?(len = 1024) x =
  let ob = Buffer.create len in
  write_json_submission_post ob x;
  Buffer.contents ob
let read_json_submission_post = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_lcurl p lb;
    let field_problem_id = ref (None) in
    let field_contents = ref (None) in
    try
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_end lb;
      Yojson.Safe.read_space p lb;
      let f =
        fun s pos len ->
          if pos < 0 || len < 0 || pos + len > String.length s then
            invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
          match len with
            | 8 -> (
                if String.unsafe_get s pos = 'c' && String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'n' && String.unsafe_get s (pos+3) = 't' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = 'n' && String.unsafe_get s (pos+6) = 't' && String.unsafe_get s (pos+7) = 's' then (
                  1
                )
                else (
                  -1
                )
              )
            | 10 -> (
                if String.unsafe_get s pos = 'p' && String.unsafe_get s (pos+1) = 'r' && String.unsafe_get s (pos+2) = 'o' && String.unsafe_get s (pos+3) = 'b' && String.unsafe_get s (pos+4) = 'l' && String.unsafe_get s (pos+5) = 'e' && String.unsafe_get s (pos+6) = 'm' && String.unsafe_get s (pos+7) = '_' && String.unsafe_get s (pos+8) = 'i' && String.unsafe_get s (pos+9) = 'd' then (
                  0
                )
                else (
                  -1
                )
              )
            | _ -> (
                -1
              )
      in
      let i = Yojson.Safe.map_ident p f lb in
      Atdgen_runtime.Oj_run.read_until_field_value p lb;
      (
        match i with
          | 0 ->
            field_problem_id := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_int
                ) p lb
              )
            );
          | 1 ->
            field_contents := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_string
                ) p lb
              )
            );
          | _ -> (
              Yojson.Safe.skip_json p lb
            )
      );
      while true do
        Yojson.Safe.read_space p lb;
        Yojson.Safe.read_object_sep p lb;
        Yojson.Safe.read_space p lb;
        let f =
          fun s pos len ->
            if pos < 0 || len < 0 || pos + len > String.length s then
              invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
            match len with
              | 8 -> (
                  if String.unsafe_get s pos = 'c' && String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'n' && String.unsafe_get s (pos+3) = 't' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = 'n' && String.unsafe_get s (pos+6) = 't' && String.unsafe_get s (pos+7) = 's' then (
                    1
                  )
                  else (
                    -1
                  )
                )
              | 10 -> (
                  if String.unsafe_get s pos = 'p' && String.unsafe_get s (pos+1) = 'r' && String.unsafe_get s (pos+2) = 'o' && String.unsafe_get s (pos+3) = 'b' && String.unsafe_get s (pos+4) = 'l' && String.unsafe_get s (pos+5) = 'e' && String.unsafe_get s (pos+6) = 'm' && String.unsafe_get s (pos+7) = '_' && String.unsafe_get s (pos+8) = 'i' && String.unsafe_get s (pos+9) = 'd' then (
                    0
                  )
                  else (
                    -1
                  )
                )
              | _ -> (
                  -1
                )
        in
        let i = Yojson.Safe.map_ident p f lb in
        Atdgen_runtime.Oj_run.read_until_field_value p lb;
        (
          match i with
            | 0 ->
              field_problem_id := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_int
                  ) p lb
                )
              );
            | 1 ->
              field_contents := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_string
                  ) p lb
                )
              );
            | _ -> (
                Yojson.Safe.skip_json p lb
              )
        );
      done;
      assert false;
    with Yojson.End_of_object -> (
        (
          {
            problem_id = (match !field_problem_id with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "problem_id");
            contents = (match !field_contents with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "contents");
          }
         : json_submission_post)
      )
)
let json_submission_post_of_string s =
  read_json_submission_post (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write__string_option = (
  Atdgen_runtime.Oj_run.write_option (
    Yojson.Safe.write_string
  )
)
let string_of__string_option ?(len = 1024) x =
  let ob = Buffer.create len in
  write__string_option ob x;
  Buffer.contents ob
let read__string_option = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    match Yojson.Safe.start_any_variant p lb with
      | `Edgy_bracket -> (
          match Yojson.Safe.read_ident p lb with
            | "None" ->
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_gt p lb;
              (None : _ option)
            | "Some" ->
              Atdgen_runtime.Oj_run.read_until_field_value p lb;
              let x = (
                  Atdgen_runtime.Oj_run.read_string
                ) p lb
              in
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_gt p lb;
              (Some x : _ option)
            | x ->
              Atdgen_runtime.Oj_run.invalid_variant_tag p x
        )
      | `Double_quote -> (
          match Yojson.Safe.finish_string p lb with
            | "None" ->
              (None : _ option)
            | x ->
              Atdgen_runtime.Oj_run.invalid_variant_tag p x
        )
      | `Square_bracket -> (
          match Atdgen_runtime.Oj_run.read_string p lb with
            | "Some" ->
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_comma p lb;
              Yojson.Safe.read_space p lb;
              let x = (
                  Atdgen_runtime.Oj_run.read_string
                ) p lb
              in
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_rbr p lb;
              (Some x : _ option)
            | x ->
              Atdgen_runtime.Oj_run.invalid_variant_tag p x
        )
)
let _string_option_of_string s =
  read__string_option (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write__float_option = (
  Atdgen_runtime.Oj_run.write_option (
    Yojson.Safe.write_float
  )
)
let string_of__float_option ?(len = 1024) x =
  let ob = Buffer.create len in
  write__float_option ob x;
  Buffer.contents ob
let read__float_option = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    match Yojson.Safe.start_any_variant p lb with
      | `Edgy_bracket -> (
          match Yojson.Safe.read_ident p lb with
            | "None" ->
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_gt p lb;
              (None : _ option)
            | "Some" ->
              Atdgen_runtime.Oj_run.read_until_field_value p lb;
              let x = (
                  Atdgen_runtime.Oj_run.read_number
                ) p lb
              in
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_gt p lb;
              (Some x : _ option)
            | x ->
              Atdgen_runtime.Oj_run.invalid_variant_tag p x
        )
      | `Double_quote -> (
          match Yojson.Safe.finish_string p lb with
            | "None" ->
              (None : _ option)
            | x ->
              Atdgen_runtime.Oj_run.invalid_variant_tag p x
        )
      | `Square_bracket -> (
          match Atdgen_runtime.Oj_run.read_string p lb with
            | "Some" ->
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_comma p lb;
              Yojson.Safe.read_space p lb;
              let x = (
                  Atdgen_runtime.Oj_run.read_number
                ) p lb
              in
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_rbr p lb;
              (Some x : _ option)
            | x ->
              Atdgen_runtime.Oj_run.invalid_variant_tag p x
        )
)
let _float_option_of_string s =
  read__float_option (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write_json_score : _ -> json_score -> _ = (
  fun ob (x : json_score) ->
    Buffer.add_char ob '{';
    let is_first = ref true in
    (match x.failure with None -> () | Some x ->
      if !is_first then
        is_first := false
      else
        Buffer.add_char ob ',';
        Buffer.add_string ob "\"Failure\":";
      (
        Yojson.Safe.write_string
      )
        ob x;
    );
    (match x.success with None -> () | Some x ->
      if !is_first then
        is_first := false
      else
        Buffer.add_char ob ',';
        Buffer.add_string ob "\"Success\":";
      (
        Yojson.Safe.write_float
      )
        ob x;
    );
    Buffer.add_char ob '}';
)
let string_of_json_score ?(len = 1024) x =
  let ob = Buffer.create len in
  write_json_score ob x;
  Buffer.contents ob
let read_json_score = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_lcurl p lb;
    let field_failure = ref (None) in
    let field_success = ref (None) in
    try
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_end lb;
      Yojson.Safe.read_space p lb;
      let f =
        fun s pos len ->
          if pos < 0 || len < 0 || pos + len > String.length s then
            invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
          if len = 7 then (
            match String.unsafe_get s pos with
              | 'F' -> (
                  if String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 'i' && String.unsafe_get s (pos+3) = 'l' && String.unsafe_get s (pos+4) = 'u' && String.unsafe_get s (pos+5) = 'r' && String.unsafe_get s (pos+6) = 'e' then (
                    0
                  )
                  else (
                    -1
                  )
                )
              | 'S' -> (
                  if String.unsafe_get s (pos+1) = 'u' && String.unsafe_get s (pos+2) = 'c' && String.unsafe_get s (pos+3) = 'c' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = 's' && String.unsafe_get s (pos+6) = 's' then (
                    1
                  )
                  else (
                    -1
                  )
                )
              | _ -> (
                  -1
                )
          )
          else (
            -1
          )
      in
      let i = Yojson.Safe.map_ident p f lb in
      Atdgen_runtime.Oj_run.read_until_field_value p lb;
      (
        match i with
          | 0 ->
            if not (Yojson.Safe.read_null_if_possible p lb) then (
              field_failure := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_string
                  ) p lb
                )
              );
            )
          | 1 ->
            if not (Yojson.Safe.read_null_if_possible p lb) then (
              field_success := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_number
                  ) p lb
                )
              );
            )
          | _ -> (
              Yojson.Safe.skip_json p lb
            )
      );
      while true do
        Yojson.Safe.read_space p lb;
        Yojson.Safe.read_object_sep p lb;
        Yojson.Safe.read_space p lb;
        let f =
          fun s pos len ->
            if pos < 0 || len < 0 || pos + len > String.length s then
              invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
            if len = 7 then (
              match String.unsafe_get s pos with
                | 'F' -> (
                    if String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 'i' && String.unsafe_get s (pos+3) = 'l' && String.unsafe_get s (pos+4) = 'u' && String.unsafe_get s (pos+5) = 'r' && String.unsafe_get s (pos+6) = 'e' then (
                      0
                    )
                    else (
                      -1
                    )
                  )
                | 'S' -> (
                    if String.unsafe_get s (pos+1) = 'u' && String.unsafe_get s (pos+2) = 'c' && String.unsafe_get s (pos+3) = 'c' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = 's' && String.unsafe_get s (pos+6) = 's' then (
                      1
                    )
                    else (
                      -1
                    )
                  )
                | _ -> (
                    -1
                  )
            )
            else (
              -1
            )
        in
        let i = Yojson.Safe.map_ident p f lb in
        Atdgen_runtime.Oj_run.read_until_field_value p lb;
        (
          match i with
            | 0 ->
              if not (Yojson.Safe.read_null_if_possible p lb) then (
                field_failure := (
                  Some (
                    (
                      Atdgen_runtime.Oj_run.read_string
                    ) p lb
                  )
                );
              )
            | 1 ->
              if not (Yojson.Safe.read_null_if_possible p lb) then (
                field_success := (
                  Some (
                    (
                      Atdgen_runtime.Oj_run.read_number
                    ) p lb
                  )
                );
              )
            | _ -> (
                Yojson.Safe.skip_json p lb
              )
        );
      done;
      assert false;
    with Yojson.End_of_object -> (
        (
          {
            failure = !field_failure;
            success = !field_success;
          }
         : json_score)
      )
)
let json_score_of_string s =
  read_json_score (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write_json_submission_get_success_submission : _ -> json_submission_get_success_submission -> _ = (
  fun ob (x : json_submission_get_success_submission) ->
    Buffer.add_char ob '{';
    let is_first = ref true in
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"_id\":";
    (
      Yojson.Safe.write_string
    )
      ob x._id;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"problem_id\":";
    (
      Yojson.Safe.write_float
    )
      ob x.problem_id;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"user_id\":";
    (
      Yojson.Safe.write_string
    )
      ob x.user_id;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"score\":";
    (
      write_json_score
    )
      ob x.score;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"submitted_at\":";
    (
      Yojson.Safe.write_string
    )
      ob x.submitted_at;
    Buffer.add_char ob '}';
)
let string_of_json_submission_get_success_submission ?(len = 1024) x =
  let ob = Buffer.create len in
  write_json_submission_get_success_submission ob x;
  Buffer.contents ob
let read_json_submission_get_success_submission = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_lcurl p lb;
    let field__id = ref (None) in
    let field_problem_id = ref (None) in
    let field_user_id = ref (None) in
    let field_score = ref (None) in
    let field_submitted_at = ref (None) in
    try
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_end lb;
      Yojson.Safe.read_space p lb;
      let f =
        fun s pos len ->
          if pos < 0 || len < 0 || pos + len > String.length s then
            invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
          match len with
            | 3 -> (
                if String.unsafe_get s pos = '_' && String.unsafe_get s (pos+1) = 'i' && String.unsafe_get s (pos+2) = 'd' then (
                  0
                )
                else (
                  -1
                )
              )
            | 5 -> (
                if String.unsafe_get s pos = 's' && String.unsafe_get s (pos+1) = 'c' && String.unsafe_get s (pos+2) = 'o' && String.unsafe_get s (pos+3) = 'r' && String.unsafe_get s (pos+4) = 'e' then (
                  3
                )
                else (
                  -1
                )
              )
            | 7 -> (
                if String.unsafe_get s pos = 'u' && String.unsafe_get s (pos+1) = 's' && String.unsafe_get s (pos+2) = 'e' && String.unsafe_get s (pos+3) = 'r' && String.unsafe_get s (pos+4) = '_' && String.unsafe_get s (pos+5) = 'i' && String.unsafe_get s (pos+6) = 'd' then (
                  2
                )
                else (
                  -1
                )
              )
            | 10 -> (
                if String.unsafe_get s pos = 'p' && String.unsafe_get s (pos+1) = 'r' && String.unsafe_get s (pos+2) = 'o' && String.unsafe_get s (pos+3) = 'b' && String.unsafe_get s (pos+4) = 'l' && String.unsafe_get s (pos+5) = 'e' && String.unsafe_get s (pos+6) = 'm' && String.unsafe_get s (pos+7) = '_' && String.unsafe_get s (pos+8) = 'i' && String.unsafe_get s (pos+9) = 'd' then (
                  1
                )
                else (
                  -1
                )
              )
            | 12 -> (
                if String.unsafe_get s pos = 's' && String.unsafe_get s (pos+1) = 'u' && String.unsafe_get s (pos+2) = 'b' && String.unsafe_get s (pos+3) = 'm' && String.unsafe_get s (pos+4) = 'i' && String.unsafe_get s (pos+5) = 't' && String.unsafe_get s (pos+6) = 't' && String.unsafe_get s (pos+7) = 'e' && String.unsafe_get s (pos+8) = 'd' && String.unsafe_get s (pos+9) = '_' && String.unsafe_get s (pos+10) = 'a' && String.unsafe_get s (pos+11) = 't' then (
                  4
                )
                else (
                  -1
                )
              )
            | _ -> (
                -1
              )
      in
      let i = Yojson.Safe.map_ident p f lb in
      Atdgen_runtime.Oj_run.read_until_field_value p lb;
      (
        match i with
          | 0 ->
            field__id := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_string
                ) p lb
              )
            );
          | 1 ->
            field_problem_id := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_number
                ) p lb
              )
            );
          | 2 ->
            field_user_id := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_string
                ) p lb
              )
            );
          | 3 ->
            field_score := (
              Some (
                (
                  read_json_score
                ) p lb
              )
            );
          | 4 ->
            field_submitted_at := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_string
                ) p lb
              )
            );
          | _ -> (
              Yojson.Safe.skip_json p lb
            )
      );
      while true do
        Yojson.Safe.read_space p lb;
        Yojson.Safe.read_object_sep p lb;
        Yojson.Safe.read_space p lb;
        let f =
          fun s pos len ->
            if pos < 0 || len < 0 || pos + len > String.length s then
              invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
            match len with
              | 3 -> (
                  if String.unsafe_get s pos = '_' && String.unsafe_get s (pos+1) = 'i' && String.unsafe_get s (pos+2) = 'd' then (
                    0
                  )
                  else (
                    -1
                  )
                )
              | 5 -> (
                  if String.unsafe_get s pos = 's' && String.unsafe_get s (pos+1) = 'c' && String.unsafe_get s (pos+2) = 'o' && String.unsafe_get s (pos+3) = 'r' && String.unsafe_get s (pos+4) = 'e' then (
                    3
                  )
                  else (
                    -1
                  )
                )
              | 7 -> (
                  if String.unsafe_get s pos = 'u' && String.unsafe_get s (pos+1) = 's' && String.unsafe_get s (pos+2) = 'e' && String.unsafe_get s (pos+3) = 'r' && String.unsafe_get s (pos+4) = '_' && String.unsafe_get s (pos+5) = 'i' && String.unsafe_get s (pos+6) = 'd' then (
                    2
                  )
                  else (
                    -1
                  )
                )
              | 10 -> (
                  if String.unsafe_get s pos = 'p' && String.unsafe_get s (pos+1) = 'r' && String.unsafe_get s (pos+2) = 'o' && String.unsafe_get s (pos+3) = 'b' && String.unsafe_get s (pos+4) = 'l' && String.unsafe_get s (pos+5) = 'e' && String.unsafe_get s (pos+6) = 'm' && String.unsafe_get s (pos+7) = '_' && String.unsafe_get s (pos+8) = 'i' && String.unsafe_get s (pos+9) = 'd' then (
                    1
                  )
                  else (
                    -1
                  )
                )
              | 12 -> (
                  if String.unsafe_get s pos = 's' && String.unsafe_get s (pos+1) = 'u' && String.unsafe_get s (pos+2) = 'b' && String.unsafe_get s (pos+3) = 'm' && String.unsafe_get s (pos+4) = 'i' && String.unsafe_get s (pos+5) = 't' && String.unsafe_get s (pos+6) = 't' && String.unsafe_get s (pos+7) = 'e' && String.unsafe_get s (pos+8) = 'd' && String.unsafe_get s (pos+9) = '_' && String.unsafe_get s (pos+10) = 'a' && String.unsafe_get s (pos+11) = 't' then (
                    4
                  )
                  else (
                    -1
                  )
                )
              | _ -> (
                  -1
                )
        in
        let i = Yojson.Safe.map_ident p f lb in
        Atdgen_runtime.Oj_run.read_until_field_value p lb;
        (
          match i with
            | 0 ->
              field__id := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_string
                  ) p lb
                )
              );
            | 1 ->
              field_problem_id := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_number
                  ) p lb
                )
              );
            | 2 ->
              field_user_id := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_string
                  ) p lb
                )
              );
            | 3 ->
              field_score := (
                Some (
                  (
                    read_json_score
                  ) p lb
                )
              );
            | 4 ->
              field_submitted_at := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_string
                  ) p lb
                )
              );
            | _ -> (
                Yojson.Safe.skip_json p lb
              )
        );
      done;
      assert false;
    with Yojson.End_of_object -> (
        (
          {
            _id = (match !field__id with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "_id");
            problem_id = (match !field_problem_id with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "problem_id");
            user_id = (match !field_user_id with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "user_id");
            score = (match !field_score with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "score");
            submitted_at = (match !field_submitted_at with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "submitted_at");
          }
         : json_submission_get_success_submission)
      )
)
let json_submission_get_success_submission_of_string s =
  read_json_submission_get_success_submission (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write_json_submission_get_success : _ -> json_submission_get_success -> _ = (
  fun ob (x : json_submission_get_success) ->
    Buffer.add_char ob '{';
    let is_first = ref true in
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"submission\":";
    (
      write_json_submission_get_success_submission
    )
      ob x.submission;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"contents\":";
    (
      Yojson.Safe.write_string
    )
      ob x.contents;
    Buffer.add_char ob '}';
)
let string_of_json_submission_get_success ?(len = 1024) x =
  let ob = Buffer.create len in
  write_json_submission_get_success ob x;
  Buffer.contents ob
let read_json_submission_get_success = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_lcurl p lb;
    let field_submission = ref (None) in
    let field_contents = ref (None) in
    try
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_end lb;
      Yojson.Safe.read_space p lb;
      let f =
        fun s pos len ->
          if pos < 0 || len < 0 || pos + len > String.length s then
            invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
          match len with
            | 8 -> (
                if String.unsafe_get s pos = 'c' && String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'n' && String.unsafe_get s (pos+3) = 't' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = 'n' && String.unsafe_get s (pos+6) = 't' && String.unsafe_get s (pos+7) = 's' then (
                  1
                )
                else (
                  -1
                )
              )
            | 10 -> (
                if String.unsafe_get s pos = 's' && String.unsafe_get s (pos+1) = 'u' && String.unsafe_get s (pos+2) = 'b' && String.unsafe_get s (pos+3) = 'm' && String.unsafe_get s (pos+4) = 'i' && String.unsafe_get s (pos+5) = 's' && String.unsafe_get s (pos+6) = 's' && String.unsafe_get s (pos+7) = 'i' && String.unsafe_get s (pos+8) = 'o' && String.unsafe_get s (pos+9) = 'n' then (
                  0
                )
                else (
                  -1
                )
              )
            | _ -> (
                -1
              )
      in
      let i = Yojson.Safe.map_ident p f lb in
      Atdgen_runtime.Oj_run.read_until_field_value p lb;
      (
        match i with
          | 0 ->
            field_submission := (
              Some (
                (
                  read_json_submission_get_success_submission
                ) p lb
              )
            );
          | 1 ->
            field_contents := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_string
                ) p lb
              )
            );
          | _ -> (
              Yojson.Safe.skip_json p lb
            )
      );
      while true do
        Yojson.Safe.read_space p lb;
        Yojson.Safe.read_object_sep p lb;
        Yojson.Safe.read_space p lb;
        let f =
          fun s pos len ->
            if pos < 0 || len < 0 || pos + len > String.length s then
              invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
            match len with
              | 8 -> (
                  if String.unsafe_get s pos = 'c' && String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'n' && String.unsafe_get s (pos+3) = 't' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = 'n' && String.unsafe_get s (pos+6) = 't' && String.unsafe_get s (pos+7) = 's' then (
                    1
                  )
                  else (
                    -1
                  )
                )
              | 10 -> (
                  if String.unsafe_get s pos = 's' && String.unsafe_get s (pos+1) = 'u' && String.unsafe_get s (pos+2) = 'b' && String.unsafe_get s (pos+3) = 'm' && String.unsafe_get s (pos+4) = 'i' && String.unsafe_get s (pos+5) = 's' && String.unsafe_get s (pos+6) = 's' && String.unsafe_get s (pos+7) = 'i' && String.unsafe_get s (pos+8) = 'o' && String.unsafe_get s (pos+9) = 'n' then (
                    0
                  )
                  else (
                    -1
                  )
                )
              | _ -> (
                  -1
                )
        in
        let i = Yojson.Safe.map_ident p f lb in
        Atdgen_runtime.Oj_run.read_until_field_value p lb;
        (
          match i with
            | 0 ->
              field_submission := (
                Some (
                  (
                    read_json_submission_get_success_submission
                  ) p lb
                )
              );
            | 1 ->
              field_contents := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_string
                  ) p lb
                )
              );
            | _ -> (
                Yojson.Safe.skip_json p lb
              )
        );
      done;
      assert false;
    with Yojson.End_of_object -> (
        (
          {
            submission = (match !field_submission with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "submission");
            contents = (match !field_contents with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "contents");
          }
         : json_submission_get_success)
      )
)
let json_submission_get_success_of_string s =
  read_json_submission_get_success (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write__json_submission_get_success_option = (
  Atdgen_runtime.Oj_run.write_option (
    write_json_submission_get_success
  )
)
let string_of__json_submission_get_success_option ?(len = 1024) x =
  let ob = Buffer.create len in
  write__json_submission_get_success_option ob x;
  Buffer.contents ob
let read__json_submission_get_success_option = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    match Yojson.Safe.start_any_variant p lb with
      | `Edgy_bracket -> (
          match Yojson.Safe.read_ident p lb with
            | "None" ->
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_gt p lb;
              (None : _ option)
            | "Some" ->
              Atdgen_runtime.Oj_run.read_until_field_value p lb;
              let x = (
                  read_json_submission_get_success
                ) p lb
              in
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_gt p lb;
              (Some x : _ option)
            | x ->
              Atdgen_runtime.Oj_run.invalid_variant_tag p x
        )
      | `Double_quote -> (
          match Yojson.Safe.finish_string p lb with
            | "None" ->
              (None : _ option)
            | x ->
              Atdgen_runtime.Oj_run.invalid_variant_tag p x
        )
      | `Square_bracket -> (
          match Atdgen_runtime.Oj_run.read_string p lb with
            | "Some" ->
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_comma p lb;
              Yojson.Safe.read_space p lb;
              let x = (
                  read_json_submission_get_success
                ) p lb
              in
              Yojson.Safe.read_space p lb;
              Yojson.Safe.read_rbr p lb;
              (Some x : _ option)
            | x ->
              Atdgen_runtime.Oj_run.invalid_variant_tag p x
        )
)
let _json_submission_get_success_option_of_string s =
  read__json_submission_get_success_option (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write_json_submission_get : _ -> json_submission_get -> _ = (
  fun ob (x : json_submission_get) ->
    Buffer.add_char ob '{';
    let is_first = ref true in
    (match x.success with None -> () | Some x ->
      if !is_first then
        is_first := false
      else
        Buffer.add_char ob ',';
        Buffer.add_string ob "\"Success\":";
      (
        write_json_submission_get_success
      )
        ob x;
    );
    (match x.failure with None -> () | Some x ->
      if !is_first then
        is_first := false
      else
        Buffer.add_char ob ',';
        Buffer.add_string ob "\"Failure\":";
      (
        Yojson.Safe.write_string
      )
        ob x;
    );
    Buffer.add_char ob '}';
)
let string_of_json_submission_get ?(len = 1024) x =
  let ob = Buffer.create len in
  write_json_submission_get ob x;
  Buffer.contents ob
let read_json_submission_get = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_lcurl p lb;
    let field_success = ref (None) in
    let field_failure = ref (None) in
    try
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_end lb;
      Yojson.Safe.read_space p lb;
      let f =
        fun s pos len ->
          if pos < 0 || len < 0 || pos + len > String.length s then
            invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
          if len = 7 then (
            match String.unsafe_get s pos with
              | 'F' -> (
                  if String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 'i' && String.unsafe_get s (pos+3) = 'l' && String.unsafe_get s (pos+4) = 'u' && String.unsafe_get s (pos+5) = 'r' && String.unsafe_get s (pos+6) = 'e' then (
                    1
                  )
                  else (
                    -1
                  )
                )
              | 'S' -> (
                  if String.unsafe_get s (pos+1) = 'u' && String.unsafe_get s (pos+2) = 'c' && String.unsafe_get s (pos+3) = 'c' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = 's' && String.unsafe_get s (pos+6) = 's' then (
                    0
                  )
                  else (
                    -1
                  )
                )
              | _ -> (
                  -1
                )
          )
          else (
            -1
          )
      in
      let i = Yojson.Safe.map_ident p f lb in
      Atdgen_runtime.Oj_run.read_until_field_value p lb;
      (
        match i with
          | 0 ->
            if not (Yojson.Safe.read_null_if_possible p lb) then (
              field_success := (
                Some (
                  (
                    read_json_submission_get_success
                  ) p lb
                )
              );
            )
          | 1 ->
            if not (Yojson.Safe.read_null_if_possible p lb) then (
              field_failure := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_string
                  ) p lb
                )
              );
            )
          | _ -> (
              Yojson.Safe.skip_json p lb
            )
      );
      while true do
        Yojson.Safe.read_space p lb;
        Yojson.Safe.read_object_sep p lb;
        Yojson.Safe.read_space p lb;
        let f =
          fun s pos len ->
            if pos < 0 || len < 0 || pos + len > String.length s then
              invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
            if len = 7 then (
              match String.unsafe_get s pos with
                | 'F' -> (
                    if String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 'i' && String.unsafe_get s (pos+3) = 'l' && String.unsafe_get s (pos+4) = 'u' && String.unsafe_get s (pos+5) = 'r' && String.unsafe_get s (pos+6) = 'e' then (
                      1
                    )
                    else (
                      -1
                    )
                  )
                | 'S' -> (
                    if String.unsafe_get s (pos+1) = 'u' && String.unsafe_get s (pos+2) = 'c' && String.unsafe_get s (pos+3) = 'c' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = 's' && String.unsafe_get s (pos+6) = 's' then (
                      0
                    )
                    else (
                      -1
                    )
                  )
                | _ -> (
                    -1
                  )
            )
            else (
              -1
            )
        in
        let i = Yojson.Safe.map_ident p f lb in
        Atdgen_runtime.Oj_run.read_until_field_value p lb;
        (
          match i with
            | 0 ->
              if not (Yojson.Safe.read_null_if_possible p lb) then (
                field_success := (
                  Some (
                    (
                      read_json_submission_get_success
                    ) p lb
                  )
                );
              )
            | 1 ->
              if not (Yojson.Safe.read_null_if_possible p lb) then (
                field_failure := (
                  Some (
                    (
                      Atdgen_runtime.Oj_run.read_string
                    ) p lb
                  )
                );
              )
            | _ -> (
                Yojson.Safe.skip_json p lb
              )
        );
      done;
      assert false;
    with Yojson.End_of_object -> (
        (
          {
            success = !field_success;
            failure = !field_failure;
          }
         : json_submission_get)
      )
)
let json_submission_get_of_string s =
  read_json_submission_get (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write_json_placement : _ -> json_placement -> _ = (
  fun ob (x : json_placement) ->
    Buffer.add_char ob '{';
    let is_first = ref true in
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"x\":";
    (
      Yojson.Safe.write_float
    )
      ob x.x;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"y\":";
    (
      Yojson.Safe.write_float
    )
      ob x.y;
    Buffer.add_char ob '}';
)
let string_of_json_placement ?(len = 1024) x =
  let ob = Buffer.create len in
  write_json_placement ob x;
  Buffer.contents ob
let read_json_placement = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_lcurl p lb;
    let field_x = ref (None) in
    let field_y = ref (None) in
    try
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_end lb;
      Yojson.Safe.read_space p lb;
      let f =
        fun s pos len ->
          if pos < 0 || len < 0 || pos + len > String.length s then
            invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
          if len = 1 then (
            match String.unsafe_get s pos with
              | 'x' -> (
                  0
                )
              | 'y' -> (
                  1
                )
              | _ -> (
                  -1
                )
          )
          else (
            -1
          )
      in
      let i = Yojson.Safe.map_ident p f lb in
      Atdgen_runtime.Oj_run.read_until_field_value p lb;
      (
        match i with
          | 0 ->
            field_x := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_number
                ) p lb
              )
            );
          | 1 ->
            field_y := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_number
                ) p lb
              )
            );
          | _ -> (
              Yojson.Safe.skip_json p lb
            )
      );
      while true do
        Yojson.Safe.read_space p lb;
        Yojson.Safe.read_object_sep p lb;
        Yojson.Safe.read_space p lb;
        let f =
          fun s pos len ->
            if pos < 0 || len < 0 || pos + len > String.length s then
              invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
            if len = 1 then (
              match String.unsafe_get s pos with
                | 'x' -> (
                    0
                  )
                | 'y' -> (
                    1
                  )
                | _ -> (
                    -1
                  )
            )
            else (
              -1
            )
        in
        let i = Yojson.Safe.map_ident p f lb in
        Atdgen_runtime.Oj_run.read_until_field_value p lb;
        (
          match i with
            | 0 ->
              field_x := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_number
                  ) p lb
                )
              );
            | 1 ->
              field_y := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_number
                  ) p lb
                )
              );
            | _ -> (
                Yojson.Safe.skip_json p lb
              )
        );
      done;
      assert false;
    with Yojson.End_of_object -> (
        (
          {
            x = (match !field_x with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "x");
            y = (match !field_y with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "y");
          }
         : json_placement)
      )
)
let json_placement_of_string s =
  read_json_placement (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write__json_placement_list = (
  Atdgen_runtime.Oj_run.write_list (
    write_json_placement
  )
)
let string_of__json_placement_list ?(len = 1024) x =
  let ob = Buffer.create len in
  write__json_placement_list ob x;
  Buffer.contents ob
let read__json_placement_list = (
  Atdgen_runtime.Oj_run.read_list (
    read_json_placement
  )
)
let _json_placement_list_of_string s =
  read__json_placement_list (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write_json_solution : _ -> json_solution -> _ = (
  fun ob (x : json_solution) ->
    Buffer.add_char ob '{';
    let is_first = ref true in
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"placements\":";
    (
      write__json_placement_list
    )
      ob x.placements;
    Buffer.add_char ob '}';
)
let string_of_json_solution ?(len = 1024) x =
  let ob = Buffer.create len in
  write_json_solution ob x;
  Buffer.contents ob
let read_json_solution = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_lcurl p lb;
    let field_placements = ref (None) in
    try
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_end lb;
      Yojson.Safe.read_space p lb;
      let f =
        fun s pos len ->
          if pos < 0 || len < 0 || pos + len > String.length s then
            invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
          if len = 10 && String.unsafe_get s pos = 'p' && String.unsafe_get s (pos+1) = 'l' && String.unsafe_get s (pos+2) = 'a' && String.unsafe_get s (pos+3) = 'c' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = 'm' && String.unsafe_get s (pos+6) = 'e' && String.unsafe_get s (pos+7) = 'n' && String.unsafe_get s (pos+8) = 't' && String.unsafe_get s (pos+9) = 's' then (
            0
          )
          else (
            -1
          )
      in
      let i = Yojson.Safe.map_ident p f lb in
      Atdgen_runtime.Oj_run.read_until_field_value p lb;
      (
        match i with
          | 0 ->
            field_placements := (
              Some (
                (
                  read__json_placement_list
                ) p lb
              )
            );
          | _ -> (
              Yojson.Safe.skip_json p lb
            )
      );
      while true do
        Yojson.Safe.read_space p lb;
        Yojson.Safe.read_object_sep p lb;
        Yojson.Safe.read_space p lb;
        let f =
          fun s pos len ->
            if pos < 0 || len < 0 || pos + len > String.length s then
              invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
            if len = 10 && String.unsafe_get s pos = 'p' && String.unsafe_get s (pos+1) = 'l' && String.unsafe_get s (pos+2) = 'a' && String.unsafe_get s (pos+3) = 'c' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = 'm' && String.unsafe_get s (pos+6) = 'e' && String.unsafe_get s (pos+7) = 'n' && String.unsafe_get s (pos+8) = 't' && String.unsafe_get s (pos+9) = 's' then (
              0
            )
            else (
              -1
            )
        in
        let i = Yojson.Safe.map_ident p f lb in
        Atdgen_runtime.Oj_run.read_until_field_value p lb;
        (
          match i with
            | 0 ->
              field_placements := (
                Some (
                  (
                    read__json_placement_list
                  ) p lb
                )
              );
            | _ -> (
                Yojson.Safe.skip_json p lb
              )
        );
      done;
      assert false;
    with Yojson.End_of_object -> (
        (
          {
            placements = (match !field_placements with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "placements");
          }
         : json_solution)
      )
)
let json_solution_of_string s =
  read_json_solution (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write__float_list = (
  Atdgen_runtime.Oj_run.write_list (
    Yojson.Safe.write_float
  )
)
let string_of__float_list ?(len = 1024) x =
  let ob = Buffer.create len in
  write__float_list ob x;
  Buffer.contents ob
let read__float_list = (
  Atdgen_runtime.Oj_run.read_list (
    Atdgen_runtime.Oj_run.read_number
  )
)
let _float_list_of_string s =
  read__float_list (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write_json_attendee : _ -> json_attendee -> _ = (
  fun ob (x : json_attendee) ->
    Buffer.add_char ob '{';
    let is_first = ref true in
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"x\":";
    (
      Yojson.Safe.write_float
    )
      ob x.x;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"y\":";
    (
      Yojson.Safe.write_float
    )
      ob x.y;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"tastes\":";
    (
      write__float_list
    )
      ob x.tastes;
    Buffer.add_char ob '}';
)
let string_of_json_attendee ?(len = 1024) x =
  let ob = Buffer.create len in
  write_json_attendee ob x;
  Buffer.contents ob
let read_json_attendee = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_lcurl p lb;
    let field_x = ref (None) in
    let field_y = ref (None) in
    let field_tastes = ref (None) in
    try
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_end lb;
      Yojson.Safe.read_space p lb;
      let f =
        fun s pos len ->
          if pos < 0 || len < 0 || pos + len > String.length s then
            invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
          match len with
            | 1 -> (
                match String.unsafe_get s pos with
                  | 'x' -> (
                      0
                    )
                  | 'y' -> (
                      1
                    )
                  | _ -> (
                      -1
                    )
              )
            | 6 -> (
                if String.unsafe_get s pos = 't' && String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 's' && String.unsafe_get s (pos+3) = 't' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = 's' then (
                  2
                )
                else (
                  -1
                )
              )
            | _ -> (
                -1
              )
      in
      let i = Yojson.Safe.map_ident p f lb in
      Atdgen_runtime.Oj_run.read_until_field_value p lb;
      (
        match i with
          | 0 ->
            field_x := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_number
                ) p lb
              )
            );
          | 1 ->
            field_y := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_number
                ) p lb
              )
            );
          | 2 ->
            field_tastes := (
              Some (
                (
                  read__float_list
                ) p lb
              )
            );
          | _ -> (
              Yojson.Safe.skip_json p lb
            )
      );
      while true do
        Yojson.Safe.read_space p lb;
        Yojson.Safe.read_object_sep p lb;
        Yojson.Safe.read_space p lb;
        let f =
          fun s pos len ->
            if pos < 0 || len < 0 || pos + len > String.length s then
              invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
            match len with
              | 1 -> (
                  match String.unsafe_get s pos with
                    | 'x' -> (
                        0
                      )
                    | 'y' -> (
                        1
                      )
                    | _ -> (
                        -1
                      )
                )
              | 6 -> (
                  if String.unsafe_get s pos = 't' && String.unsafe_get s (pos+1) = 'a' && String.unsafe_get s (pos+2) = 's' && String.unsafe_get s (pos+3) = 't' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = 's' then (
                    2
                  )
                  else (
                    -1
                  )
                )
              | _ -> (
                  -1
                )
        in
        let i = Yojson.Safe.map_ident p f lb in
        Atdgen_runtime.Oj_run.read_until_field_value p lb;
        (
          match i with
            | 0 ->
              field_x := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_number
                  ) p lb
                )
              );
            | 1 ->
              field_y := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_number
                  ) p lb
                )
              );
            | 2 ->
              field_tastes := (
                Some (
                  (
                    read__float_list
                  ) p lb
                )
              );
            | _ -> (
                Yojson.Safe.skip_json p lb
              )
        );
      done;
      assert false;
    with Yojson.End_of_object -> (
        (
          {
            x = (match !field_x with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "x");
            y = (match !field_y with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "y");
            tastes = (match !field_tastes with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "tastes");
          }
         : json_attendee)
      )
)
let json_attendee_of_string s =
  read_json_attendee (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write__json_attendee_list = (
  Atdgen_runtime.Oj_run.write_list (
    write_json_attendee
  )
)
let string_of__json_attendee_list ?(len = 1024) x =
  let ob = Buffer.create len in
  write__json_attendee_list ob x;
  Buffer.contents ob
let read__json_attendee_list = (
  Atdgen_runtime.Oj_run.read_list (
    read_json_attendee
  )
)
let _json_attendee_list_of_string s =
  read__json_attendee_list (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write__int_list = (
  Atdgen_runtime.Oj_run.write_list (
    Yojson.Safe.write_int
  )
)
let string_of__int_list ?(len = 1024) x =
  let ob = Buffer.create len in
  write__int_list ob x;
  Buffer.contents ob
let read__int_list = (
  Atdgen_runtime.Oj_run.read_list (
    Atdgen_runtime.Oj_run.read_int
  )
)
let _int_list_of_string s =
  read__int_list (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
let write_json_problem : _ -> json_problem -> _ = (
  fun ob (x : json_problem) ->
    Buffer.add_char ob '{';
    let is_first = ref true in
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"room_width\":";
    (
      Yojson.Safe.write_float
    )
      ob x.room_width;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"room_height\":";
    (
      Yojson.Safe.write_float
    )
      ob x.room_height;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"stage_width\":";
    (
      Yojson.Safe.write_float
    )
      ob x.stage_width;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"stage_height\":";
    (
      Yojson.Safe.write_float
    )
      ob x.stage_height;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"stage_bottom_left\":";
    (
      fun ob x ->
        Buffer.add_char ob '(';
        (let x, _ = x in
        (
          Yojson.Safe.write_float
        ) ob x
        );
        Buffer.add_char ob ',';
        (let _, x = x in
        (
          Yojson.Safe.write_float
        ) ob x
        );
        Buffer.add_char ob ')';
    )
      ob x.stage_bottom_left;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"musicians\":";
    (
      write__int_list
    )
      ob x.musicians;
    if !is_first then
      is_first := false
    else
      Buffer.add_char ob ',';
      Buffer.add_string ob "\"attendees\":";
    (
      write__json_attendee_list
    )
      ob x.attendees;
    Buffer.add_char ob '}';
)
let string_of_json_problem ?(len = 1024) x =
  let ob = Buffer.create len in
  write_json_problem ob x;
  Buffer.contents ob
let read_json_problem = (
  fun p lb ->
    Yojson.Safe.read_space p lb;
    Yojson.Safe.read_lcurl p lb;
    let field_room_width = ref (None) in
    let field_room_height = ref (None) in
    let field_stage_width = ref (None) in
    let field_stage_height = ref (None) in
    let field_stage_bottom_left = ref (None) in
    let field_musicians = ref (None) in
    let field_attendees = ref (None) in
    try
      Yojson.Safe.read_space p lb;
      Yojson.Safe.read_object_end lb;
      Yojson.Safe.read_space p lb;
      let f =
        fun s pos len ->
          if pos < 0 || len < 0 || pos + len > String.length s then
            invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
          match len with
            | 9 -> (
                match String.unsafe_get s pos with
                  | 'a' -> (
                      if String.unsafe_get s (pos+1) = 't' && String.unsafe_get s (pos+2) = 't' && String.unsafe_get s (pos+3) = 'e' && String.unsafe_get s (pos+4) = 'n' && String.unsafe_get s (pos+5) = 'd' && String.unsafe_get s (pos+6) = 'e' && String.unsafe_get s (pos+7) = 'e' && String.unsafe_get s (pos+8) = 's' then (
                        6
                      )
                      else (
                        -1
                      )
                    )
                  | 'm' -> (
                      if String.unsafe_get s (pos+1) = 'u' && String.unsafe_get s (pos+2) = 's' && String.unsafe_get s (pos+3) = 'i' && String.unsafe_get s (pos+4) = 'c' && String.unsafe_get s (pos+5) = 'i' && String.unsafe_get s (pos+6) = 'a' && String.unsafe_get s (pos+7) = 'n' && String.unsafe_get s (pos+8) = 's' then (
                        5
                      )
                      else (
                        -1
                      )
                    )
                  | _ -> (
                      -1
                    )
              )
            | 10 -> (
                if String.unsafe_get s pos = 'r' && String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'o' && String.unsafe_get s (pos+3) = 'm' && String.unsafe_get s (pos+4) = '_' && String.unsafe_get s (pos+5) = 'w' && String.unsafe_get s (pos+6) = 'i' && String.unsafe_get s (pos+7) = 'd' && String.unsafe_get s (pos+8) = 't' && String.unsafe_get s (pos+9) = 'h' then (
                  0
                )
                else (
                  -1
                )
              )
            | 11 -> (
                match String.unsafe_get s pos with
                  | 'r' -> (
                      if String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'o' && String.unsafe_get s (pos+3) = 'm' && String.unsafe_get s (pos+4) = '_' && String.unsafe_get s (pos+5) = 'h' && String.unsafe_get s (pos+6) = 'e' && String.unsafe_get s (pos+7) = 'i' && String.unsafe_get s (pos+8) = 'g' && String.unsafe_get s (pos+9) = 'h' && String.unsafe_get s (pos+10) = 't' then (
                        1
                      )
                      else (
                        -1
                      )
                    )
                  | 's' -> (
                      if String.unsafe_get s (pos+1) = 't' && String.unsafe_get s (pos+2) = 'a' && String.unsafe_get s (pos+3) = 'g' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = '_' && String.unsafe_get s (pos+6) = 'w' && String.unsafe_get s (pos+7) = 'i' && String.unsafe_get s (pos+8) = 'd' && String.unsafe_get s (pos+9) = 't' && String.unsafe_get s (pos+10) = 'h' then (
                        2
                      )
                      else (
                        -1
                      )
                    )
                  | _ -> (
                      -1
                    )
              )
            | 12 -> (
                if String.unsafe_get s pos = 's' && String.unsafe_get s (pos+1) = 't' && String.unsafe_get s (pos+2) = 'a' && String.unsafe_get s (pos+3) = 'g' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = '_' && String.unsafe_get s (pos+6) = 'h' && String.unsafe_get s (pos+7) = 'e' && String.unsafe_get s (pos+8) = 'i' && String.unsafe_get s (pos+9) = 'g' && String.unsafe_get s (pos+10) = 'h' && String.unsafe_get s (pos+11) = 't' then (
                  3
                )
                else (
                  -1
                )
              )
            | 17 -> (
                if String.unsafe_get s pos = 's' && String.unsafe_get s (pos+1) = 't' && String.unsafe_get s (pos+2) = 'a' && String.unsafe_get s (pos+3) = 'g' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = '_' && String.unsafe_get s (pos+6) = 'b' && String.unsafe_get s (pos+7) = 'o' && String.unsafe_get s (pos+8) = 't' && String.unsafe_get s (pos+9) = 't' && String.unsafe_get s (pos+10) = 'o' && String.unsafe_get s (pos+11) = 'm' && String.unsafe_get s (pos+12) = '_' && String.unsafe_get s (pos+13) = 'l' && String.unsafe_get s (pos+14) = 'e' && String.unsafe_get s (pos+15) = 'f' && String.unsafe_get s (pos+16) = 't' then (
                  4
                )
                else (
                  -1
                )
              )
            | _ -> (
                -1
              )
      in
      let i = Yojson.Safe.map_ident p f lb in
      Atdgen_runtime.Oj_run.read_until_field_value p lb;
      (
        match i with
          | 0 ->
            field_room_width := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_number
                ) p lb
              )
            );
          | 1 ->
            field_room_height := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_number
                ) p lb
              )
            );
          | 2 ->
            field_stage_width := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_number
                ) p lb
              )
            );
          | 3 ->
            field_stage_height := (
              Some (
                (
                  Atdgen_runtime.Oj_run.read_number
                ) p lb
              )
            );
          | 4 ->
            field_stage_bottom_left := (
              Some (
                (
                  fun p lb ->
                    Yojson.Safe.read_space p lb;
                    let std_tuple = Yojson.Safe.start_any_tuple p lb in
                    let len = ref 0 in
                    let end_of_tuple = ref false in
                    (try
                      let x0 =
                        let x =
                          (
                            Atdgen_runtime.Oj_run.read_number
                          ) p lb
                        in
                        incr len;
                        Yojson.Safe.read_space p lb;
                        Yojson.Safe.read_tuple_sep2 p std_tuple lb;
                        x
                      in
                      let x1 =
                        let x =
                          (
                            Atdgen_runtime.Oj_run.read_number
                          ) p lb
                        in
                        incr len;
                        (try
                          Yojson.Safe.read_space p lb;
                          Yojson.Safe.read_tuple_sep2 p std_tuple lb;
                        with Yojson.End_of_tuple -> end_of_tuple := true);
                        x
                      in
                      if not !end_of_tuple then (
                        try
                          while true do
                            Yojson.Safe.skip_json p lb;
                            Yojson.Safe.read_space p lb;
                            Yojson.Safe.read_tuple_sep2 p std_tuple lb;
                          done
                        with Yojson.End_of_tuple -> ()
                      );
                      (x0, x1)
                    with Yojson.End_of_tuple ->
                      Atdgen_runtime.Oj_run.missing_tuple_fields p !len [ 0; 1 ]);
                ) p lb
              )
            );
          | 5 ->
            field_musicians := (
              Some (
                (
                  read__int_list
                ) p lb
              )
            );
          | 6 ->
            field_attendees := (
              Some (
                (
                  read__json_attendee_list
                ) p lb
              )
            );
          | _ -> (
              Yojson.Safe.skip_json p lb
            )
      );
      while true do
        Yojson.Safe.read_space p lb;
        Yojson.Safe.read_object_sep p lb;
        Yojson.Safe.read_space p lb;
        let f =
          fun s pos len ->
            if pos < 0 || len < 0 || pos + len > String.length s then
              invalid_arg (Printf.sprintf "out-of-bounds substring position or length: string = %S, requested position = %i, requested length = %i" s pos len);
            match len with
              | 9 -> (
                  match String.unsafe_get s pos with
                    | 'a' -> (
                        if String.unsafe_get s (pos+1) = 't' && String.unsafe_get s (pos+2) = 't' && String.unsafe_get s (pos+3) = 'e' && String.unsafe_get s (pos+4) = 'n' && String.unsafe_get s (pos+5) = 'd' && String.unsafe_get s (pos+6) = 'e' && String.unsafe_get s (pos+7) = 'e' && String.unsafe_get s (pos+8) = 's' then (
                          6
                        )
                        else (
                          -1
                        )
                      )
                    | 'm' -> (
                        if String.unsafe_get s (pos+1) = 'u' && String.unsafe_get s (pos+2) = 's' && String.unsafe_get s (pos+3) = 'i' && String.unsafe_get s (pos+4) = 'c' && String.unsafe_get s (pos+5) = 'i' && String.unsafe_get s (pos+6) = 'a' && String.unsafe_get s (pos+7) = 'n' && String.unsafe_get s (pos+8) = 's' then (
                          5
                        )
                        else (
                          -1
                        )
                      )
                    | _ -> (
                        -1
                      )
                )
              | 10 -> (
                  if String.unsafe_get s pos = 'r' && String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'o' && String.unsafe_get s (pos+3) = 'm' && String.unsafe_get s (pos+4) = '_' && String.unsafe_get s (pos+5) = 'w' && String.unsafe_get s (pos+6) = 'i' && String.unsafe_get s (pos+7) = 'd' && String.unsafe_get s (pos+8) = 't' && String.unsafe_get s (pos+9) = 'h' then (
                    0
                  )
                  else (
                    -1
                  )
                )
              | 11 -> (
                  match String.unsafe_get s pos with
                    | 'r' -> (
                        if String.unsafe_get s (pos+1) = 'o' && String.unsafe_get s (pos+2) = 'o' && String.unsafe_get s (pos+3) = 'm' && String.unsafe_get s (pos+4) = '_' && String.unsafe_get s (pos+5) = 'h' && String.unsafe_get s (pos+6) = 'e' && String.unsafe_get s (pos+7) = 'i' && String.unsafe_get s (pos+8) = 'g' && String.unsafe_get s (pos+9) = 'h' && String.unsafe_get s (pos+10) = 't' then (
                          1
                        )
                        else (
                          -1
                        )
                      )
                    | 's' -> (
                        if String.unsafe_get s (pos+1) = 't' && String.unsafe_get s (pos+2) = 'a' && String.unsafe_get s (pos+3) = 'g' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = '_' && String.unsafe_get s (pos+6) = 'w' && String.unsafe_get s (pos+7) = 'i' && String.unsafe_get s (pos+8) = 'd' && String.unsafe_get s (pos+9) = 't' && String.unsafe_get s (pos+10) = 'h' then (
                          2
                        )
                        else (
                          -1
                        )
                      )
                    | _ -> (
                        -1
                      )
                )
              | 12 -> (
                  if String.unsafe_get s pos = 's' && String.unsafe_get s (pos+1) = 't' && String.unsafe_get s (pos+2) = 'a' && String.unsafe_get s (pos+3) = 'g' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = '_' && String.unsafe_get s (pos+6) = 'h' && String.unsafe_get s (pos+7) = 'e' && String.unsafe_get s (pos+8) = 'i' && String.unsafe_get s (pos+9) = 'g' && String.unsafe_get s (pos+10) = 'h' && String.unsafe_get s (pos+11) = 't' then (
                    3
                  )
                  else (
                    -1
                  )
                )
              | 17 -> (
                  if String.unsafe_get s pos = 's' && String.unsafe_get s (pos+1) = 't' && String.unsafe_get s (pos+2) = 'a' && String.unsafe_get s (pos+3) = 'g' && String.unsafe_get s (pos+4) = 'e' && String.unsafe_get s (pos+5) = '_' && String.unsafe_get s (pos+6) = 'b' && String.unsafe_get s (pos+7) = 'o' && String.unsafe_get s (pos+8) = 't' && String.unsafe_get s (pos+9) = 't' && String.unsafe_get s (pos+10) = 'o' && String.unsafe_get s (pos+11) = 'm' && String.unsafe_get s (pos+12) = '_' && String.unsafe_get s (pos+13) = 'l' && String.unsafe_get s (pos+14) = 'e' && String.unsafe_get s (pos+15) = 'f' && String.unsafe_get s (pos+16) = 't' then (
                    4
                  )
                  else (
                    -1
                  )
                )
              | _ -> (
                  -1
                )
        in
        let i = Yojson.Safe.map_ident p f lb in
        Atdgen_runtime.Oj_run.read_until_field_value p lb;
        (
          match i with
            | 0 ->
              field_room_width := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_number
                  ) p lb
                )
              );
            | 1 ->
              field_room_height := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_number
                  ) p lb
                )
              );
            | 2 ->
              field_stage_width := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_number
                  ) p lb
                )
              );
            | 3 ->
              field_stage_height := (
                Some (
                  (
                    Atdgen_runtime.Oj_run.read_number
                  ) p lb
                )
              );
            | 4 ->
              field_stage_bottom_left := (
                Some (
                  (
                    fun p lb ->
                      Yojson.Safe.read_space p lb;
                      let std_tuple = Yojson.Safe.start_any_tuple p lb in
                      let len = ref 0 in
                      let end_of_tuple = ref false in
                      (try
                        let x0 =
                          let x =
                            (
                              Atdgen_runtime.Oj_run.read_number
                            ) p lb
                          in
                          incr len;
                          Yojson.Safe.read_space p lb;
                          Yojson.Safe.read_tuple_sep2 p std_tuple lb;
                          x
                        in
                        let x1 =
                          let x =
                            (
                              Atdgen_runtime.Oj_run.read_number
                            ) p lb
                          in
                          incr len;
                          (try
                            Yojson.Safe.read_space p lb;
                            Yojson.Safe.read_tuple_sep2 p std_tuple lb;
                          with Yojson.End_of_tuple -> end_of_tuple := true);
                          x
                        in
                        if not !end_of_tuple then (
                          try
                            while true do
                              Yojson.Safe.skip_json p lb;
                              Yojson.Safe.read_space p lb;
                              Yojson.Safe.read_tuple_sep2 p std_tuple lb;
                            done
                          with Yojson.End_of_tuple -> ()
                        );
                        (x0, x1)
                      with Yojson.End_of_tuple ->
                        Atdgen_runtime.Oj_run.missing_tuple_fields p !len [ 0; 1 ]);
                  ) p lb
                )
              );
            | 5 ->
              field_musicians := (
                Some (
                  (
                    read__int_list
                  ) p lb
                )
              );
            | 6 ->
              field_attendees := (
                Some (
                  (
                    read__json_attendee_list
                  ) p lb
                )
              );
            | _ -> (
                Yojson.Safe.skip_json p lb
              )
        );
      done;
      assert false;
    with Yojson.End_of_object -> (
        (
          {
            room_width = (match !field_room_width with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "room_width");
            room_height = (match !field_room_height with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "room_height");
            stage_width = (match !field_stage_width with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "stage_width");
            stage_height = (match !field_stage_height with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "stage_height");
            stage_bottom_left = (match !field_stage_bottom_left with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "stage_bottom_left");
            musicians = (match !field_musicians with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "musicians");
            attendees = (match !field_attendees with Some x -> x | None -> Atdgen_runtime.Oj_run.missing_field p "attendees");
          }
         : json_problem)
      )
)
let json_problem_of_string s =
  read_json_problem (Yojson.Safe.init_lexer ()) (Lexing.from_string s)
