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

%{
open Common
open Poly
open Path_sum
module KS = Ket.String
module QS = Qubit.String
module MS = Monome.String
module PS = Poly.String
let debug _ = ()
let size = ref 0
%}
// let debug msg = print_endline ("Debug: " ^ msg)

%token <int> INT
%token <string> IDENT
%token RANGLE COMMA 
%token DIV PLUS QPLUS PROD QPROD MINUS
%token BAR LBRACKET RBRACKET LSBRACKET RSBRACKET

%start <Path_sum.t> path_sum
%type <Poly.t> poly
%type <Ket.t> ket
%type <Qubit.t> qubit
%token EOF


%left QPLUS
%left QPROD
%left PLUS MINUS

%%

path_sum:
| size COMMA COMMA ket EOF {
  debug "Fin du programme principal";
  debug ("pathsum INT COMMA poly COMMA ket EOF, size = " ^ (string_of_int !size));
  let ket = $4 in
  let phase = Poly.zero in
  debug ("pathsum phase = " ^ (Poly.String.pretty phase !size));
  let wq = Array.length ket in 
  debug ("pathsum wq = " ^ (string_of_int wq));
  let pvs = Poly.extract_path_var phase wq in 
  debug ("pathsum pvs = " ^ (ListBis.string_int pvs));
  let path_var = List.sort_uniq Int.compare (
    Ket.extract_path_var ket @ 
    pvs) in 
  { path_var; phase; ket; } 
  }
| size COMMA poly COMMA ket EOF {
  debug "Fin du programme principal";
  debug ("pathsum INT COMMA poly COMMA ket EOF, size = " ^ (string_of_int !size));
  let ket = $5 in
  let phase = Poly.simplify_monomes (Poly.lift_poly $3) in
  debug ("pathsum phase = " ^ (Poly.String.pretty phase !size));
  let wq = Array.length ket in 
  debug ("pathsum wq = " ^ (string_of_int wq));
  let pvs = Poly.extract_path_var phase wq in 
  debug ("pathsum pvs = " ^ (ListBis.string_int pvs));
  let path_var = List.sort_uniq Int.compare (
    Ket.extract_path_var ket @ 
    pvs) in 
  { path_var; phase; ket; } 
  }

poly:
| monome { 
  let m = $1 in
  debug ("poly monome = " ^ (MS.pretty m !size));
  Poly.to_poly m
  }
| monome PLUS poly { 
  let m = $1 in
  debug ("poly monome PLUS poly, m = " ^ (MS.pretty m !size));
  let p = $3 in
  debug ("poly monome PLUS poly, p = " ^ (PS.pretty p !size));
  Poly.insert m p
  }
| poly MINUS monome {
  let m = $3 in
  debug ("poly MINUS monome, m = " ^ (MS.pretty m !size));
  let p = $1 in
  debug ("poly MINUS monome, p = " ^ (PS.pretty p !size));
  let sum = Poly.insert (Monome.Prod(Scal (Q.of_int (-1)), m)) p in 
  debug ("poly MINUS monome, sum = " ^ (PS.pretty sum !size));
  sum
}
| LBRACKET poly RBRACKET {
  let p = Poly.lift_poly $2 in
  debug ("poly MINUS monome, p = " ^ (PS.pretty p !size));
  p
}

// type t = Scal of Q.t | Qubit of q | Prod of t * t
monome:
| qubit { 
  let q = $1 in
  debug ("monome, qubit = " ^ (QS.pretty q !size));
  (Monome.Qubit q) 
  }
| scal {
  let s = $1 in 
  debug ("scal, s = " ^ (MS.pretty s !size));
  s
}
| qubit PROD monome { 
  let q = $1 in
  let m = $3 in
  debug ("qubit PROD monome, q = " ^ (QS.pretty q !size));
  (Monome.Prod(Qubit q, m)) 
  }
| scal PROD monome {
  let s = $1 in 
  debug ("scal PROD monome, s = " ^ (MS.pretty s !size));
  let m = $3 in 
  debug ("scal PROD monome, m = " ^ (MS.pretty m !size));
  Monome.Prod (s,m)
}

scal:
| INT DIV INT { 
  let num = Z.of_int $1 in 
  let den = Z.of_int $3 in
  debug ("monome INT DIV INT, num = " ^ (Z.to_string num) ^ ", den = " ^ (Z.to_string den));
  Monome.Scal (Q.make num den) 
  }

ket:
| BAR ket_content RANGLE { 
  debug ("ket BAR ket_content RANGLE");
  Path_sum.Ket.list_of_qubits_to_ket $2 
  }

// type t = Qubit.t array
ket_content:
| qubit { 
  let q = $1 in
  debug ("ket_content qubit, q = " ^ (QS.exact q));
  [q] 
  }
| qubit COMMA ket_content { 
  let q = $1 in 
  debug ("qubit COMMA ket_content, q = " ^ (QS.exact q));
  let q_list = $3 in 
  q :: q_list 
  }

// type t = Zero | One | Var of int | Prod of t * t | SumMod2 of t * t
qubit:
| INT { 
    debug ("qubit INT = " ^ (string_of_int $1));
    if $1 = 0 then Qubit.Zero else
    if $1 = 1 then Qubit.One else failwith "value of qubit forbidden"
  }
| IDENT INT {
  let id = $1 in 
  let index = $2 in 
  debug ("qubit IDENT INT id = " ^ id ^ ", index = " ^ (string_of_int index));
  let q = 
    if id = "y" then 
      Qubit.Var (index + !size) 
    else 
      Qubit.Var index 
    in 
  debug ("qubit IDENT INT q = " ^ (QS.pretty q !size));
  q
}
| qubit QPLUS qubit {
  let q1, q2 = $1, $3 in
  debug ("qubit QPLUS: " ^ QS.exact q1 ^ " + " ^ QS.exact q2);
  Qubit.simplify (Qubit.SumMod2(q1, q2))
}
| qubit QPROD qubit {
  let q1, q2 = $1, $3 in
  debug ("qubit QPROD: " ^ QS.exact q1 ^ " * " ^ QS.exact q2);
  Qubit.simplify (Qubit.Prod(q1, q2))
}
| LSBRACKET qubit RSBRACKET {
  let q = $2 in 
  debug ("qubit LSBRACKET qubit RSBRACKET, q = " ^ (QS.pretty q !size));
  Qubit.simplify q
}

size:
| INT { 
  size := $1
  }







