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

module QS = Qubit.String
module KS = Path_sum.Ket.String
module PSS = Path_sum.String
module ProgS = Program.String
include Program.Macros
open Printf
open Common
include Rational

let format = Program.format

type res_measure = Zero | One | S of int

type t =
  | ID
  | N of int
  | E of int * int
  | X of int * res_measure
  | Z of int * res_measure
  | M of int * res_measure * res_measure * res_measure * Q.t * int
  | Sequence of t * t

let to_string_res_meas (r : res_measure) =
  match r with One -> "1" | Zero -> "0" | S i -> "s" ^ string_of_int i

let rec to_string p =
  match p with
  | ID -> ""
  | N i -> sprintf "N %d" i
  | E (i, j) -> sprintf "E (%d,%d)" i j
  | X (i, s) -> sprintf "X (%d,%s)" i (to_string_res_meas s)
  | Z (i, s) -> sprintf "Z (%d,%s)" i (to_string_res_meas s)
  | M (i, res_m, s, t, num, k) ->
      if k < 0 then
        failwith (sprintf "Translation.to_string, k = %d must be positive" k);
      sprintf "M (%d,%s,%s,%s,%s)" i (to_string_res_meas res_m)
        (to_string_res_meas s) (to_string_res_meas t)
        (Q.to_string (Q.div_2exp num k))
  | Sequence (p1, p2) -> to_string p1 ^ "\n" ^ to_string p2

let ( -- ) p1 p2 : Program.t = Sequence (p1, p2)
let ( --- ) p1 p2 : t = Sequence (p1, p2)

let rec preprocess (p : Program.t) : Program.t =
  match p with
  | Apply (X, [ co1; co2 ], [ ta ]) -> ccxoq2 co1 co2 ta
  | Apply (H, [ co ], [ ta ]) -> chdecomp co ta
  | Apply (U1 (num, k), [ co ], [ ta ]) ->
      let angle = Q.div_2exp num k in
      if angle = div2 then h ta -- cx co ta -- h ta
      else
        let s = Q.to_int num in
        cu1decomp ~s k co ta
  | Sequence (p1, p2) -> preprocess p1 -- preprocess p2
  | _ -> p

let to_sqbricks ?(debug = false) (p : t) : Program.t =
  let process_xz op s =
    (* let rec aux s = *)
    match s with
    | Zero -> id
    | One -> op
    | S i -> it i op
  in

  let apply_s ta num k (s : res_measure) =
    if k < 1 then failwith (sprintf "Owm.apply_s, k = %d must be positive" k);
    let aux num k (s : res_measure) : Program.t =
      match s with
      | Zero -> u1 ~s:num k ta
      | One -> u1 ~s:(-num) k ta
      | S i -> u1 ~s:num k ta -- it i (u1 ~s:(-num) (k - 1) ta)
    in
    aux num k s
  in

  let apply_t ta t : Program.t =
    match t with Zero -> E | One -> zz ta | S i -> it i (zz ta)
  in

  let process_m ta (s : res_measure) (t : res_measure) (num : int) (k : int) =
    if k < 0 then failwith "Owm.process_m, k < 0 forbidden";
    if debug then
      printf
        "Translation.to_qbricks.process_m, ta = %d, num = %d, k = %d, s = %s, \
         t = %s\n"
        ta num k (to_string_res_meas s) (to_string_res_meas t);
    if k = 0 || num = 0 then apply_t ta t
    else if k = 1 && (num = 1 || num = -1) then u1 ~s:num k ta -- apply_t ta t
    else apply_s ta num k s -- apply_t ta t
  in

  let rec aux (p : t) : Program.t =
    match p with
    | ID -> id
    | N ta ->
        let p_output = iq0 ta -- h ta in
        if debug then
          printf "Translation.to_qbricks.N, ta = %d, p_output =\n%s\n" ta
            (ProgS.pretty p_output);
        p_output
    | E (co, ta) when co = ta ->
        failwith
          (sprintf "Translation.to_qbricks_rec, co = %d, ta = %d\n" co ta)
    | E (co, ta) ->
        let p_output = cz co ta in
        if debug then
          printf "Translation.to_qbricks.E, co = %d, ta = %d, p_output =\n%s\n"
            co ta (ProgS.pretty p_output);
        p_output
    | X (ta, s) ->
        let p_output = process_xz (x ta) s in
        if debug then
          printf "Translation.to_qbricks.X, ta = %d, s = %s, p_output =\n%s\n"
            ta (to_string_res_meas s) (ProgS.pretty p_output);
        p_output
    | Z (ta, s) ->
        let p_output = process_xz (zz ta) s in
        if debug then
          printf "Translation.to_qbricks.Z, ta = %d, s = %s, p_output =\n%s\n"
            ta (to_string_res_meas s) (ProgS.pretty p_output);
        p_output
    | M (ta, S sta, s, t, num, k) ->
        let p_output = process_m ta s t (Q.to_int num) k -- h ta -- m ta sta in
        if debug then
          printf
            "Translation.to_qbricks.M, sta = %d, num = %s, k = %d, p_output =\n\
             %s\n"
            sta (Q.to_string num) k (ProgS.pretty p_output);
        p_output
    | Sequence (p1, p2) -> aux p1 -- aux p2
    | _ -> failwith (sprintf "Owm.to_sqbricks, p =\n%s" (to_string p))
  in
  Program.format (aux p)

let rec cleaning (p : Program.t) : Program.t =
  let is_eliminated (p : Program.t) =
    match p with E | InitQ _ -> true | _ -> false
  in
  match p with
  | Sequence (p1, p2) when is_eliminated p1 && is_eliminated p2 -> E
  | Sequence (p1, p2) when is_eliminated p1 -> cleaning p2
  | Sequence (p1, p2) when is_eliminated p2 -> cleaning p1
  | Sequence (p1, p2) -> cleaning p1 -- cleaning p2
  | _ -> p

(** Compute the number of necessary qubits from initial qubits. *)
let widths (p : Program.t) : int array =
  let _, w = Program.widths p in
  let wq = Array.make w 1 in
  (* Usually 1 wire for 1 qubit. *)
  (* Auxiliary function for adjusting widths to suit the operation. *)
  let adjust_width op controls targets =
    match ((op : Gates.t), controls, targets) with
    | H, [], [ ta ] -> wq.(ta) <- wq.(ta) + 1
    | U1 _, [], [ ta ] -> wq.(ta) <- wq.(ta) + 2
    | X, [], [ ta ] -> wq.(ta) <- wq.(ta)
    | X, [ _ ], [ ta ] ->
        wq.(ta) <- wq.(ta) + 2 (* Taking into account a control for X. *)
    | _ -> ()
  in

  let rec widths_rec (p : Program.t) =
    match p with
    | Apply (op, controls, targets) -> adjust_width op controls targets
    | Sequence (p1, p2) ->
        widths_rec p1;
        widths_rec p2
    | _ -> ()
  in
  widths_rec p;
  wq

let to_owm ?(debug = false) ?(dm = false) (p : Program.t) =
  let p = format (preprocess p) in
  let wq : int array = widths p in
  (* Number of necessary qubits from initial qubits. *)
  if debug then printf "Owm.to_mbqc, wq = %s\n" (ArrayBis.string_int wq);
  let _, width_initial = Program.widths p in
  if debug then printf "Owm.to_mbqc, width_initial = %d\n" width_initial;
  if width_initial = 0 then (Program.E, [], [])
  else
    (* Map the input qubit with its expected value *)
    let mapInput = Array.make width_initial (-1) in
    (* Map the input qubit with its output *)
    let mapOutput = Array.make width_initial (-1) in
    let init_maps mapI mapO n =
      mapI.(0) <- 0;
      mapO.(0) <- 0;
      for i = 1 to n - 1 do
        mapI.(i) <- mapI.(i - 1) + wq.(i - 1);
        mapO.(i) <- mapO.(i - 1) + wq.(i - 1)
      done;
      (mapI, mapO)
    in
    let mapInput, mapOutput = init_maps mapInput mapOutput width_initial in
    (* Maps initialisation. *)
    if debug then printf "Owm.mapInput = %s\n" (ArrayBis.string_int mapInput);
    if debug then
      printf "Owm.mapOutput = %s\n\n" (ArrayBis.string_int mapOutput);

    let adjust_mapOutput ta offset =
      mapOutput.(ta) <- offset + mapOutput.(ta)
    in

    let rec aux (p : Program.t) wq wc =
      match p with
      | E -> (wq, wc, ID)
      | Apply (H, [], [ ta ]) ->
          let offset = 1 in
          if debug then
            printf "Owm.aux.H, ta = %d, mapInput = %s, mapOutput = %s\n" ta
              (ArrayBis.string_int mapInput)
              (ArrayBis.string_int mapOutput);
          adjust_mapOutput ta offset;
          let output = mapOutput.(ta) in
          let input = output - 1 in
          let s1 : res_measure = S wc in
          let prog_by_measure =
            N output
            --- E (input, output)
            --- M (input, s1, Zero, Zero, Q.zero, 0)
            --- X (output, s1)
          in
          if debug then
            printf
              "Owm.aux.H, adjusted ta = %d, mapInput = %s, mapOutput = %s\n" ta
              (ArrayBis.string_int mapInput)
              (ArrayBis.string_int mapOutput);
          (wq + offset, wc + 1, prog_by_measure)
      | Apply (U1 (num, k), [], [ ta ]) ->
          let offset = 2 in
          adjust_mapOutput ta offset;
          let input = mapOutput.(ta) - 2 in
          let inter = mapOutput.(ta) - 1 in
          let output = mapOutput.(ta) in
          let s1 : res_measure = S wc in
          let s2 : res_measure = S (wc + 1) in
          let prog_by_measure =
            N inter --- N output
            --- E (input, inter)
            --- E (inter, output)
            --- M (input, s1, Zero, Zero, num, k)
            --- M (inter, s2, Zero, Zero, Q.zero, 0)
            --- Z (output, s1)
            --- X (output, s2)
          in
          if debug then
            printf
              "Owm.aux.U1.else, adjusted num = %s, k = %d, ta = %d, mapInput = \
               %s, mapOutput = %s\n"
              (Q.to_string num) k ta
              (ArrayBis.string_int mapInput)
              (ArrayBis.string_int mapOutput);
          (wq + offset, wc + 2, prog_by_measure)
      | Apply (X, [], [ ta ]) ->
          let output = mapOutput.(ta) in
          let prog_by_measure = X (output, One) in
          (wq, wc, prog_by_measure)
      | Apply (X, [ co ], [ ta ]) when co = ta ->
          failwith (sprintf "Translation.aux, co = %d = ta" ta)
      | Apply (X, [ co ], [ ta ]) ->
          let offset = 2 in
          let control = mapOutput.(co) in
          adjust_mapOutput ta offset;
          let input = mapOutput.(ta) - 2 in
          let inter = mapOutput.(ta) - 1 in
          let output = mapOutput.(ta) in
          let s2 : res_measure = S wc in
          let s3 : res_measure = S (wc + 1) in
          let prog_by_measure =
            N inter --- N output
            --- E (inter, output)
            --- E (input, inter)
            --- E (control, inter)
            --- M (input, s2, Zero, Zero, Q.zero, 0)
            --- M (inter, s3, Zero, Zero, Q.zero, 0)
            --- Z (control, s2)
            --- Z (output, s2)
            --- X (output, s3)
          in
          if debug then
            printf "Translation.aux, Apply (X, [ %d ], [ %d ])\n" co ta;
          if debug then printf "Translation.aux, control = %d\n" control;
          if debug then
            printf
              "Owm.aux.CX, co = %d, ta = %d, adjusted mapInput = %s, mapOutput \
               = %s\n"
              co ta
              (ArrayBis.string_int mapInput)
              (ArrayBis.string_int mapOutput);
          (wq + offset, wc + 2, prog_by_measure)
      | Sequence (p1, p2) ->
          let wq1, wc1, p1' = aux p1 wq wc in
          let wq2, wc2, p2' = aux p2 wq1 wc1 in
          if debug then
            printf
              "Owm.to_mbqc.Sequence,wq1 = %d, wq2 = %d, wc1 = %d, wc2 = %d, \
               mapOutput = %s\n"
              wq1 wq2 wc1 wc2
              (ArrayBis.string_int mapOutput);
          (wq2, wc2, p1' --- p2')
      | _ ->
          failwith
            (sprintf "Translation.to_mbqc, gates not implemented, p = %s"
               (ProgS.exact p))
    in
    let p_cleaned = cleaning p in
    let wq, wc, prog_by_meas = aux p_cleaned width_initial 0 in
    if debug then printf "Translation.to_mbqc, wq = %d, wc = %d\n" wq wc;

    let inputs = Array.to_list mapInput in
    let outputs = Array.to_list mapOutput in

    (* Preparing the IUM version of `by_meas`. *)
    let by_meas = Program.format (to_sqbricks prog_by_meas) in

    let inputs, outputs = if by_meas = E then ([], []) else (inputs, outputs) in

    if debug then
      printf "Owm.to_owm, by_meas =\n%s\n\n%!" (ProgS.pretty by_meas);

    if dm then (
      let by_meas_dm, _, _ =
        To_deferred_measurement.to_deferred_measurements by_meas
      in
      if debug then
        printf "Owm.to_owm, by_meas_dm =\n%s\n\n%!" (ProgS.pretty by_meas_dm);
      let by_meas_ium = Program.format by_meas_dm in

      (by_meas_ium, inputs, outputs))
    else let by_meas = Program.format by_meas in

         (by_meas, inputs, outputs)
