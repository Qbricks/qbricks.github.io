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

open Printf
module ProgS = Program.String
include Program.Macros
module PSS = Path_sum.String
module QS = Qubit.String
open Common

(** Circuit teleportation of n qubits. *)
let circuit n : Program.t =
  if n < 1 then
    failwith (Printf.sprintf "Teleportation.circuit, n = %d < 1\n" n)
  else
    let aux i =
      let indiceq = 3 * i in
      let indicec = 2 * i in
      (* Preparation *)
      iq0 (indiceq + 1)
      -- iq0 (indiceq + 2)
      -- h (indiceq + 1)
      -- cx (indiceq + 1) (indiceq + 2)
      -- cx indiceq (indiceq + 1)
      -- h indiceq
      --
      (* Measures *)
      m indiceq indicec
      -- m (indiceq + 1) (indicec + 1)
      --
      (* Corrections *)
      it (indicec + 1) (x (indiceq + 2))
      -- it indicec (zz (indiceq + 2))
    in
    let result = ref Program.E in
    for i = 0 to n - 1 do
      result := !result -- aux i
    done;
    !result

let circuit_false n : Program.t =
  if n < 1 then
    failwith (Printf.sprintf "Teleportation.circuit_false, n = %d < 1\n" n)
  else
    let aux i =
      let indiceq = 3 * i in
      let indicec = 2 * i in
      iq0 (indiceq + 1)
      -- iq0 (indiceq + 2)
      -- m indiceq indicec
      -- it indicec (x (indiceq + 2))
    in
    let result = ref Program.E in
    for i = 0 to n - 1 do
      result := !result -- aux i
    done;
    !result

let to_teleport ?(debug = false) ?(false_teleportation = false) ?(dm = false)
    (p : Program.t) =
  let wc, wq = Program.widths p in
  if wc <> 0 then failwith (sprintf "Teleportation.to_teleport, wc = %d" wc);

  let offset = 3 in

  let rec prepare_circuit_to_teleport (p : Program.t) : Program.t =
    match p with
    | Apply (g, co, ta) ->
        Apply
          ( g,
            ListBis.increment_by_coeff co offset,
            ListBis.increment_by_coeff ta offset )
    | InitQ ta -> InitQ (ta * offset)
    | Program.E -> Program.E
    | Sequence (Program.E, p1) | Sequence (p1, Program.E) ->
        prepare_circuit_to_teleport p1
    | Sequence (p1, p2) ->
        Sequence (prepare_circuit_to_teleport p1, prepare_circuit_to_teleport p2)
    | _ ->
        failwith
          (sprintf
             "Teleportation.to_teleport, classical instructions forbidden, p = \
              %s"
             (ProgS.pretty p))
  in

  let teleportation =
    Program.format
      (if false_teleportation then circuit_false wq else circuit wq)
  in
  let circuit_to_teleport = Program.format (prepare_circuit_to_teleport p) in
  let circuit_teleported =
    Program.format circuit_to_teleport -- teleportation
  in

  if debug then printf "Teleportation.to_teleport, wq = %d\n" wq;
  if debug then
    printf "Teleportation.to_teleport, teleportation_circuit =\n%s\n\n"
      (ProgS.pretty teleportation);
  if debug then
    printf "Teleportation.to_teleport, circuit_to_teleport =\n%s\n\n"
      (ProgS.pretty circuit_to_teleport);
  if debug then
    printf "Teleportation.to_teleport, circuit_teleported =\n%s\n\n"
      (ProgS.pretty circuit_teleported);

  let inputs =
    ListBis.generate_int_list_from_a_to_b_with_step 0 (offset * wq) offset
  in
  let outputs =
    ListBis.generate_int_list_from_a_to_b_with_step (offset - 1)
      ((offset * wq) + 1)
      offset
  in

  if debug then
    printf "Teleportation.to_teleport, inputs = %s\n"
      (ListBis.string_int inputs);
  if debug then
    printf "Teleportation.to_teleport, outputs = %s\n\n"
      (ListBis.string_int outputs);

  (* Preparing the IUM version of `by_meas`. *)
  let by_meas = Program.format circuit_teleported in
  let by_meas_dm, inits, _ =
    To_deferred_measurement.to_deferred_measurements by_meas
  in
  let inits = List.rev inits in

  if dm then (
    let by_meas_ium =
      Program.format
        (apply_inits (apply_measure by_meas_dm outputs (2 * wq)) inits)
    in
    if debug then
      printf "Teleportation.to_teleport, by_meas_ium =\n%s\n\n"
        (ProgS.pretty by_meas_ium);
    (by_meas_ium, inputs, outputs))
  else
    let by_meas = Program.format by_meas in
    (by_meas, inputs, outputs)
