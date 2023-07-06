(* Auto-generated from "punting.atd" *)
[@@@ocaml.warning "-27-32-33-35-39"]

type title_msg = { title_title (*atd title *): string }

type start_msg = { start_game_id (*atd game_id *): int }

type deep_b = { deep_c (*atd c *): bool; deep_d (*atd d *): int list }

type deep_msg = { deep_a (*atd a *): int; deep_b (*atd b *): deep_b }
