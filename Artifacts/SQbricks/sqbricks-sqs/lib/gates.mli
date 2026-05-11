(**************************************************************************)
(*  This file is part of SQbricks.                                        *)
(*                                                                        *)
(*  Copyright (C) 2022-2025                                               *)
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

(** This module provides types and functions for working with quantum gates in
    the context of path sum calculations for quantum circuit verification. *)

(** {1 Quantum Gates} *)

(** Type of quantum gates:
    - {b GP(s, k)}: Global phase gate with angle {b 2πs/2^k}
    - {b U1(s, k)}: Phase gate with angle {b 2πs/2^k}
    - {b X}: Pauli X gate
    - {b H}: Hadamard gate *)
type t = GP of Q.t * int | U1 of Q.t * int | X | H

(** {2 Basic Operations} *)

val to_string : t -> string
(** [to_string gate] converts a gate to a human-readable string. Example:
    - [to_string (U1 (Q.one, 1))] returns {b "Rz(1.2π/2^1)"} *)

val equal : t -> t -> bool
(** [equal g1 g2] checks equality of two quantum gates. Example:
    - [equal (U1 (Q.one, 1)) (U1 (Q.one, 1))] returns [true] *)

(** {1 Gate Application} *)

module Apply_gates : sig
  val apply_hadamard : Path_sum.t -> int list -> int -> Path_sum.t
  (** [apply_hadamard ps controls target] applies a Hadamard gate to target
      qubit, controlled by qubits in [controls]. *)

  val apply_u1 :
    ?debug:bool -> Q.t -> Path_sum.t -> int list -> int -> Path_sum.t
  (** [apply_u1 k ps controls target] applies a U1 gate with parameter [k] to
      target qubit, controlled by qubits in [controls]. *)

  val apply_not : Path_sum.t -> int list -> int -> Path_sum.t
  (** [apply_not ps controls target] applies a quantum NOT gate. *)

  val apply_classical_not : Path_sum.t -> int -> Path_sum.t
  (** [apply_classical_not ps target] applies a classical NOT gate. *)

  val apply_gp : Q.t -> Path_sum.t -> int list -> Path_sum.t
  (** [apply_gp k ps controls] applies a global phase gate. *)
end
