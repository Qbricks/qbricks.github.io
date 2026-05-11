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
module PSS = Path_sum.String
module QS = Qubit.String
module PS = Poly.String
module Ket = Path_sum.Ket
module KS = Ket.String
open Common
module ProgS = Program.String
include Program.Macros
include Rational
module Monome = Poly.Monome
open Parser_get.GetProg

let ( -- ) p1 p2 : Program.t = Program.Sequence (p1, p2)

let test_prog_equiv ?(debug = true) ?(not_equiv = false)
    ?(algo = Equiv.Sequence) ?(equivalence = Equiv.SubCircuit) (p1 : Program.t)
    (p2 : Program.t) () =
  let greeting =
    Equiv.sqv_simple_result ~debug ~not_equiv ~algo ~equivalence p1 p2
  in
  let expected = true in
  check bool
    (sprintf "Test.test_prog_equiv\np1 =\n%s\np2 =\n%s\n" (ProgS.pretty p1)
       (ProgS.pretty p2))
    expected greeting

let test_prog_equiv_qasm ?(debug = true) ?(algo = Equiv.Sequence)
    ?(not_equiv = false) ?(equivalence = Equiv.SubCircuit) (p1' : string)
    (p2' : string) () =
  let greeting =
    let current_dir = Sys.getcwd () in
    printf "Test.test_prog_equiv_qasm, p1' = %s\n" p1';
    printf "Test.test_prog_equiv_qasm, p2' = %s\n" p2';
    printf "Test.test_prog_equiv_qasm, The file is read from the folder: %s\n"
      current_dir;
    let p1 = Program.format (to_prog p1') in
    let p2 = Program.format (to_prog p2') in
    Equiv.sqv_simple_result ~debug ~not_equiv ~algo ~equivalence p1 p2
  in
  let expected = true in
  check bool
    (sprintf "Test.test_prog_equiv\np1 =\n%s\np2 =\n%s\n" p1' p2')
    expected greeting

let unitary_global_phase =
  [
    ( "rz 1 <> u1 1",
      `Quick,
      test_prog_equiv ~not_equiv:false ~equivalence:GlobalPhase (rz 1 0)
        (u1 1 0) );
    ( "crz 1 <> cu1 1, conditional phase",
      `Quick,
      test_prog_equiv ~not_equiv:true ~equivalence:GlobalPhase (crz 1 0 1)
        (cu1 1 0 1) );
    ( "crz 1 <> h 1 -- cx 0 1 -- h 1, conditional phase",
      `Quick,
      test_prog_equiv ~not_equiv:true ~equivalence:GlobalPhase (crz 1 0 1)
        (h 1 -- cx 0 1 -- h 1) );
    ( "cu1 1 = h 1 -- cx 0 1 -- h 1",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (cu1 1 0 1) (h 1 -- cx 0 1 -- h 1)
    );
    ( "h 1 -- cx 0 1 -- h 1 = cu1 1",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase
        (h 1 -- cx 0 1 -- h 1)
        (cu1 1 0 1) );
    ( "h <> x -- h, conditional phase",
      `Quick,
      test_prog_equiv ~not_equiv:true ~equivalence:GlobalPhase (h 0) (x 0 -- h 0)
    );
    ( "x = gp 2 -- rx 1",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (gp 2 -- rx 1 0) (x 0) );
    ("h = h", `Quick, test_prog_equiv ~equivalence:GlobalPhase (h 0) (h 0));
    ( "z = hxh",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (h 0 -- x 0 -- h 0) (zz 0) );
    ( "x = hzh",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (h 0 -- zz 0 -- h 0) (x 0) );
    ( "cz = hcxh",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (h 1 -- cx 0 1 -- h 1) (cz 0 1)
    );
    ( "cz = hcrxh",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (h 1 -- cx 0 1 -- h 1) (cz 0 1)
    );
    ( "cx = hczh",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (h 1 -- cz 0 1 -- h 1) (cx 0 1)
    );
    ( "ccx = ccxoq2",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (ccxoq2 0 1 2) (ccx 0 1 2) );
    ( "ccx = ccxoq2",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (ccxoq2 3 5 0) (ccx 3 5 0) );
    ("x_qb", `Quick, test_prog_equiv ~equivalence:GlobalPhase (x_qb 0) (x 0));
    ( "ccx_qb",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (ccx_qb 0 1 2) (ccx 0 1 2) );
    ( "gp 2 -- gp 2 = gp 1",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (gp 2 -- gp 2) (gp 1) );
    ( "gp 5 -- gp 5 = gp 4",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (gp 5 -- gp 5) (gp 4) );
    ( "gp 4 = gp 5 -- gp 5",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (gp 4) (gp 5 -- gp 5) );
    ( "gp -4 = gp -5 -- gp -5",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (gp ~s:(-1) 4)
        (gp ~s:(-1) 5 -- gp ~s:(-1) 5) );
    ( "u1 2 -- u1 2 = rx 1",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (u1 2 0 -- u1 2 0) (u1 1 0) );
    ( "rx 2 -- rx 2 = rx 1",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (rx 1 0) (rx 2 0 -- rx 2 0) );
    ( "rx 5 -- rx 5 = rx 4",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (rx 4 0) (rx 5 0 -- rx 5 0) );
    ( "ry 2 -- ry 2 = ry 1",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (ry 2 0 -- ry 2 0) (ry 1 0) );
    ( "ry 5 -- ry 5 = ry 4",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (ry 5 0 -- ry 5 0) (ry 4 0) );
    ( "ry (-3) -- ry (-3) = ry (-2)",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase
        (ry ~s:(-1) 3 0 -- ry ~s:(-1) 3 0)
        (ry ~s:(-1) 2 0) );
    ( "rz 2 -- rz 2 = rz 1",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (rz 2 0 -- rz 2 0) (rz 1 0) );
    ( "rz 2 -- gp 3 -- rz 2 -- gp 3 = rz 1 -- gp 2",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase
        (rz 2 0 -- gp 3 -- rz 2 0 -- gp 3)
        (rz 1 0 -- gp 2) );
    ( "h -- h = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (h 0 -- h 0) id );
    ( "x -- x = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (x 0 -- x 0) id );
    ( "x 0 -- ss 0 -- h 0 = x 0 -- ss 0 -- h 0",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase
        (x 0 -- ss 0 -- h 0)
        (x 0 -- ss 0 -- h 0) );
    ( "y -- y = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (y 0 -- y 0) id );
    ( "z -- z = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (zz 0 -- zz 0) id );
    ( "gp 0 -- gp (0) = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (gp 0 -- gp 0) id );
    ( "gp 2 -- gp (-2) = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (gp 2 -- gp ~s:(-1) 2) id );
    ( "gp (-5) -- gp 5 = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (gp ~s:(-1) 5 -- gp 5) id );
    ( "gp (-7/2^19) -- gp 7/2^19 = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (gp ~s:(-7) 19 -- gp ~s:7 19) id
    );
    ( "rx 0 -- rx 0 = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (rx 0 0 -- rx 0 0) id );
    ( "rx 2 -- rx (-2) = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (rx 2 0 -- rx ~s:(-1) 2 0) id );
    ( "rx 17/2^2 -- rx (-17/2^2) = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase
        (rx ~s:17 2 0 -- rx ~s:(-17) 2 0)
        id );
    ( "rz 0 -- rz 0 = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (rz 0 0 -- rz 0 0) id );
    ( "rz 2 -- rz (-2) = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (rz 2 0 -- rz ~s:(-1) 2 0) id );
    ( "ry 0 -- ry 0 = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (ry 0 0 -- ry 0 0) id );
    ( "ry 1 -- ry (-1) = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (ry 1 0 -- ry ~s:(-1) 1 0) id );
    ( "ry 2 -- ry (-2) = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (ry 2 0 -- ry ~s:(-1) 2 0) id );
    ( "ry_not 1 = ry -1",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (ry ~s:(-1) 1 0)
        (x 0 -- ry 1 0 -- x 0) );
    ( "y = gp 2 -- ry 1",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (y 0) (gp 2 -- ry 1 0) );
    ( "rx 3 = sinv -- ry 3 -- s",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (rx 3 0)
        (sinv 0 -- ry 3 0 -- ss 0) );
    ( "rz (-4) = h -- rx (-4) -- h",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (rz ~s:(-1) 4 0)
        (h 0 -- rx ~s:(-1) 4 0 -- h 0) );
    ( "rz (4) = u1(2) -- x -- u1(-2) -- x",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (rz 4 0)
        (u1 5 0 -- x 0 -- u1 ~s:(-1) 5 0 -- x 0) );
    ( "rz (4) = gp (-5) -- u1 4",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (rz 4 0) (gp ~s:(-1) 5 -- u1 4 0)
    );
    ( "gp 5 -- rz (4) = u1 4",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (gp 5 -- rz 4 0) (u1 4 0) );
    ( "u1 2 0 -- crz (1) = cu1 1",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (u1 2 0 -- crz 1 0 1) (cu1 1 0 1)
    );
    ( "crz (4) = u1 (-5) --  cu1 4",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (crz 4 0 1)
        (u1 ~s:(-1) 5 0 -- cu1 4 0 1) );
    ( "rz (4) = u1(5) -- x -- u1(-5) -- x",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (rz 4 0)
        (u1 5 0 -- x 0 -- u1 ~s:(-1) 5 0 -- x 0) );
    ( "u1 (4) = gp 5 -- u1(5) -- x -- u1(-5) -- x",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (u1 4 0)
        (gp 5 -- u1 5 0 -- x 0 -- u1 ~s:(-1) 5 0 -- x 0) );
    ( "crz (4) =  u1(5) -- cx -- u1(-5) -- cx",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (crz 4 0 1) (crzdecomp 4 0 1) );
    ( "cu1 (4) = u1 (5) -- u1(5) -- cx -- u1(-5) -- cx",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (cu1 4 0 1) (cu1decomp 4 0 1) );
    ( "cu1 (-4) = u1 (-5) -- u1(-5) -- cx -- u1(5) -- cx",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (cu1 ~s:(-1) 4 0 1)
        (cu1decomp ~s:(-1) 4 0 1) );
    ( "cu1 (-1) = cu1decomp (-1)",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (cu1 ~s:(-1) 1 0 1)
        (cu1decomp ~s:(-1) 1 0 1) );
    ( "cu1 (1) = cu1decomp (1)",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (cu1 1 0 1) (cu1decomp 1 0 1) );
    ( "cu1 (0) = cu1decomp (0)",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (cu1 0 0 1) (cu1decomp 0 0 1) );
    ( "ccu1 (1) 0 1 2 = cu1decomp 1 0 1 2",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (ccu1 1 0 1 2)
        (ccu1decomp 1 0 1 2) );
    ( "ccu1 (-1) 2 3 0 1 = cu1decomp (-1) 2 3 0 1",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (ccu1 ~s:(-1) 2 3 0 1)
        (ccu1decomp ~s:(-1) 2 3 0 1) );
    ( "ry 5 = s -- h -- rz 5 -- h -- sinv",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (ry 5 0)
        (ss 0 -- h 0 -- rz 5 0 -- h 0 -- sinv 0) );
    ( "FALSE angle gf2^32",
      `Slow,
      test_prog_equiv_qasm ~not_equiv:true ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/combinational/rev_circuit/gf2^32mult_1117_5213.qasm"
        "benchmarks/buggy/gf2^32_mult_veriqbench_FALSE_angle.qasm" );
    ( "FALSE gate gf2^32",
      `Slow,
      test_prog_equiv_qasm ~not_equiv:true ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/combinational/rev_circuit/gf2^32mult_1117_5213.qasm"
        "benchmarks/buggy/gf2^32_mult_veriqbench_FALSE_gate.qasm" );
    ( "FALSE indice gf2^32",
      `Slow,
      test_prog_equiv_qasm ~not_equiv:true ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/combinational/rev_circuit/gf2^32mult_1117_5213.qasm"
        "benchmarks/buggy/gf2^32_mult_veriqbench_FALSE_indice.qasm" );
    ( "FALSE gate grover_15",
      `Slow,
      test_prog_equiv_qasm ~not_equiv:true ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/combinational/grover/grover_15.qasm"
        "benchmarks/buggy/grover_15_veriqbench_FALSE_gate.qasm" );
    ( "FALSE indice grover_15",
      `Slow,
      test_prog_equiv_qasm ~not_equiv:true ~equivalence:GlobalPhase
        "benchmarks/buggy/grover_15_veriqbench_FALSE_indice.qasm"
        "benchmarks/VeriQbench/combinational/grover/grover_15.qasm" );
    ( "FALSE angle grover_15",
      `Slow,
      test_prog_equiv_qasm ~not_equiv:true ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/combinational/grover/grover_15.qasm"
        "benchmarks/buggy/grover_15_veriqbench_FALSE_angle.qasm" );
    ( "FALSE angle grover_5",
      `Slow,
      test_prog_equiv_qasm ~not_equiv:true ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/combinational/grover/grover_5.qasm"
        "benchmarks/buggy/grover_5_veriqbench_FALSE_angle.qasm" );
  ]

let unitary =
  [
    ("rz 1 <> u1 1", `Quick, test_prog_equiv ~not_equiv:true (rz 1 0) (u1 1 0));
    ( "crz 1 <> cu1 1",
      `Quick,
      test_prog_equiv ~not_equiv:true (crz 1 0 1) (cu1 1 0 1) );
    ( "crz 1 <> h 1 -- cx 0 1 -- h 1",
      `Quick,
      test_prog_equiv ~not_equiv:true (crz 1 0 1) (h 1 -- cx 0 1 -- h 1) );
    ( "cu1 1 = h 1 -- cx 0 1 -- h 1",
      `Quick,
      test_prog_equiv (cu1 1 0 1) (h 1 -- cx 0 1 -- h 1) );
    ( "h 1 -- cx 0 1 -- h 1 = cu1 1",
      `Quick,
      test_prog_equiv (h 1 -- cx 0 1 -- h 1) (cu1 1 0 1) );
    ("h <> x -- h", `Quick, test_prog_equiv ~not_equiv:true (h 0) (x 0 -- h 0));
    ("x = gp 2 -- rx 1", `Quick, test_prog_equiv (gp 2 -- rx 1 0) (x 0));
    ("h = h", `Quick, test_prog_equiv (h 0) (h 0));
    ("z = hxh", `Quick, test_prog_equiv (h 0 -- x 0 -- h 0) (zz 0));
    ("x = hzh", `Quick, test_prog_equiv (h 0 -- zz 0 -- h 0) (x 0));
    ("cz = hcxh", `Quick, test_prog_equiv (h 1 -- cx 0 1 -- h 1) (cz 0 1));
    ("cz = hcrxh", `Quick, test_prog_equiv (h 1 -- cx 0 1 -- h 1) (cz 0 1));
    ("cx = hczh", `Quick, test_prog_equiv (h 1 -- cz 0 1 -- h 1) (cx 0 1));
    ("ccx = ccxoq2", `Quick, test_prog_equiv (ccxoq2 0 1 2) (ccx 0 1 2));
    ("ccx = ccxoq2", `Quick, test_prog_equiv (ccxoq2 3 5 0) (ccx 3 5 0));
    ("x_qb", `Quick, test_prog_equiv (x_qb 0) (x 0));
    ("ccx_qb", `Quick, test_prog_equiv (ccx_qb 0 1 2) (ccx 0 1 2));
    ("gp 2 -- gp 2 = gp 1", `Quick, test_prog_equiv (gp 2 -- gp 2) (gp 1));
    ("gp 5 -- gp 5 = gp 4", `Quick, test_prog_equiv (gp 5 -- gp 5) (gp 4));
    ("gp 4 = gp 5 -- gp 5", `Quick, test_prog_equiv (gp 4) (gp 5 -- gp 5));
    ( "gp -4 = gp -5 -- gp -5",
      `Quick,
      test_prog_equiv (gp ~s:(-1) 4) (gp ~s:(-1) 5 -- gp ~s:(-1) 5) );
    ("u1 2 -- u1 2 = rx 1", `Quick, test_prog_equiv (u1 2 0 -- u1 2 0) (u1 1 0));
    ("rx 2 -- rx 2 = rx 1", `Quick, test_prog_equiv (rx 1 0) (rx 2 0 -- rx 2 0));
    ("rx 5 -- rx 5 = rx 4", `Quick, test_prog_equiv (rx 4 0) (rx 5 0 -- rx 5 0));
    ("ry 2 -- ry 2 = ry 1", `Quick, test_prog_equiv (ry 2 0 -- ry 2 0) (ry 1 0));
    ("ry 5 -- ry 5 = ry 4", `Quick, test_prog_equiv (ry 5 0 -- ry 5 0) (ry 4 0));
    ( "ry (-3) -- ry (-3) = ry (-2)",
      `Quick,
      test_prog_equiv (ry ~s:(-1) 3 0 -- ry ~s:(-1) 3 0) (ry ~s:(-1) 2 0) );
    ("rz 2 -- rz 2 = rz 1", `Quick, test_prog_equiv (rz 2 0 -- rz 2 0) (rz 1 0));
    ( "rz 2 -- gp 3 -- rz 2 -- gp 3 = rz 1 -- gp 2",
      `Quick,
      test_prog_equiv (rz 2 0 -- gp 3 -- rz 2 0 -- gp 3) (rz 1 0 -- gp 2) );
    ("h -- h = id", `Quick, test_prog_equiv (h 0 -- h 0) id);
    ("x -- x = id", `Quick, test_prog_equiv (x 0 -- x 0) id);
    ( "x 0 -- ss 0 -- h 0 = x 0 -- ss 0 -- h 0",
      `Quick,
      test_prog_equiv (x 0 -- ss 0 -- h 0) (x 0 -- ss 0 -- h 0) );
    ("y -- y = id", `Quick, test_prog_equiv (y 0 -- y 0) id);
    ("z -- z = id", `Quick, test_prog_equiv (zz 0 -- zz 0) id);
    ("gp 0 -- gp (0) = id", `Quick, test_prog_equiv (gp 0 -- gp 0) id);
    ("gp 2 -- gp (-2) = id", `Quick, test_prog_equiv (gp 2 -- gp ~s:(-1) 2) id);
    ("gp (-5) -- gp 5 = id", `Quick, test_prog_equiv (gp ~s:(-1) 5 -- gp 5) id);
    ( "gp (-7/2^19) -- gp 7/2^19 = id",
      `Quick,
      test_prog_equiv (gp ~s:(-7) 19 -- gp ~s:7 19) id );
    ("rx 0 -- rx 0 = id", `Quick, test_prog_equiv (rx 0 0 -- rx 0 0) id);
    ( "rx 2 -- rx (-2) = id",
      `Quick,
      test_prog_equiv (rx 2 0 -- rx ~s:(-1) 2 0) id );
    ( "rx 17/2^2 -- rx (-17/2^2) = id",
      `Quick,
      test_prog_equiv (rx ~s:17 2 0 -- rx ~s:(-17) 2 0) id );
    ("rz 0 -- rz 0 = id", `Quick, test_prog_equiv (rz 0 0 -- rz 0 0) id);
    ( "rz 2 -- rz (-2) = id",
      `Quick,
      test_prog_equiv (rz 2 0 -- rz ~s:(-1) 2 0) id );
    ("ry 0 -- ry 0 = id", `Quick, test_prog_equiv (ry 0 0 -- ry 0 0) id);
    ( "ry 1 -- ry (-1) = id",
      `Quick,
      test_prog_equiv (ry 1 0 -- ry ~s:(-1) 1 0) id );
    ( "ry 2 -- ry (-2) = id",
      `Quick,
      test_prog_equiv (ry 2 0 -- ry ~s:(-1) 2 0) id );
    ( "ry_not 1 = ry -1",
      `Quick,
      test_prog_equiv (ry ~s:(-1) 1 0) (x 0 -- ry 1 0 -- x 0) );
    ("y = gp 2 -- ry 1", `Quick, test_prog_equiv (y 0) (gp 2 -- ry 1 0));
    (* \( S^{-1} Ry(k) S = Rx (k) \) *)
    ( "rx 3 = sinv -- ry 3 -- s",
      `Quick,
      test_prog_equiv (rx 3 0) (sinv 0 -- ry 3 0 -- ss 0) );
    (* \( H Rx(k) H = Rz (k) \) *)
    ( "rz (-4) = h -- rx (-4) -- h",
      `Quick,
      test_prog_equiv (rz ~s:(-1) 4 0) (h 0 -- rx ~s:(-1) 4 0 -- h 0) );
    (* \( Rz(k) = U1(k/2) X U1(-k/2) X \) *)
    ( "rz (4) = u1(2) -- x -- u1(-2) -- x",
      `Quick,
      test_prog_equiv (rz 4 0) (u1 5 0 -- x 0 -- u1 ~s:(-1) 5 0 -- x 0) );
    ( "rz (4) = gp (-5) -- u1 4",
      `Quick,
      test_prog_equiv (rz 4 0) (gp ~s:(-1) 5 -- u1 4 0) );
    ("gp 5 -- rz (4) = u1 4", `Quick, test_prog_equiv (gp 5 -- rz 4 0) (u1 4 0));
    (* CRZ k co ta = CU1 k co ta -- U1 (-k/2) ta  *)
    ( "u1 2 0 -- crz (1) = cu1 1",
      `Quick,
      test_prog_equiv (u1 2 0 -- crz 1 0 1) (cu1 1 0 1) );
    ( "crz (4) = u1 (-5) --  cu1 4",
      `Quick,
      test_prog_equiv (crz 4 0 1) (u1 ~s:(-1) 5 0 -- cu1 4 0 1) );
    (* \( Rz(k) = U1(k/2) X U1(-k/2) X \) *)
    ( "rz (4) = u1(5) -- x -- u1(-5) -- x",
      `Quick,
      test_prog_equiv (rz 4 0) (u1 5 0 -- x 0 -- u1 ~s:(-1) 5 0 -- x 0) );
    ( "u1 (4) = gp 5 -- u1(5) -- x -- u1(-5) -- x",
      `Quick,
      test_prog_equiv (u1 4 0) (gp 5 -- u1 5 0 -- x 0 -- u1 ~s:(-1) 5 0 -- x 0)
    );
    ( "crz (4) =  u1(5) -- cx -- u1(-5) -- cx",
      `Quick,
      test_prog_equiv (crz 4 0 1) (crzdecomp 4 0 1) );
    ( "cu1 (4) = u1 (5) -- u1(5) -- cx -- u1(-5) -- cx",
      `Quick,
      test_prog_equiv (cu1 4 0 1) (cu1decomp 4 0 1) );
    ( "cu1 (-4) = u1 (-5) -- u1(-5) -- cx -- u1(5) -- cx",
      `Quick,
      test_prog_equiv (cu1 ~s:(-1) 4 0 1) (cu1decomp ~s:(-1) 4 0 1) );
    ( "cu1 (-1) = cu1decomp (-1)",
      `Quick,
      test_prog_equiv (cu1 ~s:(-1) 1 0 1) (cu1decomp ~s:(-1) 1 0 1) );
    ( "cu1 (1) = cu1decomp (1)",
      `Quick,
      test_prog_equiv (cu1 1 0 1) (cu1decomp 1 0 1) );
    ( "cu1 (0) = cu1decomp (0)",
      `Quick,
      test_prog_equiv (cu1 0 0 1) (cu1decomp 0 0 1) );
    ( "ccu1 (1) 0 1 2 = cu1decomp 1 0 1 2",
      `Quick,
      test_prog_equiv (ccu1 1 0 1 2) (ccu1decomp 1 0 1 2) );
    ( "ccu1 (-1) 2 3 0 1 = cu1decomp (-1) 2 3 0 1",
      `Quick,
      test_prog_equiv (ccu1 ~s:(-1) 2 3 0 1) (ccu1decomp ~s:(-1) 2 3 0 1) );
    (* \( Ry(k) = S H Rz(k) H S^{-1} \) *)
    ( "ry 5 = s -- h -- rz 5 -- h -- sinv",
      `Quick,
      test_prog_equiv (ry 5 0) (ss 0 -- h 0 -- rz 5 0 -- h 0 -- sinv 0) );
    ( "FALSE angle gf2^32",
      `Slow,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/combinational/rev_circuit/gf2^32mult_1117_5213.qasm"
        "benchmarks/buggy/gf2^32_mult_veriqbench_FALSE_angle.qasm" );
    ( "FALSE gate gf2^32",
      `Slow,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/combinational/rev_circuit/gf2^32mult_1117_5213.qasm"
        "benchmarks/buggy/gf2^32_mult_veriqbench_FALSE_gate.qasm" );
    ( "FALSE indice gf2^32",
      `Slow,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/combinational/rev_circuit/gf2^32mult_1117_5213.qasm"
        "benchmarks/buggy/gf2^32_mult_veriqbench_FALSE_indice.qasm" );
    ( "FALSE gate grover_15",
      `Slow,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/combinational/grover/grover_15.qasm"
        "benchmarks/buggy/grover_15_veriqbench_FALSE_gate.qasm" );
    ( "FALSE indice grover_15",
      `Slow,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/buggy/grover_15_veriqbench_FALSE_indice.qasm"
        "benchmarks/VeriQbench/combinational/grover/grover_15.qasm" );
    ( "FALSE angle grover_15",
      `Slow,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/combinational/grover/grover_15.qasm"
        "benchmarks/buggy/grover_15_veriqbench_FALSE_angle.qasm" );
    ( "FALSE angle grover_5",
      `Slow,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/combinational/grover/grover_5.qasm"
        "benchmarks/buggy/grover_5_veriqbench_FALSE_angle.qasm" );
  ]

let unitary_into_feynman =
  [
    ("cz_feynman 0 1", `Quick, test_prog_equiv (cz 0 1) (cz_feynman 0 1));
    ( "cz_feynman 1 2 -- h 3",
      `Quick,
      test_prog_equiv (cz 1 2 -- h 3) (cz_feynman 1 2 -- h 3) );
    ( "cz_feynman 0 3 -- h 3",
      `Quick,
      test_prog_equiv (cz 0 3 -- h 3) (cz_feynman 0 3 -- h 3) );
    ( "FALSE cz_feynman 0 3 -- h 3",
      `Quick,
      test_prog_equiv ~not_equiv:true (cs 0 3 -- h 3) (cz_feynman 0 3 -- h 3) );
    ("cs_feynman 1 0", `Quick, test_prog_equiv (cs 1 0) (cs_feynman 1 0));
    ( "cs_feynman 1 2 -- h 1",
      `Quick,
      test_prog_equiv (cs 1 2 -- h 1) (cs_feynman 1 2 -- h 1) );
    ( "cs_feynman 1 2 -- h 1 -- x 3",
      `Quick,
      test_prog_equiv (cs 1 2 -- h 1 -- x 3) (cs_feynman 1 2 -- h 1 -- x 3) );
    ( "ccx_feynman 0 1 2 -- h 1 -- x 3",
      `Quick,
      test_prog_equiv (ccx 0 1 2 -- h 1 -- x 3) (ccx_feynman 0 1 2 -- h 1 -- x 3)
    );
    ( "ccx_feynman 3 1 5 -- h 1 -- x 6",
      `Quick,
      test_prog_equiv (ccx 3 1 5 -- h 1 -- x 6) (ccx_feynman 3 1 5 -- h 1 -- x 6)
    );
    ( "FALSE ccx_feynman 2 1 5 -- h 1 -- x 6",
      `Quick,
      test_prog_equiv ~not_equiv:true
        (ccx 2 1 5 -- h 1 -- x 6)
        (ccx_feynman 3 1 5 -- h 1 -- x 6) );
    ( "cu1decomp 1 1 2 -- h 1 -- x 3",
      `Quick,
      test_prog_equiv (cu1 1 1 2 -- h 1 -- x 3) (cu1decomp 1 1 2 -- h 1 -- x 3)
    );
    ( "cu1decomp 3 1 5 -- h 1 -- x 6",
      `Quick,
      test_prog_equiv (cu1 3 1 5 -- h 1 -- x 6) (cu1decomp 3 1 5 -- h 1 -- x 6)
    );
    ( "FALSE cu1decomp 3 1 5 -- h 1 -- x 6",
      `Quick,
      test_prog_equiv ~not_equiv:true
        (cu1 3 1 5 -- h 0 -- x 6)
        (cu1decomp 3 1 5 -- h 1 -- x 6) );
  ]

let parallel =
  [
    ( "rz 1 <> u1 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~not_equiv:true (rz 1 0) (u1 1 0) );
    ( "crz 1 <> cu1 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~not_equiv:true (crz 1 0 1) (cu1 1 0 1) );
    ( "crz 1 <> h 1 -- cx 0 1 -- h 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~not_equiv:true (crz 1 0 1)
        (h 1 -- cx 0 1 -- h 1) );
    ( "cu1 1 = h 1 -- cx 0 1 -- h 1",
      `Quick,
      test_prog_equiv ~algo:Parallel (cu1 1 0 1) (h 1 -- cx 0 1 -- h 1) );
    ( "h 1 -- cx 0 1 -- h 1 = cu1 1",
      `Quick,
      test_prog_equiv ~algo:Parallel (h 1 -- cx 0 1 -- h 1) (cu1 1 0 1) );
    ( "h <> x -- h",
      `Quick,
      test_prog_equiv ~algo:Parallel ~not_equiv:true (h 0) (x 0 -- h 0) );
    ("z <> id", `Quick, test_prog_equiv ~algo:Parallel ~not_equiv:true (zz 0) E);
    ("t <> id", `Quick, test_prog_equiv ~algo:Parallel ~not_equiv:true (tt 0) E);
    ( "x = gp 2 -- rx 1",
      `Quick,
      test_prog_equiv ~algo:Parallel (gp 2 -- rx 1 0) (x 0) );
    ("h = h", `Quick, test_prog_equiv ~algo:Parallel (h 0) (h 0));
    ( "z = hxh",
      `Quick,
      test_prog_equiv ~algo:Parallel (h 0 -- x 0 -- h 0) (zz 0) );
    ( "x = hzh",
      `Quick,
      test_prog_equiv ~algo:Parallel (h 0 -- zz 0 -- h 0) (x 0) );
    ( "cz = hcxh",
      `Quick,
      test_prog_equiv ~algo:Parallel (h 1 -- cx 0 1 -- h 1) (cz 0 1) );
    ( "cz = hcrxh",
      `Quick,
      test_prog_equiv ~algo:Parallel (h 1 -- cx 0 1 -- h 1) (cz 0 1) );
    ( "cx = hczh",
      `Quick,
      test_prog_equiv ~algo:Parallel (h 1 -- cz 0 1 -- h 1) (cx 0 1) );
    ( "ccx = ccxoq2",
      `Quick,
      test_prog_equiv ~algo:Parallel (ccxoq2 0 1 2) (ccx 0 1 2) );
    ( "ccx = ccxoq2",
      `Quick,
      test_prog_equiv ~algo:Parallel (ccxoq2 3 5 0) (ccx 3 5 0) );
    ("x_qb", `Quick, test_prog_equiv ~algo:Parallel (x_qb 0) (x 0));
    ("ccx_qb", `Quick, test_prog_equiv ~algo:Parallel (ccx_qb 0 1 2) (ccx 0 1 2));
    ( "gp 2 -- gp 2 = gp 1",
      `Quick,
      test_prog_equiv ~algo:Parallel (gp 2 -- gp 2) (gp 1) );
    ( "gp 5 -- gp 5 = gp 4",
      `Quick,
      test_prog_equiv ~algo:Parallel (gp 5 -- gp 5) (gp 4) );
    ( "gp 4 = gp 5 -- gp 5",
      `Quick,
      test_prog_equiv ~algo:Parallel (gp 4) (gp 5 -- gp 5) );
    ( "gp -4 = gp -5 -- gp -5",
      `Quick,
      test_prog_equiv ~algo:Parallel (gp ~s:(-1) 4)
        (gp ~s:(-1) 5 -- gp ~s:(-1) 5) );
    ( "u1 2 -- u1 2 = rx 1",
      `Quick,
      test_prog_equiv ~algo:Parallel (u1 2 0 -- u1 2 0) (u1 1 0) );
    ( "rx 2 -- rx 2 = rx 1",
      `Quick,
      test_prog_equiv ~algo:Parallel (rx 1 0) (rx 2 0 -- rx 2 0) );
    ( "rx 5 -- rx 5 = rx 4",
      `Quick,
      test_prog_equiv ~algo:Parallel (rx 4 0) (rx 5 0 -- rx 5 0) );
    ( "ry 2 -- ry 2 = ry 1",
      `Quick,
      test_prog_equiv ~algo:Parallel (ry 2 0 -- ry 2 0) (ry 1 0) );
    ( "ry 5 -- ry 5 = ry 4",
      `Quick,
      test_prog_equiv ~algo:Parallel (ry 5 0 -- ry 5 0) (ry 4 0) );
    ( "ry (-3) -- ry (-3) = ry (-2)",
      `Quick,
      test_prog_equiv ~algo:Parallel
        (ry ~s:(-1) 3 0 -- ry ~s:(-1) 3 0)
        (ry ~s:(-1) 2 0) );
    ( "rz 2 -- rz 2 = rz 1",
      `Quick,
      test_prog_equiv ~algo:Parallel (rz 2 0 -- rz 2 0) (rz 1 0) );
    ( "rz 2 -- gp 3 -- rz 2 -- gp 3 = rz 1 -- gp 2",
      `Quick,
      test_prog_equiv ~algo:Parallel
        (rz 2 0 -- gp 3 -- rz 2 0 -- gp 3)
        (rz 1 0 -- gp 2) );
    ("h -- h = id", `Quick, test_prog_equiv ~algo:Parallel (h 0 -- h 0) id);
    ("x -- x = id", `Quick, test_prog_equiv ~algo:Parallel (x 0 -- x 0) id);
    ( "x 0 -- ss 0 -- h 0 = x 0 -- ss 0 -- h 0",
      `Quick,
      test_prog_equiv ~algo:Parallel (x 0 -- ss 0 -- h 0) (x 0 -- ss 0 -- h 0)
    );
    ("y -- y = id", `Quick, test_prog_equiv ~algo:Parallel (y 0 -- y 0) id);
    ("z -- z = id", `Quick, test_prog_equiv ~algo:Parallel (zz 0 -- zz 0) id);
    ( "gp 0 -- gp (0) = id",
      `Quick,
      test_prog_equiv ~algo:Parallel (gp 0 -- gp 0) id );
    ( "gp 2 -- gp (-2) = id",
      `Quick,
      test_prog_equiv ~algo:Parallel (gp 2 -- gp ~s:(-1) 2) id );
    ( "gp (-5) -- gp 5 = id",
      `Quick,
      test_prog_equiv ~algo:Parallel (gp ~s:(-1) 5 -- gp 5) id );
    ( "gp (-7/2^19) -- gp 7/2^19 = id",
      `Quick,
      test_prog_equiv ~algo:Parallel (gp ~s:(-7) 19 -- gp ~s:7 19) id );
    ( "rx 0 -- rx 0 = id",
      `Quick,
      test_prog_equiv ~algo:Parallel (rx 0 0 -- rx 0 0) id );
    ( "rx 2 -- rx (-2) = id",
      `Quick,
      test_prog_equiv ~algo:Parallel (rx 2 0 -- rx ~s:(-1) 2 0) id );
    ( "rx 17/2^2 -- rx (-17/2^2) = id",
      `Quick,
      test_prog_equiv ~algo:Parallel (rx ~s:17 2 0 -- rx ~s:(-17) 2 0) id );
    ( "rz 0 -- rz 0 = id",
      `Quick,
      test_prog_equiv ~algo:Parallel (rz 0 0 -- rz 0 0) id );
    ( "rz 2 -- rz (-2) = id",
      `Quick,
      test_prog_equiv ~algo:Parallel (rz 2 0 -- rz ~s:(-1) 2 0) id );
    ( "ry 0 -- ry 0 = id",
      `Quick,
      test_prog_equiv ~algo:Parallel (ry 0 0 -- ry 0 0) id );
    ( "ry 1 -- ry (-1) = id",
      `Quick,
      test_prog_equiv ~algo:Parallel (ry 1 0 -- ry ~s:(-1) 1 0) id );
    ( "ry 2 -- ry (-2) = id",
      `Quick,
      test_prog_equiv ~algo:Parallel (ry 2 0 -- ry ~s:(-1) 2 0) id );
    ( "ry_not 1 = ry -1",
      `Quick,
      test_prog_equiv ~algo:Parallel (ry ~s:(-1) 1 0) (x 0 -- ry 1 0 -- x 0) );
    ( "y = gp 2 -- ry 1",
      `Quick,
      test_prog_equiv ~algo:Parallel (y 0) (gp 2 -- ry 1 0) );
    (* \( S^{-1} Ry(k) S = Rx (k) \) *)
    ( "rx 3 = sinv -- ry 3 -- s",
      `Quick,
      test_prog_equiv ~algo:Parallel (rx 3 0) (sinv 0 -- ry 3 0 -- ss 0) );
    (* \( H Rx(k) H = Rz (k) \) *)
    ( "rz (-4) = h -- rx (-4) -- h",
      `Quick,
      test_prog_equiv ~algo:Parallel (rz ~s:(-1) 4 0)
        (h 0 -- rx ~s:(-1) 4 0 -- h 0) );
    (* \( Rz(k) = U1(k/2) X U1(-k/2) X \) *)
    ( "rz (4) = u1(2) -- x -- u1(-2) -- x",
      `Quick,
      test_prog_equiv ~algo:Parallel (rz 4 0)
        (u1 5 0 -- x 0 -- u1 ~s:(-1) 5 0 -- x 0) );
    ( "rz (4) = gp (-5) -- u1 4",
      `Quick,
      test_prog_equiv ~algo:Parallel (rz 4 0) (gp ~s:(-1) 5 -- u1 4 0) );
    ( "gp 5 -- rz (4) = u1 4",
      `Quick,
      test_prog_equiv ~algo:Parallel (gp 5 -- rz 4 0) (u1 4 0) );
    (* CRZ k co ta = CU1 k co ta -- U1 (-k/2) ta  *)
    ( "u1 2 0 -- crz (1) = cu1 1",
      `Quick,
      test_prog_equiv ~algo:Parallel (u1 2 0 -- crz 1 0 1) (cu1 1 0 1) );
    ( "crz (4) = u1 (-5) --  cu1 4",
      `Quick,
      test_prog_equiv ~algo:Parallel (crz 4 0 1) (u1 ~s:(-1) 5 0 -- cu1 4 0 1)
    );
    (* \( Rz(k) = U1(k/2) X U1(-k/2) X \) *)
    ( "rz (4) = u1(5) -- x -- u1(-5) -- x",
      `Quick,
      test_prog_equiv ~algo:Parallel (rz 4 0)
        (u1 5 0 -- x 0 -- u1 ~s:(-1) 5 0 -- x 0) );
    ( "u1 (4) = gp 5 -- u1(5) -- x -- u1(-5) -- x",
      `Quick,
      test_prog_equiv ~algo:Parallel (u1 4 0)
        (gp 5 -- u1 5 0 -- x 0 -- u1 ~s:(-1) 5 0 -- x 0) );
    ( "crz (4) =  u1(5) -- cx -- u1(-5) -- cx",
      `Quick,
      test_prog_equiv ~algo:Parallel (crz 4 0 1) (crzdecomp 4 0 1) );
    ( "cu1 (4) = u1 (5) -- u1(5) -- cx -- u1(-5) -- cx",
      `Quick,
      test_prog_equiv ~algo:Parallel (cu1 4 0 1) (cu1decomp 4 0 1) );
    ( "cu1 (-4) = u1 (-5) -- u1(-5) -- cx -- u1(5) -- cx",
      `Quick,
      test_prog_equiv ~algo:Parallel (cu1 ~s:(-1) 4 0 1)
        (cu1decomp ~s:(-1) 4 0 1) );
    ( "cu1 (-1) = cu1decomp (-1)",
      `Quick,
      test_prog_equiv ~algo:Parallel (cu1 ~s:(-1) 1 0 1)
        (cu1decomp ~s:(-1) 1 0 1) );
    ( "cu1 (1) = cu1decomp (1)",
      `Quick,
      test_prog_equiv ~algo:Parallel (cu1 1 0 1) (cu1decomp 1 0 1) );
    ( "cu1 (0) = cu1decomp (0)",
      `Quick,
      test_prog_equiv ~algo:Parallel (cu1 0 0 1) (cu1decomp 0 0 1) );
    ( "ccu1 (1) 0 1 2 = cu1decomp 1 0 1 2",
      `Quick,
      test_prog_equiv ~algo:Parallel (ccu1 1 0 1 2) (ccu1decomp 1 0 1 2) );
    ( "ccu1 (-1) 2 3 0 1 = cu1decomp (-1) 2 3 0 1",
      `Quick,
      test_prog_equiv ~algo:Parallel (ccu1 ~s:(-1) 2 3 0 1)
        (ccu1decomp ~s:(-1) 2 3 0 1) );
    (* \( Ry(k) = S H Rz(k) H S^{-1} \) *)
    ( "ry 5 = s -- h -- rz 5 -- h -- sinv",
      `Quick,
      test_prog_equiv ~algo:Parallel (ry 5 0)
        (ss 0 -- h 0 -- rz 5 0 -- h 0 -- sinv 0) );
    ( "FALSE angle gf2^32",
      `Slow,
      test_prog_equiv_qasm ~algo:Parallel ~not_equiv:true
        "benchmarks/VeriQbench/combinational/rev_circuit/gf2^32mult_1117_5213.qasm"
        "benchmarks/buggy/gf2^32_mult_veriqbench_FALSE_angle.qasm" );
    ( "FALSE gate gf2^32",
      `Slow,
      test_prog_equiv_qasm ~algo:Parallel ~not_equiv:true
        "benchmarks/VeriQbench/combinational/rev_circuit/gf2^32mult_1117_5213.qasm"
        "benchmarks/buggy/gf2^32_mult_veriqbench_FALSE_gate.qasm" );
    ( "FALSE indice gf2^32",
      `Slow,
      test_prog_equiv_qasm ~algo:Parallel ~not_equiv:true
        "benchmarks/VeriQbench/combinational/rev_circuit/gf2^32mult_1117_5213.qasm"
        "benchmarks/buggy/gf2^32_mult_veriqbench_FALSE_indice.qasm" );
    ( "FALSE gate grover_15",
      `Slow,
      test_prog_equiv_qasm ~algo:Parallel ~not_equiv:true
        "benchmarks/VeriQbench/combinational/grover/grover_15.qasm"
        "benchmarks/buggy/grover_15_veriqbench_FALSE_gate.qasm" );
    ( "FALSE indice grover_15",
      `Slow,
      test_prog_equiv_qasm ~algo:Parallel ~not_equiv:true
        "benchmarks/buggy/grover_15_veriqbench_FALSE_indice.qasm"
        "benchmarks/VeriQbench/combinational/grover/grover_15.qasm" );
    ( "FALSE angle grover_15",
      `Slow,
      test_prog_equiv_qasm ~algo:Parallel ~not_equiv:true
        "benchmarks/VeriQbench/combinational/grover/grover_15.qasm"
        "benchmarks/buggy/grover_15_veriqbench_FALSE_angle.qasm" );
    ( "FALSE angle grover_5",
      `Slow,
      test_prog_equiv_qasm ~algo:Parallel ~not_equiv:true
        "benchmarks/VeriQbench/combinational/grover/grover_5.qasm"
        "benchmarks/buggy/grover_5_veriqbench_FALSE_angle.qasm" );
  ]

let parallel_global_phase =
  [
    ( "rz 1 <> u1 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:false
        (rz 1 0) (u1 1 0) );
    ( "crz 1 <> cu1 1, conditional phase",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        (crz 1 0 1) (cu1 1 0 1) );
    ( "crz 1 <> h 1 -- cx 0 1 -- h 1, conditional phase",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        (crz 1 0 1)
        (h 1 -- cx 0 1 -- h 1) );
    ( "cu1 1 = h 1 -- cx 0 1 -- h 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (cu1 1 0 1)
        (h 1 -- cx 0 1 -- h 1) );
    ( "h 1 -- cx 0 1 -- h 1 = cu1 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (h 1 -- cx 0 1 -- h 1)
        (cu1 1 0 1) );
    ( "h <> x -- h",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        (h 0)
        (x 0 -- h 0) );
    ( "z <> id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        (zz 0) E );
    ( "t <> id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        (tt 0) E );
    ( "x = gp 2 -- rx 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (gp 2 -- rx 1 0)
        (x 0) );
    ( "h = h",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (h 0) (h 0) );
    ( "z = hxh",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- x 0 -- h 0)
        (zz 0) );
    ( "x = hzh",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- zz 0 -- h 0)
        (x 0) );
    ( "cz = hcxh",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (h 1 -- cx 0 1 -- h 1)
        (cz 0 1) );
    ( "cz = hcrxh",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (h 1 -- cx 0 1 -- h 1)
        (cz 0 1) );
    ( "cx = hczh",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (h 1 -- cz 0 1 -- h 1)
        (cx 0 1) );
    ( "ccx = ccxoq2",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (ccxoq2 0 1 2)
        (ccx 0 1 2) );
    ( "ccx = ccxoq2",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (ccxoq2 3 5 0)
        (ccx 3 5 0) );
    ( "x_qb",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (x_qb 0) (x 0) );
    ( "ccx_qb",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (ccx_qb 0 1 2)
        (ccx 0 1 2) );
    ( "gp 2 -- gp 2 = gp 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (gp 2 -- gp 2)
        (gp 1) );
    ( "gp 5 -- gp 5 = gp 4",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (gp 5 -- gp 5)
        (gp 4) );
    ( "gp 4 = gp 5 -- gp 5",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (gp 4)
        (gp 5 -- gp 5) );
    ( "gp -4 = gp -5 -- gp -5",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (gp ~s:(-1) 4)
        (gp ~s:(-1) 5 -- gp ~s:(-1) 5) );
    ( "u1 2 -- u1 2 = rx 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (u1 2 0 -- u1 2 0)
        (u1 1 0) );
    ( "rx 2 -- rx 2 = rx 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (rx 1 0)
        (rx 2 0 -- rx 2 0) );
    ( "rx 5 -- rx 5 = rx 4",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (rx 4 0)
        (rx 5 0 -- rx 5 0) );
    ( "ry 2 -- ry 2 = ry 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (ry 2 0 -- ry 2 0)
        (ry 1 0) );
    ( "ry 5 -- ry 5 = ry 4",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (ry 5 0 -- ry 5 0)
        (ry 4 0) );
    ( "ry (-3) -- ry (-3) = ry (-2)",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (ry ~s:(-1) 3 0 -- ry ~s:(-1) 3 0)
        (ry ~s:(-1) 2 0) );
    ( "rz 2 -- rz 2 = rz 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (rz 2 0 -- rz 2 0)
        (rz 1 0) );
    ( "rz 2 -- gp 3 -- rz 2 -- gp 3 = rz 1 -- gp 2",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (rz 2 0 -- gp 3 -- rz 2 0 -- gp 3)
        (rz 1 0 -- gp 2) );
    ( "h -- h = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- h 0) id );
    ( "x -- x = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (x 0 -- x 0) id );
    ( "x 0 -- ss 0 -- h 0 = x 0 -- ss 0 -- h 0",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (x 0 -- ss 0 -- h 0)
        (x 0 -- ss 0 -- h 0) );
    ( "y -- y = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (y 0 -- y 0) id );
    ( "z -- z = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (zz 0 -- zz 0) id
    );
    ( "gp 0 -- gp (0) = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (gp 0 -- gp 0) id
    );
    ( "gp 2 -- gp (-2) = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (gp 2 -- gp ~s:(-1) 2)
        id );
    ( "gp (-5) -- gp 5 = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (gp ~s:(-1) 5 -- gp 5)
        id );
    ( "gp (-7/2^19) -- gp 7/2^19 = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (gp ~s:(-7) 19 -- gp ~s:7 19)
        id );
    ( "rx 0 -- rx 0 = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (rx 0 0 -- rx 0 0)
        id );
    ( "rx 2 -- rx (-2) = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (rx 2 0 -- rx ~s:(-1) 2 0)
        id );
    ( "rx 17/2^2 -- rx (-17/2^2) = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (rx ~s:17 2 0 -- rx ~s:(-17) 2 0)
        id );
    ( "rz 0 -- rz 0 = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (rz 0 0 -- rz 0 0)
        id );
    ( "rz 2 -- rz (-2) = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (rz 2 0 -- rz ~s:(-1) 2 0)
        id );
    ( "ry 0 -- ry 0 = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (ry 0 0 -- ry 0 0)
        id );
    ( "ry 1 -- ry (-1) = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (ry 1 0 -- ry ~s:(-1) 1 0)
        id );
    ( "ry 2 -- ry (-2) = id",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (ry 2 0 -- ry ~s:(-1) 2 0)
        id );
    ( "ry_not 1 = ry -1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (ry ~s:(-1) 1 0)
        (x 0 -- ry 1 0 -- x 0) );
    ( "y = gp 2 -- ry 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (y 0)
        (gp 2 -- ry 1 0) );
    (* \( S^{-1} Ry(k) S = Rx (k) \) *)
    ( "rx 3 = sinv -- ry 3 -- s",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (rx 3 0)
        (sinv 0 -- ry 3 0 -- ss 0) );
    (* \( H Rx(k) H = Rz (k) \) *)
    ( "rz (-4) = h -- rx (-4) -- h",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (rz ~s:(-1) 4 0)
        (h 0 -- rx ~s:(-1) 4 0 -- h 0) );
    (* \( Rz(k) = U1(k/2) X U1(-k/2) X \) *)
    ( "rz (4) = u1(2) -- x -- u1(-2) -- x",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (rz 4 0)
        (u1 5 0 -- x 0 -- u1 ~s:(-1) 5 0 -- x 0) );
    ( "rz (4) = gp (-5) -- u1 4",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (rz 4 0)
        (gp ~s:(-1) 5 -- u1 4 0) );
    ( "gp 5 -- rz (4) = u1 4",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (gp 5 -- rz 4 0)
        (u1 4 0) );
    (* CRZ k co ta = CU1 k co ta -- U1 (-k/2) ta  *)
    ( "u1 2 0 -- crz (1) = cu1 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (u1 2 0 -- crz 1 0 1)
        (cu1 1 0 1) );
    ( "crz (4) = u1 (-5) --  cu1 4",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (crz 4 0 1)
        (u1 ~s:(-1) 5 0 -- cu1 4 0 1) );
    (* \( Rz(k) = U1(k/2) X U1(-k/2) X \) *)
    ( "rz (4) = u1(5) -- x -- u1(-5) -- x",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (rz 4 0)
        (u1 5 0 -- x 0 -- u1 ~s:(-1) 5 0 -- x 0) );
    ( "u1 (4) = gp 5 -- u1(5) -- x -- u1(-5) -- x",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (u1 4 0)
        (gp 5 -- u1 5 0 -- x 0 -- u1 ~s:(-1) 5 0 -- x 0) );
    ( "crz (4) =  u1(5) -- cx -- u1(-5) -- cx",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (crz 4 0 1)
        (crzdecomp 4 0 1) );
    ( "cu1 (4) = u1 (5) -- u1(5) -- cx -- u1(-5) -- cx",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (cu1 4 0 1)
        (cu1decomp 4 0 1) );
    ( "cu1 (-4) = u1 (-5) -- u1(-5) -- cx -- u1(5) -- cx",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (cu1 ~s:(-1) 4 0 1) (cu1decomp ~s:(-1) 4 0 1) );
    ( "cu1 (-1) = cu1decomp (-1)",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (cu1 ~s:(-1) 1 0 1) (cu1decomp ~s:(-1) 1 0 1) );
    ( "cu1 (1) = cu1decomp (1)",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (cu1 1 0 1)
        (cu1decomp 1 0 1) );
    ( "cu1 (0) = cu1decomp (0)",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (cu1 0 0 1)
        (cu1decomp 0 0 1) );
    ( "ccu1 (1) 0 1 2 = cu1decomp 1 0 1 2",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (ccu1 1 0 1 2)
        (ccu1decomp 1 0 1 2) );
    ( "ccu1 (-1) 2 3 0 1 = cu1decomp (-1) 2 3 0 1",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase
        (ccu1 ~s:(-1) 2 3 0 1)
        (ccu1decomp ~s:(-1) 2 3 0 1) );
    (* \( Ry(k) = S H Rz(k) H S^{-1} \) *)
    ( "ry 5 = s -- h -- rz 5 -- h -- sinv",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase (ry 5 0)
        (ss 0 -- h 0 -- rz 5 0 -- h 0 -- sinv 0) );
    ( "FALSE angle gf2^32",
      `Slow,
      test_prog_equiv_qasm ~algo:Parallel ~equivalence:GlobalPhase
        ~not_equiv:true
        "benchmarks/VeriQbench/combinational/rev_circuit/gf2^32mult_1117_5213.qasm"
        "benchmarks/buggy/gf2^32_mult_veriqbench_FALSE_angle.qasm" );
    ( "FALSE gate gf2^32",
      `Slow,
      test_prog_equiv_qasm ~algo:Parallel ~equivalence:GlobalPhase
        ~not_equiv:true
        "benchmarks/VeriQbench/combinational/rev_circuit/gf2^32mult_1117_5213.qasm"
        "benchmarks/buggy/gf2^32_mult_veriqbench_FALSE_gate.qasm" );
    ( "FALSE indice gf2^32",
      `Slow,
      test_prog_equiv_qasm ~algo:Parallel ~equivalence:GlobalPhase
        ~not_equiv:true
        "benchmarks/VeriQbench/combinational/rev_circuit/gf2^32mult_1117_5213.qasm"
        "benchmarks/buggy/gf2^32_mult_veriqbench_FALSE_indice.qasm" );
    ( "FALSE gate grover_15",
      `Slow,
      test_prog_equiv_qasm ~algo:Parallel ~equivalence:GlobalPhase
        ~not_equiv:true
        "benchmarks/VeriQbench/combinational/grover/grover_15.qasm"
        "benchmarks/buggy/grover_15_veriqbench_FALSE_gate.qasm" );
    ( "FALSE indice grover_15",
      `Slow,
      test_prog_equiv_qasm ~algo:Parallel ~equivalence:GlobalPhase
        ~not_equiv:true
        "benchmarks/buggy/grover_15_veriqbench_FALSE_indice.qasm"
        "benchmarks/VeriQbench/combinational/grover/grover_15.qasm" );
    ( "FALSE angle grover_15",
      `Slow,
      test_prog_equiv_qasm ~algo:Parallel ~equivalence:GlobalPhase
        ~not_equiv:true
        "benchmarks/VeriQbench/combinational/grover/grover_15.qasm"
        "benchmarks/buggy/grover_15_veriqbench_FALSE_angle.qasm" );
    ( "FALSE angle grover_5",
      `Slow,
      test_prog_equiv_qasm ~algo:Parallel ~equivalence:GlobalPhase
        ~not_equiv:true
        "benchmarks/VeriQbench/combinational/grover/grover_5.qasm"
        "benchmarks/buggy/grover_5_veriqbench_FALSE_angle.qasm" );
  ]

let () =
  Alcotest.run "Symbolic execution"
    [
      ("Global-Phase-Seq-Unit-Eq", unitary_global_phase);
      ("Sub-Cir-Seq-Unit-Eq", unitary);
      ("Sub-Cir-Seq-Unit-Eq Into Feynman", unitary_into_feynman);
      ("Sub-Cir-Par-Unit-Eq", parallel);
      ("Global-Phase-Par-Unit-Eq", parallel_global_phase);
    ]
