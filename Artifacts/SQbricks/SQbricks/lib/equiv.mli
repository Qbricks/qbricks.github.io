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

(** This module provides functions for verifying the equivalence of quantum
    circuits using symbolic execution and path sum techniques. *)

(** Type representing the result of an equivalence check between quantum
    circuits. *)
type result =
  | SubCircuitEquivalent  (** Circuits are equivalent as subcircuits *)
  | FullCircuitEquivalent
  | GlobalPhaseEquivalent  (** Circuits are equivalent up to global phase *)
  | NotEquivDiffMeasurements  (** Circuits differ in measurements *)
  | NotEquivDiffOutputs  (** Circuits differ in outputs *)
  | NotEquivDiffInputs  (** Circuits differ in inputs *)
  | NotEquivDiffInputsOutputs  (** Circuits differ in both inputs and outputs *)
  | SubCircuitInconclusive  (** Subcircuit equivalence check was inconclusive *)
  | Entanglement1  (** First circuit shows entanglement *)
  | Entanglement2  (** Second circuit shows entanglement *)
  | GlobalPhaseInconclusive
      (** Global phase equivalence check was inconclusive *)
  | FullCircuitInconclusive
  | FullCircuitInconclusiveAmp
  | FullCircuitInconclusiveKet
  | ErrorCircuitNotUnitary  (** Error: circuit is not unitary *)

val result_to_string : result -> string
(** Converts an equivalence result to a string representation.

    Example: [result_to_string SubCircuitEquivalent] results
    ["SubCircuitEquivalent"] *)

(** Type representing the type of equivalence to check. *)
type equivalence = SubCircuit | FullCircuit | GlobalPhase

val seq :
  ?debug:bool ->
  ?inputs1:int list ->
  ?inputs2:int list ->
  ?outputs1:int list ->
  ?outputs2:int list ->
  ?meas1:int list ->
  ?meas2:int list ->
  ?equivalence:equivalence ->
  Program.t ->
  Program.t ->
  result
(** Checks equivalence of two quantum circuits using sequence algorithm. Returns
    one of the result values indicating equivalence or reason for
    non-equivalence.

    Example: [seq (h 0) (h 0)] results [SubCircuitEquivalent] *)

val parallel :
  ?debug:bool ->
  ?inputs1:int list ->
  ?inputs2:int list ->
  ?outputs1:int list ->
  ?outputs2:int list ->
  ?meas1:int list ->
  ?meas2:int list ->
  ?equivalence:equivalence ->
  Program.t ->
  Program.t ->
  result
(** Checks equivalence of two quantum circuits using parallel algorithm. Returns
    one of the result values indicating equivalence or reason for
    non-equivalence.

    Example: [parallel (h 0) (h 0)] results [SubCircuitEquivalent] *)

(** Type representing the algorithm to use for equivalence checking. *)
type algo = Parallel | Sequence

val sqv :
  ?debug:bool ->
  ?inputs1:int list ->
  ?inputs2:int list ->
  ?outputs1:int list ->
  ?outputs2:int list ->
  ?meas1:int list ->
  ?meas2:int list ->
  ?algo:algo ->
  ?equivalence:equivalence ->
  Program.t ->
  Program.t ->
  result
(** Main function for verifying equivalence between quantum circuits. Uses
    either sequence or parallel algorithm based on parameter.

    Example: [sqv (h 0) (h 0)] results [SubCircuitEquivalent] *)

val sqv_simple_result :
  ?debug:bool ->
  ?inputs1:int list ->
  ?inputs2:int list ->
  ?outputs1:int list ->
  ?outputs2:int list ->
  ?meas1:int list ->
  ?meas2:int list ->
  ?algo:algo ->
  ?equivalence:equivalence ->
  ?not_equiv:bool ->
  Program.t ->
  Program.t ->
  bool
(** Simplified version of sqv that returns a boolean indicating equivalence.

    Example: [sqv_simple_result (h 0) (h 0)] results [true] *)
