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
open Printf

type t = Zero | One | Var of int | Prod of t * t | SumMod2 of t * t

let equal ?(debug = false) ?(wq1 = 0) ?(wq2 = 0) ?(map_path_var1 = IntMap.empty)
    ?(map_path_var2 = IntMap.empty) (q1 : t) (q2 : t) =
  if (wq1 = 0 && wq2 = 1) || (wq1 = 1 && wq2 = 0) then
    failwith "Qubit.equal, wq1 and wq2 aren't in the same state";

  if debug then
    printf
      "Qubit.equal.compare.IntMap, map_path_var1 = %s, map_path_var2 = %s\n%!"
      (Common.to_string_int_map map_path_var1)
      (Common.to_string_int_map map_path_var2);

  let compare_vars v1 v2 =
    (* If free variable *)
    if v1 < wq1 && v2 < wq2 then (
      if debug then printf "Qubit.equal, v1 = %d, v2 = %d\n\n%!" v1 v2;
      Int.equal v1 v2)
    else if
      (* If path variables *)
      wq1 <= v1 && wq2 <= v2
    then (
      let y1, y2 =
        if IntMap.is_empty map_path_var1 then
          if IntMap.is_empty map_path_var2 then (
            let y1, y2 = (v1 - wq1, v2 - wq2) in
            if debug then
              printf "Qubit.equal.compare, y1 = %d, y2 = %d\n%!" y1 y2;
            (y1, y2))
          else
            failwith
              "Qubit.equal.compare, IntMap.is_empty map_path_var1 but not \
               map_path_var2"
        else if IntMap.is_empty map_path_var2 then
          failwith
            "Qubit.equal.compare, IntMap.is_empty map_path_var2 but not \
             map_path_var1"
        else
          let key1, key2 = (v1, v2) in
          if debug then
            printf "Qubit.equal.compare.IntMap, key1 = %d, key2 = %d\n%!" key1
              key2;
          let val1 = IntMap.find key1 map_path_var1 in
          if debug then printf "Qubit.equal.compare.IntMap, val1 = %d\n%!" val1;
          let val2 = IntMap.find key2 map_path_var2 in
          if debug then printf "Qubit.equal.compare.IntMap, val2 = %d\n%!" val2;
          (val1, val2)
      in
      if debug then (
        printf "Qubit.equal, v1 = %d, v2 = %d, wq1 = %d, wq2 = %d\n\n%!" v1 v2
          wq1 wq2;
        printf "Qubit.equal, y1 = %d, y2 = %d\n\n%!" y1 y2);
      Int.equal y1 y2)
    else false
  in

  let rec aux q1 q2 =
    match (q1, q2) with
    | Zero, Zero | One, One -> true
    | Var v1, Var v2 ->
        if debug then printf "Qubit.equal.aux, v1 = %d, v2 = %d\n\n%!" v1 v2;
        compare_vars v1 v2
    | Prod (q1, q2), Prod (q3, q4) | SumMod2 (q1, q2), SumMod2 (q3, q4) ->
        aux q1 q3 && aux q2 q4
    | _ -> false
  in
  aux q1 q2

let ( ++ ) q1 q2 : t = SumMod2 (q1, q2)

let comp q1 q2 =
  let rec aux q1 q2 =
    match (q1, q2) with
    | Zero, Zero -> 0
    | Zero, _ -> 1
    | _, Zero -> -1
    | One, One -> 0
    | One, _ -> 1
    | Var _, One -> -1
    | Var v1, Var v2 when v1 < v2 -> 1
    | Var v1, Var v2 when Int.equal v1 v2 -> 0
    | Var _, Var _ -> -1
    | Prod _, One -> -1
    | Prod (q1', q1''), Prod (q2', q2'') ->
        let c1 = aux q1' q2' in
        if c1 <> 0 then c1 else aux q1'' q2''
    | Prod (q1', _), Var _ ->
        let c1 = aux q1' q2 in
        if not (Int.equal c1 0) then c1 else -1
    | Var _, Prod (q2', _) ->
        let c1 = aux q1 q2' in
        if not (Int.equal c1 0) then c1 else 1
    | Prod _, SumMod2 _ -> 1
    | Var _, SumMod2 _ -> 1
    | SumMod2 _, One | SumMod2 _, Var _ | SumMod2 _, Prod _ -> -1
    | SumMod2 (p1, p2), SumMod2 (p3, p4) ->
        let c1 = aux p1 p3 in
        if not (Int.equal c1 0) then c1 else aux p2 p4
  in
  aux q1 q2

let rec simplify (q : t) =
  let continue = ref false in
  let rec aux (q : t) =
    match q with
    | Prod (SumMod2 (q1, q2), q3) ->
        continue := true;
        let q1_simplified = q1 in
        let q2_simplified = q2 in
        let q3_simplified = q3 in
        aux
          (SumMod2
             ( aux (Prod (q1_simplified, q3_simplified)),
               aux (Prod (q2_simplified, q3_simplified)) ))
    | Prod (q1, SumMod2 (q2, q3)) ->
        continue := true;
        let q1_simplified = q1 in
        let q2_simplified = q2 in
        let q3_simplified = q3 in
        aux
          (SumMod2
             ( aux (Prod (q1_simplified, q2_simplified)),
               aux (Prod (q1_simplified, q3_simplified)) ))
    | SumMod2 (SumMod2 (q1, q2), q3) ->
        continue := true;
        let q1_simplified = q1 in
        let q2_simplified = q2 in
        let q3_simplified = q3 in
        aux
          (SumMod2 (q1_simplified, aux (SumMod2 (q2_simplified, q3_simplified))))
    | Prod (Prod (q1, q2), q3) ->
        continue := true;
        let q1_simplified = q1 in
        let q2_simplified = q2 in
        let q3_simplified = q3 in
        aux (Prod (q1_simplified, aux (Prod (q2_simplified, q3_simplified))))
    | Prod (Zero, _) | Prod (_, Zero) ->
        continue := true;
        Zero
    | SumMod2 (Zero, q') | SumMod2 (q', Zero) ->
        continue := true;
        aux q'
    | Prod (One, q') | Prod (q', One) ->
        continue := true;
        aux q'
    | Prod (q1, q2) when q1 = q2 ->
        continue := true;
        aux q1
    | SumMod2 (q1, q2) when q1 = q2 ->
        continue := true;
        Zero
    | Prod (q1, Prod (q2, q3)) when q1 = q2 ->
        continue := true;
        let q1_simplified = q1 in
        let q3_simplified = q3 in
        aux (Prod (q1_simplified, q3_simplified))
    | SumMod2 (q1, SumMod2 (q2, q3)) when q1 = q2 ->
        continue := true;
        aux q3
    | Prod (p1, p2) -> (
        let p1s = aux p1 in
        match aux p2 with
        | Prod (p2s, p2s') -> (
            match comp p1s p2s with
            | k ->
                if 0 <= k then Prod (p1s, Prod (p2s, p2s'))
                else (
                  continue := true;
                  Prod (p2s, Prod (p1s, p2s'))))
        | p2s -> (
            match comp p1 p2s with
            | k ->
                if 0 <= k then Prod (p1s, p2s)
                else (
                  continue := true;
                  Prod (p2s, p1s))))
    | SumMod2 (p1, p2) -> (
        let p1s = aux p1 in
        match aux p2 with
        | SumMod2 (p2s, p2s') -> (
            match comp p1s p2s with
            | k ->
                if 0 <= k then SumMod2 (p1s, SumMod2 (p2s, p2s'))
                else (
                  continue := true;
                  SumMod2 (p2s, SumMod2 (p1s, p2s'))))
        | p2s -> (
            match comp p1s p2s with
            | k ->
                if 0 <= k then SumMod2 (p1s, p2s)
                else (
                  continue := true;
                  SumMod2 (p2s, p1s))))
    | _ -> q
  in
  let ps = aux q in
  if !continue then simplify ps else ps

let rec member v q =
  match q with
  | SumMod2 (q1, q2) -> member v q1 || member v q2
  | Prod (q1, q2) -> member v q1 || member v q2
  | Var v' -> v = v'
  | _ -> false

let remove v q =
  let v_removed = ref false in
  let rec aux v q =
    match q with
    | SumMod2 _ -> failwith "Qubit.remove"
    | Prod (Var v1, q2) when v1 = v ->
        v_removed := true;
        aux v q2
    | Prod (q1, Var v2) when v2 = v ->
        v_removed := true;
        aux v q1
    | Var v1 when v = v1 ->
        v_removed := true;
        One
    | _ -> q
  in
  let q_output = aux v q in
  if !v_removed then Some q_output else None

let substitute v original_qubit qubit_to_substitute =
  let rec aux q =
    match q with
    | Var v' when v = v' -> qubit_to_substitute
    | Prod (q1, q2) -> Prod (aux q1, aux q2)
    | SumMod2 (q1, q2) -> SumMod2 (aux q1, aux q2)
    | _ -> q
  in
  aux original_qubit

let number_of_sum q =
  let rec aux q =
    match q with SumMod2 (q1, q2) -> aux q1 + aux q2 + 1 | _ -> 0
  in
  aux q

let extract_path_var ?(debug = false) q width =
  if debug then printf "Qubit.extract_path_var, width = %d\n\n%!" width;
  let rec aux (qubit : t) acc =
    match qubit with
    | Var v when width < v -> v :: acc
    | Prod (q1, q2) | SumMod2 (q1, q2) -> aux q1 acc |> aux q2
    (* | SumMod2 (q1, q2) -> aux q1 acc @ aux q2 acc *)
    | _ -> []
  in
  aux q []

let extract_var q =
  let rec aux (qubit : t) acc =
    match qubit with
    | Var v -> v :: acc
    | Prod (q1, q2) | SumMod2 (q1, q2) -> aux q1 acc |> aux q2
    | _ -> []
  in
  aux q []

module String = struct
  let pretty x w =
    let rec string x w =
      match x with
      | One -> "1"
      | Zero -> "0"
      | Var t ->
          if t < w then "x" ^ string_of_int t else "y" ^ string_of_int (t - w)
      | SumMod2 (q1, q2) -> string q1 w ^ " ++ " ^ string q2 w
      | Prod (q1, q2) -> string q1 w ^ "." ^ string q2 w
    in
    string x w

  let exact x =
    let rec string' x =
      match x with
      | One -> "One"
      | Zero -> "Zero"
      | Var t -> "(Var " ^ string_of_int t ^ ")"
      | SumMod2 (q1, q2) -> "SumMod2 (" ^ string' q1 ^ "," ^ string' q2 ^ ")"
      | Prod (q1, q2) -> "Prod(" ^ string' q1 ^ "," ^ string' q2 ^ ")"
    in
    string' x
end
