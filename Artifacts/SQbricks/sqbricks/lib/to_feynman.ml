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

open Common
include Rational
module ProgS = Program.String
include Program.Macros
open Printf

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

let into_feynman p =
  let rec aux (p : Program.t) =
    match p with
    | Apply (H, [ co ], [ ta ]) -> chdecomp co ta
    | Apply (U1 (s, k), [ co ], [ ta ]) when Q.equal (Q.div_2exp s k) div4 ->
        cs_feynman co ta
    | Apply (U1 (s, k), [ co ], [ ta ]) when Q.equal (Q.div_2exp s k) divm4 ->
        Program.inverse (cs_feynman co ta)
    | Apply (U1 (s, k), [ co ], [ ta ]) when Q.equal (Q.div_2exp s k) div2 ->
        cz_feynman co ta
    | Apply (U1 (s, k), [ co ], [ ta ]) when Q.equal (Q.div_2exp s k) divm2 ->
        Program.inverse (cz_feynman co ta)
    | Apply (U1 (s, k), [ co1; co2 ], [ ta ]) when Q.equal (Q.div_2exp s k) div2
      ->
        ccz_feynman co1 co2 ta
    | Apply (U1 (s, k), [ co1; co2 ], [ ta ])
      when Q.equal (Q.div_2exp s k) divm2 ->
        Program.inverse (ccz_feynman co1 co2 ta)
    | Apply (X, [ co1; co2 ], [ ta ]) -> ccx_feynman co1 co2 ta
    | Apply (U1 (s, k), [ co ], [ ta ]) ->
        if k < 0 then failwith "Feynman.aux.CU1, k < 0 forbidden";
        cu1decomp ~s:(Q.to_int s) k co ta
    | Sequence (p1, p2) -> Sequence (aux p1, aux p2)
    | _ -> p
  in
  aux p

let to_feynman ?(debug = false) (p : Program.t) : t =
  let rec aux (p : Program.t) =
    match p with
    | Apply (H, [], [ ta ]) -> H ta
    | Apply (H, [ co ], [ ta ]) -> aux (chdecomp co ta)
    | Apply (X, [], [ ta ]) -> X ta
    | Apply (X, [ co ], [ ta ]) -> CX (co, ta)
    | Apply (X, [ co1; co2 ], [ ta ]) -> CCX (co1, co2, ta)
    | Apply (U1 (s, k), [], [ ta ]) ->
        if debug then printf "Feynman.aux.U1, s = %s\n" (Q.to_string s);
        if debug then printf "Feynman.aux.U1, k = %d\n" k;
        let angle : Q.t = Q.div_2exp s (k - 1) in
        RZ (angle, ta)
    | Apply (U1 (s, k), [ co ], [ ta ]) ->
        let angle = Q.div_2exp s (k - 1) in
        if k < 0 then failwith "Feynman.aux.CU1, k < 0 forbidden";
        if angle = Q.one then CZ (co, ta)
        else aux (cu1decomp ~s:(Q.to_int s) k co ta)
    | Apply (U1 (s, k), [ co1; co2 ], [ ta ]) ->
        let angle = Q.div_2exp s (k - 1) in
        if angle = Q.one then CCZ (co1, co2, ta)
        else if angle = Q.minus_one then CCZDG (co1, co2, ta)
        else
          failwith
            (sprintf "To_feynman.to_feynman.aux, %s forbidden" (ProgS.pretty p))
    | Apply (U1 _, _, _) ->
        failwith
          (sprintf "To_feynman.to_feynman.aux, %s forbidden" (ProgS.pretty p))
    | E -> I
    | InitQ _ -> I
    | Sequence (p1, p2) -> SEQUENCE (aux p1, aux p2)
    | _ ->
        failwith
          (sprintf "To_feynman.to_feynman.aux, Program = %s" (ProgS.exact p))
  in
  aux p

let angle_to_string (angle : Q.t) rotation =
  rotation ^ "(" ^ Z.to_string angle.num ^ "pi/2^"
  ^ Int.to_string (Z.log2 angle.den)
  ^ ") "

let rec string_fm_rec (c : t) : string =
  match c with
  | H ta -> "H " ^ Int.to_string ta
  | X ta -> "X " ^ Int.to_string ta
  | RZ (angle, ta) -> angle_to_string angle "Rz" ^ Int.to_string ta
  | CX (co, ta) -> "X " ^ Int.to_string co ^ " " ^ Int.to_string ta
  | CCX (co1, co2, ta) ->
      "tof " ^ Int.to_string co1 ^ " " ^ Int.to_string co2 ^ " "
      ^ Int.to_string ta
  | CZ (co, ta) -> "Z " ^ Int.to_string co ^ " " ^ Int.to_string ta
  | CCZ (co1, co2, ta) ->
      "Z " ^ Int.to_string co1 ^ " " ^ Int.to_string co2 ^ " "
      ^ Int.to_string ta
  | CCZDG (co1, co2, ta) ->
      "Zd " ^ Int.to_string co1 ^ " " ^ Int.to_string co2 ^ " "
      ^ Int.to_string ta
  | I -> ""
  | SEQUENCE (c1, c2) -> string_fm_rec c1 ^ "\n" ^ string_fm_rec c2

let rec string_register w =
  if w = 0 then "0" else string_register (w - 1) ^ " " ^ Int.to_string w

let string_from_inputs inputs =
  let rec aux acc = function
    | hd :: tl -> aux (string_of_int hd ^ " " ^ acc) tl
    | [] -> acc
  in
  aux "" (List.rev (List.fast_sort Int.compare inputs))

let print_fm ?(inputs = []) c width_quantum =
  ".v "
  ^ string_register (width_quantum - 1)
  ^ "\n" ^ ".i " ^ string_from_inputs inputs ^ "\n\nBEGIN\n\n" ^ string_fm_rec c
  ^ "\n\nEND"

let string_fm ?(inputs = []) ?(debug = false) (p : Program.t) =
  let _, wq = Program.widths p in
  if debug then
    Printf.printf "Translation.string_fm,  width_quantum p = %d\n" wq;
  print_fm (to_feynman p ~debug) wq ~inputs

let print_to_file_fm ?(inputs = []) ?(debug = false) filename p =
  if debug then printf "To_feynman.print_to_file, p =\n%s\n\n" (ProgS.pretty p);
  let oc = open_out filename in
  Printf.fprintf oc "%s" (string_fm p ~inputs);
  close_out oc
