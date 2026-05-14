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

(** This module converts quantum programs to OpenQASM 2.0 format for quantum
    circuit description and interoperability with quantum computing tools.

    Based on:
    - Cross et al. (2017),
      {{:https://arxiv.org/abs/1707.03429} "Open Quantum Assembly Language"}.
      Sources:
      {{:https://github.com/openqasm/openqasm/tree/OpenQASM2.x}OpenQASM GitHub}.

    Includes optional conversions for:
    - {{:https://github.com/fmlab-iis/AutoQ/tree/POPL25ae}AutoQ version
       POPL25ae}
    - {{:https://github.com/fmlab-iis/AutoQ/tree/2.0}AutoQ version 2.0}
    - {{:https://github.com/zxcalc/pyzx/tree/v0.9.0}PyZX version 0.9.0} *)

(** {2 OpenQASM Operations} *)

(** Type of quantum operations in OpenQASM format:
    - {b U1(angle, target)}: Phase gate with angle on target qubit
    - {b H target}: Hadamard gate on target
    - {b X target}: Pauli X gate on target
    - {b ID}: Identity operation
    - {b CX(control, target)}: Controlled X gate
    - {b CU1(angle, control, target)}: Controlled phase gate
    - {b CH(control, target)}: Controlled Hadamard gate
    - {b CCX(c1, c2, target)}: Toffoli gate
    - {b MEASURE(qubit, bit)}: Measurement operation
    - {b IF(bit, op)}: Conditional operation
    - {b SEQUENCE(op1, op2)}: Sequential composition
    - {b QREG size}: Qubit register declaration
    - {b CREG size}: Classical register declaration
    - {b RESET target}: Qubit reset operation *)
type t =
  | U1 of Q.t * int
  | H of int
  | X of int
  | ID
  | CX of int * int
  | CU1 of Q.t * int * int
  | CH of int * int
  | CCX of int * int * int
  | MEASURE of int * int
  | IF of int * t
  | SEQUENCE of t * t
  | QREG of int
  | CREG of int
  | RESET of int

(** {2 Conversion Functions} *)

val string_oq :
  ?for_autoq:bool -> ?for_pyzx:bool -> ?one_creg:bool -> Program.t -> string
(** [string_oq ?for_autoq ?for_pyzx ?one_creg prog] converts [prog] to OpenQASM
    format string.

    Example: [string_oq (h 0)] returns "OPENQASM 2.0...h q[0];" *)

val print_to_file_oq :
  ?for_autoq:bool ->
  ?for_pyzx:bool ->
  ?one_creg:bool ->
  string ->
  Program.t ->
  unit
(** [print_to_file_oq ?for_autoq ?for_pyzx ?one_creg filename prog] writes
    [prog] to OpenQASM file in benchmarks_qasm folder. *)

val print_to_file_oq_free_folder :
  ?for_autoq:bool ->
  ?for_pyzx:bool ->
  ?one_creg:bool ->
  string ->
  Program.t ->
  unit
(** [print_to_file_oq_free_folder ?for_autoq ?for_pyzx ?one_creg path prog]
    writes [prog] to specified file path. *)
