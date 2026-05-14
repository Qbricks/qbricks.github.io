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

(** This module provides functions for reducing path sums in quantum circuits.
    This module implements reduction rules for path sums based on the techniques
    described in the following reference:
    - Amy (2019):
      {i "Towards Large-scale Functional Verification of Universal Quantum
         Circuits"}, {i Electronic Proceedings in Theoretical Computer Science},
      287:1-21. ({{:http://dx.doi.org/10.4204/EPTCS.287.1}DOI}) (ISSN:
      2075-2180). The reduction rules simplify path sums representing quantum
      states in the symbolic execution tool, using techniques from the paper
      including:
    - [Elim]
    - [HH]
    - [Variable_replacement]

    Additionally, the module includes:
    - [Rename]
    - [Simplification]*)

module Elim : sig
  (** This module implements the path variable elimination rule. It removes path
      variables from the list when they don't appear in either the ket or the
      phase polynomial. *)

  val elim : ?debug:bool -> Path_sum.t -> Path_sum.t
  (** [elim ?debug ps] Removes path variables that don't appear in either the
      phase or ket.

      Example:
      - [elim {phase = 0; ket = |x0,1>; [y0]}] returns
        [{phase = 0; ket = |x0,1>; []}] *)
end

module HH : sig
  (** This module implements the [HH] reduction rule for path variable
      elimination. *)

  val hh : ?debug:bool -> ?y0_to_remove:int -> Path_sum.t -> Path_sum.t
  (** [hh ?debug ?y0_to_remove ps] This rule looks for a path variable y0 that
      appears in the form:

      {[
        Phase = 1/2 * y0 * (yi + Q) + R
        Ket = |yi>
      ]}

      Where:
      - [y0] does not appear in [Q], [R], or the [Ket]
      - [yi] does not appear in [Q]

      When found, it performs the following transformation:
      - [New_phase = R] with [yi] replaced by [Q]
      - [New_ket = |Q>]

      Example (Double Hadamard gate application):

      {[
        Phase: 1/2 * y0 * y1 + 0
        Ket: |y1>
      ]}
      After applying [hh] rule:
      {[
        Phase: 0
        Ket: |x>
      ]}

      The optional [y0_to_remove] parameter specifies which path variable to
      eliminate. If not provided, the rule will automatically select a suitable
      [y0]. *)
end

module Rename : sig
  (** This module provides functions for renaming path variables to achieve a
      normalized form. *)

  val rename : ?debug:bool -> Path_sum.t -> Path_sum.t
  (** [rename ?debug ps] rename path variables while preserving ordering.

      Input:
      - [phase: 1/2*y13 + 1/2*y13*y8 + 1/4*y10]
      - [ket: |y13, y8, y10>]

      Output:
      - [phase: 1/2*y2 + 1/2*y2*y1 + 1/4*y0]
      - [ket: |y2, y1, y0>] *)

  (**/**)

  (** {2 Internal helpers}

      These functions are implementation details and may change. *)

  val _string_update_pvs : (int * int) list -> string
  (** Converts substitution list to string representation.

      [_string_update_pvs substitutions] converts a list of path variable
      substitutions to a string representation.

      Format: ["(old,new);(old,new);..."]

      Example: [_string_update_pvs [(5, 2); (7, 3); (9, 4)]] returns
      ["(5,2);(7,3);(9,4)"] *)

  val _find_update_path_var : Path_sum.t -> (int * int) list
  (** Computes substitution pairs for {!rename}.

      [_find_update_path_var ps] creates substitution pairs mapping path
      variables to new contiguous indices. The new indices start from the number
      of qubits in the path sum.

      For a path sum with 3 qubits and path variables [10; 12; 15], returns
      [(10, 3); (12, 4); (15, 5)] *)

  val _path_var_substitute : int list -> (int * int) list -> int list
  (** [_path_var_substitute vars substitutions] applies multiple substitutions
      to a list of path variables.

      Each substitution (old, new) replaces all occurrences of old with new.

      Example: [_path_var_substitute [10; 12; 15] [(10, 3); (12, 4); (15, 5)]]
      returns [3; 4; 5] *)

  val _substitute_path_var :
    ?debug:bool -> Path_sum.t -> (int * int) list -> Path_sum.t
  (** Applies substitutions to all components (phase, ket, path_var).

      This is the core substitution engine used by {!rename}. *)

  (* 
  val normalise_path_var : ?debug:bool -> Path_sum.t -> Path_sum.t
  (** [normalise_path_var ?debug ps] fully normalizes path variables to
      contiguous indices starting from 0. First applies [rename], then reorders.

      Input:
      - [phase: 1/2*y2 + 1/2*y2*y1 + 1/4*y0]
      - [ket: |y2, y1, y0>]

      Output:
      - [phase: 1/2*y0 + 1/2*y0*y1 + 1/4*y2]
      - [ket: |y0, y1, y2>]*)
       *)
end

module Simplification : sig
  (** This module provides functions for simplifying path sums. Simplifications
      are performed while preserving equivalence modulo 2π. *)

  val simplify : ?debug:bool -> Path_sum.t -> Path_sum.t
  (** [simplify ?debug ps] applies simplification rules to a path sum's phase
      and ket components. The phase polynomial ({m P(x,y)}) represents the
      exponent in {m e^{2 \pi i P(x,y)}}, so simplifications preserve the
      complex value.

      Example 1 (Phase simplification):
      {[
        Input:
        - Phase: 1/2*y0 + 1/4*y1*y2 + 1/2*y0
        - Ket: |y0 + y1>
        Output:
        - Phase: 1/4*y1*y2 (y0 terms cancel)
        - Ket: |y0 + y1>
      ]}

      Example 2 (Ket simplification):
      {[
        Input:
        - Phase: 0
        - Ket: |x0 + x0 + y1>
        Output:
        - Phase: 0
        - Ket: |y1> (x0 terms cancel)
      ]}

      Example 3 (Mix case):
      {[
        Input:
        - Phase: 1/2*y1 + 1/4*x0*y1 + 1/4*x0*y1
        - Ket: |x0 + y1 + y1>
        Output:
        - Phase: 1/2*y1 + 1/2*x0*y1
        - Ket: |x0>
      ]} *)
end

(* TODO: 
   - Review all functions in this module
   - Consider consolidating them into a single unified function
*)

module Variable_replacement : sig
  (** This module implements optimized variable replacement operations for path
      sums. The primary goal is to efficiently apply variable substitutions such
      as |y0 + y1> -> |y0>. Three specialized implementations are provided for
      different use cases.

      Additionally, [poly_normalized] normalizes path variables to achieve a
      canonical form. *)

  val variable_replacement : ?debug:bool -> Path_sum.t -> Path_sum.t option

  val variable_replacement_factorisation :
    ?debug:bool -> Path_sum.t -> Path_sum.t

  val replace_not_path_var_by_var : ?debug:bool -> Path_sum.t -> Path_sum.t
  val poly_normalized : ?debug:bool -> Path_sum.t -> Path_sum.t
end
