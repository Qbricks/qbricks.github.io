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

(** This module provides types and functions to represent and manipulate path
    sums, which are symbolic forms of quantum states used during circuit
    verification.

    A path sum is defined by:
    - A phase polynomial ({!Poly}),
    - A quantum state ({!Ket}),
    - A set of path variables.

    {b References}:
    - Chareton et al. (2021):
      {i "An Automated Deductive Verification Framework for Circuit-building
         Quantum Programs"}, In {i Programming Languages and Systems}, Springer.
      [DOI](http://dx.doi.org/10.1007/978-3-030-72019-3_6) (ISBN:
      978-3-030-72019-3).

    - Amy (2019):
      {i "Towards Large-scale Functional Verification of Universal Quantum
         Circuits"}, {i Electronic Proceedings in Theoretical Computer Science},
      287:1-21. [DOI](http://dx.doi.org/10.4204/EPTCS.287.1) (ISSN: 2075-2180).
*)

open Common

(** {1 Ket} *)

module Ket : sig
  (** {2 Types} *)

  type t = Qubit.t array
  (** Type of [Ket], represented as arrays of qubits ({!Qubit}). *)

  (** {2 Basic Operations} *)

  val copy : t -> t
  (** [copy ket] creates a fresh copy of [ket] (see
      {{:https://ocaml.org/manual/5.4/api/Array.html#VALcopy} Array.copy}). *)

  val equal :
    ?debug:bool ->
    ?outputs1:int list ->
    ?outputs2:int list ->
    t ->
    t ->
    bool * int IntMap.t * int IntMap.t
  (** [equal ?debug ?outputs1 ?outputs2 k1 k2] compares two kets [k1] and [k2]
      (arrays of qubits) for structural and logical equivalence, possibly up to
      a renaming of their internal path variables.

      The comparison is performed qubit by qubit:
      - If [outputs1] and [outputs2] are provided, only the qubits at those
        indices are compared.
      - Otherwise, all qubits are compared in order.

      The function returns a triple [(eq, map1, map2)] where:
      - [eq] is [true] if [k1] and [k2] are equivalent modulo a consistent
        renaming of path variables;
      - [map1] is a mapping of path variables from [k1] to [k2];
      - [map2] is the inverse mapping (from [k2] to [k1]).

      These mappings are constructed incrementally during comparison: whenever a
      new pair of path variables is matched, it is added to both maps to ensure
      consistent correspondence.

      For example:
      {[
        let k1 = [| Var 1; SumMod2 (Var 2, Var 3) |]
        and k2 = [| Var 4; SumMod2 (Var 5, Var 6) |] in
        Ket.equal k1 k2;;
        - : bool * int IntMap.t * int IntMap.t =
          (true, {1 -> 4; 2 -> 5; 3 -> 6}, {4 -> 1; 5 -> 2; 6 -> 3})
      ]}

      If the number of qubits or output indices differ,
      [(false, IntMap.empty, IntMap.empty)] is returned. *)

  val member : ?except:int -> int -> t -> bool
  (** [member ?except var state] checks if variable [var] is present in the
      quantum state, optionally excluding one qubit.

      Example(s):
      - [member 1 [|Var 1; Var 2|]] returns [true]
      - [member ~except:1 1 [|Var 1; Var 2|]] returns [false] *)

  val simplify : t -> t
  (** [simplify state] simplifies qubit expressions within the state.

      Example(s):
      - [simplify [|Prod(One, Var 1)|]] returns [[|Var 1|]] *)

  (** {2 Variable Extraction} *)

  val extract_path_var : ?debug:bool -> ?outputs:int list -> t -> int list
  (** [extract_path_var ?debug ?outputs state] extracts path variables from the
      quantum state, optionally limited to specific qubit indices.

      Example(s):
      - [extract_path_var [|Var 3|]] returns [[3]] *)

  val extract_var : t -> int list -> int list
  (** [extract_var ket indices] extracts variables from specific qubits.

      Example(s):
      - [extract_var [|Var 1; Var 2|] [0;1]] returns [[1; 2]]
      - [extract_var [|Var 1; Var 2|] [0]] returns [[1]] *)

  (** Need to have an input "Renamed" ([Rules.Rename.single])*)
  val path_var_order : ?debug:bool -> t -> int -> int array * int array
  (** Compute the ordering of path variables in a given ket. *)

  val list_of_qubits_to_ket : Qubit.t list -> t
  (** [list_of_qubits_to_ket qubits] converts a list of qubits into a quantum
      state (ket).

      Example(s):
      - [list_of_qubits_to_ket [Var 1; Var 2]] returns [[|Var 1; Var 2|]] *)

  val number_of_sum : t -> int
  (** [number_of_sum state] counts the number of [SumMod2] constructs in the
      ket.

      Example(s):
      - [number_of_sum [|SumMod2(Var 1, Var 2)|]] returns [1] *)

  (** {2 String Conversion} *)

  module String : sig
    val pretty : t -> string
    (** [pretty state] converts a ket to a human-readable string.

        Example(s):
        - [pretty [|Var 1; Var 2|]] returns ["|x1,x2>"] *)

    val exact : t -> string
    (** [exact state] converts a ket to its exact constructor form.

        Example(s):
        - [exact [|Var 1; Var 2|]] returns ["[|Var 1; Var 2|]"] *)
  end

  (** {2 Substitution} *)

  val substitute : ?debug:bool -> t -> int -> Qubit.t -> t
  (** [substitute ?debug state var expr] substitutes occurrences of variable
      [var] in the ket [state] with qubit expression [expr].

      Example(s):
      - [substitute [|Var 1|] 1 (Var 2)] returns [[|Var 2|]] *)
end

(** {1 Path Sum Representation} *)

type t = { phase : Poly.t; ket : Ket.t; path_var : int list }
(** Type representing a path sum. *)

val copy : t -> t
(** [copy ps] returns a deep copy of the path sum. *)

(** {2 String Conversion} *)

module String : sig
  val exact : t -> string
  (** [exact ps] converts a path sum to its exact constructor form.

      Example(s):
      - [exact {phase = Poly.zero; ket = [|Var 1|]; path_var = []}] returns
        ["phase = ; ket = [|Var 1|]; path_var = ;"] *)

  val pretty : t -> string
  (** [pretty ps] converts a path sum into a human-readable form.

      Example(s):
      - [pretty {phase = Poly.zero; ket = [|Var 1|]; path_var = []}] returns
        ["phase = e^{2πi·0};\nket = |x1>;\npath_var = ;"] *)

  val path_var : int list -> int -> string
  (** [path_var vars offset] converts a list of path variables to a string.

      Example(s):
      - [path_var [1; 2] 0] returns ["1;2"] *)
end

(** {1 Comparison and Equality} *)

val equal :
  ?debug:bool ->
  ?outputs1:int list ->
  ?outputs2:int list ->
  ?global_phase:bool ->
  t ->
  t ->
  bool
(** [equal ?debug ?outputs1 ?outputs2 ?global_phase ps1 ps2] checks whether two
    path sums [ps1] and [ps2] are equivalent up to qubits mapping, optionally
    ignoring global phase and restricting comparison to output qubits. *)

(** {1 Construction and Initialization} *)

val ofSize : int -> t
(** [ofSize width] creates a path sum with given width, where each qubit is
    initialized as a variable.

    Example(s):
    - [ofSize 2] returns a path sum with qubits [[|Var 0; Var 1|]]. *)

val ofSize_init : ?debug:bool -> int -> int list -> t
(** [ofSize_init ?debug width init_values] creates an initial path sum with
    given width and initialization values.

    Example(s):
    - [ofSize_init 2 [0; Var 0]] initializes the first qubit to 0 and the second
      as a variable. *)

val remove_path_var : t -> int -> t
(** [remove_path_var ps var] removes the path variable [var] from the path sum.
*)

val substitute :
  ?debug:bool -> ?except_path_var:bool -> t -> int -> Qubit.t -> t
(** [substitute ?debug ?except_path_var ps var expr] substitutes occurrences of
    variable [var] in the path sum [ps] with qubit expression [expr]. If
    [except_path_var] is [true], path variables are not substituted. *)

(** {1 Path Sum Library} *)

module Path_sum_library : sig
  (** Quantum gate constructors as path sums. *)

  val h : int -> int -> t
  (** [h target width] creates a Hadamard gate:
      {b (1/√2) Σ_y e^(2πi x·y / 2) |y⟩}.

      Example(s):
      - [h 0 1] creates a Hadamard gate on qubit 0 with width 1. *)

  val x : int -> int -> t
  (** [x target width] creates a Pauli-X (bit-flip) gate.

      Example(s):
      - [x 0 1] creates an X gate on qubit 0 with width 1. *)

  val u1 : ?s:int -> int -> int -> int -> t
  (** [u1 ?s target k width] creates a phase gate: {b e^(2πi s·x / 2^k) |x⟩}.

      Example(s):
      - [u1 0 1 1] creates a U1 gate with s=1, k=1 on qubit 0. *)

  val z : int -> int -> t
  (** [z target width] creates a Pauli-Z gate.

      Example(s):
      - [z 0 1] creates a Z gate on qubit 0 with width 1. *)

  val s : int -> int -> t
  (** [s target width] creates an S gate (π/2 phase gate).

      Example(s):
      - [s 0 1] creates an S gate on qubit 0. *)

  val t : int -> int -> t
  (** [t target width] creates a T gate (π/4 phase gate).

      Example(s):
      - [t 0 1] creates a T gate on qubit 0. *)

  val zinv : int -> int -> t
  (** [zinv target width] creates an inverse Z gate. *)

  val sinv : int -> int -> t
  (** [sinv target width] creates an inverse S gate. *)

  val tinv : int -> int -> t
  (** [tinv target width] creates an inverse T gate. *)

  val rz : ?s:int -> int -> int -> int -> t
  (** [rz ?s target k width] creates a Z-rotation gate:
      {b e^(2πi (s·x / 2^k - s / 2^(k+1))) |x⟩}. *)

  val rx : ?s:int -> int -> int -> int -> t
  (** [rx ?s target k width] creates an X-rotation gate. *)

  val ry : ?s:int -> int -> int -> int -> t
  (** [ry ?s target k width] creates a Y-rotation gate. *)

  val ch : int -> int -> int -> t
  (** [ch control target width] creates a controlled-Hadamard gate. *)

  val cx : int -> int -> int -> t
  (** [cx control target width] creates a CNOT gate. *)

  val crz : int -> int -> int -> int -> t
  (** [crz s control target width] creates a controlled-RZ gate. *)

  val cz : int -> int -> int -> t
  (** [cz control target width] creates a controlled-Z gate. *)

  val cs : int -> int -> int -> t
  (** [cs control target width] creates a controlled-S gate. *)

  val ct : int -> int -> int -> t
  (** [ct control target width] creates a controlled-T gate. *)

  val ccx : int -> int -> int -> int -> t
  (** [ccx control1 control2 target width] creates a Toffoli (CCX) gate. *)

  val ccz : int -> int -> int -> int -> t
  (** [ccz control1 control2 target width] creates a double-controlled Z gate.
  *)

  val sh3 : t
  (** [sh3] predefined state for testing and demonstration purposes. *)
end
