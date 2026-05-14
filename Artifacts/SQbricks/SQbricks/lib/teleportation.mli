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

(** This module provides functions for generating and working with quantum
    teleportation circuits, which are used to transfer quantum states between
    qubits without physical movement. *)

val to_teleport :
  ?debug:bool ->
  ?false_teleportation:bool ->
  ?dm:bool ->
  Program.t ->
  Program.t * int list * int list
(** [to_teleport ?debug ?false_teleportation ?dm prog] converts a quantum
    program to a teleportation-based circuit.

    Parameters:
    - [false_teleportation]: if true, enables false teleportation mode.
    - [dm]: if true, enables Deferred Measurement mode.
    - [prog]: the input quantum program to be converted.

    Returns a tuple [(teleported_circuit, input_qubits, output_qubits)], where:
    - [teleported_circuit] is the resulting teleportation-based circuit.
    - [input_qubits] is a list of input qubit indices.
    - [output_qubits] is a list of output qubit indices.

    Example: [to_teleport (h 0)] returns [(teleported_circuit, [0], [2])] *)
