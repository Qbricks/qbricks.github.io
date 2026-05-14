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

(** This module provides types and functions for working with polynomials used
    in path sums. *)

open Common

(** {1 Monomials} *)

(** Monomial operations for quantum path sum polynomials. *)
module Monome : sig
  type q = Qubit.t
  (** Alias for qubit expressions. *)

  (** Monomials in polynomial expressions.

      Example(s):
      - [Scal (Q.of_int 2)] -> 2
      - [Qubit (Var 1)] -> x1
      - [Prod (Scal Q.one, Qubit (Var 1))] -> 1.x1
      - [Prod (Qubit (Var 1), Qubit (Var 2))] -> x1.x2 *)
  type t = Scal of Q.t | Qubit of q | Prod of t * t

  (** {2 Comparison and Equality} *)

  val equal :
    ?debug:bool ->
    ?wq1:int ->
    ?wq2:int ->
    ?map_path_var1:int IntMap.t ->
    ?map_path_var2:int IntMap.t ->
    t ->
    t ->
    bool
  (** [equal m1 m2] checks equality of monomials [m1] and [m2], considering
      variable mappings and context widths.

      Example(s):
      - [equal (Qubit (Var 1)) (Qubit (Var 1))] returns [true] *)

  val compare : t -> t -> int
  (** [compare m1 m2] compares monomials [m1] and [m2] for ordering.

      Example(s):
      - if [m1 < m2] returns [k], where k > 0
      - if [m1 = m2] returns [0]
      - if [m1 > m2] returns [k], where k < 0
      - [compare (Qubit (Var 1)) (Qubit (Var 2))] returns [-1] *)

  (** {2 Simplification} *)

  val simplify : ?debug:bool -> t -> t
  (** [simplify m] simplifies monomial [m] by applying algebraic rules.

      Example(s):
      - [simplify (Prod (Scal (Q.of_int 1), Qubit (Var 1)))] returns
        [Qubit (Var 1)] *)

  (** {2 Variable Operations} *)

  val member : int -> t -> bool
  (** [member v m] checks if variable [v] is present in monomial [m].

      Example(s):
      - [member 1 (Qubit (Var 1))] returns [true]
      - [member 2 (Qubit (Var 1))] returns [false] *)

  val remove : int -> t -> t option
  (** [remove v m] removes variable [v] from monomial [m]. Returns [None] if
      variable not present.

      Example(s):
      - [remove 1 (Prod (Qubit (Var 1), Qubit (Var 2)))] returns
        [Some (Qubit (Var 2))]
      - [remove 3 (Qubit (Var 1))] returns [None] *)

  val remove_qubit : Qubit.t -> t -> t option
  (** [remove_qubit q m] removes qubit [q] from monomial [m]. Returns [None] if
      qubit not present.

      Example(s):
      - [remove_qubit (Var 1) (Prod (Qubit (Var 1), Qubit (Var 2)))] returns
        [Some (Qubit (Var 2))] *)

  val substitute : int -> t -> Qubit.t -> t
  (** [substitute v m q] substitutes variable [v] in monomial [m] with qubit
      [q].

      Example(s):
      - [substitute 1 (Qubit (Var 1)) (Var 2)] returns [Qubit (Var 2)] *)

  (** {2 Conversions} *)

  val of_qubit_to : Qubit.t -> t
  (** [of_qubit_to q] converts the qubit [q] into a monomial. This is a direct
      type conversion with no semantic transformation. In particular, it does
      not "lift" [Qubit.SumMod2] constructs into [Poly.Sum]. The result is a
      monomial wrapping the original qubit structure.

      Example(s):
      - [of_qubit_to (Var 1)] returns [Qubit (Var 1)]
      - [of_qubit_to (SumMod(_,_))] raises [Failure]. *)

  val to_qubit : ?debug:bool -> t -> Qubit.t
  (** [to_qubit ~debug m] converts the monomial [m] into a qubit. Scalars (other
      than [Q.one]) are not handled and will raise [Failure].

      Example(s):
      - [to_qubit (Qubit (Var 1))] returns [Var 1]
      - [to_qubit (Qubit (Scal Q.one))] returns [Qubit.One]
      - [to_qubit (Qubit (Scal (Q.of_int 3)))] raises [Failure] *)

  val monome_to_scalar_monome : t -> (Q.t * t) option
  (** [monome_to_scalar_monome m] extracts scalar and monomial from a product.
      Returns [None] if not a product with scalar.

      Example(s):
      - [monome_to_scalar_monome (Prod (Scal Q.one, Qubit (Var 1))) -> Some
         (Q.one, Qubit (Var 1))]
      - [monome_to_scalar_monome (Qubit (Var 1)) -> None] *)

  (** {2 Properties} *)

  val is_constant : ?debug:bool -> t -> int -> bool
  (** [is_constant ~debug m width] checks whether monomial [m] is constant.
      - If [width < 0]: returns [true] iff [m] contains no variables.
      - If [width >= 0]: returns [true] iff all variables in [m] satisfy
        [v >= width] (i.e., all variables are "path variables").

      Example(s):
      - [is_constant (Scal Q.one) 0] returns [true]
      - [is_constant (Qubit (Var 1)) 0] returns [true]
      - [is_constant (Qubit (Var 1)) 2] returns [false]
      - [is_constant (Qubit (Var 2)) 2] returns [true] *)

  (** {2 String Representation} *)

  (** String conversion functions for monomials. *)
  module String : sig
    val pretty : t -> int -> string
    (** [pretty m width] converts monomial [m] to a human-readable string with
        context width [width].

        Example(s):
        - [pretty (Qubit (Var 1)) 2 -> "[x1]"]
        - [pretty (Qubit (Var 1))  -> "[y0]"] *)

    val exact : t -> string
    (** [exact m] converts monomial [m] to a string showing the exact
        constructor.

        Example(s):
        - [exact (Qubit (Var 1)) -> "Qubit (Var 1)"] *)
  end
end

(** {1 Polynomial Heap} *)

(** Heap structure for storing monomials in polynomials. *)
module PolyHeap : module type of BatHeap.Make (struct
  type t = Monome.t

  let compare (m1 : t) (m2 : t) : int = -Monome.compare m1 m2
end)

(** {1 Polynomials} *)

type t = PolyHeap.t
(** Type of polynomials as min-heaps of monomials ordered by {!Monome.compare}.

    Operations:
    - Find minimum: O(1) via {!find}
    - Insert: O(log n) via {!insert}
    - Merge: O(log n) via {!merge}
    - Delete min: O(log n) via {!del}

    Example: polynomial [2x₁ + 3x₂ + 1] is stored as a heap of three monomials.
*)

(** {2 Insertion and Merging} *)

val insert : Monome.t -> t -> t
(** [insert m p] inserts monomial [m] into polynomial [p]. Duplicates are kept.

    Example(s):
    - [insert (Qubit q) [|Qubit q|]] returns [|Qubit q ++ Qubit q|] *)

val ( ++ ) : Monome.t -> t -> t
(** [m ++ p] infix operator, alias for [insert m p]. Duplicates are kept.

    Example(s):
    - [(Qubit q) ++ (Qubit q)] returns [|(Qubit q); (Qubit q)|] *)

val merge : t -> t -> t
(** [merge p1 p2] merges polynomials [p1] and [p2].

    Example(s):
    - [merge [|m1;m2|] [|m3|]] returns [[|m1;m2;m3|]] *)

(** {2 Basic Operations} *)

val empty : t
(** Empty polynomial. *)

val is_empty : t -> bool
(** [is_empty p] checks if polynomial [p] is empty.

    Example(s):
    - [is_empty empty] returns [true]
    - [is_empty (q 1)] returns [false] *)

val size : t -> int
(** [size p] returns the number of monomials in polynomial [p].

    Example(s):
    - [size empty] returns [0]
    - [size (Scal Q.one ++ Qubit q)] returns [2] *)

val find : t -> Monome.t
(** [find p] finds the minimum monomial in polynomial [p].

    Example(s):
    - [size (Scal Q.one ++ Qubit q)] returns [Scal Q.one] *)

val del : t -> t
(** [del p] deletes the minimum monomial from polynomial [p].

    Example(s):
    - [size (Scal Q.one ++ Qubit q)] returns [Qubit q] *)

(** {2 Construction} *)

val zero : t
(** Zero polynomial ([Scal Q.zero ++ empty]). *)

val one : t
(** Polynomial containing scalar [[Scal Q.one ++ empty]]. *)

val q : int -> t
(** [q v] creates a polynomial from variable [v].

    Example(s):
    - [q v] returns [|Qubit (Var v)|] *)

val to_poly : Monome.t -> t
(** [to_poly m] converts monomial [m] to a polynomial.

    Example(s):
    - [to_poly (Scal Q.one)] returns [|Scal Q.one|] *)

(** {2 Comparison and Equality} *)

val equal :
  ?global_phase:bool ->
  ?debug:bool ->
  ?wq1:int ->
  ?wq2:int ->
  ?map_path_var1:int IntMap.t ->
  ?map_path_var2:int IntMap.t ->
  t ->
  t ->
  bool
(** [equal p1 p2] compares polynomials [p1] and [p2], considering variable
    mappings and context widths

    Example(s):
    - [equal [|Scal Q.one|] [|Scal Q.one|]] returns [true] *)

(** {2 Variable Operations} *)

val member : int -> t -> bool
(** [member v p] checks if variable [v] is present in polynomial [p].

    Example(s):
    - [member 1 [|Qubit (Var 1)|]] returns [true]
    - [member 2 [|Qubit (Var 1)|]] returns [false] *)

val member_list : int list -> t -> bool
(** [member_list vs p] checks if any variable in list [vs] is present in
    polynomial [p].

    Example(s):
    - [member_list [1; 2] [|Qubit (Var 1); Qubit (Var 2)|]] returns [true]
    - [member_list [1; 2] [|Qubit (Var 1)|]] returns [false] *)

val extract_path_var : t -> int -> int list
(** [extract_path_var p width] extracts path variables ([Var v, v >= width])
    from polynomial [p].

    Example(s):
    - [extract_path_var [|Qubit (Var 1)|] 2] returns [[]]
    - [extract_path_var [|Qubit (Var 1)|] 1] returns [|Qubit (Var 1)|] *)

(** {2 Simplification} *)

val simplify_monomes : ?debug:bool -> t -> t
(** [simplify_monomes p] simplifies polynomial [p] for scalar-free cases. *)

val simplify : ?debug:bool -> t -> t
(** [simplify p] fully simplifies polynomial [p].

    Example(s):
    - [simplify [|Scal Q.one; Scal Q.one|]] returns [[|Scal Q.zero|]] *)

(** {2 Algebraic Operations} *)

val distribution : ?debug:bool -> ?s1:Q.t -> Monome.t -> t -> t
(** [distribution m p] distributes monomial [m] over polynomial [p]. Optional
    scalar [s1] can be provided.

    Example(s):
    - [distribution m [|m1; m2|]] returns [|Prod(m,m1); Prod(m,m2)|] *)

val prod : ?debug:bool -> ?s1:Q.t -> t -> t -> t
(** [prod p1 p2] multiplies polynomials [p1] and [p2]. Optional scalar [s1] can
    be provided.

    Example(s):
    - [prod [|m1; m2|] [|m3; m4|]] returns
      [|Prod(m1,m3); Prod(m1,m4); Prod(m2,m3); Prod(m2,m4)|] *)

(** {2 Substitution} *)

val substitute : ?debug:bool -> int -> t -> Qubit.t -> t
(** [substitute v p q] substitutes variable [v] in polynomial [p] with qubit
    [q].

    Example(s):
    - [substitute 1 [|Qubit (Var 1)|] (Var 2)] returns [[|Qubit (Var 2)|]] *)

val substitute_rules_monome_hh : ?debug:bool -> int -> t -> Monome.t -> t
(** [substitute_rules_monome_hh yi p m] substitutes every occurrence of the
    variable [Var yi] in the monomial [m] by the polynomial [p].

    Examples:
    - [substitute_rules_monome_hh y0 [|y0|] 1] returns [[|1|]]
    - [substitute_rules_monome_hh y0 [|x0; y0|] y0] returns [[|x0; y0|]] *)

val substitute_rules_hh : ?debug:bool -> t -> int -> t -> t
(** [substitute_rules_hh p1 v p2] substitutes variable [v] in polynomial [p1]
    with polynomial [p2].

    Example(s):
    - [substitute_rules_hh [|x0y0; y1|] y0 [|y2|]] returns [|x0y2; y1|] *)

val substitute_poly_monome : ?debug:bool -> int -> t -> Monome.t -> t
(** [substitute_poly_monome v p m] substitutes variable [v] in monomial [m] with
    polynomial [p].

    Example(s):
    - [substitute_poly_monome 1 [|Scal.one; Qubit(Var 2)|] (Qubit (Var 1))]
      returns [|Scal.one; Qubit(Var 2)|] *)

val substitute_poly : ?debug:bool -> t -> int -> t -> t
(** [substitute_poly p1 v p2] substitutes variable [v] in polynomial [p1] with
    polynomial [p2].

    Example(s):
    - [substitute_poly [|Qubit(Var 1)|] 1 [|Qubit(Var 3)|]] returns
      [[|Qubit(Var 3)|]] *)

(** {2 Conversions} *)

val of_qubit : ?debug:bool -> Qubit.t -> Q.t -> t
(** [of_qubit q s] converts qubit [q] to a polynomial with scalar [s].

    Example(s):
    - [of_qubit (Var 1) Q.one] returns [[|Qubit (Var 1)|]]
    - [of_qubit SumMod2(q1,q2) Q.one] returns
      [[|(Qubit q1); (Qubit q2); Prod(Scal (-2), Prod(q1,q2))|]] *)

val of_qubit_2_pi : ?debug:bool -> Qubit.t -> t
(** [of_qubit_2_pi q] simplified version of [of_qubit] for scalar [1/2]. Indeed,
    we have the following equality:
    {b e^(2π * 1/2 * (x0 + x1 - 2 * x0 * x1)) = e^(2π * 1/2 * (x0 + x1))}

    Example(s):
    - [of_qubit_2_pi (Var 1)] returns [[|Qubit (Var 1)|]]
    - [of_qubit SumMod2(q1,q2) Q.one] returns [[|(Qubit q1); (Qubit q2)|]] *)

val to_qubit : t -> Qubit.t
(** [to_qubit p] converts polynomial [p] to a qubit.

    Example(s):
    - [to_qubit [|Qubit q1; Qubit q2|]] returns [SumMod2(q1,q2)] *)

(** {2 Lifting Operations} *)

val lift : ?debug:bool -> t -> Q.t -> t
(** [lift p s] lifts polynomial [p] with scalar [s]. *)

val lift_qubit : ?debug:bool -> Q.t -> Monome.t -> t
(** [lift_qubit s m] lifts monomial [m] with scalar [s]. *)

val lift_monome : ?debug:bool -> Monome.t -> t
(** [lift_monome m] lifts monomial [m]. *)

val lift_poly : ?debug:bool -> t -> t
(** [lift_poly p] lifts polynomial [p]. *)

(** {2 Properties and Analysis} *)

val is_constant : ?debug:bool -> ?width:int -> t -> bool
(** [is_constant ~debug ~width p] checks whether polynomial [p] is constant.
    - If [width < 0]: returns [true] iff [p] contains no variables.
    - If [width >= 0]: returns [true] iff all variables in [p] satisfy
      [v >= width] (i.e., all variables are "path variables").

    Example(s):
    - [is_constant ~width:0 [|(Scal Q.one)|]] returns [true]
    - [is_constant ~width:0 [|(Qubit (Var 1))|]] returns [true]
    - [is_constant ~width:2 [|(Qubit (Var 1))|]] returns [false]
    - [is_constant ~width:2 [|(Qubit (Var 2))|]] returns [true] *)

val is_constant_superior_zero : t -> bool
(** [is_constant_superior_zero p] checks if polynomial [p] is constant with
    positive value.

    Example(s):
    - [is_constant_superior_zero [|Scal Q.one|]] returns [true]
    - [is_constant_superior_zero [|Scal (Q.of_int (-1))|]] returns [false] *)

val separable_in_poly : ?debug:bool -> t -> int list -> int list -> bool
(** [separable_in_poly p vs1 vs2] checks if polynomial [p] is separable between
    variable lists [vs1] and [vs2].

    Example(s):
    - [separable_in_poly [|Qubit (Var 1); Qubit (Var 2)|] [1] [2]] returns
      [true]
    - [separable_in_poly [|Qubit (Var 1); Prod(Qubit (Var 1), Qubit (Var 2))|]
       [1] [2]] returns [false] *)

val extract : t -> int list -> t
(** [extract p vs] extracts monomials from polynomial [p] containing any of the
    variables in list [vs].

    Example(s):
    - [extract [|Qubit (Var 1); Prod(Qubit (Var 1), Qubit (Var 2))|] [2]]
      returns [|Prod(Qubit (Var 1), Qubit (Var 2))|] *)

val occurrence : ('a -> Monome.t -> int) -> 'a -> t -> int
(** [occurrence f a p] counts occurrences matching predicate [f a] in polynomial
    [p]. *)

val exists : (Monome.t -> bool) -> t -> bool
(** [exists f p] checks if any monomial in polynomial [p] satisfies predicate
    [f]. *)

(** {2 String Representation} *)

(** String conversion functions for polynomials. *)
module String : sig
  val pretty : t -> int -> string
  (** [pretty p width] converts polynomial [p] to a human-readable string with
      context width [width].

      Example(s):
      - [pretty (Scal Q.one ++ empty) 2] returns ["(1)"] *)

  val exact : t -> string
  (** [exact p] converts polynomial [p] to a string showing the exact
      constructor.

      Example(s):
      - [exact (Scal Q.one ++ empty)] returns ["(Scal 1/1)"] *)
end
