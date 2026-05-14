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

{
open Parser_OpenQASM
}

rule token = parse
  | [' ' '\t' '\r' '\n'] { token lexbuf }
  | "barrier" { comment lexbuf }
  | "//" { comment lexbuf }
  | "OPENQASM" { OPENQASM }
  | "2.0" { VERSION }
  | "3.0" { VERSION }
  | "include" { INCLUDE }
  | "qreg" { QREG }
  | "creg" { CREG }
  | "reset" { RESET }
  | "h" { H }
  | "id" { ID }
  | "x" { X }
  | "z" { Z }
  | "s" { S }
  | "t" { T }

  | "rx" { RX }
  | "ry" { RY }
  | "rz" { RZ }
  | "u1" { U1 }
  | "sx" { SX }

  | "zdg" { ZDG }
  | "sdg" { SDG }
  | "tdg" { TDG }
  | "cx" { CX }
  | "CX" { CX }
  | "CH" { CH }
  | "ch" { CH }
  | "cz" { CZ }

  | "cu1" { CU1 }
  | "crz" { CRZ }

  | "ccz" { CCZ }
  | "ccx" { CCX }
  | "tof" { CCX }
  | "toffoli" { CCX }
  | "swap" { SWAP }
  | "cswap" { CSWAP }
  | "fredkin" { CSWAP }

  | "measure" { MEASURE }
  | "if" { IF }


  | "pi" { PI }
  | "-pi" { MPI }
  | "/" { DIV }
  | "-" { MINUS }
  | "*" { MUL }
  | "==" { EQUAL }
  | "->" { ARROW } 

  | '"' [^'"']* '"' as s { STRING(String.sub s 1 (String.length s - 2)) }
  | '[' { LBRACKET }
  | ']' { RBRACKET }

  | '(' { LRBRACKET }
  | ')' { RRBRACKET }

  | ['0'-'9']+ as s { INT(int_of_string s) }
  | ['a'-'z''A'-'Z']['a'-'z''A'-'Z''0'-'9''_']* as s { IDENT(s) }
  | ',' { COMMA }				
  | ';' { SEMICOLON }
  | eof { EOF }
  | _ { failwith "Unexpected character" }

and comment = parse 
  | "\n" { token lexbuf } (* Ignore the comment and continue tokenizing *) 
  | _ { comment lexbuf } 
