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

open Alcotest
open Printf
open SQbricks
open Path_sum
module PSS = String
module ProgS = Program.String
open Parser_get.GetProg
open Parser_get.GetPs

let verif_specs ?(wrong = false) ?(debug = true) pre prog post () =
  let greeting =
    let pre = to_ps pre in
    if debug then printf "Verif.verif_specs, pre =\n%s\n\n" (PSS.pretty pre);
    let prog = to_prog prog in
    if debug then printf "Verif.verif_specs, prog = %s\n\n" (ProgS.pretty prog);
    let post = to_ps post in
    if debug then printf "Verif.verif_specs, post =\n%s\n\n" (PSS.pretty post);
    let unit, _, _ = To_deferred_measurement.to_deferred_measurements prog in
    if debug then printf "Verif.verif_specs, unit = %s\n\n" (ProgS.pretty unit);
    let ps = Program.execution ~input_state:pre unit in
    if debug then printf "Verif.verif_specs, ps =\n%s\n\n" (PSS.pretty ps);
    let result = Path_sum.equal ps post in
    if wrong then not result else result
  in
  let expected = true in
  check bool (sprintf "Test.verif\n") expected greeting

let verif =
  [
    ( "h",
      `Quick,
      verif_specs "benchmarks/verif/h/pre.txt" "benchmarks/verif/h/circ.qasm"
        "benchmarks/verif/h/post.txt" );
    ( "h wrong",
      `Quick,
      verif_specs ~wrong:true "benchmarks/verif/h/pre.txt"
        "benchmarks/verif/h/circ.qasm" "benchmarks/verif/h/post-wrong.txt" );
    ( "x",
      `Quick,
      verif_specs "benchmarks/verif/x/pre.txt" "benchmarks/verif/x/circ.qasm"
        "benchmarks/verif/x/post.txt" );
    ( "x wrong",
      `Quick,
      verif_specs ~wrong:true "benchmarks/verif/x/pre.txt"
        "benchmarks/verif/x/circ.qasm" "benchmarks/verif/x/post-wrong.txt" );
    ( "z",
      `Quick,
      verif_specs "benchmarks/verif/z/pre.txt" "benchmarks/verif/z/circ.qasm"
        "benchmarks/verif/z/post.txt" );
    ( "z wrong",
      `Quick,
      verif_specs ~wrong:true "benchmarks/verif/z/pre.txt"
        "benchmarks/verif/z/circ.qasm" "benchmarks/verif/z/post-wrong.txt" );
    ( "cx",
      `Quick,
      verif_specs "benchmarks/verif/cx/pre.txt" "benchmarks/verif/cx/circ.qasm"
        "benchmarks/verif/cx/post.txt" );
    ( "cx wrong",
      `Quick,
      verif_specs ~wrong:true "benchmarks/verif/cx/pre.txt"
        "benchmarks/verif/cx/circ.qasm" "benchmarks/verif/cx/post-wrong.txt" );
    ( "cz",
      `Quick,
      verif_specs "benchmarks/verif/cz/pre.txt" "benchmarks/verif/cz/circ.qasm"
        "benchmarks/verif/cz/post.txt" );
    ( "cz wrong",
      `Quick,
      verif_specs ~wrong:true "benchmarks/verif/cz/pre.txt"
        "benchmarks/verif/cz/circ.qasm" "benchmarks/verif/cz/post-wrong.txt" );
    ( "ch",
      `Quick,
      verif_specs "benchmarks/verif/ch/pre.txt" "benchmarks/verif/ch/circ.qasm"
        "benchmarks/verif/ch/post.txt" );
    ( "ch wrong",
      `Quick,
      verif_specs ~wrong:true "benchmarks/verif/ch/pre.txt"
        "benchmarks/verif/ch/circ.qasm" "benchmarks/verif/ch/post-wrong.txt" );
    ( "coin toss",
      `Quick,
      verif_specs "benchmarks/verif/coin-toss2/pre.txt"
        "benchmarks/verif/coin-toss2/circ.qasm"
        "benchmarks/verif/coin-toss2/post.txt" );
    ( "coin toss wrong",
      `Quick,
      verif_specs ~wrong:true "benchmarks/verif/coin-toss2/pre.txt"
        "benchmarks/verif/coin-toss2/circ.qasm"
        "benchmarks/verif/coin-toss2/post-wrong.txt" );
  ]

let () = Alcotest.run "Symbolic execution" [ ("Specification", verif) ]
