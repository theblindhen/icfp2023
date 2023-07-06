(* Auto-generated from "punting.atd" *)
[@@@ocaml.warning "-27-32-33-35-39"]

type title_msg = Punting_t.title_msg = { title_title (*atd title *): string }

type start_msg = Punting_t.start_msg = {
  start_game_id (*atd game_id *): int
}

type deep_b = Punting_t.deep_b = {
  deep_c (*atd c *): bool;
  deep_d (*atd d *): int list
}

type deep_msg = Punting_t.deep_msg = {
  deep_a (*atd a *): int;
  deep_b (*atd b *): deep_b
}

val write_title_msg :
  Buffer.t -> title_msg -> unit
  (** Output a JSON value of type {!type:title_msg}. *)

val string_of_title_msg :
  ?len:int -> title_msg -> string
  (** Serialize a value of type {!type:title_msg}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_title_msg :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> title_msg
  (** Input JSON data of type {!type:title_msg}. *)

val title_msg_of_string :
  string -> title_msg
  (** Deserialize JSON data of type {!type:title_msg}. *)

val write_start_msg :
  Buffer.t -> start_msg -> unit
  (** Output a JSON value of type {!type:start_msg}. *)

val string_of_start_msg :
  ?len:int -> start_msg -> string
  (** Serialize a value of type {!type:start_msg}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_start_msg :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> start_msg
  (** Input JSON data of type {!type:start_msg}. *)

val start_msg_of_string :
  string -> start_msg
  (** Deserialize JSON data of type {!type:start_msg}. *)

val write_deep_b :
  Buffer.t -> deep_b -> unit
  (** Output a JSON value of type {!type:deep_b}. *)

val string_of_deep_b :
  ?len:int -> deep_b -> string
  (** Serialize a value of type {!type:deep_b}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_deep_b :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> deep_b
  (** Input JSON data of type {!type:deep_b}. *)

val deep_b_of_string :
  string -> deep_b
  (** Deserialize JSON data of type {!type:deep_b}. *)

val write_deep_msg :
  Buffer.t -> deep_msg -> unit
  (** Output a JSON value of type {!type:deep_msg}. *)

val string_of_deep_msg :
  ?len:int -> deep_msg -> string
  (** Serialize a value of type {!type:deep_msg}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_deep_msg :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> deep_msg
  (** Input JSON data of type {!type:deep_msg}. *)

val deep_msg_of_string :
  string -> deep_msg
  (** Deserialize JSON data of type {!type:deep_msg}. *)

