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

module ProgS = Program.String
include Program.Macros
module QS = Qubit.String
module PSS = Path_sum.String
module Ket = Path_sum.Ket
module Monome = Poly.Monome
module PS = Poly.String
open Printf
open Common
open Rules

type result =
  | SubCircuitEquivalent
  | FullCircuitEquivalent
  | GlobalPhaseEquivalent
  | NotEquivDiffMeasurements
  | NotEquivDiffOutputs
  | NotEquivDiffInputs
  | NotEquivDiffInputsOutputs
  | SubCircuitInconclusive
  | Entanglement1
  | Entanglement2
  | GlobalPhaseInconclusive
  | FullCircuitInconclusive
  | FullCircuitInconclusiveAmp
  | FullCircuitInconclusiveKet
  | ErrorCircuitNotUnitary

let result_to_string = function
  | SubCircuitEquivalent -> "SubCircuitEquivalent"
  | FullCircuitEquivalent -> "FullCircuitEquivalent"
  | GlobalPhaseEquivalent -> "GlobalPhaseEquivalent"
  | NotEquivDiffMeasurements -> "NotEquivDiffMeasurements"
  | NotEquivDiffOutputs -> "NotEquivDiffOutputs"
  | NotEquivDiffInputs -> "NotEquivDiffInputs"
  | NotEquivDiffInputsOutputs -> "NotEquivDiffInputsOutputs"
  | SubCircuitInconclusive -> "SubCircuitInconclusive"
  | Entanglement1 -> "Entanglement1"
  | Entanglement2 -> "Entanglement2"
  | GlobalPhaseInconclusive -> "GlobalPhaseInconclusive"
  | FullCircuitInconclusive -> "FullCircuitInconclusive"
  | FullCircuitInconclusiveAmp -> "FullCircuitInconclusiveAmp"
  | FullCircuitInconclusiveKet -> "FullCircuitInconclusiveKet"
  | ErrorCircuitNotUnitary -> "ErrorCircuitNotUnitary"

type equivalence = SubCircuit | FullCircuit | GlobalPhase

let reduction = Reduction_algorithm.reduction_algorithm

let compute_result ?(debug = false) inputs (output_state : Path_sum.t)
    (identity_state : Path_sum.t) =
  if List.is_empty inputs then Path_sum.equal output_state identity_state
  else
    let width = Array.length identity_state.ket in
    let rec aux = function
      | input :: inputs' ->
          let q_expect = identity_state.ket.(input) in
          let q_greet = output_state.ket.(input) in
          if debug then
            printf "Equiv.compute_result, q_expect = %s, q_greet = %s\n\n%!"
              (QS.pretty q_expect width) (QS.pretty q_greet width);

          if Qubit.equal q_greet q_expect then aux inputs' else false
      | _ -> true
    in
    aux inputs

let separability_states ?(debug = false) (state : Path_sum.t) outputs wq =
  if debug then
    printf "Equiv.separability_states, state =\n%s\n\n" (PSS.pretty state);
  let garbages = ListBis.missing_in_range outputs wq in
  let var_output =
    List.sort_uniq Int.compare (Ket.extract_var state.ket outputs)
  in
  let var_garbage =
    List.sort_uniq Int.compare (Ket.extract_var state.ket garbages)
  in
  let width = Array.length state.ket in

  (* if an external variable is in garbage then outputs and garbages are not separable *)
  let var_garbage_contents_external_variables =
    List.exists (fun i -> i < width) var_garbage
  in
  if debug then
    printf
      "Equiv.separability, var_garbage_contents_external_variables = %b\n\n%!"
      var_garbage_contents_external_variables;
  if var_garbage_contents_external_variables then false
  else (
    if debug then
      printf "Equiv.separability, garbages = %s\n\n%!"
        (ListBis.string_int garbages);
    if debug then
      printf "Equiv.separability, outputs = %s\n\n%!"
        (ListBis.string_int outputs);
    if debug then
      printf "Equiv.separability, var_output = %s\n\n%!"
        (ListBis.string_int var_output);
    if debug then
      printf "Equiv.separability, var_garbage = %s\n\n%!"
        (ListBis.string_int var_garbage);
    let rec aux = function
      | hd :: tl ->
          if ListBis.member hd var_garbage Int.equal then false else aux tl
      | [] -> true
    in
    if not (aux var_output) then false
    else
      let poly_sep =
        Poly.separable_in_poly state.phase var_output var_garbage
      in
      if debug then printf "Equiv.separability, poly_sep = %b\n\n%!" poly_sep;
      poly_sep)

let parameters_preparation ?(debug = false) inputs1 inputs2 outputs1 outputs2
    unitary1 unitary2 =
  let inputs1 = List.sort_uniq Int.compare inputs1 in
  let inputs2 = List.sort_uniq Int.compare inputs2 in
  let outputs1 = List.sort_uniq Int.compare outputs1 in
  let outputs2 = List.sort_uniq Int.compare outputs2 in
  if debug then
    printf "Equiv.parameters_preparation, inputs1 = %s\n\n%!"
      (ListBis.string_int inputs1);
  if debug then
    printf "Equiv.parameters_preparation, inputs2 = %s\n\n%!"
      (ListBis.string_int inputs2);
  if debug then
    printf "Equiv.parameters_preparation, outputs1 = %s\n\n%!"
      (ListBis.string_int outputs1);
  if debug then
    printf "Equiv.parameters_preparation, outputs2 = %s\n\n%!"
      (ListBis.string_int outputs2);

  let wc1, wq1 = Program.widths unitary1 in
  let wc2, wq2 = Program.widths unitary2 in
  if debug then
    printf
      "Equiv.parameters_preparation, wc1 = %d, wc2 = %d, wq1 = %d, wq2 = %d\n\n\
       %!"
      wc1 wc2 wq1 wq2;

  let length_inputs1 = List.length inputs1 in
  let length_inputs2 = List.length inputs2 in
  let max_inputs = Int.max length_inputs1 length_inputs2 in
  let max_wqs = Int.max wq1 wq2 in

  let wq1, no_inits1 =
    if wq1 = length_inputs1 then
      ((if max_inputs = 0 then max_wqs else max_inputs), true)
    else (wq1, false)
  in
  let wq2, no_inits2 =
    if wq2 = length_inputs2 then
      ((if max_inputs = 0 then max_wqs else max_inputs), true)
    else (wq2, false)
  in

  if debug then
    printf
      "Equiv.parameters_preparation, max_inputs = %d, wq1 = %d, wq2 = %d\n\n%!"
      max_inputs wq1 wq2;

  let inputs1 =
    List.rev (if List.is_empty inputs1 then ListBis.range 0 wq1 else inputs1)
  in
  let inputs2 =
    List.rev (if List.is_empty inputs2 then ListBis.range 0 wq2 else inputs2)
  in
  let outputs1 =
    if List.is_empty outputs1 then ListBis.range 0 wq1 else outputs1
  in
  let outputs2 =
    if List.is_empty outputs2 then ListBis.range 0 wq2 else outputs2
  in
  if debug then
    printf "Equiv.parameters_preparation, inputs1 fixed = %s\n\n%!"
      (ListBis.string_int inputs1);
  if debug then
    printf "Equiv.parameters_preparation, inputs2 fixed = %s\n\n%!"
      (ListBis.string_int inputs2);
  if debug then
    printf "Equiv.parameters_preparation, outputs1 fixed = %s\n\n%!"
      (ListBis.string_int outputs1);
  if debug then
    printf "Equiv.parameters_preparation, outputs2 fixed = %s\n\n%!"
      (ListBis.string_int outputs2);

  let length_inputs1 = List.length inputs1 in
  let length_inputs2 = List.length inputs2 in
  if length_inputs1 <> length_inputs2 then
    failwith "Equiv.parameters_preparation, length_inputs1 <> length_inputs2";

  let length_outputs1 = List.length outputs1 in
  let length_outputs2 = List.length outputs2 in
  if length_outputs1 <> length_outputs2 then
    failwith "Equiv.parameters_preparation, length_outputs1 <> length_outputs2";

  if length_outputs1 <> length_inputs1 then
    failwith "Equiv.parameters_preparation, length_outputs <> length_inputs";

  if debug then
    printf "Equiv.parameters_preparation, unitary_1 =\n%s\n\n"
      (ProgS.pretty unitary1);
  if debug then
    printf "Equiv.parameters_preparation, unitary_2 =\n%s\n\n"
      (ProgS.pretty unitary2);

  if 0 < wc1 || 0 < wc2 then
    failwith "Equiv.parameters_preparation, circuits must be unitary";

  let inits1 =
    if List.is_empty inputs1 || no_inits1 then []
    else ListBis.missing_in_range inputs1 wq1
  in
  let inits2 =
    if List.is_empty inputs2 || no_inits2 then []
    else ListBis.missing_in_range inputs2 wq2
  in
  ( wq1,
    wq2,
    inits1,
    inits2,
    inputs1,
    inputs2,
    outputs1,
    outputs2,
    length_inputs1 )

let check_observable_measurement outputs1 outputs2 meas1 meas2 =
  let intersection1 = ListBis.intersect outputs1 meas1 in
  let intersection2 = ListBis.intersect outputs2 meas2 in
  List.equal Int.equal intersection1 intersection2

type phase_equality =
  | SubCircuitEquality
  | GlobalPhaseEquality
  | ConditionalEquality

let phase_equality_to_string = function
  | SubCircuitEquality -> "SubCircuitEquality"
  | GlobalPhaseEquality -> "GlobalPhaseEquality"
  | ConditionalEquality -> "ConditionalEquality"

let seq ?(debug = false) ?(inputs1 = []) ?(inputs2 = []) ?(outputs1 = [])
    ?(outputs2 = []) ?(meas1 = []) ?(meas2 = []) ?(equivalence = SubCircuit)
    unitary1 unitary2 =
  let ( wq1,
        wq2,
        inits1,
        inits2,
        inputs1,
        inputs2,
        outputs1,
        outputs2,
        length_inputs1 ) =
    parameters_preparation ~debug inputs1 inputs2 outputs1 outputs2 unitary1
      unitary2
  in
  (* Check if the lists of measured qubits are equal in the two circuits for the observable part *)
  if not (check_observable_measurement outputs1 outputs2 meas1 meas2) then (
    if debug then printf "Equiv.seq, list of measurements differents\n\n";
    NotEquivDiffMeasurements)
  else
    let unitary1, wq1, unitary2, wq2 =
      if not (List.is_empty inits1) then
        if not (List.is_empty inits2) then
          failwith "Equiv.seq, one of the two circuits mustn't have init"
        else (Program.format unitary1, wq1, Program.format unitary2, wq2)
      else (Program.format unitary2, wq2, Program.format unitary1, wq1)
    in
    if debug then
      printf "Equiv.seq, unitary_1 =\n%s\n\n" (ProgS.pretty unitary1);
    if debug then
      printf "Equiv.seq, unitary_2 =\n%s\n\n" (ProgS.pretty unitary2);

    let width = Int.max wq1 wq2 in
    if debug then printf "Equiv.seq, width = %d\n\n%!" width;

    let input_state = Path_sum.ofSize_init width inits1 in

    if debug then
      printf "Equiv.seq, input_state =\n%s\n\n%!" (PSS.pretty input_state);

    let unitary1_swap = apply_swap unitary1 outputs1 outputs2 in

    if debug then
      printf "Equiv.seq, good order unitary1_swap =\n%s\n\n"
        (ProgS.pretty unitary1_swap);

    (* Check Separability just after 1st circuit *)
    let state1 = Program.execution ~input_state unitary1_swap in

    if debug then printf "Equiv.seq, state1 =\n%s\n\n%!" (PSS.pretty state1);

    let state1_reduced = reduction state1 ~debug in
    if debug then
      printf "Equiv.seq, state1_reduced =\n%s\n\n"
        (PSS.pretty (Rename.rename state1_reduced));

    (* `outputs2` instead `outputs2` because of swap *)
    let separability =
      separability_states ~debug state1_reduced outputs2 width
    in

    if debug then printf "Equiv.seq, separability = %b\n\n%!" separability;

    if separability then (
      let unitary2_inv = Program.inverse unitary2 in
      if debug then
        printf "Equiv.seq, good order unitary2_inv =\n%s\n\n"
          (ProgS.pretty unitary2_inv);
      let unitary2_swap = apply_swap unitary2_inv inputs1 inputs2 in
      if debug then
        printf "Equiv.seq, good order unitary2_swap =\n%s\n\n"
          (ProgS.pretty unitary2_swap);

      (* `[|unit1--unit2^(-1)|] : |x>|0>_init1 -> |output_state>` *)
      let output_state =
        if length_inputs1 = 0 then
          Program.execution ~input_state:state1 unitary2_inv
        else Program.execution ~input_state:state1 unitary2_swap
      in

      if debug then
        printf "Equiv.seq, output_state =\n%s\n\n%!" (PSS.pretty output_state);

      let output_state_reduced = reduction output_state ~debug in
      if debug then
        printf "Equiv.seq, output_state_reduced =\n%s\n\n"
          (PSS.pretty output_state_reduced);

      let identity_state = Path_sum.ofSize_init width inits1 in
      let var_inputs = Ket.extract_var output_state_reduced.ket inputs1 in
      if debug then
        printf "Equiv.seq, var_inputs =\n%s\n\n%!"
          (ListBis.string_int var_inputs);

      (* Determine the type of phase equality for the reduced output state *)
      let condition_zero_phase =
        match output_state_reduced.phase with
        | phase when Poly.is_constant phase ->
            (* Phase is constant *)
            if Poly.equal phase Poly.zero then
              (* Phase = 0 *)
              SubCircuitEquality
            else
              (* Phase ≠ 0 *)
              GlobalPhaseEquality
        | phase when not (Poly.member_list var_inputs phase) ->
            (* Phase depends only on path variables *)
            SubCircuitEquality
        | _ -> ConditionalEquality
      in

      (* Debug display *)
      if debug then (
        printf "Equiv.seq, output_state_reduced.phase = %s\n\n%!"
          (PS.exact output_state_reduced.phase);

        printf "Equiv.seq, condition_zero_phase = %s\n\n%!"
          (phase_equality_to_string condition_zero_phase));

      (* Evaluate result according to the phase condition *)
      match condition_zero_phase with
      | SubCircuitEquality ->
          if compute_result ~debug inputs1 output_state_reduced identity_state
          then SubCircuitEquivalent
          else SubCircuitInconclusive
      | GlobalPhaseEquality ->
          if compute_result ~debug inputs1 output_state_reduced identity_state
          then GlobalPhaseEquivalent
          else SubCircuitInconclusive
      | ConditionalEquality -> (
          match equivalence with
          | SubCircuit -> SubCircuitInconclusive
          | GlobalPhase -> GlobalPhaseInconclusive
          | FullCircuit -> failwith "Full-circuit equivalence not implemented."))
    else Entanglement1

let parallel ?(debug = false) ?(inputs1 = []) ?(inputs2 = []) ?(outputs1 = [])
    ?(outputs2 = []) ?(meas1 = []) ?(meas2 = []) ?(equivalence = SubCircuit)
    unitary1 unitary2 =
  let wq1, wq2, inits1, inits2, inputs1, inputs2, outputs1, outputs2, _ =
    parameters_preparation inputs1 inputs2 outputs1 outputs2 unitary1 unitary2
  in
  if List.length inputs1 <> List.length inputs2 then NotEquivDiffInputs
  else if List.length outputs1 <> List.length outputs2 then NotEquivDiffOutputs
  else if List.length inputs1 <> List.length outputs1 then
    NotEquivDiffInputsOutputs
  else if
    (* observable check *)
    equivalence <> FullCircuit
    && not (check_observable_measurement outputs1 outputs2 meas1 meas2)
  then NotEquivDiffMeasurements
  else
    let input_state1 = Path_sum.ofSize_init (Int.max 1 wq1) inits1 in
    let input_state2 = Path_sum.ofSize_init (Int.max 1 wq2) inits2 in

    let output_state1 = Program.execution ~input_state:input_state1 unitary1 in
    let output_state2 = Program.execution ~input_state:input_state2 unitary2 in

    let output_state_reduced1 = reduction output_state1 in
    let output_state_reduced2 = reduction output_state2 in

    let output_path_var_norm1 =
      Rules.Variable_replacement.poly_normalized output_state_reduced1
    in
    let output_path_var_norm2 =
      Rules.Variable_replacement.poly_normalized output_state_reduced2
    in

    if debug then
      printf "Equiv.parallel,\noutput_path_var_norm1 =\n%s\n\n"
        (PSS.pretty output_path_var_norm1);
    if debug then
      printf "Equiv.parallel,\noutput_path_var_norm2 =\n%s\n\n"
        (PSS.pretty output_path_var_norm2);

    let check_separability () =
      let s1 = separability_states output_path_var_norm1 outputs1 wq1
      and s2 = separability_states output_path_var_norm2 outputs2 wq2 in
      match (s1, s2) with
      | false, _ -> Some Entanglement1
      | _, false -> Some Entanglement2
      | _ -> None
    in

    match equivalence with
    | SubCircuit -> (
        match check_separability () with
        | Some res ->
            (* Entanglement of out and disc*)
            res
        | None ->
            (* Entanglement of out and disc*)
            if
              Path_sum.equal ~outputs1 ~outputs2 output_path_var_norm1
                output_path_var_norm2
            then SubCircuitEquivalent
            else SubCircuitInconclusive)
    | GlobalPhase -> (
        match check_separability () with
        | Some res ->
            (* Entanglement of out and disc*)
            res
        | None ->
            if
              Path_sum.equal ~outputs1 ~outputs2 ~global_phase:true
                output_path_var_norm1 output_path_var_norm2
            then GlobalPhaseEquivalent
            else GlobalPhaseInconclusive)
    | FullCircuit -> failwith "Full-circuit equivalence not implemented."

(* Defines the type 'algo' representing the algorithm type to use. *)
type algo = Parallel | Sequence

(* Function SQV (Sequence or Parallel Verification) to verify the partial-unitary-equivalence of two quantum circuits *)
let sqv ?(debug = false) ?(inputs1 = []) ?(inputs2 = []) ?(outputs1 = [])
    ?(outputs2 = []) ?(meas1 = []) ?(meas2 = []) ?(algo = Sequence)
    ?(equivalence = SubCircuit) p1 p2 : result =
  (* Determines the equivalence result based on the algorithm and the requested equivalence type *)
  let result =
    match (algo, equivalence) with
    | Parallel, _ ->
        parallel p1 p2 ~debug ~equivalence ~inputs1 ~inputs2 ~outputs1 ~outputs2
          ~meas1 ~meas2
    | Sequence, FullCircuit ->
        (* Raises an exception as full circuit equivalence in sequence is not possible *)
        failwith "Full-circuit equivalence not implemented."
    | Sequence, _ ->
        seq p1 p2 ~debug ~equivalence ~inputs1 ~inputs2 ~outputs1 ~outputs2
          ~meas1 ~meas2
  in
  result

let sqv_simple_result ?(debug = false) ?(inputs1 = []) ?(inputs2 = [])
    ?(outputs1 = []) ?(outputs2 = []) ?(meas1 = []) ?(meas2 = [])
    ?(algo = Sequence) ?(equivalence = SubCircuit) ?(not_equiv = false) p1 p2 =
  let is_equivalent =
    let result =
      sqv ~debug ~inputs1 ~inputs2 ~outputs1 ~outputs2 ~meas1 ~meas2 ~algo
        ~equivalence p1 p2
    in
    match equivalence with
    | SubCircuit -> result = SubCircuitEquivalent
    | GlobalPhase ->
        result = SubCircuitEquivalent || result = GlobalPhaseEquivalent
    | FullCircuit -> failwith "Full-circuit equivalence not implemented."
  in
  if not_equiv then not is_equivalent else is_equivalent
