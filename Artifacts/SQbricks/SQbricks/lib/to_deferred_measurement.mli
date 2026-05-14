(**************************************************************************)
(*  This file is part of SQbricks.                                        *)
(*                                                                        *)
(*  Copyright (C) 2022-2026                                               *)
(*  CEA (Commissariat à l'énergie atomique et aux énergies alternatives)  *)
(*  Université Paris-Saclay                                               *)
(*                                                                        *)
(*  you can redistribute it and/or modify it under the terms of the GNU   *)
(*  Lesser General Public License as published by the Free Software       *)
(*  Foundation, version 2.1.                                              *)
(*                                                                        *)
(*  It is distributed in the hope that it will be useful,                 *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
(*  GNU Lesser General Public License for more details.                   *)
(*                                                                        *)
(*  See the GNU Lesser General Public License version 2.1                 *)
(*  for more details (enclosed in the file licenses/LGPLv2.1).            *)
(*                                                                        *)
(**************************************************************************)

(** This module translates quantum programs to deferred measurement form, where
    all measurements are moved to the end of the program. *)

val to_deferred_measurements :
  ?debug:bool -> Program.t -> Program.t * int list * int list
(** [to_deferred_measurements ?debug prog] converts [prog] to deferred
    measurement form. Returns:
    - A transformed program without measurement
    - List of initialized qubits
    - List of measured qubits

    Example:
    {[
      to_deferred_measurements (m 0 1)  (* Original program with measurement *)
      -> (E, [], [0])
    ]}

    {b Note}: The transformation preserves program semantics while restructuring
    measurement operations. *)
