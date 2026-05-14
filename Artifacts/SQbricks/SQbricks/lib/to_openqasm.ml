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

module ProgS = Program.String
include Program.Macros
open Common
include Rational
open Printf

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

(* `one_creg` manages OpenQASM 2's c0[1] c1[1] c2[1]. *)
let to_qasm ?(one_creg = false) ?(debug = false) (p : Program.t) : t =
  let wc, wq = Program.widths p in

  let rec multi_control_if l acc : int =
    match l with
    | co :: l' -> multi_control_if l' (acc + Q.to_int (Q.mul_2exp Q.one co))
    | [] -> acc
  in

  let rec multi_apply co l (g : Gates.t) acc : Program.t =
    match l with
    | ta :: l' -> multi_apply co l' g (acc -- Apply (g, co, [ ta ]))
    | [] -> acc
  in

  let rec aux (p : Program.t) : t =
    match p with
    | E -> ID
    | Apply (H, [], [ ta ]) -> H ta
    | Apply (H, [ co ], [ ta ]) -> CH (co, ta)
    | Apply (X, [], [ ta ]) -> X ta
    | Apply (X, [ co ], [ ta ]) -> CX (co, ta)
    | Apply (X, [ co1; co2 ], [ ta ]) -> CCX (co1, co2, ta)
    | Apply (U1 (s, k), [], [ ta ]) ->
        let angle = Q.div_2exp s (k - 1) in
        U1 (angle, ta)
    | Apply (U1 (s, k), [ co ], [ ta ]) ->
        let angle = Q.div_2exp s (k - 1) in
        CU1 (angle, co, ta)
    | Apply (U1 (s, k), [ co1; co2 ], [ ta ]) ->
        aux (ccu1decomp ~s:(Q.to_int s) k co1 co2 ta)
    | Apply (U1 _, _, _) ->
        failwith
          (sprintf "To_openqasm.to_qasm.aux, program = %s\n" (ProgS.pretty p))
    | Apply (g, co, ta) -> aux (multi_apply co ta g E)
    | Measure (k, ta) -> MEASURE (k, ta)
    | It ([ k ], Sequence (p1, p2)) -> aux (it k p1 -- it k p2)
    | It ([ k ], p') -> IF (k, aux p')
    | It (co, p') -> IF (multi_control_if co 0, aux p')
    | Sequence (p1, p2) -> SEQUENCE (aux p1, aux p2)
    | InitQ ta -> RESET ta
    | _ ->
        failwith
          (sprintf "To_openqasm.to_qasm.aux, Program = %s\n" (ProgS.pretty p))
  in
  let output = aux p in
  if wc = 0 then SEQUENCE (QREG wq, output)
  else if one_creg then CREG wc
  else
    let res = ref (CREG 0) in
    for i = 1 to wc - 1 do
      if debug then printf "Translation.aux, i = %d\n" i;
      res := SEQUENCE (!res, CREG i)
    done;
    SEQUENCE (QREG wq, SEQUENCE (!res, output))

let angle_to_string (angle : Q.t) rotation : string =
  if angle.num = Z.one then rotation ^ "(pi/" ^ Z.to_string angle.den ^ ")"
  else if angle.num = Z.minus_one then
    rotation ^ "(-pi/" ^ Z.to_string angle.den ^ ")"
  else
    rotation ^ "(" ^ Z.to_string angle.num ^ "*pi/" ^ Z.to_string angle.den
    ^ ")"

let string_oq_rec ?(for_autoq = false) ?(for_pyzx = false) ?(debug = false)
    ?(one_creg = false) (c : t) =
  let rec aux (c : t) =
    match c with
    | ID -> ""
    | H ta -> "h q[" ^ Int.to_string ta ^ "];\n"
    | CH (co, ta) ->
        "ch q[" ^ Int.to_string co ^ "], q[" ^ Int.to_string ta ^ "];\n"
    | X ta -> "x q[" ^ Int.to_string ta ^ "];\n"
    | CX (co, t) ->
        "cx q[" ^ Int.to_string co ^ "], q[" ^ Int.to_string t ^ "];\n"
    | CCX (co1, co2, t) ->
        "ccx q[" ^ Int.to_string co1 ^ "], q[" ^ Int.to_string co2 ^ "], q["
        ^ Int.to_string t ^ "];\n"
    | U1 (angle, ta) ->
        if for_pyzx || for_autoq then
          if Q.equal (Q.abs angle) Q.one then
            "z" ^ " q[" ^ Int.to_string ta ^ "];\n"
          else angle_to_string angle "rz" ^ " q[" ^ Int.to_string ta ^ "];\n"
        else angle_to_string angle "u1" ^ " q[" ^ Int.to_string ta ^ "];\n"
    | CU1 (angle, co, ta) ->
        if for_pyzx || for_autoq then
          if Q.equal (Q.abs angle) Q.one then
            "cz" ^ " q[" ^ Int.to_string co ^ "], q[" ^ Int.to_string ta
            ^ "];\n"
          else
            angle_to_string angle "crz"
            ^ " q[" ^ Int.to_string co ^ "], q[" ^ Int.to_string ta ^ "];\n"
        else
          angle_to_string angle "cu1"
          ^ " q[" ^ Int.to_string co ^ "], q[" ^ Int.to_string ta ^ "];\n"
    | MEASURE (k, ta) ->
        if one_creg then
          "measure q[" ^ Int.to_string k ^ "] -> c[" ^ Int.to_string ta ^ "];\n"
        else
          "measure q[" ^ Int.to_string k ^ "] -> c" ^ Int.to_string ta
          ^ "[0];\n"
    | IF (k, p') ->
        if one_creg then "if (c == " ^ Int.to_string k ^ ") " ^ aux p'
        else "if (c" ^ Int.to_string k ^ " == 1) " ^ aux p'
    | QREG w -> "qreg q[" ^ Int.to_string w ^ "];\n"
    | CREG wc ->
        if for_autoq then ""
        else if one_creg then "creg c[" ^ Int.to_string wc ^ "];\n"
        else "creg c" ^ Int.to_string wc ^ "[1];\n"
    | RESET ta -> "reset q[" ^ Int.to_string ta ^ "];\n"
    | SEQUENCE (d, e) ->
        if debug then (
          printf "Translation.aux, SEQUENCE\n";
          printf "Translation.aux, (aux d) = %s, (aux e) = %s\n" (aux d) (aux e));
        aux d ^ aux e
  in
  aux c

let print_oq ?(for_autoq = false) ?(for_pyzx = false) ?(one_creg = false)
    (c : t) =
  let debug = false in
  if debug then printf "Translation.print_oq, one_creg = %b\n" one_creg;
  "OPENQASM 2.0;\ninclude \"qelib1.inc\";\n"
  ^ string_oq_rec ~for_autoq ~for_pyzx ~one_creg c

let string_oq ?(for_autoq = false) ?(for_pyzx = false) ?(one_creg = false)
    (p : Program.t) =
  let debug = false in
  if debug then printf "Translation.string_oq, one_creg = %b\n" one_creg;
  print_oq ~for_autoq ~for_pyzx ~one_creg (to_qasm ~one_creg p)

let print_to_file_oq ?(for_autoq = false) ?(for_pyzx = false)
    ?(one_creg = false) filename p =
  let debug = false in
  if debug then printf "Translation.print_to_file_oq, one_creg = %b\n" one_creg;
  let file_path = Filename.concat "benchmarks_qasm" (filename ^ ".qasm") in
  let oc = open_out file_path in
  fprintf oc "%s" (string_oq ~for_autoq ~for_pyzx ~one_creg p);
  close_out oc

let print_to_file_oq_free_folder ?(for_autoq = false) ?(for_pyzx = false)
    ?(one_creg = false) file_path p =
  let oc = open_out file_path in
  fprintf oc "%s" (string_oq ~for_autoq ~for_pyzx ~one_creg p);
  close_out oc
