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
open Parser_get.GetProg

let test_prog_equiv ?(debug = true) ?(not_equiv = false) ?(inputs1 = [])
    ?(inputs2 = []) ?(outputs1 = []) ?(outputs2 = [])
    ?(equivalence = Equiv.SubCircuit) ?(algo = Equiv.Sequence) (p1 : Program.t)
    (p2 : Program.t) () =
  let greeting =
    let p1_dm, _, meas1 =
      To_deferred_measurement.to_deferred_measurements ~debug p1
    in
    let p2_dm, _, meas2 =
      To_deferred_measurement.to_deferred_measurements ~debug p2
    in

    let p1_ready = Program.format p1_dm in
    let p2_ready = Program.format p2_dm in
    if debug then
      printf "Test.Qiskit.test_prog_equiv, p1_ready =\n%s\n\n"
        (ProgS.pretty p1_ready);
    if debug then
      printf "Test.Qiskit.test_prog_equiv, p2_ready =\n%s\n\n"
        (ProgS.pretty p2_ready);
    Equiv.sqv_simple_result ~algo ~not_equiv ~inputs1 ~inputs2 ~outputs1
      ~outputs2 ~meas1 ~meas2 p1_ready p2_ready ~debug ~equivalence
  in
  let expected = true in
  check bool
    (sprintf "Test.test_prog_equiv\np1 =\n%s\n\np2 =\n%s\n" (ProgS.pretty p1)
       (ProgS.pretty p2))
    expected greeting

let test_prog_equiv_qasm ?(debug = true) ?(not_equiv = false)
    ?(equivalence = Equiv.SubCircuit) ?(algo = Equiv.Sequence) (p1' : string)
    (p2' : string) () =
  let greeting =
    let current_dir = Sys.getcwd () in
    printf "Test.test_prog_equiv_qasm, p1' = %s\n" p1';
    printf "Test.test_prog_equiv_qasm, p2' = %s\n" p2';
    printf "Test.test_prog_equiv_qasm, The file is read from the folder : %s\n"
      current_dir;
    let p1_dm, _, meas1 =
      To_deferred_measurement.to_deferred_measurements (to_prog p1')
    in
    let p2_dm, _, meas2 =
      To_deferred_measurement.to_deferred_measurements (to_prog p2')
    in

    let p1 = Program.format p1_dm in
    let p2 = Program.format p2_dm in
    Equiv.sqv_simple_result ~debug ~not_equiv ~equivalence ~algo ~meas1 ~meas2
      p1 p2
  in
  let expected = true in
  check bool
    (sprintf "Test.test_prog_equiv p1 =\n%s\np2 =\n%s\n" p1' p2')
    expected greeting

let hybrid =
  [
    ("h -- m <> h", `Quick, test_prog_equiv ~not_equiv:true (h 0 -- m 0 0) (h 0));
    ( "h -- m <> h",
      `Quick,
      test_prog_equiv ~algo:Parallel ~not_equiv:true (h 0 -- m 0 0) (h 0) );
    ( "cx -- m -- h <> cx -- h",
      `Quick,
      test_prog_equiv ~not_equiv:true (cx 0 1 -- m 1 0 -- h 0) (cx 0 1 -- h 0)
    );
    ( "cx -- m -- h <> cx -- h",
      `Quick,
      test_prog_equiv ~algo:Parallel ~not_equiv:true
        (cx 0 1 -- m 1 0 -- h 0)
        (cx 0 1 -- h 0) );
    ("swap -- swap = id", `Quick, test_prog_equiv (swap 0 1 -- swap 0 1) E);
    ("cx -- cx = id", `Quick, test_prog_equiv (cx 0 1 -- cx 0 1) E);
    ("ccx -- ccx = id", `Quick, test_prog_equiv (ccx 0 1 2 -- ccx 0 1 2) E);
    ( "check separation condition",
      `Quick,
      let ancilla = [ 0; 1 ] in
      test_prog_equiv ~not_equiv:true ~algo:Parallel ~inputs1:ancilla
        ~inputs2:ancilla ~outputs1:ancilla ~outputs2:ancilla
        (cx 1 2 -- cx 2 1 -- cx 0 1)
        (cx 1 2 -- cx 2 1 -- cx 0 1) );
    ( "dqc_qft_2",
      `Quick,
      test_prog_equiv_qasm "benchmarks/VeriQbench/dynamic/qft/dqc_qft_2.qasm"
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_2.qasm" );
    ( "dqc_qft_2",
      `Quick,
      test_prog_equiv_qasm "benchmarks/VeriQbench/dynamic/qft/dqc_qft_2.qasm"
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_2.qasm" );
    ( "FALSE angle dqc_qft_2",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_2.qasm"
        "benchmarks/buggy/dqc_qft_2_FALSE_angle.qasm" );
    ( "FALSE indice dqc_qft_2",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_2.qasm"
        "benchmarks/buggy/dqc_qft_2_FALSE_indice.qasm" );
    ( "FALSE gate dqc_qft_2",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_2.qasm"
        "benchmarks/buggy/dqc_qft_2_FALSE_gate.qasm" );
    ( "dqc_qft_10",
      `Quick,
      test_prog_equiv_qasm "benchmarks/VeriQbench/dynamic/qft/dqc_qft_10.qasm"
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_10.qasm" );
    ( "dqc_qft_11",
      `Quick,
      test_prog_equiv_qasm "benchmarks/VeriQbench/dynamic/qft/dqc_qft_11.qasm"
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_11.qasm" );
    ( "FALSE gate dqc_qft_11",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_11.qasm"
        "benchmarks/buggy/dqc_qft_11_FALSE_gate.qasm" );
    ( "FALSE angle dqc_qft_11",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_11.qasm"
        "benchmarks/buggy/dqc_qft_11_FALSE_angle.qasm" );
    ( "FALSE indice dqc_qft_11",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_11.qasm"
        "benchmarks/buggy/dqc_qft_11_FALSE_indice.qasm" );
    ( "dqc_pe_2",
      `Quick,
      test_prog_equiv_qasm "benchmarks/VeriQbench/dynamic/pe/dqc_pe_2.qasm"
        "benchmarks/VeriQbench/dynamic/pe/dqc_pe_2.qasm" );
    ( "dqc_pe_20",
      `Quick,
      test_prog_equiv_qasm "benchmarks/VeriQbench/dynamic/pe/dqc_pe_20.qasm"
        "benchmarks/VeriQbench/dynamic/pe/dqc_pe_20.qasm" );
    ( "FALSE gate dqc_pe_20",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/buggy/dqc_pe_20_FALSE_gate.qasm"
        "benchmarks/VeriQbench/dynamic/pe/dqc_pe_20.qasm" );
    ( "FALSE angle dqc_pe_20",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/buggy/dqc_pe_20_FALSE_angle.qasm"
        "benchmarks/VeriQbench/dynamic/pe/dqc_pe_20.qasm" );
    ( "FALSE indice dqc_pe_20",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/buggy/dqc_pe_20_FALSE_indice.qasm"
        "benchmarks/VeriQbench/dynamic/pe/dqc_pe_20.qasm" );
    ( "bitflip_correction",
      `Quick,
      test_prog_equiv_qasm
        "benchmarks/VeriQbench/dynamic/dqc_bitflip_code_corrected.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_bitflip_code_corrected.qasm" );
    ( "FALSE gate bitflip_correction",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/dqc_bitflip_code_corrected.qasm"
        "benchmarks/buggy/dqc_bitflip_code_corrected_FALSE_gate.qasm" );
    ( "FALSE indice bitflip_correction",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/dqc_bitflip_code_corrected.qasm"
        "benchmarks/buggy/dqc_bitflip_code_corrected_FALSE_indice.qasm" );
    ( "FALSE angle bitflip_correction",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/dqc_bitflip_code_corrected.qasm"
        "benchmarks/buggy/dqc_bitflip_code_corrected_FALSE_angle.qasm" );
    ( "dqc_state_injection_S",
      `Quick,
      test_prog_equiv_qasm
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_S.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_S.qasm" );
    ( "FALSE gate dqc_state_injection_S",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_S.qasm"
        "benchmarks/buggy/dqc_state_injection_S_FALSE_gate.qasm" );
    ( "FALSE indice dqc_state_injection_S",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_S.qasm"
        "benchmarks/buggy/dqc_state_injection_S_FALSE_indice.qasm" );
    ( "FALSE angle dqc_state_injection_S",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_S.qasm"
        "benchmarks/buggy/dqc_state_injection_S_FALSE_angle.qasm" );
    ( "dqc_state_injection_T",
      `Quick,
      test_prog_equiv_qasm
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_T.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_T.qasm" );
    ( "FALSE dqc_state_injection_T",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_T.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_S.qasm" );
    ( "teleportation",
      `Quick,
      test_prog_equiv_qasm
        "benchmarks/VeriQbench/dynamic/dqc_teleportation.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_teleportation.qasm" );
    ( "FALSE angle teleportation",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/buggy/dqc_teleportation_FALSE_angle.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_teleportation.qasm" );
    ( "FALSE gate teleportation",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/buggy/dqc_teleportation_FALSE_gate.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_teleportation.qasm" );
    ( "FALSE indice teleportation",
      `Quick,
      test_prog_equiv_qasm ~not_equiv:true
        "benchmarks/buggy/dqc_teleportation_FALSE_indice.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_teleportation.qasm" );
  ]

let hybrid_global_phase =
  [
    ( "h -- m <> h",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase ~not_equiv:true
        (h 0 -- m 0 0)
        (h 0) );
    ( "h -- m <> h",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        (h 0 -- m 0 0)
        (h 0) );
    ( "cx -- m -- h <> cx -- h",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase ~not_equiv:true
        (cx 0 1 -- m 1 0 -- h 0)
        (cx 0 1 -- h 0) );
    ( "cx -- m -- h <> cx -- h",
      `Quick,
      test_prog_equiv ~algo:Parallel ~equivalence:GlobalPhase ~not_equiv:true
        (cx 0 1 -- m 1 0 -- h 0)
        (cx 0 1 -- h 0) );
    ( "swap -- swap = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (swap 0 1 -- swap 0 1) E );
    ( "cx -- cx = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (cx 0 1 -- cx 0 1) E );
    ( "ccx -- ccx = id",
      `Quick,
      test_prog_equiv ~equivalence:GlobalPhase (ccx 0 1 2 -- ccx 0 1 2) E );
    ( "check separation condition",
      `Quick,
      let ancilla = [ 0; 1 ] in
      test_prog_equiv ~equivalence:GlobalPhase ~not_equiv:true ~algo:Parallel
        ~inputs1:ancilla ~inputs2:ancilla ~outputs1:ancilla ~outputs2:ancilla
        (cx 1 2 -- cx 2 1 -- cx 0 1)
        (cx 1 2 -- cx 2 1 -- cx 0 1) );
    ( "dqc_qft_2",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_2.qasm"
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_2.qasm" );
    ( "dqc_qft_2",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_2.qasm"
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_2.qasm" );
    ( "FALSE angle dqc_qft_2",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_2.qasm"
        "benchmarks/buggy/dqc_qft_2_FALSE_angle.qasm" );
    ( "FALSE indice dqc_qft_2",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_2.qasm"
        "benchmarks/buggy/dqc_qft_2_FALSE_indice.qasm" );
    ( "FALSE gate dqc_qft_2",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_2.qasm"
        "benchmarks/buggy/dqc_qft_2_FALSE_gate.qasm" );
    ( "dqc_qft_10",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_10.qasm"
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_10.qasm" );
    ( "dqc_qft_11",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_11.qasm"
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_11.qasm" );
    ( "FALSE gate dqc_qft_11",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_11.qasm"
        "benchmarks/buggy/dqc_qft_11_FALSE_gate.qasm" );
    ( "FALSE angle dqc_qft_11",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_11.qasm"
        "benchmarks/buggy/dqc_qft_11_FALSE_angle.qasm" );
    ( "FALSE indice dqc_qft_11",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/qft/dqc_qft_11.qasm"
        "benchmarks/buggy/dqc_qft_11_FALSE_indice.qasm" );
    ( "dqc_pe_2",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/dynamic/pe/dqc_pe_2.qasm"
        "benchmarks/VeriQbench/dynamic/pe/dqc_pe_2.qasm" );
    ( "dqc_pe_20",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/dynamic/pe/dqc_pe_20.qasm"
        "benchmarks/VeriQbench/dynamic/pe/dqc_pe_20.qasm" );
    ( "FALSE gate dqc_pe_20",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/buggy/dqc_pe_20_FALSE_gate.qasm"
        "benchmarks/VeriQbench/dynamic/pe/dqc_pe_20.qasm" );
    ( "FALSE angle dqc_pe_20",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/buggy/dqc_pe_20_FALSE_angle.qasm"
        "benchmarks/VeriQbench/dynamic/pe/dqc_pe_20.qasm" );
    ( "FALSE indice dqc_pe_20",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/buggy/dqc_pe_20_FALSE_indice.qasm"
        "benchmarks/VeriQbench/dynamic/pe/dqc_pe_20.qasm" );
    ( "bitflip_correction",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/dynamic/dqc_bitflip_code_corrected.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_bitflip_code_corrected.qasm" );
    ( "FALSE gate bitflip_correction",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/dqc_bitflip_code_corrected.qasm"
        "benchmarks/buggy/dqc_bitflip_code_corrected_FALSE_gate.qasm" );
    ( "FALSE indice bitflip_correction",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/dqc_bitflip_code_corrected.qasm"
        "benchmarks/buggy/dqc_bitflip_code_corrected_FALSE_indice.qasm" );
    ( "FALSE angle bitflip_correction",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/dqc_bitflip_code_corrected.qasm"
        "benchmarks/buggy/dqc_bitflip_code_corrected_FALSE_angle.qasm" );
    ( "dqc_state_injection_S",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_S.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_S.qasm" );
    ( "FALSE gate dqc_state_injection_S",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_S.qasm"
        "benchmarks/buggy/dqc_state_injection_S_FALSE_gate.qasm" );
    ( "FALSE indice dqc_state_injection_S",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_S.qasm"
        "benchmarks/buggy/dqc_state_injection_S_FALSE_indice.qasm" );
    ( "FALSE angle dqc_state_injection_S",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_S.qasm"
        "benchmarks/buggy/dqc_state_injection_S_FALSE_angle.qasm" );
    ( "dqc_state_injection_T",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_T.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_T.qasm" );
    ( "FALSE dqc_state_injection_T",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_T.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_state_injection_S.qasm" );
    ( "teleportation",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase
        "benchmarks/VeriQbench/dynamic/dqc_teleportation.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_teleportation.qasm" );
    ( "FALSE angle teleportation",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/buggy/dqc_teleportation_FALSE_angle.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_teleportation.qasm" );
    ( "FALSE gate teleportation",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/buggy/dqc_teleportation_FALSE_gate.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_teleportation.qasm" );
    ( "FALSE indice teleportation",
      `Quick,
      test_prog_equiv_qasm ~equivalence:GlobalPhase ~not_equiv:true
        "benchmarks/buggy/dqc_teleportation_FALSE_indice.qasm"
        "benchmarks/VeriQbench/dynamic/dqc_teleportation.qasm" );
  ]

let () =
  Alcotest.run "Symbolic execution"
    [
      ("Sub-Circuit-Hybrid-Equivalence", hybrid);
      ("Global-Phase-Hybrid-Equivalence", hybrid_global_phase);
    ]
