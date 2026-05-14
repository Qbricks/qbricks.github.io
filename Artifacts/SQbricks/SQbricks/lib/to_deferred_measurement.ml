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

open Common
include Rational
open Printf
include Program
module ProgS = Program.String
include Program.Macros

let to_deferred_measurements ?(debug = false) p =
  let p = Program.format p in
  let wc, wq = Program.widths p in
  if debug then printf "1. Translation.to_deferred_measurements, wq = %d\n\n" wq;
  if debug then
    printf "2. Translation.to_deferred_measurements, p =\n%s\n\n"
      (ProgS.pretty p);

  let bit_to_qubit = Array.make wc (-1) in

  let is_wires_available wires_unavailable wires_to_check =
    let rec aux wires_to_check =
      match wires_to_check with
      | [] -> true
      | wire :: _ when Array.mem wire wires_unavailable -> false
      | _ :: wires_to_check_remain -> aux wires_to_check_remain
    in
    aux wires_to_check
  in

  let rec aux ?(debug = false) p inits meas =
    match p with
    | Apply (_, co, ta) when is_wires_available bit_to_qubit (co @ ta) ->
        (p, inits, meas)
    | Apply (_, co, ta) ->
        failwith
          (sprintf
             "Translation.to_deferred_measurements, Apply on wire(s) \
              unvailable, co = %s, ta = %s, bit_to_qubit = %s\n"
             (ListBis.string_int co) (ListBis.string_int ta)
             (ArrayBis.string_int bit_to_qubit))
    | Measure (qubit_indice, bit_indice) ->
        if debug then
          printf
            "Translation.to_deferred_measurements.Measure, qubit_indice = %d, \
             bit_indice = %d\n\n"
            qubit_indice bit_indice;
        bit_to_qubit.(bit_indice) <- qubit_indice;
        (E, inits, qubit_indice :: meas)
    | It (bits_indices, _) when ListBis.check_bounds (-1) wc bits_indices ->
        failwith
          (sprintf
             "Translation.to_deferred_measurements, %d <= bits_indices or \
              bits_indices < -1, bits_indices = %s\n"
             wc
             (ListBis.string_int bits_indices))
    | It (bits_indices, Apply (g, qubits_indices_co, qubits_indices_ta))
      when is_wires_available bit_to_qubit
             (qubits_indices_co @ qubits_indices_ta) ->
        if debug then
          printf
            "Translation.to_deferred_measurements.It, bits_indices = %s\n\n"
            (ListBis.string_int bits_indices);

        let rec bits_to_qubits bits_indices =
          match bits_indices with
          | [] -> []
          | bit_indice :: bits_indices_remain ->
              let qubit_indice = bit_to_qubit.(bit_indice) in
              if qubit_indice = -1 then
                failwith
                  "Translation.to_deferred_measurements.It, classical control \
                   on wire doesn't store measurement result forbiden.";
              if debug then
                printf
                  "Translation.to_deferred_measurements.bits_to_qubits, \
                   qubit_indice = %d\n\n"
                  qubit_indice;
              qubit_indice :: bits_to_qubits bits_indices_remain
        in

        let qubits_indices = bits_to_qubits bits_indices in
        if debug then
          printf
            "Translation.to_deferred_measurements.It, qubits_indices = %s\n\n"
            (ListBis.string_int qubits_indices);
        ( Apply
            ( g,
              List.sort_uniq Int.compare (qubits_indices @ qubits_indices_co),
              qubits_indices_ta ),
          inits,
          meas )
    | It (_, Apply (_, qubits_indices_co, qubits_indices_ta)) ->
        failwith
          (sprintf
             "Translation.to_deferred_measurements.It, Apply on wire(s) \
              unvailable, qubits_indices_co = %s, qubits_indices_ta = %s, \
              bit_to_qubit = %s\n"
             (ListBis.string_int qubits_indices_co)
             (ListBis.string_int qubits_indices_ta)
             (ArrayBis.string_int bit_to_qubit))
    | It (_, E) -> (E, inits, meas)
    | It ([ bit_indice ], Sequence (p1, p2)) ->
        aux
          (Sequence (It ([ bit_indice ], p1), It ([ bit_indice ], p2)))
          inits meas
    | Sequence (p1, p2) ->
        let p1', l1, l1' = aux p1 inits meas in
        let p2', l2, l2' = aux p2 l1 l1' in
        (Sequence (p1', p2'), l2, l2')
    | E -> (E, inits, meas)
    | Not bit_indice when bit_indice < 0 || wc <= bit_indice ->
        failwith "Translation.to_deferred_measurement.Not apply outside creg"
    | Not bit_indice -> (x bit_to_qubit.(bit_indice), inits, meas)
    | InitQ ta -> (E, ta :: inits, meas)
    | _ ->
        failwith
          (sprintf "Translation.to_deferred_measurement, p = %s forbidden"
             (ProgS.pretty p))
  in
  let deferred_measurement, inits, meas = aux p [] [] in
  let dm = Program.format deferred_measurement in
  let inits = List.rev (List.sort_uniq Int.compare inits) in
  let meas = List.sort_uniq Int.compare meas in
  (dm, inits, meas)
