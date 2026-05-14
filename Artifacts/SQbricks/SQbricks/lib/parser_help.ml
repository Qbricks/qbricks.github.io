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

open Printf
open List

let classical_register_to_int c =
  match c with
  | s when String.length s > 1 && String.sub s 0 1 = "c" ->
      let n = String.sub s 1 (String.length s - 1) in
      int_of_string n
  | _ -> 0

let int_to_control_qubits n offset =
  let rec aux n index acc =
    if n = 0 then acc
    else
      let is_control_bit = n mod 2 = 1 in
      let new_acc = if is_control_bit then (index + offset) :: acc else acc in
      aux (n / 2) (index + 1) new_acc
  in
  List.sort_uniq Int.compare (aux n 0 [])

(* den = 2^k *)
let den_to_k ?(debug = false) (den : Z.t) : int =
  let k = Z.log2 den in
  let den_from_k = Z.pow (Z.of_int 2) k in
  if debug then
    printf "Parser_help.den_to_k, den = %s, k = %d, den_from_k = %s\n\n"
      (Z.to_string den) k (Z.to_string den_from_k);
  if den != den_from_k then
    failwith
      (sprintf "Parser_help.den_to_k, den = %s != den_from_k = %s"
         (Z.to_string den) (Z.to_string den_from_k));
  (* pi / den = pi / 2^k = 2.pi / 2^{k+1} *)
  k + 1

let condition_empty_program s den = s = Q.zero || (den = Z.one && s = Q.of_int 2)
