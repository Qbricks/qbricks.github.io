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

{
open Parser_Path_sum
}

rule token = parse
| [' ' '\t' '\n' '\r']   { token lexbuf }
| "//"                   { comment lexbuf }
| ">"                    { RANGLE }
| ","                    { COMMA }
| "("                    { LBRACKET }
| ")"                    { RBRACKET }
| "["                    { LSBRACKET }
| "]"                    { RSBRACKET }
| "."                    { PROD }
| "*"                   { QPROD }
| "-"                    { MINUS }
| "+"                    { PLUS }
| "++"                   { QPLUS }
| "/"                    { DIV }
| "|"                    { BAR }
| ['0'-'9']+ as lxm      { INT (int_of_string lxm) }
| ['a'-'z' 'A'-'Z']+ as lxm { IDENT lxm }
| eof { EOF }
| _ { failwith "Unexpected character" }

and comment = parse 
  | "\n" { token lexbuf } (* Ignore the comment and continue tokenizing *) 
  | _ { comment lexbuf } 