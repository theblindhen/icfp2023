(* Auto-generated from "json.atd" *)
[@@@ocaml.warning "-27-32-33-35-39"]

type solution_placement = Json_t.solution_placement = {
  placement_x (*atd x *): float;
  placement_y (*atd y *): float
}

type solution = Json_t.solution = {
  solution_placement (*atd placement *): solution_placement list
}

type attendee = Json_t.attendee = {
  attendee_x (*atd x *): float;
  attendee_y (*atd y *): float;
  attendee_tastes (*atd tastes *): float list
}

type problem = Json_t.problem = {
  problem_room_width (*atd room_width *): float;
  problem_room_height (*atd room_height *): float;
  problem_stage_width (*atd stage_width *): float;
  problem_stage_height (*atd stage_height *): float;
  problem_stage_bottom_left (*atd stage_bottom_left *): (float * float);
  problem_musicians (*atd musicians *): int list;
  problem_attendees (*atd attendees *): attendee list
}

val write_solution_placement :
  Buffer.t -> solution_placement -> unit
  (** Output a JSON value of type {!type:solution_placement}. *)

val string_of_solution_placement :
  ?len:int -> solution_placement -> string
  (** Serialize a value of type {!type:solution_placement}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_solution_placement :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> solution_placement
  (** Input JSON data of type {!type:solution_placement}. *)

val solution_placement_of_string :
  string -> solution_placement
  (** Deserialize JSON data of type {!type:solution_placement}. *)

val write_solution :
  Buffer.t -> solution -> unit
  (** Output a JSON value of type {!type:solution}. *)

val string_of_solution :
  ?len:int -> solution -> string
  (** Serialize a value of type {!type:solution}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_solution :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> solution
  (** Input JSON data of type {!type:solution}. *)

val solution_of_string :
  string -> solution
  (** Deserialize JSON data of type {!type:solution}. *)

val write_attendee :
  Buffer.t -> attendee -> unit
  (** Output a JSON value of type {!type:attendee}. *)

val string_of_attendee :
  ?len:int -> attendee -> string
  (** Serialize a value of type {!type:attendee}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_attendee :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> attendee
  (** Input JSON data of type {!type:attendee}. *)

val attendee_of_string :
  string -> attendee
  (** Deserialize JSON data of type {!type:attendee}. *)

val write_problem :
  Buffer.t -> problem -> unit
  (** Output a JSON value of type {!type:problem}. *)

val string_of_problem :
  ?len:int -> problem -> string
  (** Serialize a value of type {!type:problem}
      into a JSON string.
      @param len specifies the initial length
                 of the buffer used internally.
                 Default: 1024. *)

val read_problem :
  Yojson.Safe.lexer_state -> Lexing.lexbuf -> problem
  (** Input JSON data of type {!type:problem}. *)

val problem_of_string :
  string -> problem
  (** Deserialize JSON data of type {!type:problem}. *)

