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

(** This Module provides types and operations to represent and manipulate qubit
    expressions, used in path-sum. *)

open Common

(** {1 Type} *)

type t =
  | Zero
  | One
  | Var of int
  | Prod of t * t
  | SumMod2 of t * t
      (** The type of qubit expressions:
          - [Zero]: |0>
          - [One]: |1>
          - [Var 0]: |x0>
          - [Prod (Var 0, Var 1)]: |x0.x1>
          - [SumMod2 (One, Var 0)]: |1++x0> *)

(** {1 Comparison and Equality} *)

val equal :
  ?debug:bool ->
  ?wq1:int ->
  ?wq2:int ->
  ?map_path_var1:int IntMap.t ->
  ?map_path_var2:int IntMap.t ->
  t ->
  t ->
  bool
(** [equal ?debug ?wq1 ?wq2 ?map_path_var1 ?map_path_var2 q1 q2] compares two
    qubits [q1] and [q2] for structural equality, taking into account both *free
    variables* and *path variables*.

    - [wq1] and [wq2] are the numbers of *free variables* in [q1] and [q2]. A
      variable index smaller than [wq1] (resp. [wq2]) is considered a free
      variable; a variable index greater or equal to [wq1] (resp. [wq2]) is a
      *path variable*.

    - [map_path_var1] and [map_path_var2] are mappings between path variables
      encountered so far in [q1] and [q2]. They are used to ensure that two
      qubits are equivalent up to a consistent renaming of their path variables.

    - Returns [true] if [q1] and [q2] are structurally equivalent modulo
      renaming of path variables, [false] otherwise.

    For example:
    {[
      let q1 = SumMod2 (Var 1, Var 2)
      and q2 = SumMod2 (Var 3, Var 4) in
      Qubit.equal ~wq1:2 ~wq2:2 q1 q2;;
      - : bool = true
    ]}
    Both qubits have the same structure and differ only by path-variable
    indices. *)

val comp : t -> t -> int
(** [comp q1 q2] compares qubit expressions [q1] and [q2] for canonical
    ordering.

    Returns:
    - 0 if equal,
    - positive if [q1] < [q2],
    - negative if [q1] > [q2].

    Examples:
    - [comp Zero One] returns [1]
    - [comp (Var 2) (Var 1)] returns [-1] *)

(** {1 Operators} *)

val ( ++ ) : t -> t -> t
(** [q1 ++ q2] infix operator for sum modulo 2 of qubit expressions.

    Examples:
    - [(Var 1) ++ (Var 2)] returns [SumMod2(Var 1, Var 2)] *)

(** {1 Algebraic Operations} *)

val simplify : t -> t
(** [simplify q] applies algebraic simplification rules to expression [q].

    Examples:
    - [simplify (Prod (One, Var 1))] returns [Var 1]
    - [simplify (SumMod2 (x, x))] returns [Zero] *)

val substitute : int -> t -> t -> t
(** [substitute v q1 q2] replaces all occurrences of [Var v] with [q2] in [q1].

    Examples:
    - [substitute 1 (Var 2) (Var 1)] returns [Var 2]
    - [substitute 1 (Prod (Var 1, Var 2)) (Var 3)] returns [Prod (Var 3, Var 2)]
*)

(** {1 Variable Operations} *)

val member : int -> t -> bool
(** [member v q] checks if variable [v] appears in expression [q].

    Examples:
    - [member 1 (Var 1)] returns [true]
    - [member 1 (Prod (Var 1, Var 2))] returns [true] *)

val remove : int -> t -> t option
(** [remove v q] removes variable [Var v] from expression [q] when possible.

    Returns [None] if [Var v] cannot be isolated or isn't present.

    Examples:
    - [remove 1 (Prod (Var 1, Var 2))] returns [Some (Var 2)]
    - [remove 1 (Var 1)] returns [Some One]
    - [remove 1 (SumMod2 (Var 1, Var 2))] returns [None] *)

val extract_var : t -> int list
(** [extract_var q] returns all variables in expression [q].

    Examples:
    - [extract_var (Var 1)] returns [[1]]
    - [extract_var (Prod (Var 1, Var 2))] returns [[1; 2]] *)

val extract_path_var : ?debug:bool -> t -> int -> int list
(** [extract_path_var q width] returns path variables from expression [q].

    Examples:
    - [extract_path_var (Var 3) 2] returns [[3]]
    - [extract_path_var (Prod (Var 1, Var 3)) 2] returns [[3]] *)

(** {1 Analysis} *)

val number_of_sum : t -> int
(** [number_of_sum q] counts [SumMod2] operations in expression [q].

    Examples:
    - [number_of_sum (SumMod2 (Var 1, Var 2))] returns [1]
    - [number_of_sum (SumMod2 (Var 1, SumMod2 (Var 2, Var 3)))] returns [2] *)

(** {1 String Representation} *)

module String : sig
  val pretty : t -> int -> string
  (** [pretty q width] pretty prints expression [q] with context width [width].

      Examples:
      - [pretty (Var 1) 2] returns ["x1"]
      - [pretty (Var 3) 2] returns ["y1"] *)

  val exact : t -> string
  (** [exact q] returns the exact constructor representation of expression [q].

      Examples:
      - [exact (Var 1)] returns ["(Var 1)"]
      - [exact (Prod (Var 1, Var 2))] returns ["Prod(Var 1,Var 2)"] *)
end
