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

(** This module converts quantum programs to Feynman format for circuit
    verification and analysis, based on: Amy (2019),
    {i "Towards Large-scale Functional Verification of Universal Quantum
       Circuits"}, EPTCS 287:1-21.
    ({{:http://dx.doi.org/10.4204/EPTCS.287.1} DOI}) *)

(** {2 Feynman Operations} *)

(** Type of quantum operations in Feynman format:
    - {b H target}: Hadamard gate on target qubit
    - {b X target}: Pauli X gate on target qubit
    - {b RZ(angle, target)}: Z-rotation with angle on target
    - {b CX(control, target)}: Controlled X gate
    - {b CCX(c1, c2, target)}: Toffoli gate with controls c1,c2
    - {b CZ(control, target)}: Controlled Z gate
    - {b CCZ(c1, c2, target)}: Controlled-controlled Z gate
    - {b CCZDG(c1, c2, target)}: Controlled-controlled Z dagger gate
    - {b I}: Identity operation
    - {b SEQUENCE(op1, op2)}: Sequential composition *)
type t =
  | H of int
  | X of int
  | RZ of Q.t * int
  | CX of int * int
  | CCX of int * int * int
  | CZ of (int * int)
  | CCZ of (int * int * int)
  | CCZDG of (int * int * int)
  | I
  | SEQUENCE of t * t

(** {2 Conversion Functions} *)

val into_feynman : Program.t -> Program.t
(** [into_feynman prog] converts [prog] to intermediate Feynman format.

    Example decomposition of CH gate:
    {[
      into_feynman (ch 0 1) ->
        SEQUENCE(
          SS 1, SEQUENCE(
            H 1, SEQUENCE(
              TINV 1, SEQUENCE(
                H 1, SEQUENCE(
                  CX(0,1), SEQUENCE(
                    TINV 1, SEQUENCE(
                      CX(0,1), SEQUENCE(
                        TINV 1, SEQUENCE(
                          H 1, SEQUENCE(
                            T 1, SS 1)))))))))
    ]} *)

val to_feynman : ?debug:bool -> Program.t -> t
(** [to_feynman ?debug prog] converts [prog] to Feynman format. *)

val print_to_file_fm :
  ?inputs:int list -> ?debug:bool -> string -> Program.t -> unit
(** [print_to_file_fm ?inputs ?debug filename prog] writes [prog] in Feynman
    format to [filename]. *)
