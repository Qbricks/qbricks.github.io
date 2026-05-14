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

%{
open Printf
open Common
module ProgS = Program.String
include Program.Macros
let debug _ = ()
(*let debug msg = print_endline ("Debug: " ^ msg)*)
%}

%token <string>  IDENT STRING
%token OPENQASM INCLUDE QREG CREG 
%token SEMICOLON COMMA LBRACKET RBRACKET 
%token VERSION H X Z CX CCX CCZ CZ ZDG S SDG T TDG SWAP CSWAP U1 CU1 CH MPI ID
%token MEASURE ARROW IF EQUAL 
%token PI DIV MUL LRBRACKET RRBRACKET RX RY RZ CRZ MINUS SX
%token RESET
%token <int> INT  
%token EOF

%start <Program.t> program
%type <Program.t> program_aux
%type <Program.t> statement
%type <Program.t> include_statement
%type <Program.t> statements
%type <Q.t * Z.t> angle
%type <int> qubit creg 
%type <int> qreg_declaration creg_declaration 

%%

program:
  | program_aux EOF { debug "Fin du programme principal"; $1 }

program_aux:
  | OPENQASM VERSION SEMICOLON include_statement statements { debug "Début du programme QASM"; $5 }

include_statement:
  | INCLUDE STRING SEMICOLON { debug ("Inclusion de " ^ $2); Program.E }

statements:
  | statement SEMICOLON { debug "Traitement d'une instruction"; $1 }
  | statement SEMICOLON statements { debug "Traitement d'une séquence d'instructions"; Program.Sequence($1, $3) }

statement:
  | ID qubit { E }
  | H qubit { 
    debug ("H " ^ string_of_int $2); 
    Program.Apply(H, [], [$2]) }

  | CH qubit COMMA qubit { 
    debug ("CH " ^ string_of_int $2 ^ " " ^ string_of_int $4);
    if $2 = $4 then failwith "Parser.statement.CH, co = ta\n" else
    Program.Apply(H, [$2], [$4]) 
    }

  | CX qubit COMMA qubit { 
    debug ("CX " ^ string_of_int $2 ^ " " ^ string_of_int $4);
    if $2 = $4 then failwith "Parser.statement.CX, co = ta\n" else
    Program.Apply(X, [$2], [$4]) 
    }

  | CCX qubit COMMA qubit COMMA qubit { 
    debug ("CCX " ^ string_of_int $2 ^ " " ^ string_of_int $4 ^ " " ^ string_of_int $6); 
    if $2 = $4 then failwith "Parser.statement.CCX, co1 = co2\n" else
    if $2 = $6 then failwith "Parser.statement.CCX, co1 = ta\n" else
    if $4 = $6 then failwith "Parser.statement.CCX, co2 = ta\n" else
    Program.Apply(X, [$2; $4], [$6]) 
    }

  | CCZ qubit COMMA qubit COMMA qubit { 
    debug ("CCZ " ^ string_of_int $2 ^ " " ^ string_of_int $4 ^ " " ^ string_of_int $6); 
    if $2 = $4 then failwith "Parser.statement.CCZ, co1 = co2\n" else
    if $2 = $6 then failwith "Parser.statement.CCZ, co1 = ta\n" else
    if $4 = $6 then failwith "Parser.statement.CCZ, co2 = ta\n" else
    ccz $2 $4 $6 
    }

  | SWAP qubit COMMA qubit { 
    debug ("SWAP " ^ string_of_int $2 ^ " " ^ string_of_int $4); 
    if $2 = $4 then failwith "Parser.statement.SWAP, ta1 = ta2\n" else
    Program.Sequence (Program.Sequence (Program.Apply(X, [$2], [$4]),Program.Apply(X, [$4], [$2])),Program.Apply(X,[$2],[$4])) 
    }

  | CSWAP qubit COMMA qubit COMMA qubit { 
    debug ("CSWAP " ^ string_of_int $2 ^ " " ^ string_of_int $4 ^ " " ^ string_of_int $6); 
    if $2 = $4 then failwith "Parser.statement.SWAP, ta1 = ta2\n" else
    Program.Sequence (Program.Sequence (Program.Apply(X, [$2;$4], [$6]),Program.Apply(X, [$2;$6], [$4])),Program.Apply(X,[$2;$4],[$6])) 
    }

  | RX angle qubit { 
    let s,den = $2 in
    debug ("RX " ^ Q.to_string s ^ "/" ^ Z.to_string den ^ " " ^ string_of_int $3); 
    if Parser_help.condition_empty_program s den then Program.E else
    let k = Parser_help.den_to_k den in
    let p = rx ~s:(Q.to_int s) k $3 in
    debug (sprintf "-> %s\n" (ProgS.pretty p));
    p
    }

  | RY angle qubit { 
    let s,den = $2 in
    debug ("RY " ^ Q.to_string s ^ "/" ^ Z.to_string den ^ " " ^ string_of_int $3); 
    if Parser_help.condition_empty_program s den then Program.E else
    let k = Parser_help.den_to_k den in
    let p = ry ~s:(Q.to_int s) k $3 in
    debug (sprintf "-> %s\n" (ProgS.pretty p));
    p
    }

  | RZ angle qubit { 
    let s,den = $2 in
    debug ("RZ " ^ Q.to_string s ^ "/" ^ Z.to_string den ^ " " ^ string_of_int $3); 
    if Parser_help.condition_empty_program s den then Program.E else
    let k = Parser_help.den_to_k den in
    let p = Program.Sequence (Apply (GP (Q.neg s,k+1),[],[]), Program.Apply (U1 (s,k),[],[$3])) in
    debug (sprintf "-> %s\n" (ProgS.pretty p));
    p
    }

  | SX qubit { 
    debug ("SX " ^ string_of_int $2); 
    let p = sx $2  in
    debug (sprintf "-> %s\n" (ProgS.pretty p));
    p
    }

  | CRZ angle qubit COMMA qubit { 
    let s,den = $2 in
    debug ("CRZ " ^ Q.to_string s ^ "/" ^ Z.to_string den ^ " " ^ string_of_int $3 ^ " " ^ string_of_int $5); 
    if $3 = $5 then failwith "Parser.statement.CRZ, co = ta\n" else
    if Parser_help.condition_empty_program s den then Program.E else(
    let k = Parser_help.den_to_k den in
    let p = Program.Sequence (Apply (GP (Q.neg s,k+1),[],[]), Program.Apply (U1 (s,k),[$3],[$5])) in
    debug (sprintf "-> %s\n" (ProgS.pretty p));
    p)
  }

  | U1 angle qubit { 
    let s,den = $2 in
    debug ("U1 " ^ Q.to_string s ^ "/" ^ Z.to_string den ^ " " ^ string_of_int $3); 
    if Parser_help.condition_empty_program s den then Program.E else
    let k = Parser_help.den_to_k den in
    let p = Program.Apply (U1 (s,k),[],[$3]) in
    debug (sprintf "-> %s\n" (ProgS.pretty p));
    p
    }

  | CU1 angle qubit COMMA qubit { 
    let s,den = $2 in
    debug ("CU1 " ^ Q.to_string s ^ "/" ^ Z.to_string den ^ " " ^ string_of_int $3 ^ " " ^ string_of_int $5); 
    if $3 = $5 then failwith "Parser.statement.CU1, co = ta\n" else
    if Parser_help.condition_empty_program s den then Program.E else(
    let k = Parser_help.den_to_k den in
    let p = Program.Apply (U1 (s,k),[$3],[$5]) in
    debug (sprintf "-> %s\n" (ProgS.exact p));
    p)
    }

  | X qubit { debug ("X " ^ string_of_int $2); Program.Apply(X, [], [$2]) }
  | Z qubit { debug ("Z " ^ string_of_int $2); Program.Apply(U1 (Q.one,1), [], [$2]) }
  | CZ qubit COMMA qubit { 
    debug ("CZ " ^ string_of_int $2 ^ " " ^ string_of_int $4); 
    if $2 = $4 then failwith "Parser.statement.CZ, co = ta\n" else
    Program.Apply(U1 (Q.one,1), [$2], [$4]) 
    }
  | ZDG qubit { 
    debug ("ZDG " ^ string_of_int $2); 
    Program.Apply(U1 (Q.minus_one,2), [], [$2]) }
  | S qubit { 
    debug ("S " ^ string_of_int $2); 
    Program.Apply(U1 (Q.one,2), [], [$2]) }
  | SDG qubit { 
    debug ("SDG " ^ string_of_int $2); 
    Program.Apply(U1 (Q.minus_one,2), [], [$2]) }
  | T qubit { Program.Apply(U1 (Q.one,3), [], [$2]) }
  | TDG qubit { 
    debug ("TDG " ^ string_of_int $2);
    Program.Apply(U1 (Q.minus_one, 3), [], [$2]) }

  | MEASURE qubit ARROW creg { 
    debug ("MEASURE " ^ string_of_int $2 ^ " -> " ^ string_of_int $4); 
    Program.Measure($2,$4) }

  | IF LRBRACKET creg EQUAL INT RRBRACKET statement { 
    let co = Parser_help.int_to_control_qubits $5 $3 in
    debug ("IF c" ^ (ListBis.string_int co) ^ " then " ^ (ProgS.pretty $7)); 
    Program.It (co,$7) }
  
  | RESET qubit { InitQ $2 }

  | qreg_declaration { Program.E }
  | creg_declaration { 
    Program.E }

creg:
  | IDENT { 
    let co = Parser_help.classical_register_to_int $1 in
    debug((sprintf "1. 1 = %s, creg, co = %d\n" $1 (co) ));
    co}
  | IDENT LBRACKET INT RBRACKET { 
    let co = Parser_help.classical_register_to_int $1 + $3 in
    debug((sprintf "2. creg, 1 = %s, 3 = %d, co = %d\n" $1 $3 co ));
    co}

qreg_declaration:
  | QREG IDENT LBRACKET INT RBRACKET { $4 }

creg_declaration:
  | CREG IDENT LBRACKET INT RBRACKET { $4 }

qubit:
  | IDENT LBRACKET INT RBRACKET { $3 }

angle:
  // (pi/den)
  | LRBRACKET PI DIV INT RRBRACKET { (Q.of_int 1,Z.of_int $4) }
  // (-pi/den)
  | LRBRACKET MPI DIV INT RRBRACKET { (Q.of_int (-1),Z.of_int $4) }
  // (pi)
  | LRBRACKET PI RRBRACKET { (Q.of_int 1,Z.of_int 1) }
  // (-pi/den)
  | LRBRACKET MPI RRBRACKET { (Q.of_int (-1),Z.of_int 1) }
  // (num*pi/den)
  | LRBRACKET INT MUL PI DIV INT RRBRACKET { 
    let num, den = Q.of_int $2,Z.of_int $6 in 
    (num,den)  }
  | LRBRACKET MINUS INT MUL PI DIV INT RRBRACKET { 
    let num, den = Q.of_int (-$3),Z.of_int $7 in 
    (num,den)  }
  // (num*pi)
  | LRBRACKET INT MUL PI RRBRACKET { (Q.of_int $2,Z.of_int 1) }
  // e^0 = e^(2 pi/2^0)
  | LRBRACKET INT RRBRACKET { if $2 = 0 then (Q.zero,Z.zero) else failwith "Parser.angle\n" }


