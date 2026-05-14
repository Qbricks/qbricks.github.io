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

(** Common utility functions for the symbolic execution tool. *)

(** {1 Data Structures} *)

module IntMap : Map.S with type key = int
(** A map with integer keys. *)

val to_string_int_map : int IntMap.t -> string
(** [to_string_int_map m] converts an integer map [m] to its string
    representation.

    Examples:
    - [to_string_int_map (IntMap.of_list [(1, 10); (2, 20)])] returns
      ["{1->10, 2->20}"] *)

(** {1 Array Operations} *)

module ArrayBis : sig
  val string_int : int array -> string
  (** [string_int a] converts array [a] to a string representation.

      Examples:
      - [string_int [|1; 2; 3|]] returns ["1;2;3"]
      - [string_int [||]] returns [""] *)

  val max_int : int array -> int
  (** [max_int a] returns the maximum integer in array [a].

      Examples:
      - [max_int [|1; 3; 2|]] returns [3]
      - [max_int [||]] returns [Int.min_int] *)
end

(** {1 List Operations} *)

module ListBis : sig
  val string_int : int list -> string
  (** [string_int l] converts list [l] to a string representation.

      Examples:
      - [string_int [1; 2; 3]] returns ["1;2;3"]
      - [string_int []] returns [""] *)

  val y_string_int : int list -> int -> string
  (** [y_string_int l n] converts list [l] to a string where each number is
      represented as 'y' followed by (i - [n]). All elements must be >= [n],
      otherwise raises [Failure]. The list is sorted before conversion.

      Examples:
      - [y_string_int [3; 4; 5] 3] returns ["y0;y1;y2"]
      - [y_string_int [1] 2] raises [Failure] *)

  val max_int : int list -> int
  (** [max_int l] returns the maximum integer from list [l]. Returns 0 if [l] is
      empty or contains only non-positive integers.

      Examples:
      - [max_int [1; 3; 2]] returns [3]
      - [max_int [-1; -2]] returns [0] *)

  val min_int : int list -> int
  (** [min_int l] returns the minimum integer from list [l] that is less than 0,
      or 0 if no such element exists.

      Examples:
      - [min_int [-1; -2]] returns [-2]
      - [min_int [1; 2; 3]] returns [0] *)

  val increment : int list -> int -> int list
  (** [increment l k] increments each element of list [l] by [k].

      Examples:
      - [increment [1; 2; 3] 1] returns [[2; 3; 4]]
      - [increment [] 5] returns [[]] *)

  val increment_by_coeff : int list -> int -> int list
  (** [increment_by_coeff l k] multiplies each element of list [l] by [k].

      Examples:
      - [increment_by_coeff [1; 2; 3] 2] returns [[2; 4; 6]]
      - [increment_by_coeff [] 5] returns [[]] *)

  val increment_by_coeff_and_add : int list -> int -> int -> int list
  (** [increment_by_coeff_and_add l k1 k2] applies the transformation
      [x -> x * k1 + k2] to each element of list [l].

      Examples:
      - [increment_by_coeff_and_add [1; 2; 3] 2 1] returns [[3; 5; 7]]
      - [increment_by_coeff_and_add [] 2 1] returns [[]] *)

  val missing_in_range : ?lower:int -> int list -> int -> int list
  (** [missing_in_range ?lower l upper] returns integers in the range
      [[lower; lower+1; ...; upper-1]] that are not in list [l]. Default for
      [lower] is 0.

      Examples:
      - [missing_in_range ~lower:1 [1; 3] 6] returns [[2; 4; 5]]
      - [missing_in_range [0; 2] 3] returns [[1]] *)

  val range : int -> int -> int list
  (** [range lower upper] returns the list of integers from [lower] to [upper-1]
      inclusive.

      Examples:
      - [range 1 4] returns [[1; 2; 3]]
      - [range 0 0] returns [[]] *)

  val check_bounds : int -> int -> int list -> bool
  (** [check_bounds ?debug lower upper l] checks if all elements in list [l] are
      within the interval [[lower, upper]].

      Examples:
      - [check_bounds 1 4 [1; 2; 3]] returns [true]
      - [check_bounds 1 4 [1; 2; 4]] returns [false] *)

  val generate_int_list_from_a_to_b_with_step : int -> int -> int -> int list
  (** [generate_int_list_from_a_to_b_with_step lower upper step] generates a
      list of integers starting from [lower], incrementing by [step], until
      reaching or exceeding [upper].

      Examples:
      - [generate_int_list_from_a_to_b_with_step 1 5 2] returns [[1; 3]]
      - [generate_int_list_from_a_to_b_with_step 0 10 3] returns [[0; 3; 6; 9]]
  *)

  val remove : ?eq:(int -> int -> bool) -> int -> int list -> int list
  (** [remove ?eq i l] removes all occurrences of [i] from list [l]. The
      equality function can be specified with [eq] (defaults to [Int.equal]).

      Examples:
      - [remove 2 [1; 2; 3]] returns [[1; 3]]
      - [remove 2 [2; 2; 3]] returns [[3]] *)

  val remove_duplicate : 'a list -> 'a list
  (** [remove_duplicate l] removes duplicate elements from list [l], preserving
      the order.

      Examples:
      - [remove_duplicate [1; 2; 2; 3]] returns [[1; 2; 3]]
      - [remove_duplicate ["a"; "b"; "a"]] returns [["a"; "b"]] *)

  val is_decrease : ?lower:int -> int list -> bool
  (** [is_decrease ?lower l] checks if list [l] is strictly decreasing and ends
      with [lower] (defaults to 0).

      Examples:
      - [is_decrease [3; 2; 1; 0]] returns [true]
      - [is_decrease [2; 1; 3]] returns [false] *)

  val substitute : 'a list -> 'a -> 'a -> 'a list
  (** [substitute l old_val new_val] replaces all occurrences of [old_val] with
      [new_val] in list [l].

      Examples:
      - [substitute [1; 2; 1] 1 3] returns [[3; 2; 3]]
      - [substitute ["a"; "b"] "a" "c"] returns [["c"; "b"]] *)

  val remove_list : int list -> int list -> int list
  (** [remove_list to_remove l] removes each element in [to_remove] from list
      [l], returning the result of the last removal.

      Examples:
      - [remove_list [1; 2] [1; 2; 3]] returns [[3]]
      - [remove_list [] [1; 2; 3]] returns [[1; 2; 3]] *)

  val member : 'a -> 'a list -> ('a -> 'a -> bool) -> bool
  (** [member e l eq] checks if element [e] is present in list [l] using the
      given equality function [eq].

      Examples:
      - [member 1 [1; 2; 3] (=)] returns [true]
      - [member "a" ["b"; "c"] (fun x y -> x = y)] returns [false] *)

  val of_string_to_int_list : string -> int list
  (** [of_string_to_int_list ?debug s] converts a string representation [s] of
      an integer list to a list of integers. The string should be in the format
      produced by [string_int], e.g., ["[1;2;3]"].

      Examples:
      - [of_string_to_int_list "[1;2;3]"] returns [[1; 2; 3]]
      - [of_string_to_int_list ""] returns [[]] *)

  val extract_upper_bound_list : int -> int list -> int list
  (** [extract_upper_bound_list upper l] returns the sublist of elements from
      [l] that are greater than or equal to [upper].

      Examples:
      - [extract_upper_bound_list 3 [1; 3; 5]] returns [[3; 5]]
      - [extract_upper_bound_list 10 [1; 2; 3]] returns [[]] *)

  val extract_lower_bound_list : int -> int list -> int list
  (** [extract_lower_bound_list lower l] returns the sublist of elements from
      [l] that are less than [lower].

      Examples:
      - [extract_lower_bound_list 3 [1; 3; 5]] returns [[1]]
      - [extract_lower_bound_list 0 [1; 2; 3]] returns [[]] *)

  val intersect : int list -> int list -> int list
  (** [intersect l1 l2] returns the intersection of lists [l1] and [l2], sorted
      and without duplicates.

      Examples:
      - [intersect [1; 3; 5] [1; 5; 7]] returns [[1; 5]]
      - [intersect [1; 2; 2] [2; 3]] returns [[2]] *)
end

(** {1 Rational Number Operations} *)

module Rational : sig
  val divk : int -> Q.t
  (** [divk k] returns the rational number 1 divided by 2 to the power of [k].

      Examples:
      - [divk 1] returns [1/2]
      - [divk 2] returns [1/4] *)

  val div2 : Q.t
  (** Precomputed rational number 1/2. *)

  val div4 : Q.t
  (** Precomputed rational number 1/4. *)

  val div8 : Q.t
  (** Precomputed rational number 1/8. *)

  val divmk : int -> Q.t
  (** [divmk k] returns the rational number -1 divided by 2 to the power of [k].

      Examples:
      - [divmk 1] returns [-1/2]
      - [divmk 2] returns [-1/4] *)

  val divm2 : Q.t
  (** Precomputed rational number -1/2. *)

  val divm4 : Q.t
  (** Precomputed rational number -1/4. *)

  val divm8 : Q.t
  (** Precomputed rational number -1/8. *)

  val two : Q.t
  (** Rational number 2. *)

  val four : Q.t
  (** Rational number 4. *)

  val minus_two : Q.t
  (** Rational number -2. *)

  val pow2Q : int -> Q.t
  (** [pow2Q k] returns 2 raised to the power of [k] as a rational number.

      Examples:
      - [pow2Q 1] returns [2]
      - [pow2Q 2] returns [4] *)

  val pow2Z : int -> Z.t
  (** [pow2Z k] returns 2 raised to the power of [k] as an integer. Calculated
      using [Q.mul_2exp] of 1 and [k].

      Examples:
      - [pow2Z 1] returns [2]
      - [pow2Z 3] returns [8] *)

  val coef_lift : Q.t -> Q.t
  (** [coef_lift k1] given a rational number [k1] with denominator a power of 2,
      returns 2^[k2] - 2 where [k2] is such that den = 2^[k2].

      Examples:
      - [coef_lift (Q.make Z.one (Z.of_int 4))] returns [2] *)

  val find_k : Z.t -> int
  (** [find_k den] calculates the exponent [k] such that [den] = 2^[k]. Checks
      whether [den] is a power of 2 and returns the exponent.

      Raises [Failure] if [den] is not a power of 2. *)

  val ( /// ) : int -> int -> Q.t
  (** [num /// den] performs rational number division: [num / den].

      Examples:
      - [1 /// 2] returns [1/2]
      - [3 /// 4] returns [3/4] *)
end

(** {1 String Operations} *)

module StringBis : sig
  val capitalize_first_character : string -> string
  (** [capitalize_first_character s] capitalizes the first character of string
      [s].

      Examples:
      - [capitalize_first_character "hello"] returns ["Hello"]
      - [capitalize_first_character ""] returns [""] *)

  val extract_filename : string -> string
  (** [extract_filename path] extracts the filename without extension from a
      file path.

      Examples:
      - [extract_filename "path/to/file.txt"] returns ["file"]
      - [extract_filename "file"] returns ["file"] *)
end

(** {1 File Operations} *)

module FileBis : sig
  val find_root_path : string -> string
  (** [find_root_path ?debug filename] searches for [filename] in parent
      directories. Returns the path if found, or empty string if not found.

      Examples:
      - [find_root_path "input.txt"] returns ["../../../../input.txt"]
      - [find_root_path "nonexistent"] returns [""] *)
end
