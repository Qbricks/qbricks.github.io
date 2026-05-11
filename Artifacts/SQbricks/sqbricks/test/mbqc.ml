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
module Path_sum_library = Path_sum.Path_sum_library
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

let test_owm ?(debug = true) ?(algo = Equiv.Sequence)
    ?(equivalence = Equiv.SubCircuit) (p : Program.t) () =
  let greeting =
    let by_meas, inputs1, outputs1 = Owm.to_owm p ~debug in
    let _, wq = Program.widths p in
    let inputs2 = ListBis.range 0 wq in
    let outputs2 = inputs2 in
    let by_meas_dm, _, meas1 =
      To_deferred_measurement.to_deferred_measurements by_meas
    in
    let result =
      Equiv.sqv_simple_result ~debug ~algo ~equivalence ~inputs1 ~outputs1
        ~meas1 ~inputs2 ~outputs2 by_meas_dm p
    in
    result
  in
  let expected = true in
  check bool (sprintf "Test.test_owm\n") expected greeting

let owm =
  [
    ("id", `Quick, test_owm id);
    ("z", `Quick, test_owm (zz 0));
    ("z", `Quick, test_owm (zz 4));
    ("z", `Quick, test_owm (zz 3));
    ("z", `Quick, test_owm (zz 3));
    ("z", `Quick, test_owm (zz 3));
    ("z", `Quick, test_owm (zz 3));
    ("z", `Quick, test_owm (zz 3));
    ("z", `Quick, test_owm (zz 3));
    ("z", `Quick, test_owm (zz 3));
    ("z", `Quick, test_owm (zz 3));
    ("zz", `Quick, test_owm (zz 0 -- zz 0));
    ("zz", `Quick, test_owm (zz 1 -- zz 1));
    ("zz", `Quick, test_owm (zz 1 -- zz 3));
    ("zz", `Quick, test_owm (zz 0 -- zz 1 -- zz 3 -- zz 4));
    ("s", `Quick, test_owm (ss 0));
    ("ss", `Quick, test_owm (ss 0 -- ss 0));
    ("ss", `Quick, test_owm (ss 1 -- ss 0 -- ss 4));
    ("ss rewrite", `Quick, test_owm (ss 1 -- ss 0 -- ss 4));
    ("t", `Quick, test_owm (tt 0));
    ("tt rewrite", `Quick, test_owm (tt 1 -- tt 0 -- tt 4));
    ("sinv", `Quick, test_owm (sinv 2));
    ("tinv", `Quick, test_owm (tinv 4));
    ("zinv", `Quick, test_owm (zinv 0));
    ("zinv", `Quick, test_owm (zinv 3));
    ("zinv", `Quick, test_owm (zinv 4));
    ("u1", `Quick, test_owm (u1 1 0));
    ("u1", `Quick, test_owm (u1 ~s:(-1) 5 0));
    ("u1", `Quick, test_owm (u1 ~s:(-1) 5 3));
    ("h", `Quick, test_owm (h 0));
    ("h", `Quick, test_owm (h 2));
    ("hh", `Quick, test_owm (h 0 -- h 0));
    ("x", `Quick, test_owm (x 0));
    ("x", `Quick, test_owm (x 0));
    ("x", `Quick, test_owm (x 1));
    ("x", `Quick, test_owm (x 2));
    ("x", `Quick, test_owm (x 3));
    ("xx", `Quick, test_owm (x 0 -- x 1));
    ("cx", `Quick, test_owm (cx 0 3));
    ("cx", `Quick, test_owm (cx 1 2));
    ("cx", `Quick, test_owm (cx 1 2));
    ("cx", `Quick, test_owm (cx 1 0));
    ("cx", `Quick, test_owm (cx 5 3));
    ("cxcx", `Quick, test_owm (cx 0 1 -- cx 0 1));
    ("cxcx", `Quick, test_owm (cx 3 0 -- cx 2 7));
    ("cxcx", `Quick, test_owm (cx 7 1 -- cx 0 5));
    ("cxcx", `Quick, test_owm (cx 0 1 -- cx 1 2 -- cx 1 2));
    ("hx", `Quick, test_owm (h 0 -- x 0));
    ("xh", `Quick, test_owm (x 0 -- h 0));
    ("hxh", `Quick, test_owm (h 0 -- x 0 -- h 0));
    ("hz", `Quick, test_owm (h 0 -- zz 0));
    ("zh", `Quick, test_owm (zz 0 -- h 0));
    ("hzh", `Quick, test_owm (h 0 -- zz 0 -- h 0));
    ("ht", `Quick, test_owm (h 0 -- tt 0));
    ("th", `Quick, test_owm (tt 0 -- h 0));
    ("hth", `Quick, test_owm (h 0 -- tt 0 -- h 0));
    ("hs", `Quick, test_owm (h 0 -- ss 0));
    ("sh", `Quick, test_owm (ss 0 -- h 0));
    ("hsh", `Quick, test_owm (h 0 -- ss 0 -- h 0));
    ("hsh", `Quick, test_owm (h 0 -- ss 0 -- h 1));
    ("hsh", `Quick, test_owm (h 0 -- ss 1 -- h 2));
    ("hsh", `Quick, test_owm (h 3 -- ss 1 -- h 4));
    ("hsh", `Quick, test_owm (h 0 -- ss 5 -- h 5));
    ("cxh", `Quick, test_owm (cx 0 1 -- h 0));
    ("cxh", `Quick, test_owm (cx 1 3 -- h 1));
    ("cxh", `Quick, test_owm (cx 1 3 -- h 0));
    ("cxh", `Quick, test_owm (cx 1 3 -- h 3));
    ("cxhh", `Quick, test_owm (cx 1 3 -- h 3 -- h 0));
    ("hcxhh'", `Quick, test_owm (h 0 -- cx 1 3 -- h 3 -- h 0));
    ("hcxhh''", `Quick, test_owm (h 0 -- h 1 -- cx 0 1));
    (* ( "hcxhh",
      `Quick,
      test_owm
        (cx 3 4 -- zz 1 -- h 0 -- cx 1 3 -- ss 0 -- h 3 -- h 0 -- tt 2 -- h 4
       -- cx 0 4) ); *)
    ("cxh", `Quick, test_owm (cx 3 1 -- h 1));
    ("ccxoq2", `Quick, test_owm (ccxoq2 0 1 2));
    ("x_qb", `Quick, test_owm (x_qb 0));
    ("crzdecomp", `Quick, test_owm (crzdecomp 1 0 1));
    ("cu1decomp", `Quick, test_owm (cu1decomp ~s:(-1) 5 0 1));
    ("cu1decomp", `Quick, test_owm (cu1decomp ~s:(-1) 5 0 1));
    ("cu1decomp", `Quick, test_owm (cu1decomp ~s:(-1) 5 0 1));
    ("cu1decomp", `Quick, test_owm (cu1decomp ~s:(-1) 5 0 1));
    ("chdecomp", `Quick, test_owm (chdecomp 0 1));
    ("bv2", `Quick, test_owm (h 0 -- x 1 -- h 1 -- cx 0 1 -- h 0 -- h 1));
    ( "bv3",
      `Quick,
      test_owm
        (h 0 -- h 1 -- x 2 -- h 2 -- cx 0 2 -- cx 1 2 -- h 0 -- h 1 -- h 2) );
    ( "bv7",
      `Quick,
      test_owm
        (h 0 -- h 1 -- h 2 -- h 3 -- h 4 -- h 5 -- x 6 -- h 6 -- cx 0 6
       -- cx 1 6 -- cx 2 6 -- cx 3 6 -- cx 4 6 -- cx 5 6 -- h 0 -- h 1 -- h 2
       -- h 3 -- h 4 -- h 5 -- h 6) );
    ("cxn", `Quick, test_owm (cx 0 1 -- cx 1 2));
    ("ccx", `Quick, test_owm (ccx 0 1 2));
    ("swap", `Quick, test_owm (swap 0 1));
    ("swap", `Quick, test_owm (swap 1 3 -- swap 4 2 -- swap 1 2));
    ("pe3'", `Quick, test_owm (h 1 -- cu1 2 1 2 -- h 0 -- h 1));
    ( "pe3",
      `Quick,
      test_owm
        (h 0 -- h 1 -- h 2 -- cu1 9 2 3 -- cu1 8 1 3 -- cu1 7 0 3 -- h 0
       -- cu1 ~s:(-1) 1 0 1 -- cu1 ~s:(-1) 2 0 2 -- h 1 -- cu1 ~s:(-1) 1 1 2
       -- h 2) );
  ]

let owm_global_phase =
  [
    ("id", `Quick, test_owm ~equivalence:GlobalPhase id);
    ("z", `Quick, test_owm ~equivalence:GlobalPhase (zz 0));
    ("z", `Quick, test_owm ~equivalence:GlobalPhase (zz 4));
    ("z", `Quick, test_owm ~equivalence:GlobalPhase (zz 3));
    ("z", `Quick, test_owm ~equivalence:GlobalPhase (zz 3));
    ("z", `Quick, test_owm ~equivalence:GlobalPhase (zz 3));
    ("z", `Quick, test_owm ~equivalence:GlobalPhase (zz 3));
    ("z", `Quick, test_owm ~equivalence:GlobalPhase (zz 3));
    ("z", `Quick, test_owm ~equivalence:GlobalPhase (zz 3));
    ("z", `Quick, test_owm ~equivalence:GlobalPhase (zz 3));
    ("z", `Quick, test_owm ~equivalence:GlobalPhase (zz 3));
    ("zz", `Quick, test_owm ~equivalence:GlobalPhase (zz 0 -- zz 0));
    ("zz", `Quick, test_owm ~equivalence:GlobalPhase (zz 1 -- zz 1));
    ("zz", `Quick, test_owm ~equivalence:GlobalPhase (zz 1 -- zz 3));
    ( "zz",
      `Quick,
      test_owm ~equivalence:GlobalPhase (zz 0 -- zz 1 -- zz 3 -- zz 4) );
    ("s", `Quick, test_owm ~equivalence:GlobalPhase (ss 0));
    ("ss", `Quick, test_owm ~equivalence:GlobalPhase (ss 0 -- ss 0));
    ("ss", `Quick, test_owm ~equivalence:GlobalPhase (ss 1 -- ss 0 -- ss 4));
    ( "ss rewrite",
      `Quick,
      test_owm ~equivalence:GlobalPhase (ss 1 -- ss 0 -- ss 4) );
    ("t", `Quick, test_owm ~equivalence:GlobalPhase (tt 0));
    ( "tt rewrite",
      `Quick,
      test_owm ~equivalence:GlobalPhase (tt 1 -- tt 0 -- tt 4) );
    ("sinv", `Quick, test_owm ~equivalence:GlobalPhase (sinv 2));
    ("tinv", `Quick, test_owm ~equivalence:GlobalPhase (tinv 4));
    ("zinv", `Quick, test_owm ~equivalence:GlobalPhase (zinv 0));
    ("zinv", `Quick, test_owm ~equivalence:GlobalPhase (zinv 3));
    ("zinv", `Quick, test_owm ~equivalence:GlobalPhase (zinv 4));
    ("u1", `Quick, test_owm ~equivalence:GlobalPhase (u1 1 0));
    ("u1", `Quick, test_owm ~equivalence:GlobalPhase (u1 ~s:(-1) 5 0));
    ("u1", `Quick, test_owm ~equivalence:GlobalPhase (u1 ~s:(-1) 5 3));
    ("h", `Quick, test_owm ~equivalence:GlobalPhase (h 0));
    ("h", `Quick, test_owm ~equivalence:GlobalPhase (h 2));
    ("hh", `Quick, test_owm ~equivalence:GlobalPhase (h 0 -- h 0));
    ("x", `Quick, test_owm ~equivalence:GlobalPhase (x 0));
    ("x", `Quick, test_owm ~equivalence:GlobalPhase (x 0));
    ("x", `Quick, test_owm ~equivalence:GlobalPhase (x 1));
    ("x", `Quick, test_owm ~equivalence:GlobalPhase (x 2));
    ("x", `Quick, test_owm ~equivalence:GlobalPhase (x 3));
    ("xx", `Quick, test_owm ~equivalence:GlobalPhase (x 0 -- x 1));
    ("cx", `Quick, test_owm ~equivalence:GlobalPhase (cx 0 3));
    ("cx", `Quick, test_owm ~equivalence:GlobalPhase (cx 1 2));
    ("cx", `Quick, test_owm ~equivalence:GlobalPhase (cx 1 2));
    ("cx", `Quick, test_owm ~equivalence:GlobalPhase (cx 1 0));
    ("cx", `Quick, test_owm ~equivalence:GlobalPhase (cx 5 3));
    ("cxcx", `Quick, test_owm ~equivalence:GlobalPhase (cx 0 1 -- cx 0 1));
    ("cxcx", `Quick, test_owm ~equivalence:GlobalPhase (cx 3 0 -- cx 2 7));
    ("cxcx", `Quick, test_owm ~equivalence:GlobalPhase (cx 7 1 -- cx 0 5));
    ( "cxcx",
      `Quick,
      test_owm ~equivalence:GlobalPhase (cx 0 1 -- cx 1 2 -- cx 1 2) );
    ("hx", `Quick, test_owm ~equivalence:GlobalPhase (h 0 -- x 0));
    ("xh", `Quick, test_owm ~equivalence:GlobalPhase (x 0 -- h 0));
    ("hxh", `Quick, test_owm ~equivalence:GlobalPhase (h 0 -- x 0 -- h 0));
    ("hz", `Quick, test_owm ~equivalence:GlobalPhase (h 0 -- zz 0));
    ("zh", `Quick, test_owm ~equivalence:GlobalPhase (zz 0 -- h 0));
    ("hzh", `Quick, test_owm ~equivalence:GlobalPhase (h 0 -- zz 0 -- h 0));
    ("ht", `Quick, test_owm ~equivalence:GlobalPhase (h 0 -- tt 0));
    ("th", `Quick, test_owm ~equivalence:GlobalPhase (tt 0 -- h 0));
    ("hth", `Quick, test_owm ~equivalence:GlobalPhase (h 0 -- tt 0 -- h 0));
    ("hs", `Quick, test_owm ~equivalence:GlobalPhase (h 0 -- ss 0));
    ("sh", `Quick, test_owm ~equivalence:GlobalPhase (ss 0 -- h 0));
    ("hsh", `Quick, test_owm ~equivalence:GlobalPhase (h 0 -- ss 0 -- h 0));
    ("hsh", `Quick, test_owm ~equivalence:GlobalPhase (h 0 -- ss 0 -- h 1));
    ("hsh", `Quick, test_owm ~equivalence:GlobalPhase (h 0 -- ss 1 -- h 2));
    ("hsh", `Quick, test_owm ~equivalence:GlobalPhase (h 3 -- ss 1 -- h 4));
    ("hsh", `Quick, test_owm ~equivalence:GlobalPhase (h 0 -- ss 5 -- h 5));
    ("cxh", `Quick, test_owm ~equivalence:GlobalPhase (cx 0 1 -- h 0));
    ("cxh", `Quick, test_owm ~equivalence:GlobalPhase (cx 1 3 -- h 1));
    ("cxh", `Quick, test_owm ~equivalence:GlobalPhase (cx 1 3 -- h 0));
    ("cxh", `Quick, test_owm ~equivalence:GlobalPhase (cx 1 3 -- h 3));
    ("cxhh", `Quick, test_owm ~equivalence:GlobalPhase (cx 1 3 -- h 3 -- h 0));
    ( "hcxhh'",
      `Quick,
      test_owm ~equivalence:GlobalPhase (h 0 -- cx 1 3 -- h 3 -- h 0) );
    ("hcxhh''", `Quick, test_owm ~equivalence:GlobalPhase (h 0 -- h 1 -- cx 0 1));
    (* ( "hcxhh",
        `Quick,
        test_owm ~equivalence:GlobalPhase
          (cx 3 4 -- zz 1 -- h 0 -- cx 1 3 -- ss 0 -- h 3 -- h 0 -- tt 2 -- h 4
         -- cx 0 4) ); *)
    ("cxh", `Quick, test_owm ~equivalence:GlobalPhase (cx 3 1 -- h 1));
    ("ccxoq2", `Quick, test_owm ~equivalence:GlobalPhase (ccxoq2 0 1 2));
    ("x_qb", `Quick, test_owm ~equivalence:GlobalPhase (x_qb 0));
    ("crzdecomp", `Quick, test_owm ~equivalence:GlobalPhase (crzdecomp 1 0 1));
    ( "cu1decomp",
      `Quick,
      test_owm ~equivalence:GlobalPhase (cu1decomp ~s:(-1) 5 0 1) );
    ( "cu1decomp",
      `Quick,
      test_owm ~equivalence:GlobalPhase (cu1decomp ~s:(-1) 5 0 1) );
    ( "cu1decomp",
      `Quick,
      test_owm ~equivalence:GlobalPhase (cu1decomp ~s:(-1) 5 0 1) );
    ( "cu1decomp",
      `Quick,
      test_owm ~equivalence:GlobalPhase (cu1decomp ~s:(-1) 5 0 1) );
    ("chdecomp", `Quick, test_owm ~equivalence:GlobalPhase (chdecomp 0 1));
    ( "bv2",
      `Quick,
      test_owm ~equivalence:GlobalPhase
        (h 0 -- x 1 -- h 1 -- cx 0 1 -- h 0 -- h 1) );
    ( "bv3",
      `Quick,
      test_owm ~equivalence:GlobalPhase
        (h 0 -- h 1 -- x 2 -- h 2 -- cx 0 2 -- cx 1 2 -- h 0 -- h 1 -- h 2) );
    ( "bv7",
      `Quick,
      test_owm ~equivalence:GlobalPhase
        (h 0 -- h 1 -- h 2 -- h 3 -- h 4 -- h 5 -- x 6 -- h 6 -- cx 0 6
       -- cx 1 6 -- cx 2 6 -- cx 3 6 -- cx 4 6 -- cx 5 6 -- h 0 -- h 1 -- h 2
       -- h 3 -- h 4 -- h 5 -- h 6) );
    ("cxn", `Quick, test_owm ~equivalence:GlobalPhase (cx 0 1 -- cx 1 2));
    ("ccx", `Quick, test_owm ~equivalence:GlobalPhase (ccx 0 1 2));
    ("swap", `Quick, test_owm ~equivalence:GlobalPhase (swap 0 1));
    ( "swap",
      `Quick,
      test_owm ~equivalence:GlobalPhase (swap 1 3 -- swap 4 2 -- swap 1 2) );
    ( "pe3'",
      `Quick,
      test_owm ~equivalence:GlobalPhase (h 1 -- cu1 2 1 2 -- h 0 -- h 1) );
    ( "pe3",
      `Quick,
      test_owm ~equivalence:GlobalPhase
        (h 0 -- h 1 -- h 2 -- cu1 9 2 3 -- cu1 8 1 3 -- cu1 7 0 3 -- h 0
       -- cu1 ~s:(-1) 1 0 1 -- cu1 ~s:(-1) 2 0 2 -- h 1 -- cu1 ~s:(-1) 1 1 2
       -- h 2) );
  ]

let owm_parallel =
  [
    ("id", `Quick, test_owm ~algo:Parallel id);
    ("z", `Quick, test_owm ~algo:Parallel (zz 0));
    ("z", `Quick, test_owm ~algo:Parallel (zz 4));
    ("z", `Quick, test_owm ~algo:Parallel (zz 3));
    ("z", `Quick, test_owm ~algo:Parallel (zz 3));
    ("z", `Quick, test_owm ~algo:Parallel (zz 3));
    ("z", `Quick, test_owm ~algo:Parallel (zz 3));
    ("z", `Quick, test_owm ~algo:Parallel (zz 3));
    ("z", `Quick, test_owm ~algo:Parallel (zz 3));
    ("z", `Quick, test_owm ~algo:Parallel (zz 3));
    ("z", `Quick, test_owm ~algo:Parallel (zz 3));
    ("zz", `Quick, test_owm ~algo:Parallel (zz 0 -- zz 0));
    ("zz", `Quick, test_owm ~algo:Parallel (zz 1 -- zz 1));
    ("zz", `Quick, test_owm ~algo:Parallel (zz 1 -- zz 3));
    ("zz", `Quick, test_owm ~algo:Parallel (zz 0 -- zz 1 -- zz 3 -- zz 4));
    ("s", `Quick, test_owm ~algo:Parallel (ss 0));
    ("ss", `Quick, test_owm ~algo:Parallel (ss 0 -- ss 0));
    ("ss", `Quick, test_owm ~algo:Parallel (ss 1 -- ss 0 -- ss 4));
    ("ss rewrite", `Quick, test_owm ~algo:Parallel (ss 1 -- ss 0 -- ss 4));
    ("t", `Quick, test_owm ~algo:Parallel (tt 0));
    ("tt rewrite", `Quick, test_owm ~algo:Parallel (tt 1 -- tt 0 -- tt 4));
    ("sinv", `Quick, test_owm ~algo:Parallel (sinv 2));
    ("tinv", `Quick, test_owm ~algo:Parallel (tinv 4));
    ("zinv", `Quick, test_owm ~algo:Parallel (zinv 0));
    ("zinv", `Quick, test_owm ~algo:Parallel (zinv 3));
    ("zinv", `Quick, test_owm ~algo:Parallel (zinv 4));
    ("u1", `Quick, test_owm ~algo:Parallel (u1 1 0));
    ("u1", `Quick, test_owm ~algo:Parallel (u1 ~s:(-1) 5 0));
    ("u1", `Quick, test_owm ~algo:Parallel (u1 ~s:(-1) 5 3));
    ("h", `Quick, test_owm ~algo:Parallel (h 0));
    ("h", `Quick, test_owm ~algo:Parallel (h 2));
    ("hh", `Quick, test_owm ~algo:Parallel (h 0 -- h 0));
    ("x", `Quick, test_owm ~algo:Parallel (x 0));
    ("x", `Quick, test_owm ~algo:Parallel (x 0));
    ("x", `Quick, test_owm ~algo:Parallel (x 1));
    ("x", `Quick, test_owm ~algo:Parallel (x 2));
    ("x", `Quick, test_owm ~algo:Parallel (x 3));
    ("xx", `Quick, test_owm ~algo:Parallel (x 0 -- x 1));
    ("cx", `Quick, test_owm ~algo:Parallel (cx 0 3));
    ("cx", `Quick, test_owm ~algo:Parallel (cx 1 2));
    ("cx", `Quick, test_owm ~algo:Parallel (cx 1 2));
    ("cx", `Quick, test_owm ~algo:Parallel (cx 1 0));
    ("cx", `Quick, test_owm ~algo:Parallel (cx 5 3));
    ("cxcx", `Quick, test_owm ~algo:Parallel (cx 0 1 -- cx 0 1));
    ("cxcx", `Quick, test_owm ~algo:Parallel (cx 3 0 -- cx 2 7));
    ("cxcx", `Quick, test_owm ~algo:Parallel (cx 7 1 -- cx 0 5));
    ("cxcx", `Quick, test_owm ~algo:Parallel (cx 0 1 -- cx 1 2 -- cx 1 2));
    ("hx", `Quick, test_owm ~algo:Parallel (h 0 -- x 0));
    ("xh", `Quick, test_owm ~algo:Parallel (x 0 -- h 0));
    ("hxh", `Quick, test_owm ~algo:Parallel (h 0 -- x 0 -- h 0));
    ("hz", `Quick, test_owm ~algo:Parallel (h 0 -- zz 0));
    ("zh", `Quick, test_owm ~algo:Parallel (zz 0 -- h 0));
    ("hzh", `Quick, test_owm ~algo:Parallel (h 0 -- zz 0 -- h 0));
    ("ht", `Quick, test_owm ~algo:Parallel (h 0 -- tt 0));
    ("th", `Quick, test_owm ~algo:Parallel (tt 0 -- h 0));
    ("hth", `Quick, test_owm ~algo:Parallel (h 0 -- tt 0 -- h 0));
    ("hs", `Quick, test_owm ~algo:Parallel (h 0 -- ss 0));
    ("sh", `Quick, test_owm ~algo:Parallel (ss 0 -- h 0));
    ("hsh", `Quick, test_owm ~algo:Parallel (h 0 -- ss 0 -- h 0));
    ("hsh", `Quick, test_owm ~algo:Parallel (h 0 -- ss 0 -- h 1));
    ("hsh", `Quick, test_owm ~algo:Parallel (h 0 -- ss 1 -- h 2));
    ("hsh", `Quick, test_owm ~algo:Parallel (h 3 -- ss 1 -- h 4));
    ("hsh", `Quick, test_owm ~algo:Parallel (h 0 -- ss 5 -- h 5));
    ("cxh", `Quick, test_owm ~algo:Parallel (cx 0 1 -- h 0));
    ("cxh", `Quick, test_owm ~algo:Parallel (cx 1 3 -- h 1));
    ("cxh", `Quick, test_owm ~algo:Parallel (cx 1 3 -- h 0));
    ("cxh", `Quick, test_owm ~algo:Parallel (cx 1 3 -- h 3));
    ("cxhh", `Quick, test_owm ~algo:Parallel (cx 1 3 -- h 3 -- h 0));
    ("hcxhh", `Quick, test_owm ~algo:Parallel (h 0 -- cx 1 3 -- h 3 -- h 0));
    ("cxh", `Quick, test_owm ~algo:Parallel (cx 3 1 -- h 1));
    ("ccxoq2", `Quick, test_owm ~algo:Parallel (ccxoq2 0 1 2));
    ("x_qb", `Quick, test_owm ~algo:Parallel (x_qb 0));
    ("crzdecomp", `Quick, test_owm ~algo:Parallel (crzdecomp 1 0 1));
    ("cu1decomp", `Quick, test_owm ~algo:Parallel (cu1decomp ~s:(-1) 5 0 1));
    ("cu1decomp", `Quick, test_owm ~algo:Parallel (cu1decomp ~s:(-1) 5 0 1));
    ("cu1decomp", `Quick, test_owm ~algo:Parallel (cu1decomp ~s:(-1) 5 0 1));
    ("cu1decomp", `Quick, test_owm ~algo:Parallel (cu1decomp ~s:(-1) 5 0 1));
    ( "bv2",
      `Quick,
      test_owm ~algo:Parallel (h 0 -- x 1 -- h 1 -- cx 0 1 -- h 0 -- h 1) );
    ( "bv3",
      `Quick,
      test_owm ~algo:Parallel
        (h 0 -- h 1 -- x 2 -- h 2 -- cx 0 2 -- cx 1 2 -- h 0 -- h 1 -- h 2) );
    ( "bv7",
      `Quick,
      test_owm ~algo:Parallel
        (h 0 -- h 1 -- h 2 -- h 3 -- h 4 -- h 5 -- x 6 -- h 6 -- cx 0 6
       -- cx 1 6 -- cx 2 6 -- cx 3 6 -- cx 4 6 -- cx 5 6 -- h 0 -- h 1 -- h 2
       -- h 3 -- h 4 -- h 5 -- h 6) );
    ("cxn", `Quick, test_owm ~algo:Parallel (cx 0 1 -- cx 1 2));
    ("ccx", `Quick, test_owm ~algo:Parallel (ccx 0 1 2));
    ("swap", `Quick, test_owm ~algo:Parallel (swap 0 1));
    ("swap", `Quick, test_owm ~algo:Parallel (swap 1 3 -- swap 4 2 -- swap 1 2));
  ]

let owm_parallel_global_phase =
  [
    ("id", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase id);
    ("z", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (zz 0));
    ("z", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (zz 4));
    ("z", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (zz 3));
    ("z", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (zz 3));
    ("z", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (zz 3));
    ("z", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (zz 3));
    ("z", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (zz 3));
    ("z", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (zz 3));
    ("z", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (zz 3));
    ("z", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (zz 3));
    ( "zz",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (zz 0 -- zz 0) );
    ( "zz",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (zz 1 -- zz 1) );
    ( "zz",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (zz 1 -- zz 3) );
    ( "zz",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase
        (zz 0 -- zz 1 -- zz 3 -- zz 4) );
    ("s", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (ss 0));
    ( "ss",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (ss 0 -- ss 0) );
    ( "ss",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (ss 1 -- ss 0 -- ss 4) );
    ( "ss rewrite",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (ss 1 -- ss 0 -- ss 4) );
    ("t", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (tt 0));
    ( "tt rewrite",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (tt 1 -- tt 0 -- tt 4) );
    ("sinv", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (sinv 2));
    ("tinv", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (tinv 4));
    ("zinv", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (zinv 0));
    ("zinv", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (zinv 3));
    ("zinv", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (zinv 4));
    ("u1", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (u1 1 0));
    ( "u1",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (u1 ~s:(-1) 5 0) );
    ( "u1",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (u1 ~s:(-1) 5 3) );
    ("h", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 0));
    ("h", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 2));
    ("hh", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- h 0));
    ("x", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (x 0));
    ("x", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (x 0));
    ("x", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (x 1));
    ("x", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (x 2));
    ("x", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (x 3));
    ("xx", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (x 0 -- x 1));
    ("cx", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 0 3));
    ("cx", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 1 2));
    ("cx", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 1 2));
    ("cx", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 1 0));
    ("cx", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 5 3));
    ( "cxcx",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 0 1 -- cx 0 1) );
    ( "cxcx",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 3 0 -- cx 2 7) );
    ( "cxcx",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 7 1 -- cx 0 5) );
    ( "cxcx",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase
        (cx 0 1 -- cx 1 2 -- cx 1 2) );
    ("hx", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- x 0));
    ("xh", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (x 0 -- h 0));
    ( "hxh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- x 0 -- h 0) );
    ( "hz",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- zz 0) );
    ( "zh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (zz 0 -- h 0) );
    ( "hzh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- zz 0 -- h 0) );
    ( "ht",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- tt 0) );
    ( "th",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (tt 0 -- h 0) );
    ( "hth",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- tt 0 -- h 0) );
    ( "hs",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- ss 0) );
    ( "sh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (ss 0 -- h 0) );
    ( "hsh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- ss 0 -- h 0) );
    ( "hsh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- ss 0 -- h 1) );
    ( "hsh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- ss 1 -- h 2) );
    ( "hsh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 3 -- ss 1 -- h 4) );
    ( "hsh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- ss 5 -- h 5) );
    ( "cxh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 0 1 -- h 0) );
    ( "cxh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 1 3 -- h 1) );
    ( "cxh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 1 3 -- h 0) );
    ( "cxh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 1 3 -- h 3) );
    ( "cxhh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 1 3 -- h 3 -- h 0) );
    ( "hcxhh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- cx 1 3 -- h 3 -- h 0) );
    ( "cxh",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 3 1 -- h 1) );
    ( "ccxoq2",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (ccxoq2 0 1 2) );
    ("x_qb", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (x_qb 0));
    ( "crzdecomp",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (crzdecomp 1 0 1) );
    ( "cu1decomp",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (cu1decomp ~s:(-1) 5 0 1)
    );
    ( "cu1decomp",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (cu1decomp ~s:(-1) 5 0 1)
    );
    ( "cu1decomp",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (cu1decomp ~s:(-1) 5 0 1)
    );
    ( "cu1decomp",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (cu1decomp ~s:(-1) 5 0 1)
    );
    ( "bv2",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- x 1 -- h 1 -- cx 0 1 -- h 0 -- h 1) );
    ( "bv3",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- h 1 -- x 2 -- h 2 -- cx 0 2 -- cx 1 2 -- h 0 -- h 1 -- h 2) );
    ( "bv7",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- h 1 -- h 2 -- h 3 -- h 4 -- h 5 -- x 6 -- h 6 -- cx 0 6
       -- cx 1 6 -- cx 2 6 -- cx 3 6 -- cx 4 6 -- cx 5 6 -- h 0 -- h 1 -- h 2
       -- h 3 -- h 4 -- h 5 -- h 6) );
    ( "cxn",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase (cx 0 1 -- cx 1 2) );
    ("ccx", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (ccx 0 1 2));
    ("swap", `Quick, test_owm ~algo:Parallel ~equivalence:GlobalPhase (swap 0 1));
    ( "swap",
      `Quick,
      test_owm ~algo:Parallel ~equivalence:GlobalPhase
        (swap 1 3 -- swap 4 2 -- swap 1 2) );
  ]

let test_teleportation ?(not_equiv = false) ?(false_teleportation = false)
    ?(debug = true) ?(algo = Equiv.Sequence) ?(equivalence = Equiv.SubCircuit)
    (p : Program.t) () =
  let greeting =
    let by_meas, inputs1, outputs1 =
      Teleportation.to_teleport p ~false_teleportation ~debug
    in
    let _, wq = Program.widths p in
    let inputs2 = ListBis.range 0 wq in
    let outputs2 = inputs2 in
    let by_meas_dm, _, meas1 =
      To_deferred_measurement.to_deferred_measurements by_meas
    in
    Equiv.sqv_simple_result ~debug ~algo ~equivalence ~not_equiv ~inputs1
      ~outputs1 ~meas1 ~inputs2 ~outputs2 by_meas_dm p
  in
  let expected = true in
  check bool (sprintf "Test.test_teleportation\n") expected greeting

let teleportation =
  [
    ("h 0", `Quick, test_teleportation (h 0));
    ( "false_teleportation h",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true (h 0) );
    ("h 2", `Quick, test_teleportation (h 2));
    ( "false_teleportation h",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true (h 2) );
    ("hh 0", `Quick, test_teleportation (h 0 -- h 0));
    ( "false_teleportation hh",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true (h 0 -- h 0)
    );
    ("x 0", `Quick, test_teleportation (x 0));
    ( "false_teleportation x",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true (x 0) );
    ("x 0", `Quick, test_teleportation (x 0));
    ("x 2", `Quick, test_teleportation (x 2));
    ("x 3", `Quick, test_teleportation (x 3));
    ( "xn 0",
      `Quick,
      test_teleportation (x 0 -- x 0 -- x 0 -- x 0 -- x 0 -- x 0 -- x 0) );
    ( "false_teleportation cx",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true (cx 0 1) );
    ("cx 0 3", `Quick, test_teleportation (cx 0 3));
    ("cx 1 2", `Quick, test_teleportation (cx 1 2));
    ("cx 1 0", `Quick, test_teleportation (cx 1 0));
    ("cx 5 3", `Quick, test_teleportation (cx 5 3));
    ( "false_teleportation cx",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true (cx 5 3) );
    ("cxn 0 1", `Quick, test_teleportation (cx 0 1 -- cx 0 1));
    ("cxn", `Quick, test_teleportation (cx 3 0 -- cx 2 7));
    ("cxn", `Quick, test_teleportation (cx 7 1 -- cx 0 5));
    ("ccxoq2", `Quick, test_teleportation (ccxoq2 0 1 2));
    ("z", `Quick, test_teleportation (zz 0));
    ("z", `Quick, test_teleportation (zz 4));
    ("z", `Quick, test_teleportation (zz 3));
    ("s", `Quick, test_teleportation (ss 0));
    ("t", `Quick, test_teleportation (tt 0));
    ("sinv", `Quick, test_teleportation (sinv 2));
    ("tinv", `Quick, test_teleportation (tinv 4));
    ("zinv", `Quick, test_teleportation (zinv 0));
    ("zinv", `Quick, test_teleportation (zinv 3));
    ("zinv", `Quick, test_teleportation (zinv 4));
    ("u1", `Quick, test_teleportation (u1 1 0));
    ("u1", `Quick, test_teleportation (u1 ~s:(-1) 5 0));
    ("u1", `Quick, test_teleportation (u1 ~s:(-1) 5 3));
    ("hx", `Quick, test_teleportation (h 0 -- x 0));
    ("xh", `Quick, test_teleportation (x 0 -- h 0));
    ("hxh", `Quick, test_teleportation (h 0 -- x 0 -- h 0));
    ("hz", `Quick, test_teleportation (h 0 -- zz 0));
    ("zh", `Quick, test_teleportation (zz 0 -- h 0));
    ("hzh", `Quick, test_teleportation (h 0 -- zz 0 -- h 0));
    ("ht", `Quick, test_teleportation (h 0 -- tt 0));
    ("th", `Quick, test_teleportation (tt 0 -- h 0));
    ("hth", `Quick, test_teleportation (h 0 -- tt 0 -- h 0));
    ("hs", `Quick, test_teleportation (h 0 -- ss 0));
    ("sh", `Quick, test_teleportation (ss 0 -- h 0));
    ("hsh", `Quick, test_teleportation (h 0 -- ss 0 -- h 0));
    ("hsh", `Quick, test_teleportation (h 0 -- ss 0 -- h 1));
    ("hsh", `Quick, test_teleportation (h 0 -- ss 1 -- h 2));
    ("hsh", `Quick, test_teleportation (h 3 -- ss 1 -- h 4));
    ("hsh", `Quick, test_teleportation (h 0 -- ss 5 -- h 5));
    ("cxh", `Quick, test_teleportation (cx 0 1 -- h 0));
    ("cxh", `Quick, test_teleportation (cx 1 3 -- h 1));
    ("cxh", `Quick, test_teleportation (cx 1 3 -- h 0));
    ("cxh", `Quick, test_teleportation (cx 1 3 -- h 3));
    ("cxhh", `Quick, test_teleportation (cx 1 3 -- h 3 -- h 0));
    ("hcxhh", `Quick, test_teleportation (h 0 -- cx 1 3 -- h 3 -- h 0));
    ( "hcxhh",
      `Quick,
      test_teleportation
        (cx 3 4 -- zz 1 -- h 0 -- cx 1 3 -- ss 0 -- h 3 -- h 0 -- tt 2 -- h 4
       -- cx 0 4) );
    ( "false_teleportation hcxhh",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true
        (cx 3 4 -- zz 1 -- h 0 -- cx 1 3 -- ss 0 -- h 3 -- h 0 -- tt 2 -- h 4
       -- cx 0 4) );
    ("cxh", `Quick, test_teleportation (cx 3 1 -- h 1));
    ("x_qb", `Quick, test_teleportation (x_qb 0));
    ("chdecomp", `Quick, test_teleportation (chdecomp 0 1));
    ("crzdecomp", `Quick, test_teleportation (crzdecomp 1 0 1));
    ("cu1decomp", `Quick, test_teleportation (cu1decomp ~s:(-1) 5 0 1));
    ( "bv2",
      `Quick,
      test_teleportation (h 0 -- x 1 -- h 1 -- cx 0 1 -- h 0 -- h 1) );
    ( "bv3",
      `Quick,
      test_teleportation
        (h 0 -- h 1 -- x 2 -- h 2 -- cx 0 2 -- cx 1 2 -- h 0 -- h 1 -- h 2) );
    ( "false_teleportation bv3",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true
        (h 0 -- h 1 -- x 2 -- h 2 -- cx 0 2 -- cx 1 2 -- h 0 -- h 1 -- h 2) );
    ( "bv7",
      `Quick,
      test_teleportation
        (h 0 -- h 1 -- h 2 -- h 3 -- h 4 -- h 5 -- x 6 -- h 6 -- cx 0 6
       -- cx 1 6 -- cx 2 6 -- cx 3 6 -- cx 4 6 -- cx 5 6 -- h 0 -- h 1 -- h 2
       -- h 3 -- h 4 -- h 5 -- h 6) );
    ("cxn", `Quick, test_teleportation (cx 0 1 -- cx 1 2));
    ( "ccx_part1",
      `Quick,
      test_teleportation
        (h 1 -- tinv 1 -- cx 0 1 -- tt 1 -- cx 0 1 -- tinv 1 -- cx 0 1 -- tt 1)
    );
    ( "ccx_part2",
      `Quick,
      test_teleportation
        (h 2 -- tinv 2 -- cx 0 2 -- tt 2 -- cx 1 2 -- tinv 2 -- cx 0 2 -- tt 2)
    );
    ("ccx", `Quick, test_teleportation (ccx 0 1 2));
    ( "qft4",
      `Quick,
      test_teleportation
        (h 0 -- cu1 1 0 1 -- cu1 2 0 2 -- cu1 3 0 3 -- h 1 -- cu1 1 1 2
       -- cu1 2 1 3 -- h 2 -- cu1 1 2 3 -- h 3) );
    ( "false_teleportation qft4",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true
        (h 0 -- cu1 1 0 1 -- cu1 2 0 2 -- cu1 3 0 3 -- h 1 -- cu1 1 1 2
       -- cu1 2 1 3 -- h 2 -- cu1 1 2 3 -- h 3) );
  ]

let teleportation_global_phase =
  [
    ("h 0", `Quick, test_teleportation (h 0));
    ( "false_teleportation h",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true (h 0) );
    ("h 2", `Quick, test_teleportation (h 2));
    ( "false_teleportation h",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true (h 2) );
    ("hh 0", `Quick, test_teleportation (h 0 -- h 0));
    ( "false_teleportation hh",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true (h 0 -- h 0)
    );
    ("x 0", `Quick, test_teleportation (x 0));
    ( "false_teleportation x",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true (x 0) );
    ("x 0", `Quick, test_teleportation (x 0));
    ("x 2", `Quick, test_teleportation (x 2));
    ("x 3", `Quick, test_teleportation (x 3));
    ( "xn 0",
      `Quick,
      test_teleportation (x 0 -- x 0 -- x 0 -- x 0 -- x 0 -- x 0 -- x 0) );
    ( "false_teleportation cx",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true (cx 0 1) );
    ("cx 0 3", `Quick, test_teleportation (cx 0 3));
    ("cx 1 2", `Quick, test_teleportation (cx 1 2));
    ("cx 1 0", `Quick, test_teleportation (cx 1 0));
    ("cx 5 3", `Quick, test_teleportation (cx 5 3));
    ( "false_teleportation cx",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true (cx 5 3) );
    ("cxn 0 1", `Quick, test_teleportation (cx 0 1 -- cx 0 1));
    ("cxn", `Quick, test_teleportation (cx 3 0 -- cx 2 7));
    ("cxn", `Quick, test_teleportation (cx 7 1 -- cx 0 5));
    ("ccxoq2", `Quick, test_teleportation (ccxoq2 0 1 2));
    ("z", `Quick, test_teleportation (zz 0));
    ("z", `Quick, test_teleportation (zz 4));
    ("z", `Quick, test_teleportation (zz 3));
    ("s", `Quick, test_teleportation (ss 0));
    ("t", `Quick, test_teleportation (tt 0));
    ("sinv", `Quick, test_teleportation (sinv 2));
    ("tinv", `Quick, test_teleportation (tinv 4));
    ("zinv", `Quick, test_teleportation (zinv 0));
    ("zinv", `Quick, test_teleportation (zinv 3));
    ("zinv", `Quick, test_teleportation (zinv 4));
    ("u1", `Quick, test_teleportation (u1 1 0));
    ("u1", `Quick, test_teleportation (u1 ~s:(-1) 5 0));
    ("u1", `Quick, test_teleportation (u1 ~s:(-1) 5 3));
    ("hx", `Quick, test_teleportation (h 0 -- x 0));
    ("xh", `Quick, test_teleportation (x 0 -- h 0));
    ("hxh", `Quick, test_teleportation (h 0 -- x 0 -- h 0));
    ("hz", `Quick, test_teleportation (h 0 -- zz 0));
    ("zh", `Quick, test_teleportation (zz 0 -- h 0));
    ("hzh", `Quick, test_teleportation (h 0 -- zz 0 -- h 0));
    ("ht", `Quick, test_teleportation (h 0 -- tt 0));
    ("th", `Quick, test_teleportation (tt 0 -- h 0));
    ("hth", `Quick, test_teleportation (h 0 -- tt 0 -- h 0));
    ("hs", `Quick, test_teleportation (h 0 -- ss 0));
    ("sh", `Quick, test_teleportation (ss 0 -- h 0));
    ("hsh", `Quick, test_teleportation (h 0 -- ss 0 -- h 0));
    ("hsh", `Quick, test_teleportation (h 0 -- ss 0 -- h 1));
    ("hsh", `Quick, test_teleportation (h 0 -- ss 1 -- h 2));
    ("hsh", `Quick, test_teleportation (h 3 -- ss 1 -- h 4));
    ("hsh", `Quick, test_teleportation (h 0 -- ss 5 -- h 5));
    ("cxh", `Quick, test_teleportation (cx 0 1 -- h 0));
    ("cxh", `Quick, test_teleportation (cx 1 3 -- h 1));
    ("cxh", `Quick, test_teleportation (cx 1 3 -- h 0));
    ("cxh", `Quick, test_teleportation (cx 1 3 -- h 3));
    ("cxhh", `Quick, test_teleportation (cx 1 3 -- h 3 -- h 0));
    ("hcxhh", `Quick, test_teleportation (h 0 -- cx 1 3 -- h 3 -- h 0));
    ( "hcxhh",
      `Quick,
      test_teleportation
        (cx 3 4 -- zz 1 -- h 0 -- cx 1 3 -- ss 0 -- h 3 -- h 0 -- tt 2 -- h 4
       -- cx 0 4) );
    ( "false_teleportation hcxhh",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true
        (cx 3 4 -- zz 1 -- h 0 -- cx 1 3 -- ss 0 -- h 3 -- h 0 -- tt 2 -- h 4
       -- cx 0 4) );
    ("cxh", `Quick, test_teleportation (cx 3 1 -- h 1));
    ("x_qb", `Quick, test_teleportation (x_qb 0));
    ("chdecomp", `Quick, test_teleportation (chdecomp 0 1));
    ("crzdecomp", `Quick, test_teleportation (crzdecomp 1 0 1));
    ("cu1decomp", `Quick, test_teleportation (cu1decomp ~s:(-1) 5 0 1));
    ( "bv2",
      `Quick,
      test_teleportation (h 0 -- x 1 -- h 1 -- cx 0 1 -- h 0 -- h 1) );
    ( "bv3",
      `Quick,
      test_teleportation
        (h 0 -- h 1 -- x 2 -- h 2 -- cx 0 2 -- cx 1 2 -- h 0 -- h 1 -- h 2) );
    ( "false_teleportation bv3",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true
        (h 0 -- h 1 -- x 2 -- h 2 -- cx 0 2 -- cx 1 2 -- h 0 -- h 1 -- h 2) );
    ( "bv7",
      `Quick,
      test_teleportation
        (h 0 -- h 1 -- h 2 -- h 3 -- h 4 -- h 5 -- x 6 -- h 6 -- cx 0 6
       -- cx 1 6 -- cx 2 6 -- cx 3 6 -- cx 4 6 -- cx 5 6 -- h 0 -- h 1 -- h 2
       -- h 3 -- h 4 -- h 5 -- h 6) );
    ("cxn", `Quick, test_teleportation (cx 0 1 -- cx 1 2));
    ( "ccx_part1",
      `Quick,
      test_teleportation
        (h 1 -- tinv 1 -- cx 0 1 -- tt 1 -- cx 0 1 -- tinv 1 -- cx 0 1 -- tt 1)
    );
    ( "ccx_part2",
      `Quick,
      test_teleportation
        (h 2 -- tinv 2 -- cx 0 2 -- tt 2 -- cx 1 2 -- tinv 2 -- cx 0 2 -- tt 2)
    );
    ("ccx", `Quick, test_teleportation (ccx 0 1 2));
    ( "qft4",
      `Quick,
      test_teleportation
        (h 0 -- cu1 1 0 1 -- cu1 2 0 2 -- cu1 3 0 3 -- h 1 -- cu1 1 1 2
       -- cu1 2 1 3 -- h 2 -- cu1 1 2 3 -- h 3) );
    ( "false_teleportation qft4",
      `Quick,
      test_teleportation ~not_equiv:true ~false_teleportation:true
        (h 0 -- cu1 1 0 1 -- cu1 2 0 2 -- cu1 3 0 3 -- h 1 -- cu1 1 1 2
       -- cu1 2 1 3 -- h 2 -- cu1 1 2 3 -- h 3) );
  ]

let teleportation_parallel =
  [
    ("h 0", `Quick, test_teleportation ~algo:Parallel (h 0));
    ( "false_teleportation h",
      `Quick,
      test_teleportation ~algo:Parallel ~not_equiv:true
        ~false_teleportation:true (h 0) );
    ("h 2", `Quick, test_teleportation ~algo:Parallel (h 2));
    ( "false_teleportation h",
      `Quick,
      test_teleportation ~algo:Parallel ~not_equiv:true
        ~false_teleportation:true (h 2) );
    ("hh 0", `Quick, test_teleportation ~algo:Parallel (h 0 -- h 0));
    ( "false_teleportation hh",
      `Quick,
      test_teleportation ~algo:Parallel ~not_equiv:true
        ~false_teleportation:true
        (h 0 -- h 0) );
    ("x 0", `Quick, test_teleportation ~algo:Parallel (x 0));
    ( "false_teleportation x",
      `Quick,
      test_teleportation ~algo:Parallel ~not_equiv:true
        ~false_teleportation:true (x 0) );
    ("x 0", `Quick, test_teleportation ~algo:Parallel (x 0));
    ("x 2", `Quick, test_teleportation ~algo:Parallel (x 2));
    ("x 3", `Quick, test_teleportation ~algo:Parallel (x 3));
    ( "xn 0",
      `Quick,
      test_teleportation ~algo:Parallel
        (x 0 -- x 0 -- x 0 -- x 0 -- x 0 -- x 0 -- x 0) );
    ( "false_teleportation cx",
      `Quick,
      test_teleportation ~algo:Parallel ~not_equiv:true
        ~false_teleportation:true (cx 0 1) );
    ("cx 0 3", `Quick, test_teleportation ~algo:Parallel (cx 0 3));
    ("cx 1 2", `Quick, test_teleportation ~algo:Parallel (cx 1 2));
    ("cx 1 0", `Quick, test_teleportation ~algo:Parallel (cx 1 0));
    ("cx 5 3", `Quick, test_teleportation ~algo:Parallel (cx 5 3));
    ( "false_teleportation cx",
      `Quick,
      test_teleportation ~algo:Parallel ~not_equiv:true
        ~false_teleportation:true (cx 5 3) );
    ("cxn 0 1", `Quick, test_teleportation ~algo:Parallel (cx 0 1 -- cx 0 1));
    ("cxn", `Quick, test_teleportation ~algo:Parallel (cx 3 0 -- cx 2 7));
    ("cxn", `Quick, test_teleportation ~algo:Parallel (cx 7 1 -- cx 0 5));
    ("ccxoq2", `Quick, test_teleportation ~algo:Parallel (ccxoq2 0 1 2));
    ("z", `Quick, test_teleportation ~algo:Parallel (zz 0));
    ("z", `Quick, test_teleportation ~algo:Parallel (zz 4));
    ("z", `Quick, test_teleportation ~algo:Parallel (zz 3));
    ("s", `Quick, test_teleportation ~algo:Parallel (ss 0));
    ("t", `Quick, test_teleportation ~algo:Parallel (tt 0));
    ("sinv", `Quick, test_teleportation ~algo:Parallel (sinv 2));
    ("tinv", `Quick, test_teleportation ~algo:Parallel (tinv 4));
    ("zinv", `Quick, test_teleportation ~algo:Parallel (zinv 0));
    ("zinv", `Quick, test_teleportation ~algo:Parallel (zinv 3));
    ("zinv", `Quick, test_teleportation ~algo:Parallel (zinv 4));
    ("u1", `Quick, test_teleportation ~algo:Parallel (u1 1 0));
    ("u1", `Quick, test_teleportation ~algo:Parallel (u1 ~s:(-1) 5 0));
    ("u1", `Quick, test_teleportation ~algo:Parallel (u1 ~s:(-1) 5 3));
    ("hx", `Quick, test_teleportation ~algo:Parallel (h 0 -- x 0));
    ("xh", `Quick, test_teleportation ~algo:Parallel (x 0 -- h 0));
    ("hxh", `Quick, test_teleportation ~algo:Parallel (h 0 -- x 0 -- h 0));
    ("hz", `Quick, test_teleportation ~algo:Parallel (h 0 -- zz 0));
    ("zh", `Quick, test_teleportation ~algo:Parallel (zz 0 -- h 0));
    ("hzh", `Quick, test_teleportation ~algo:Parallel (h 0 -- zz 0 -- h 0));
    ("ht", `Quick, test_teleportation ~algo:Parallel (h 0 -- tt 0));
    ("th", `Quick, test_teleportation ~algo:Parallel (tt 0 -- h 0));
    ("hth", `Quick, test_teleportation ~algo:Parallel (h 0 -- tt 0 -- h 0));
    ("hs", `Quick, test_teleportation ~algo:Parallel (h 0 -- ss 0));
    ("sh", `Quick, test_teleportation ~algo:Parallel (ss 0 -- h 0));
    ("hsh", `Quick, test_teleportation ~algo:Parallel (h 0 -- ss 0 -- h 0));
    ("hsh", `Quick, test_teleportation ~algo:Parallel (h 0 -- ss 0 -- h 1));
    ("hsh", `Quick, test_teleportation ~algo:Parallel (h 0 -- ss 1 -- h 2));
    ("hsh", `Quick, test_teleportation ~algo:Parallel (h 3 -- ss 1 -- h 4));
    ("hsh", `Quick, test_teleportation ~algo:Parallel (h 0 -- ss 5 -- h 5));
    ("cxh", `Quick, test_teleportation ~algo:Parallel (cx 0 1 -- h 0));
    ("cxh", `Quick, test_teleportation ~algo:Parallel (cx 1 3 -- h 1));
    ("cxh", `Quick, test_teleportation ~algo:Parallel (cx 1 3 -- h 0));
    ("cxh", `Quick, test_teleportation ~algo:Parallel (cx 1 3 -- h 3));
    ("cxhh", `Quick, test_teleportation ~algo:Parallel (cx 1 3 -- h 3 -- h 0));
    ( "hcxhh",
      `Quick,
      test_teleportation ~algo:Parallel (h 0 -- cx 1 3 -- h 3 -- h 0) );
    ( "false_teleportation hcxhh",
      `Quick,
      test_teleportation ~algo:Parallel ~not_equiv:true
        ~false_teleportation:true
        (cx 3 4 -- zz 1 -- h 0 -- cx 1 3 -- ss 0 -- h 3 -- h 0 -- tt 2 -- h 4
       -- cx 0 4) );
    ("cxh", `Quick, test_teleportation ~algo:Parallel (cx 3 1 -- h 1));
    ("x_qb", `Quick, test_teleportation ~algo:Parallel (x_qb 0));
    ("chdecomp", `Quick, test_teleportation ~algo:Parallel (chdecomp 0 1));
    ("crzdecomp", `Quick, test_teleportation ~algo:Parallel (crzdecomp 1 0 1));
    ( "cu1decomp",
      `Quick,
      test_teleportation ~algo:Parallel (cu1decomp ~s:(-1) 5 0 1) );
    ( "bv2",
      `Quick,
      test_teleportation ~algo:Parallel
        (h 0 -- x 1 -- h 1 -- cx 0 1 -- h 0 -- h 1) );
    ( "bv3",
      `Quick,
      test_teleportation ~algo:Parallel
        (h 0 -- h 1 -- x 2 -- h 2 -- cx 0 2 -- cx 1 2 -- h 0 -- h 1 -- h 2) );
    ( "false_teleportation bv3",
      `Quick,
      test_teleportation ~algo:Parallel ~not_equiv:true
        ~false_teleportation:true
        (h 0 -- h 1 -- x 2 -- h 2 -- cx 0 2 -- cx 1 2 -- h 0 -- h 1 -- h 2) );
    ( "bv7",
      `Quick,
      test_teleportation ~algo:Parallel
        (h 0 -- h 1 -- h 2 -- h 3 -- h 4 -- h 5 -- x 6 -- h 6 -- cx 0 6
       -- cx 1 6 -- cx 2 6 -- cx 3 6 -- cx 4 6 -- cx 5 6 -- h 0 -- h 1 -- h 2
       -- h 3 -- h 4 -- h 5 -- h 6) );
    ("cxn", `Quick, test_teleportation ~algo:Parallel (cx 0 1 -- cx 1 2));
    ( "ccx_part1",
      `Quick,
      test_teleportation ~algo:Parallel
        (h 1 -- tinv 1 -- cx 0 1 -- tt 1 -- cx 0 1 -- tinv 1 -- cx 0 1 -- tt 1)
    );
    ( "ccx_part2",
      `Quick,
      test_teleportation ~algo:Parallel
        (h 2 -- tinv 2 -- cx 0 2 -- tt 2 -- cx 1 2 -- tinv 2 -- cx 0 2 -- tt 2)
    );
    ("ccx", `Quick, test_teleportation ~algo:Parallel (ccx 0 1 2));
    ( "qft4",
      `Quick,
      test_teleportation ~algo:Parallel
        (h 0 -- cu1 1 0 1 -- cu1 2 0 2 -- cu1 3 0 3 -- h 1 -- cu1 1 1 2
       -- cu1 2 1 3 -- h 2 -- cu1 1 2 3 -- h 3) );
    ( "false_teleportation qft4",
      `Quick,
      test_teleportation ~algo:Parallel ~not_equiv:true
        ~false_teleportation:true
        (h 0 -- cu1 1 0 1 -- cu1 2 0 2 -- cu1 3 0 3 -- h 1 -- cu1 1 1 2
       -- cu1 2 1 3 -- h 2 -- cu1 1 2 3 -- h 3) );
  ]

let teleportation_parallel_global_phase =
  [
    ( "h 0",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (h 0) );
    ( "false_teleportation h",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        ~false_teleportation:true (h 0) );
    ( "h 2",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (h 2) );
    ( "false_teleportation h",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        ~false_teleportation:true (h 2) );
    ( "hh 0",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- h 0) );
    ( "false_teleportation hh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        ~false_teleportation:true
        (h 0 -- h 0) );
    ( "x 0",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (x 0) );
    ( "false_teleportation x",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        ~false_teleportation:true (x 0) );
    ( "x 0",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (x 0) );
    ( "x 2",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (x 2) );
    ( "x 3",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (x 3) );
    ( "xn 0",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (x 0 -- x 0 -- x 0 -- x 0 -- x 0 -- x 0 -- x 0) );
    ( "false_teleportation cx",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        ~false_teleportation:true (cx 0 1) );
    ( "cx 0 3",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (cx 0 3) );
    ( "cx 1 2",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (cx 1 2) );
    ( "cx 1 0",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (cx 1 0) );
    ( "cx 5 3",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (cx 5 3) );
    ( "false_teleportation cx",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        ~false_teleportation:true (cx 5 3) );
    ( "cxn 0 1",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (cx 0 1 -- cx 0 1) );
    ( "cxn",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (cx 3 0 -- cx 2 7) );
    ( "cxn",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (cx 7 1 -- cx 0 5) );
    ( "ccxoq2",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (ccxoq2 0 1 2)
    );
    ( "z",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (zz 0) );
    ( "z",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (zz 4) );
    ( "z",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (zz 3) );
    ( "s",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (ss 0) );
    ( "t",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (tt 0) );
    ( "sinv",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (sinv 2) );
    ( "tinv",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (tinv 4) );
    ( "zinv",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (zinv 0) );
    ( "zinv",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (zinv 3) );
    ( "zinv",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (zinv 4) );
    ( "u1",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (u1 1 0) );
    ( "u1",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (u1 ~s:(-1) 5 0) );
    ( "u1",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (u1 ~s:(-1) 5 3) );
    ( "hx",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- x 0) );
    ( "xh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (x 0 -- h 0) );
    ( "hxh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- x 0 -- h 0) );
    ( "hz",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- zz 0)
    );
    ( "zh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (zz 0 -- h 0)
    );
    ( "hzh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- zz 0 -- h 0) );
    ( "ht",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- tt 0)
    );
    ( "th",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (tt 0 -- h 0)
    );
    ( "hth",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- tt 0 -- h 0) );
    ( "hs",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (h 0 -- ss 0)
    );
    ( "sh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (ss 0 -- h 0)
    );
    ( "hsh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- ss 0 -- h 0) );
    ( "hsh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- ss 0 -- h 1) );
    ( "hsh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- ss 1 -- h 2) );
    ( "hsh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 3 -- ss 1 -- h 4) );
    ( "hsh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- ss 5 -- h 5) );
    ( "cxh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (cx 0 1 -- h 0)
    );
    ( "cxh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (cx 1 3 -- h 1)
    );
    ( "cxh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (cx 1 3 -- h 0)
    );
    ( "cxh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (cx 1 3 -- h 3)
    );
    ( "cxhh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (cx 1 3 -- h 3 -- h 0) );
    ( "hcxhh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- cx 1 3 -- h 3 -- h 0) );
    ( "false_teleportation hcxhh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        ~false_teleportation:true
        (cx 3 4 -- zz 1 -- h 0 -- cx 1 3 -- ss 0 -- h 3 -- h 0 -- tt 2 -- h 4
       -- cx 0 4) );
    ( "cxh",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (cx 3 1 -- h 1)
    );
    ( "x_qb",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (x_qb 0) );
    ( "chdecomp",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (chdecomp 0 1)
    );
    ( "crzdecomp",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (crzdecomp 1 0 1) );
    ( "cu1decomp",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (cu1decomp ~s:(-1) 5 0 1) );
    ( "bv2",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- x 1 -- h 1 -- cx 0 1 -- h 0 -- h 1) );
    ( "bv3",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- h 1 -- x 2 -- h 2 -- cx 0 2 -- cx 1 2 -- h 0 -- h 1 -- h 2) );
    ( "false_teleportation bv3",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        ~false_teleportation:true
        (h 0 -- h 1 -- x 2 -- h 2 -- cx 0 2 -- cx 1 2 -- h 0 -- h 1 -- h 2) );
    ( "bv7",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- h 1 -- h 2 -- h 3 -- h 4 -- h 5 -- x 6 -- h 6 -- cx 0 6
       -- cx 1 6 -- cx 2 6 -- cx 3 6 -- cx 4 6 -- cx 5 6 -- h 0 -- h 1 -- h 2
       -- h 3 -- h 4 -- h 5 -- h 6) );
    ( "cxn",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (cx 0 1 -- cx 1 2) );
    ( "ccx_part1",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 1 -- tinv 1 -- cx 0 1 -- tt 1 -- cx 0 1 -- tinv 1 -- cx 0 1 -- tt 1)
    );
    ( "ccx_part2",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 2 -- tinv 2 -- cx 0 2 -- tt 2 -- cx 1 2 -- tinv 2 -- cx 0 2 -- tt 2)
    );
    ( "ccx",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase (ccx 0 1 2) );
    ( "qft4",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase
        (h 0 -- cu1 1 0 1 -- cu1 2 0 2 -- cu1 3 0 3 -- h 1 -- cu1 1 1 2
       -- cu1 2 1 3 -- h 2 -- cu1 1 2 3 -- h 3) );
    ( "false_teleportation qft4",
      `Quick,
      test_teleportation ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        ~false_teleportation:true
        (h 0 -- cu1 1 0 1 -- cu1 2 0 2 -- cu1 3 0 3 -- h 1 -- cu1 1 1 2
       -- cu1 2 1 3 -- h 2 -- cu1 1 2 3 -- h 3) );
  ]

let test_owm_teleportation ?(not_equiv = false) ?(debug = true)
    ?(equivalence = Equiv.SubCircuit) (p : Program.t) () =
  let greeting =
    let tele, tele_inputs, tele_outputs = Teleportation.to_teleport p ~debug in
    let owm, owm_inputs, owm_outputs = Owm.to_owm p ~debug in
    let tele_dm, _, _ = To_deferred_measurement.to_deferred_measurements tele in
    let owm_dm, _, _ = To_deferred_measurement.to_deferred_measurements owm in
    Equiv.sqv_simple_result ~debug ~equivalence ~algo:Parallel ~not_equiv
      ~inputs1:tele_inputs ~inputs2:owm_inputs ~outputs1:tele_outputs
      ~outputs2:owm_outputs tele_dm owm_dm
  in
  let expected = true in
  check bool (sprintf "Test.test_owm_teleportation\n") expected greeting

let owm_vs_teleportation =
  [
    ("h 0", `Quick, test_owm_teleportation (h 0));
    ("h 2", `Quick, test_owm_teleportation (h 2));
    ("hh 0", `Quick, test_owm_teleportation (h 0 -- h 0));
    ("x 0", `Quick, test_owm_teleportation (x 0));
    ("x 0", `Quick, test_owm_teleportation (x 0));
    ("x 2", `Quick, test_owm_teleportation (x 2));
    ("x 3", `Quick, test_owm_teleportation (x 3));
    ( "xn 0",
      `Quick,
      test_owm_teleportation (x 0 -- x 0 -- x 0 -- x 0 -- x 0 -- x 0 -- x 0) );
    ("cx 0 3", `Quick, test_owm_teleportation (cx 0 3));
    ("cx 1 2", `Quick, test_owm_teleportation (cx 1 2));
    ("cx 1 0", `Quick, test_owm_teleportation (cx 1 0));
    ("cx 5 3", `Quick, test_owm_teleportation (cx 5 3));
    ("cxn 0 1", `Quick, test_owm_teleportation (cx 0 1 -- cx 0 1));
    ("cxn", `Quick, test_owm_teleportation (cx 3 0 -- cx 2 7));
    ("cxn", `Quick, test_owm_teleportation (cx 7 1 -- cx 0 5));
    ("ccxoq2", `Quick, test_owm_teleportation (ccxoq2 0 1 2));
    ("z", `Quick, test_owm_teleportation (zz 0));
    ("z", `Quick, test_owm_teleportation (zz 4));
    ("z", `Quick, test_owm_teleportation (zz 3));
    ("s", `Quick, test_owm_teleportation (ss 0));
    ("t", `Quick, test_owm_teleportation (tt 0));
    ("sinv", `Quick, test_owm_teleportation (sinv 2));
    ("tinv", `Quick, test_owm_teleportation (tinv 4));
    ("zinv", `Quick, test_owm_teleportation (zinv 0));
    ("zinv", `Quick, test_owm_teleportation (zinv 3));
    ("zinv", `Quick, test_owm_teleportation (zinv 4));
    ("u1", `Quick, test_owm_teleportation (u1 1 0));
    ("u1", `Quick, test_owm_teleportation (u1 ~s:(-1) 5 0));
    ("u1", `Quick, test_owm_teleportation (u1 ~s:(-1) 5 3));
    ("hx", `Quick, test_owm_teleportation (h 0 -- x 0));
    ("xh", `Quick, test_owm_teleportation (x 0 -- h 0));
    ("hxh", `Quick, test_owm_teleportation (h 0 -- x 0 -- h 0));
    ("hz", `Quick, test_owm_teleportation (h 0 -- zz 0));
    ("zh", `Quick, test_owm_teleportation (zz 0 -- h 0));
    ("hzh", `Quick, test_owm_teleportation (h 0 -- zz 0 -- h 0));
    ("ht", `Quick, test_owm_teleportation (h 0 -- tt 0));
    ("th", `Quick, test_owm_teleportation (tt 0 -- h 0));
    ("hth", `Quick, test_owm_teleportation (h 0 -- tt 0 -- h 0));
    ("hs", `Quick, test_owm_teleportation (h 0 -- ss 0));
    ("sh", `Quick, test_owm_teleportation (ss 0 -- h 0));
    ("hsh", `Quick, test_owm_teleportation (h 0 -- ss 0 -- h 0));
    ("hsh", `Quick, test_owm_teleportation (h 0 -- ss 0 -- h 1));
    ("hsh", `Quick, test_owm_teleportation (h 0 -- ss 1 -- h 2));
    ("hsh", `Quick, test_owm_teleportation (h 3 -- ss 1 -- h 4));
    ("hsh", `Quick, test_owm_teleportation (h 0 -- ss 5 -- h 5));
    ("cxh", `Quick, test_owm_teleportation (cx 0 1 -- h 0));
    ("cxh", `Quick, test_owm_teleportation (cx 1 3 -- h 1));
    ("cxh", `Quick, test_owm_teleportation (cx 1 3 -- h 0));
    ("cxh", `Quick, test_owm_teleportation (cx 1 3 -- h 3));
    ("cxhh", `Quick, test_owm_teleportation (cx 1 3 -- h 3 -- h 0));
    ("hcxhh", `Quick, test_owm_teleportation (h 0 -- cx 1 3 -- h 3 -- h 0));
    ("cxh", `Quick, test_owm_teleportation (cx 3 1 -- h 1));
    ("x_qb", `Quick, test_owm_teleportation (x_qb 0));
    ("crzdecomp", `Quick, test_owm_teleportation (crzdecomp 1 0 1));
    ("cu1decomp", `Quick, test_owm_teleportation (cu1decomp ~s:(-1) 5 0 1));
    ( "bv2",
      `Quick,
      test_owm_teleportation (h 0 -- x 1 -- h 1 -- cx 0 1 -- h 0 -- h 1) );
    ( "bv3",
      `Quick,
      test_owm_teleportation
        (h 0 -- h 1 -- x 2 -- h 2 -- cx 0 2 -- cx 1 2 -- h 0 -- h 1 -- h 2) );
    ( "bv7",
      `Quick,
      test_owm_teleportation
        (h 0 -- h 1 -- h 2 -- h 3 -- h 4 -- h 5 -- x 6 -- h 6 -- cx 0 6
       -- cx 1 6 -- cx 2 6 -- cx 3 6 -- cx 4 6 -- cx 5 6 -- h 0 -- h 1 -- h 2
       -- h 3 -- h 4 -- h 5 -- h 6) );
    ("cxn", `Quick, test_owm_teleportation (cx 0 1 -- cx 1 2));
    ("ccx", `Quick, test_owm_teleportation (ccx 0 1 2));
  ]

let owm_vs_teleportation_global_phase =
  [
    ("h 0", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (h 0));
    ("h 2", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (h 2));
    ( "hh 0",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (h 0 -- h 0) );
    ("x 0", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (x 0));
    ("x 0", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (x 0));
    ("x 2", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (x 2));
    ("x 3", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (x 3));
    ( "xn 0",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase
        (x 0 -- x 0 -- x 0 -- x 0 -- x 0 -- x 0 -- x 0) );
    ("cx 0 3", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (cx 0 3));
    ("cx 1 2", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (cx 1 2));
    ("cx 1 0", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (cx 1 0));
    ("cx 5 3", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (cx 5 3));
    ( "cxn 0 1",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (cx 0 1 -- cx 0 1) );
    ( "cxn",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (cx 3 0 -- cx 2 7) );
    ( "cxn",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (cx 7 1 -- cx 0 5) );
    ( "ccxoq2",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (ccxoq2 0 1 2) );
    ("z", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (zz 0));
    ("z", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (zz 4));
    ("z", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (zz 3));
    ("s", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (ss 0));
    ("t", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (tt 0));
    ("sinv", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (sinv 2));
    ("tinv", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (tinv 4));
    ("zinv", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (zinv 0));
    ("zinv", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (zinv 3));
    ("zinv", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (zinv 4));
    ("u1", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (u1 1 0));
    ( "u1",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (u1 ~s:(-1) 5 0) );
    ( "u1",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (u1 ~s:(-1) 5 3) );
    ("hx", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (h 0 -- x 0));
    ("xh", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (x 0 -- h 0));
    ( "hxh",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (h 0 -- x 0 -- h 0) );
    ("hz", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (h 0 -- zz 0));
    ("zh", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (zz 0 -- h 0));
    ( "hzh",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (h 0 -- zz 0 -- h 0) );
    ("ht", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (h 0 -- tt 0));
    ("th", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (tt 0 -- h 0));
    ( "hth",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (h 0 -- tt 0 -- h 0) );
    ("hs", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (h 0 -- ss 0));
    ("sh", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (ss 0 -- h 0));
    ( "hsh",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (h 0 -- ss 0 -- h 0) );
    ( "hsh",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (h 0 -- ss 0 -- h 1) );
    ( "hsh",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (h 0 -- ss 1 -- h 2) );
    ( "hsh",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (h 3 -- ss 1 -- h 4) );
    ( "hsh",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (h 0 -- ss 5 -- h 5) );
    ( "cxh",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (cx 0 1 -- h 0) );
    ( "cxh",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (cx 1 3 -- h 1) );
    ( "cxh",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (cx 1 3 -- h 0) );
    ( "cxh",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (cx 1 3 -- h 3) );
    ( "cxhh",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (cx 1 3 -- h 3 -- h 0) );
    ( "hcxhh",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase
        (h 0 -- cx 1 3 -- h 3 -- h 0) );
    ( "cxh",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (cx 3 1 -- h 1) );
    ("x_qb", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (x_qb 0));
    ( "crzdecomp",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (crzdecomp 1 0 1) );
    ( "cu1decomp",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (cu1decomp ~s:(-1) 5 0 1)
    );
    ( "bv2",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase
        (h 0 -- x 1 -- h 1 -- cx 0 1 -- h 0 -- h 1) );
    ( "bv3",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase
        (h 0 -- h 1 -- x 2 -- h 2 -- cx 0 2 -- cx 1 2 -- h 0 -- h 1 -- h 2) );
    ( "bv7",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase
        (h 0 -- h 1 -- h 2 -- h 3 -- h 4 -- h 5 -- x 6 -- h 6 -- cx 0 6
       -- cx 1 6 -- cx 2 6 -- cx 3 6 -- cx 4 6 -- cx 5 6 -- h 0 -- h 1 -- h 2
       -- h 3 -- h 4 -- h 5 -- h 6) );
    ( "cxn",
      `Quick,
      test_owm_teleportation ~equivalence:GlobalPhase (cx 0 1 -- cx 1 2) );
    ("ccx", `Quick, test_owm_teleportation ~equivalence:GlobalPhase (ccx 0 1 2));
  ]

let () =
  Alcotest.run "Symbolic execution"
    [
      (* OWM *)
      ("Sub-Circ-Seq-Part-Hyb-Eq OWM", owm);
      ("Gobal-Phase-Seq-Part-Hyb-Eq OWM", owm_global_phase);
      ("Sub-Cir-Par-Part-Hyb-Eq OWM", owm_parallel);
      ("Global-Phase-Par-Part-Hyb-Eq OWM", owm_parallel_global_phase);
      (* Teleportation *)
      ("Sub-Circ-Seq-Part-Hyb-Eq Tele", teleportation);
      ("Global-Phase-Seq-Part-Hyb-Eq Tele", teleportation_global_phase);
      ("Sub-Cir-Par-Part-Hyb-Eq Tele", teleportation_parallel);
      ("Global-Phase-Par-Part-Hyb-Eq Tele", teleportation_parallel_global_phase);
      (* OWM vs Teleportation *)
      ("Sub-Cir-Part-Hyb-Eq OWM vs Teleportation", owm_vs_teleportation);
      ( "Global-Phase-Part-Hyb-Eq OWM vs Teleportation",
        owm_vs_teleportation_global_phase );
    ]
