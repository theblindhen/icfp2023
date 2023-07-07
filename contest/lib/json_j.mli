(* Auto-generated from "json.atd" *)
[@@@ocaml.warning "-27-32-33-35-39"]

type json_score = Json_t.json_score = {
  score_failure (*atd failure *): string option;
  score_success (*atd success *): float option
}

type json_submission_get_success_submission =
  Json_t.json_submission_get_success_submission = {
  submission_get__id (*atd _id *): string;
  submission_get_problem_id (*atd problem_id *): float;
  submission_get_user_id (*atd user_id *): string;
  submission_get_score (*atd score *): json_score;
  submission_get_submitted_at (*atd submitted_at *): string
}

type json_submission_get_success = Json_t.json_submission_get_success = {
  submission_get_submission (*atd submission *):
    json_submission_get_success_submission;
  submission_get_contents (*atd contents *): string
}

type json_submission_get = Json_t.json_submission_get = {
  submission_getsuccess (*atd success *): json_submission_get_success option;
  submission_getfailure (*atd failure *): string option
}

type json_placement = Json_t.json_placement = {
  placement_x (*atd x *): float;
  placement_y (*atd y *): float
}

type json_solution = Json_t.json_solution = {
  solution_placement (*atd placement *): json_placement list
}

type json_attendee = Json_t.json_attendee = {
  attendee_x (*atd x *): float;
  attendee_y (*atd y *): float;
  attendee_tastes (*atd tastes *): float list
}

type json_problem = Json_t.json_problem = {
  problem_room_width (*atd room_width *): float;
  problem_room_height (*atd room_height *): float;
  problem_stage_width (*atd stage_width *): float;
  problem_stage_height (*atd stage_height *): float;
  problem_stage_bottom_left (*atd stage_bottom_left *): (float * float);
  problem_musicians (*atd musicians *): int list;
  problem_attendees (*atd attendees *): json_attendee list
}

val write_json_score :
  Buffer.t -> json_score -> unit
  (** Output a JSON value of type {!type:json_score}. *)

val string_of_json_score :
  ?len:int -> json_score -> string
  (** Serialize a value of type {!type:json_score}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_json_score :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> json_score
  (** Input JSON data of type {!type:json_score}. *)

val json_score_of_string :
  string -> json_score
  (** Deserialize JSON data of type {!type:json_score}. *)

val write_json_submission_get_success_submission :
  Buffer.t -> json_submission_get_success_submission -> unit
  (** Output a JSON value of type {!type:json_submission_get_success_submission}. *)

val string_of_json_submission_get_success_submission :
  ?len:int -> json_submission_get_success_submission -> string
  (** Serialize a value of type {!type:json_submission_get_success_submission}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_json_submission_get_success_submission :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> json_submission_get_success_submission
  (** Input JSON data of type {!type:json_submission_get_success_submission}. *)

val json_submission_get_success_submission_of_string :
  string -> json_submission_get_success_submission
  (** Deserialize JSON data of type {!type:json_submission_get_success_submission}. *)

val write_json_submission_get_success :
  Buffer.t -> json_submission_get_success -> unit
  (** Output a JSON value of type {!type:json_submission_get_success}. *)

val string_of_json_submission_get_success :
  ?len:int -> json_submission_get_success -> string
  (** Serialize a value of type {!type:json_submission_get_success}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_json_submission_get_success :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> json_submission_get_success
  (** Input JSON data of type {!type:json_submission_get_success}. *)

val json_submission_get_success_of_string :
  string -> json_submission_get_success
  (** Deserialize JSON data of type {!type:json_submission_get_success}. *)

val write_json_submission_get :
  Buffer.t -> json_submission_get -> unit
  (** Output a JSON value of type {!type:json_submission_get}. *)

val string_of_json_submission_get :
  ?len:int -> json_submission_get -> string
  (** Serialize a value of type {!type:json_submission_get}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_json_submission_get :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> json_submission_get
  (** Input JSON data of type {!type:json_submission_get}. *)

val json_submission_get_of_string :
  string -> json_submission_get
  (** Deserialize JSON data of type {!type:json_submission_get}. *)

val write_json_placement :
  Buffer.t -> json_placement -> unit
  (** Output a JSON value of type {!type:json_placement}. *)

val string_of_json_placement :
  ?len:int -> json_placement -> string
  (** Serialize a value of type {!type:json_placement}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_json_placement :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> json_placement
  (** Input JSON data of type {!type:json_placement}. *)

val json_placement_of_string :
  string -> json_placement
  (** Deserialize JSON data of type {!type:json_placement}. *)

val write_json_solution :
  Buffer.t -> json_solution -> unit
  (** Output a JSON value of type {!type:json_solution}. *)

val string_of_json_solution :
  ?len:int -> json_solution -> string
  (** Serialize a value of type {!type:json_solution}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_json_solution :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> json_solution
  (** Input JSON data of type {!type:json_solution}. *)

val json_solution_of_string :
  string -> json_solution
  (** Deserialize JSON data of type {!type:json_solution}. *)

val write_json_attendee :
  Buffer.t -> json_attendee -> unit
  (** Output a JSON value of type {!type:json_attendee}. *)

val string_of_json_attendee :
  ?len:int -> json_attendee -> string
  (** Serialize a value of type {!type:json_attendee}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_json_attendee :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> json_attendee
  (** Input JSON data of type {!type:json_attendee}. *)

val json_attendee_of_string :
  string -> json_attendee
  (** Deserialize JSON data of type {!type:json_attendee}. *)

val write_json_problem :
  Buffer.t -> json_problem -> unit
  (** Output a JSON value of type {!type:json_problem}. *)

val string_of_json_problem :
  ?len:int -> json_problem -> string
  (** Serialize a value of type {!type:json_problem}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_json_problem :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> json_problem
  (** Input JSON data of type {!type:json_problem}. *)

val json_problem_of_string :
  string -> json_problem
  (** Deserialize JSON data of type {!type:json_problem}. *)

