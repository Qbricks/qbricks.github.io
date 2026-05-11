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

open Common
include Rational
module QS = Qubit.String
open Printf

module Monome = struct
  type q = Qubit.t
  type t = Scal of Q.t | Qubit of q | Prod of t * t

  let equal ?(debug = false) ?(wq1 = 0) ?(wq2 = 0)
      ?(map_path_var1 = IntMap.empty) ?(map_path_var2 = IntMap.empty) (m1 : t)
      (m2 : t) =
    if debug then
      printf "Monome.equal.IntMap, map_path_var1 = %s, map_path_var2 = %s\n%!"
        (Common.to_string_int_map map_path_var1)
        (Common.to_string_int_map map_path_var2);

    let rec aux (m1 : t) (m2 : t) =
      match (m1, m2) with
      | Scal s1, Scal s2 -> Q.equal s1 s2
      | Qubit q1, Qubit q2 ->
          if debug then
            printf "Monome.equal, q1 = %s, q2 = %s\n\n%!" (QS.exact q1)
              (QS.exact q2);
          Qubit.equal ~debug ~wq1 ~wq2 ~map_path_var1 ~map_path_var2 q1 q2
      | Prod (q1, q2), Prod (q3, q4) -> aux q1 q3 && aux q2 q4
      | _ -> false
    in
    aux m1 m2

  let rec compare (m1 : t) (m2 : t) =
    match (m1, m2) with
    | Scal s1, Scal s2 when Q.lt s1 s2 -> 1
    | Scal s1, Scal s2 when Q.equal s1 s2 -> 0
    | Scal _, Scal _ -> -1
    | Scal _, _ -> 1
    | Qubit _, Scal _ -> -1
    | Qubit q1, Qubit q2 -> Qubit.comp q1 q2
    | Prod (Scal _, m1'), Qubit _ ->
        let comp = compare m1' m2 in
        if Int.equal comp 0 then -1 else comp
    | Qubit _, Prod (Scal _, m2') ->
        let comp = compare m1 m2' in
        if comp = 0 then 1 else comp
    | Prod (m1', m1''), Qubit _ ->
        let c1 = compare m1' m2 in
        if not (Int.equal c1 0) then c1 else compare m1'' m2
    | Qubit _, Prod (m2', m2'') ->
        let c1 = compare m1 m2' in
        if not (Int.equal c1 0) then c1 else compare m1 m2''
    | Prod _, Scal _ -> -1
    | Prod (Scal s1', m1'), Prod (Scal s2', m2') ->
        let comp = compare m1' m2' in
        if Int.equal comp 0 then compare (Scal s1') (Scal s2') else comp
    | Prod (Scal _, m1'), m2' ->
        let comp = compare m1' m2' in
        if Int.equal comp 0 then -1 else comp
    | m1', Prod (Scal _, m2') ->
        let comp = compare m1' m2' in
        if Int.equal comp 0 then 1 else comp
    | Prod (p1, p2), Prod (p3, p4) ->
        let c1 = compare p1 p3 in
        if not (Int.equal c1 0) then c1 else compare p2 p4

  module String = struct
    let rec pretty (p : t) w =
      match p with
      | Scal s -> Q.to_string s
      | Qubit q -> "[" ^ QS.pretty q w ^ "]"
      | Prod (p1, p2) -> pretty p1 w ^ " * " ^ pretty p2 w

    let rec exact p =
      match p with
      | Scal s -> Q.to_string s
      | Qubit q -> "Qubit (" ^ QS.exact q ^ ")"
      | Prod (p1, p2) -> "Prod (" ^ exact p1 ^ "," ^ exact p2 ^ ")"
  end

  let remove_neg_scal ?(debug = false) m =
    if debug then printf "Poly.remove_neg_scal, m = %s\n%!" (String.exact m);
    let rec aux m =
      match m with
      | Scal s when Q.( < ) s (Q.of_int 0) && Z.lt (Z.of_int 1) s.den ->
          (* -2pi.1/4 -> 2pi.3/4 *)
          if debug then
            printf "Poly.remove_neg_scal, s = %s\n%!" (Q.to_string s);
          if debug then
            printf "Poly.remove_neg_scal, s.num = %s, s.den = %s\n%!"
              (Z.to_string s.num) (Z.to_string s.den);
          let num = Z.add s.num s.den in
          if debug then
            printf "Poly.remove_neg_scal, num = %s\n%!" (Z.to_string num);
          let s = Q.make num s.den in
          if debug then
            printf "Poly.remove_neg_scal, s = %s\n%!" (Q.to_string s);
          let m' = Scal s in
          if debug then
            printf "Poly.remove_neg_scal, m' = %s\n\n%!" (String.exact m');
          m'
      | Prod (m1, m2) -> Prod (aux m1, aux m2)
      | _ -> m
    in
    aux m

  let simplify ?(debug = false) (m : t) : t =
    if debug then printf "Phase.simplify, m = %s\n" (String.exact m);
    let m = remove_neg_scal ~debug m in
    let rec aux' ?(debug = false) (m : t) : t =
      let continue = ref false in
      if debug then
        printf "Phase.simplify,after remove negative scalar, m = %s\n"
          (String.exact m);
      let rec aux m =
        match m with
        | Scal s when s = divm2 -> Scal div2
        | Scal s ->
            let num =
              let new_num = Z.rem s.num s.den in
              if Z.equal new_num Z.zero then s.num else new_num
            in
            Scal (Q.make num s.den)
        | Prod (Scal s, m1) when Q.equal s divm2 ->
            aux (Prod (Scal div2, aux m1))
        | Prod (Scal s, m1) when Q.equal s Q.one ->
            if debug then
              printf "Phase.simplify.Prod s, s = %s\n" (Q.to_string s);
            if debug then
              printf "Phase.simplify.Prod s, m1 = %s\n" (String.exact m1);
            aux m1
        | Prod (m1, Scal s) when Q.equal s Q.one -> aux m1
        | Prod (Scal k1, Scal k2) -> Scal (Q.mul k1 k2)
        | Prod (Scal k1, Prod (Scal k2, p')) ->
            if debug then
              printf "Phase.simplify.Prod k1 k2, k1 = %s, k2 = %s\n"
                (Q.to_string k1) (Q.to_string k2);
            aux (Prod (Scal (Q.mul k1 k2), p'))
        | Prod (Qubit Qubit.Zero, _) | Prod (_, Qubit Qubit.Zero) -> Scal Q.zero
        | Prod (Scal s, _) when Q.equal s Q.zero -> Scal Q.zero
        | Prod (_, Scal s) when Q.equal s Q.zero -> Scal Q.zero
        | Prod (Qubit One, m1) -> aux m1
        | Prod (m1, Qubit One) -> aux m1
        | Prod (Qubit q1, Qubit q2) when Qubit.equal q1 q2 ->
            Qubit (Qubit.simplify q1)
        | Prod (Qubit q1, Prod (Qubit q2, p')) when Qubit.equal q1 q2 ->
            aux (Prod (Qubit (Qubit.simplify q1), aux p'))
        | Prod (Prod (m1, m2), m3) ->
            let m1_simplified = m1 in
            let m2_simplified = m2 in
            let m3_simplified = m3 in
            aux (Prod (m1_simplified, Prod (m2_simplified, m3_simplified)))
        | Prod (Scal s, m1) ->
            let num =
              let new_num = Z.rem s.num s.den in
              if Z.equal new_num Z.zero then s.num else new_num
            in
            Prod (Scal (Q.make num s.den), aux m1)
        | Qubit One -> Scal Q.one
        | Qubit Zero -> Scal Q.zero
        | Qubit (Prod (q1, q2)) -> Prod (Qubit q1, Qubit q2)
        | Prod (p1, p2) -> (
            let p1s = aux p1 in
            match aux p2 with
            | Prod (p2s, p2s') -> (
                match compare p1s p2s with
                | k ->
                    if 0 <= k then Prod (p1s, Prod (p2s, p2s'))
                    else (
                      continue := true;
                      Prod (p2s, Prod (p1s, p2s'))))
            | p2s -> (
                match compare p1 p2s with
                | k ->
                    if 0 <= k then Prod (p1s, p2s)
                    else (
                      continue := true;
                      Prod (p2s, p1s))))
        | Qubit q -> Qubit (Qubit.simplify q)
      in
      let m_simplified = remove_neg_scal ~debug (aux m) in
      if debug then
        printf "Phase.simplify, m_simplified = %s\n" (String.exact m_simplified);
      if !continue then aux' m_simplified else m_simplified
    in
    aux' ~debug m

  let rec member v (p : t) =
    match p with
    | Prod (p1, p2) -> if member v p1 then true else member v p2
    | Qubit q -> Qubit.member v q
    | _ -> false

  let of_qubit_to (q : Qubit.t) : t =
    let rec aux (q : Qubit.t) =
      match q with
      | One -> Scal Q.one
      | Zero -> Scal Q.zero
      | Var _ -> Qubit q
      | Prod (q1, q2) -> simplify (Prod (aux q1, aux q2))
      | SumMod2 _ -> failwith "SumMod2 forbidden in of_qubit_to"
    in
    aux q

  let to_qubit ?(debug = false) (p : t) : Qubit.t =
    let rec to_qubit_rec (p : t) : Qubit.t =
      if debug then printf "Phase.to_qubit_rec, p = %s\n" (String.pretty p 2);
      match p with
      | Scal s when Q.equal s Q.zero -> Zero
      | Scal s when Q.equal s Q.one -> One
      | Scal s ->
          failwith (sprintf "Phase.to_qubit_rec, s = %s" (Q.to_string s))
      | Qubit q ->
          if debug then printf "Phase.to_qubit_rec, q = %s\n" (QS.pretty q 2);
          q
      | Prod (p1, p2) -> Prod (to_qubit_rec p1, to_qubit_rec p2)
    in
    Qubit.simplify (to_qubit_rec p)

  let remove v m =
    let v_removed = ref false in
    let rec aux m =
      match m with
      | Prod (m1, Qubit (Var v1)) when v = v1 ->
          v_removed := true;
          aux m1
      | Prod (Qubit (Var v1), m1) when v = v1 ->
          v_removed := true;
          aux m1
      | Prod (m1, m2) -> Prod (aux m1, aux m2)
      | Qubit q -> (
          match Qubit.remove v q with
          | Some q_without_v ->
              v_removed := true;
              Qubit q_without_v
          | None -> Qubit q)
      | _ -> m
    in
    let m_output = simplify (aux m) in
    if !v_removed then Some m_output else None

  let remove_qubit qubit_to_remove m =
    let qubit_removed = ref false in
    let rec aux m =
      match m with
      | Prod (m1, Qubit q1) when Qubit.equal qubit_to_remove q1 ->
          qubit_removed := true;
          aux m1
      | Prod (Qubit q1, m1) when Qubit.equal qubit_to_remove q1 ->
          qubit_removed := true;
          aux m1
      | Prod (m1, m2) -> Prod (aux m1, aux m2)
      | Qubit q when Qubit.equal q qubit_to_remove -> Scal Q.zero
      | _ -> m
    in
    let m_output = simplify (aux m) in
    if !qubit_removed then Some m_output else None

  (* m[Var v <- q'] *)
  let substitute (v : int) (m : t) (q' : Qubit.t) : t =
    let rec aux m : t =
      match m with
      | Qubit q -> Qubit (Qubit.substitute v q q')
      | Prod (m1, m2) -> Prod (aux m1, aux m2)
      | _ -> m
    in
    aux m

  let extract_path_var ?(debug = false) m wq =
    let rec aux m acc =
      if debug then
        printf "Poly.extract_path_var,\n m = %s\n acc = %s\n" (String.exact m)
          (ListBis.string_int acc);
      match m with
      | Qubit (Var v) when wq <= v ->
          if debug then printf "Poly.extract_path_var, v = %d\n" v;
          v :: acc
      | Prod (m1, m2) -> aux m2 (aux m1 acc)
      | _ -> acc
    in
    List.rev (aux m [])

  let monome_to_scalar_monome monome =
    match monome with Prod (Scal s, m) -> Some (s, m) | _ -> None

  (* 
  Checks if the given monomial is constant. 
  If width < 0, then the monomial is constant only if it contains no variables.
  If width >= 0, then variables with index < width are considered constant. 
  *)
  let is_constant ?(debug = false) monome width =
    let rec is_constant_rec = function
      | Qubit (Qubit.Var v) ->
          if debug then
            printf "Poly.Monome.is_constant, v = %d, width = %d\n" v width;
          (* let is_const = *)
          if width < 0 then
            (* If width < 0, then the monomial is constant only if it contains no variables.  *)
            false
          else
            (* If width >= 0, then variables with index >= width are considered constant.  *)
            width <= v
      | Prod (m1, m2) -> is_constant_rec m1 && is_constant_rec m2
      | _ -> true (* Scalar or other constant terms *)
    in
    let result = is_constant_rec monome in
    if debug then
      printf "Poly.Monome.is_constant, result = %b, width = %d\n\n" result width;
    result
end

module MS = Monome.String

(* A phase polynomial is a heap of monomials *)
(* Heap structure keeps polynomial ordered in log n *)
module PolyHeap = BatHeap.Make (struct
  type t = Monome.t

  let compare m1 m2 = -Monome.compare m1 m2
end)

type t = PolyHeap.t

let empty = PolyHeap.empty
let find = PolyHeap.find_min
let del = PolyHeap.del_min
let size = PolyHeap.size

module String = struct
  let pretty (p : PolyHeap.t) w =
    let rec aux h acc =
      if h = empty then acc
      else
        let elem = find h in
        let heap = del h in
        aux heap
          (acc ^ (if acc = "" then "" else " + ") ^ Monome.String.pretty elem w)
    in
    "(" ^ aux p "" ^ ")"

  let exact (p : PolyHeap.t) =
    let rec aux h acc =
      if h = empty then acc
      else
        let elem = find h in
        let heap = del h in
        aux heap
          (acc ^ (if acc = "" then "" else " + ") ^ Monome.String.exact elem)
    in
    "(" ^ aux p "" ^ ")"
end

(** TODO : utiliser [find_opt] dans la suite *)
let find_opt (poly : t) = if poly = empty then None else Some (find poly)

(** Compares two polynomials p1 and p2. Returns true if they are equal,
    optionally ignoring global phases. *)
let equal ?(global_phase = false) ?(debug = false) ?(wq1 = 0) ?(wq2 = 0)
    ?(map_path_var1 = IntMap.empty) ?(map_path_var2 = IntMap.empty) (p1 : t)
    (p2 : t) =
  if debug then
    printf "Poly.equal,  p1 = %s\n  p2 = %s\n%!" (String.exact p1)
      (String.exact p2);

  (* Helper: remove global phase term if requested *)
  let rec drop_global_phase p =
    match find_opt p with
    | Some (Monome.Scal _) when global_phase -> drop_global_phase (del p)
    | _ -> p
  in

  (* Recursive structural comparison *)
  let rec compare_poly (a : t) (b : t) =
    match (a = empty, b = empty) with
    | true, true -> true
    | true, false | false, true -> false
    | false, false ->
        let m1, rest1 = (find a, del a) in
        let m2, rest2 = (find b, del b) in

        if debug then
          printf "Poly.equal,\nm1 = %s\nm2 = %s\n\n%!" (MS.exact m1)
            (MS.exact m2);

        Monome.equal ~debug ~wq1 ~wq2 ~map_path_var1 ~map_path_var2 m1 m2
        && compare_poly rest1 rest2
  in

  (* Clean up input polynomials if global phase should be ignored *)
  let p1' = if global_phase then drop_global_phase p1 else p1 in
  let p2' = if global_phase then drop_global_phase p2 else p2 in

  compare_poly p1' p2'

(* insert keeps duplicate *)
let insert (m : Monome.t) (p : PolyHeap.t) : PolyHeap.t = PolyHeap.insert p m
let ( ++ ) (m : Monome.t) (p : PolyHeap.t) : PolyHeap.t = insert m p
let merge (p1 : t) (p2 : t) : t = PolyHeap.merge p1 p2
let ( @@ ) (p1 : t) (p2 : t) : t = merge p1 p2
let to_poly (m : Monome.t) = m ++ empty
let zero = Scal Q.zero ++ empty
let one : PolyHeap.t = Scal Q.one ++ empty
let q v : PolyHeap.t = Qubit (Var v) ++ empty

(* let occurrence f a (p : t) =
  let rec aux p acc =
    if equal p empty then acc else aux (del p) (acc + f a (find p))
  in
  aux p 0 *)

let occurrence f a (p : t) =
  let rec aux p acc =
    if equal p empty then acc
    else
      match find_opt p with
      | None -> aux (del p) acc
      | Some x -> aux (del p) (acc + f a x)
  in
  aux p 0

(* Use for scalar-free polynomials *)
let simplify_monomes ?(debug = false) (p : PolyHeap.t) : PolyHeap.t =
  let zero_condition s = Q.equal s Q.zero in
  let rec aux p (acc : t) =
    if debug then printf "Phase.simplify_monomes, p = %s\n" (String.exact p);
    if equal p empty then acc
    else
      let m1, p1 = (Monome.simplify (find p), del p) in
      if equal p1 empty then
        match m1 with
        | (Scal s1 | Prod (Scal s1, _)) when zero_condition s1 -> acc
        | m1 -> m1 ++ acc
      else
        let m2, p2 = (Monome.simplify (find p1), del p1) in
        if debug then
          printf "Phase.simplify_monomes, m1 = %s\n" (Monome.String.exact m1);
        if debug then
          printf "Phase.simplify_monomes, m2 = %s\n" (Monome.String.exact m2);
        match (m1, m2) with
        | Scal s1, Scal s2 ->
            let s' = Q.add s1 s2 in
            if zero_condition s' then aux p2 acc else aux (Scal s' ++ p2) acc
        (* \( 0 + m = m \) *)
        | (Scal s, _ | Prod (Scal s, _), _) when zero_condition s -> aux p1 acc
        | (_, Scal s | _, Prod (Scal s, _)) when zero_condition s ->
            aux (m1 ++ p2) acc
        | Prod (Scal s1, m1), Prod (Scal s2, m2) when Monome.equal m1 m2 ->
            let s' = Q.add s1 s2 in
            if debug then
              printf "Poly.simplify_monomes, s' = %s\n\n%!" (Q.to_string s');
            if zero_condition s' then aux p2 acc
            else
              let m_simplified = Monome.simplify (Prod (Scal s', m1)) in
              aux (m_simplified ++ p2) acc
        | m1, Prod (Scal s2, m2) when Monome.equal m1 m2 ->
            let s' = Q.add Q.one s2 in
            if zero_condition s' then aux p2 acc
            else
              let m_simplified = Monome.simplify (Prod (Scal s', m2)) in
              aux (m_simplified ++ p2) acc
        | Prod (Scal s1, m1), m2 when Monome.equal m1 m2 ->
            let s' = Q.add Q.one s1 in
            if zero_condition s' then aux p2 acc
            else
              let m_simplified = Monome.simplify (Prod (Scal s', m1)) in
              aux (m_simplified ++ p2) acc
        | m1, m2 when Monome.equal m1 m2 ->
            let s' = Q.mul_2exp Q.one 1 in
            let m_simplified = Monome.simplify (Prod (Scal s', m1)) in
            aux (m_simplified ++ p2) acc
        | _ -> aux p1 (m1 ++ acc)
  in
  let poly_simplified = aux p empty in
  if poly_simplified = empty then to_poly (Scal Q.zero) else poly_simplified

let simplify ?(debug = false) (p : PolyHeap.t) : PolyHeap.t =
  let zero_condition s =
    Q.equal s Q.zero || Z.equal s.den Z.one || Z.equal s.den Z.minus_one
  in
  let rec aux p (acc : t) =
    if debug then printf "Phase.simplify, p = %s\n" (String.exact p);
    if debug then printf "Phase.simplify, acc = %s\n" (String.exact acc);
    if equal p empty then acc
    else
      let m1, p1 = (Monome.simplify (find p), del p) in
      if debug then printf "Phase.simplify, p1 = %s\n" (String.exact p1);
      if equal p1 empty then (
        if debug then
          printf "Phase.simplify.p1 = empty, p1 = %s\n" (String.exact p1);
        if debug then
          printf "Phase.simplify.p1 = empty, m1 = %s\n" (Monome.String.exact m1);
        match m1 with
        | (Scal s1 | Prod (Scal s1, _)) when zero_condition s1 -> acc
        | Prod (Qubit _, _) | Qubit _ -> acc
        | _ ->
            let result = m1 ++ acc in
            if debug then
              printf "Phase.simplify, result = %s\n" (String.exact result);
            result)
      else
        let m2, p2 = (Monome.simplify (find p1), del p1) in
        if debug then
          printf "Phase.simplify, m1 = %s\n" (Monome.String.exact m1);
        if debug then
          printf "Phase.simplify, m2 = %s\n" (Monome.String.exact m2);
        match (m1, m2) with
        | Scal s1, Scal s2 ->
            let s' = Q.add s1 s2 in
            if zero_condition s' then aux p2 acc else aux (Scal s' ++ p2) acc
        (* \( 0 + m = m \) *)
        | Scal s, _ when zero_condition s -> aux p1 acc
        | _, Scal s when zero_condition s -> aux (m1 ++ p2) acc
        | Prod (Qubit _, _), _ | Qubit _, _ -> aux p1 acc
        | _, Prod (Qubit _, _) | _, Qubit _ -> aux (m1 ++ p2) acc
        | Prod (Scal s, _), _ when zero_condition s -> aux p1 acc
        | _, Prod (Scal s, _) when zero_condition s -> aux (m1 ++ p2) acc
        | Prod (Scal s1, m1), Prod (Scal s2, m2) when Monome.equal m1 m2 ->
            let s' = Q.add s1 s2 in
            if zero_condition s' then aux p2 acc
            else
              let m_simplified = Monome.simplify (Prod (Scal s', m1)) in
              aux (m_simplified ++ p2) acc
        | m1, Prod (Scal s2, m2) when Monome.equal m1 m2 ->
            let s' = Q.add Q.one s2 in
            if zero_condition s' then aux p2 acc
            else
              let m_simplified = Monome.simplify (Prod (Scal s', m2)) in
              aux (m_simplified ++ p2) acc
        | Prod (Scal s1, m1), m2 when Monome.equal m1 m2 ->
            let s' = Q.add Q.one s1 in
            if zero_condition s' then aux p2 acc
            else
              let m_simplified = Monome.simplify (Prod (Scal s', m1)) in
              aux (m_simplified ++ p2) acc
        | _, _ when Monome.equal m1 m2 ->
            let s' = Q.mul_2exp Q.one 1 in
            if zero_condition s' then aux p2 acc
            else
              let m_simplified = Monome.simplify (Prod (Scal s', m1)) in
              aux (m_simplified ++ p2) acc
        | m1, m2 ->
            if debug then
              printf "Phase.simplify.end, m1 = %s\n" (Monome.String.exact m1);
            if debug then
              printf "Phase.simplify.end, m2 = %s\n" (Monome.String.exact m2);
            aux p1 (m1 ++ acc)
  in
  let poly_simplified = aux p empty in
  if equal poly_simplified empty then to_poly (Scal Q.zero) else poly_simplified

let exists (pred : Monome.t -> bool) (p : PolyHeap.t) =
  let rec aux p_input =
    if equal p_input empty then false
    else if pred (find p_input) then true
    else aux (del p_input)
  in
  aux p

let member v (p : PolyHeap.t) : bool = exists (Monome.member v) p

let member_list list poly =
  let rec aux = function
    | hd :: tl -> if member hd poly then true else aux tl
    | [] -> false
  in
  aux list

let is_empty poly = equal poly empty

(* p[m <- f(m)] *)
let forall (p : t) (f : Monome.t -> t) =
  let rec aux (p : t) (acc : t) =
    if is_empty p then acc
    else
      let m = find p in
      aux (del p) (f m @@ acc)
  in
  aux p empty

let distribution ?(debug = false) ?(s1 = Q.one) (m1 : Monome.t) (p2 : t) : t =
  let rec aux p2 acc =
    if equal p2 empty then acc
    else
      let m2 : Monome.t = find p2 in
      let p2_remain = del p2 in
      if debug then printf "Poly.distribution, s1 = %s\n%!" (Q.to_string s1);
      if debug then printf "Poly.distribution, m1 = %s\n%!" (MS.exact m1);
      if debug then printf "Poly.distribution, m2 = %s\n%!" (MS.exact m2);
      if debug then
        printf "Poly.distribution, p2_remain = %s\n%!" (String.exact p2_remain);
      let add_to_acc m3 = aux p2_remain (m3 ++ acc) in
      match m2 with
      | Prod (_, Scal _) -> failwith "Phase.distribution, m2 is not formatted"
      | Prod (Scal s2, m2') ->
          let m3' : Monome.t = Prod (Scal (Q.mul s1 s2), Prod (m1, m2')) in
          if debug then printf "Poly.distribution, m3' = %s\n%!" (MS.exact m3');
          let m3 = Monome.simplify ~debug m3' in
          if debug then printf "Poly.distribution, m3 = %s\n%!" (MS.exact m3);
          add_to_acc m3
      | Scal s2 ->
          let m4 = Monome.simplify (Prod (Scal (Q.mul s1 s2), m1)) in
          if debug then printf "Poly.distribution, m4 = %s\n%!" (MS.exact m4);
          add_to_acc m4
      | m2' ->
          let m5 = Monome.simplify (Prod (Scal s1, Prod (m1, m2'))) in
          add_to_acc m5
  in
  aux p2 empty

let prod ?(debug = false) ?(s1 = Q.one) p1 p2 =
  if debug then printf "Phase.prod, p2 = %s\n" (String.exact p2);
  let rec aux p1 acc =
    if equal p1 empty then acc
    else
      let m1, p1_remain = (find p1, del p1) in
      if debug then printf "Phase.prod, m1 = %s\n" (Monome.String.exact m1);
      aux p1_remain
        (acc @@ simplify_monomes (distribution ~s1 m1 (simplify_monomes p2)))
  in
  aux (simplify_monomes p1) empty

let of_qubit ?(debug = false) (q : Qubit.t) (s : Q.t) : t =
  let rec aux (q : Qubit.t) : t =
    match q with
    | SumMod2 (SumMod2 _, _) -> failwith "q must be formatted"
    | SumMod2 (q1, q2) ->
        let p1 = simplify_monomes (aux q1) in
        if debug then printf "Phase.of_qubit, p1 = %s\n" (String.exact p1);
        let p2 = simplify_monomes (aux q2) in
        if debug then printf "Phase.of_qubit, p2 = %s\n" (String.exact p2);
        let coef = coef_lift s in
        if debug then printf "Phase.of_qubit, coef = %s\n" (Q.to_string coef);
        if Q.equal coef Q.zero then p1 @@ p2
        else p1 @@ p2 @@ prod ~s1:coef p1 p2
    | _ -> Monome.of_qubit_to q ++ empty
  in
  aux q

(*
  Simplified version of `of_qubit`.
  Applicable when the qubit to be lifted is in a monomial
  whose scalar coefficient is 1/2.
  Indeed, we have the following equality:
  e^{2π * 1/2 * (x0 + x1 - 2 * x0 * x1)} = e^{2π * 1/2 * (x0 + x1)}
  *)
let of_qubit_2_pi ?(debug = false) (q : Qubit.t) : t =
  let rec aux (q : Qubit.t) : t =
    match q with
    | SumMod2 (SumMod2 _, _) -> failwith "q must be formatted"
    | SumMod2 (q1, q2) ->
        let p1 = aux q1 in
        if debug then printf "Phase.of_qubit_2_pi, p1 = %s\n" (String.exact p1);
        let p2 = aux q2 in
        if debug then printf "Phase.of_qubit_2_pi, p2 = %s\n" (String.exact p2);
        let p_output = simplify_monomes (p1 @@ p2) in
        if debug then
          printf "Phase.of_qubit_2_pi, p_output = %s\n\n"
            (String.exact p_output);
        p_output
    | _ -> Monome.of_qubit_to q ++ empty
  in
  aux q

(* In the following, we identify s with k1/2^k2 *)
(* `s` is the poly scalar *)
(* Prod(Scal s, (lift p) *)
let lift ?(debug = false) (p : t) (s : Q.t) : t =
  let rec aux (p : t) : t =
    if debug then printf "Poly.lift, p = %s\n\n" (String.exact p);
    if equal p empty then empty
    else
      let m1, p1_remain = (find p, del p) in
      if equal p1_remain empty then m1 ++ empty
      else
        let p1_remain_lifted = simplify_monomes (aux p1_remain) in
        let coef = coef_lift s in
        if Q.equal coef Q.zero then m1 ++ p1_remain_lifted
        else
          m1 ++ (p1_remain_lifted @@ distribution ~s1:coef m1 p1_remain_lifted)
  in
  aux p

let to_qubit (p : t) : Qubit.t =
  let rec aux p (acc : Qubit.t) =
    if equal p empty then acc
    else
      let m, p_remain = (find p, del p) in
      aux p_remain (SumMod2 (Monome.to_qubit m, acc))
  in
  aux p Qubit.Zero

(* m[yi <- Q] *)
let substitute_rules_monome_hh ?(debug = false) (yi : int) (q : t)
    (m : Monome.t) : PolyHeap.t =
  match Monome.remove yi m with
  | Some (Scal s1) -> distribution (Scal s1) (lift q s1) ~debug
  | Some (Prod (Scal s1, m1)) -> distribution ~s1 m1 (lift q s1) ~debug
  | Some m1 -> distribution m1 q ~debug
  | None -> to_poly m

(* r[yi <- q] *)
let substitute_rules_hh ?(debug = false) (r : PolyHeap.t) (yi : int) (q : t) =
  let rec aux r acc =
    if equal r empty then acc
    else
      let m, r_remain = (find r, del r) in
      if debug then printf "Poly.substitute_rules_hh, m = %s\n\n%!" (MS.exact m);
      aux r_remain (substitute_rules_monome_hh yi q m @@ acc)
  in
  aux r empty

(* input[Var variable_indice <- qubit_to_substitute ] *)
let substitute ?(debug = false) (variable_indice : int) (input : t)
    (qubit_to_substitute : Qubit.t) : t =
  let rec aux (input : t) (acc : t) : t =
    if debug then
      printf "Poly.substitute.aux, input = %s\n%!" (String.exact input);
    if debug then printf "Poly.substitute.aux, acc = %s\n%!" (String.exact acc);
    if equal input empty then acc
    else
      let m, p_remain = (find input, del input) in
      aux p_remain
        (Monome.substitute variable_indice m qubit_to_substitute ++ acc)
  in
  let output = aux input empty in
  if debug then
    printf "Poly.substitute.aux, output = %s\n%!" (String.exact output);
  output

(* m[v <- p'] *)
let substitute_poly_monome ?(debug = false) (v : int) (p' : t) (m : Monome.t) :
    t =
  if debug then
    printf "Poly.substitute_poly_monome, p' = %s\n\n%!" (String.exact p');
  match Monome.remove v m with
  | Some (Scal s1) ->
      if debug then
        printf "Poly.substitute_poly_monome, s1 = %s\n\n%!" (Q.to_string s1);
      let new_p = distribution ~debug (Scal s1) p' in
      if debug then
        printf "Poly.substitute_poly_monome, new_p = %s\n\n%!"
          (String.exact new_p);
      new_p
  | Some (Prod (Scal s1, m1)) -> distribution ~s1 m1 p'
  | Some m1 -> distribution m1 p'
  | None -> to_poly m

(* p[v <- p'] *)
let substitute_poly ?(debug = false) (p : t) (v : int) (p' : t) : t =
  let rec aux p acc =
    if equal p empty then acc
    else
      let m, p_remain = (find p, del p) in
      if debug then printf "Poly.substitute_poly, m = %s\n\n%!" (MS.exact m);
      let new_p = substitute_poly_monome ~debug v p' m @@ acc in
      if debug then
        printf "Poly.substitute_poly, new_p = %s\n\n%!" (String.exact new_p);
      aux p_remain new_p
  in
  aux p empty

let is_constant ?(debug = false) ?(width = -1) (p : t) : bool =
  if equal p empty then true
  else
    let result =
      not (exists (fun m -> not (Monome.is_constant ~debug m width)) p)
    in
    if debug then printf "Poly.is_constant, result = %b\n\n" result;
    result

let is_constant_superior_zero (p : t) : bool =
  if equal p empty then true
  else
    match (find p, del p) with
    | Monome.Scal k, remain when equal remain empty && Q.lt Q.zero k -> true
    | _ -> false

(* Returns true if the polynomial `poly` is separable between the variables of `l1` and `l2`. *)
let separable_in_poly ?(debug = false) (poly : t) l1 l2 =
  let rec is_separable (p : t) =
    if equal p empty then true
    else
      let m = find p in
      let p' = del p in

      if debug then
        printf "Poly.separable_in_poly, m = %s\n%!" (Monome.String.exact m);
      if debug then
        printf "Poly.separable_in_poly, p' = %s\n%!" (String.exact p');

      (* If some element of l1 is in the monomial, then none from l2 must be present. *)
      let has_l1 = List.exists (fun x -> Monome.member x m) l1 in
      let has_l2 = List.exists (fun y -> Monome.member y m) l2 in
      if debug then
        printf "Poly.separable_in_poly, has_l1 = %b, has_l2 = %b\n%!" has_l1
          has_l2;

      if has_l1 && has_l2 then false else is_separable p'
  in
  is_separable poly

(* Returns the monomes containing one of the vars variables *)
let extract poly vars =
  let rec aux p acc =
    if equal empty p then acc
    else
      let m = find p in
      let p' = del p in
      (* Compute the new acc *)
      let rec aux' = function
        | hd :: [] -> if Monome.member hd m then insert m acc else acc
        | hd :: tl -> if Monome.member hd m then insert m acc else aux' tl
        | [] -> acc
      in
      let acc' = aux' vars in
      aux p' acc'
  in
  aux poly empty

let extract_path_var (poly : t) wq =
  let rec aux (p : t) acc =
    if is_empty p then acc
    else
      let m1 = find p in
      let p1 = del p in
      aux p1 (List.rev (Monome.extract_path_var m1 wq) @ acc)
  in
  List.rev (aux poly [])

(* s(q1 ++ q2) -> s.m1 + s.m2 - 2.s.m1m2 *)
(* s -> (q1 ++ q2) -> s.m1 + s.m2 - 2.s.m1m2 *)
let lift_qubit ?(debug = false) scal monome =
  if debug then printf "Poly.lift_qubit, scal = %s\n%!" (Q.to_string scal);
  let rec aux m acc =
    if debug then printf "Poly.lift_qubit, m = %s\n%!" (Monome.String.exact m);
    if debug then printf "Poly.lift_qubit, acc = %s\n%!" (String.exact acc);
    match m with
    | Monome.Qubit (SumMod2 (q0, q1)) -> (
        match (q0, q1) with
        | Var _, Var _ | Prod _, Var _ | Var _, Prod _ | Prod _, Prod _ ->
            let m0 = Monome.Qubit q0 in
            let m1 = Monome.Qubit q1 in
            let minus_2s = Monome.Scal (Q.of_int (-2)) in
            m0 ++ (m1 ++ (Prod (minus_2s, Prod (m0, m1)) ++ acc))
        | _ ->
            let acc' = aux (Qubit q0) acc in
            if debug then
              printf "Poly.lift_qubit_, acc' = %s\n\n%!" (String.exact acc');
            let acc'' = aux (Qubit q1) acc in
            if debug then
              printf "Poly.lift_qubit_, acc'' = %s\n\n%!" (String.exact acc'');
            let output =
              acc' @@ acc''
              @@ distribution (Scal (Q.of_int (-2))) (prod acc' acc'')
            in
            if debug then
              printf "Poly.lift_qubit_, output = %s\n\n%!" (String.exact output);
            output)
    | _ -> m ++ acc
  in
  let output = distribution (Scal scal) (aux monome empty) in
  if debug then
    printf "Poly.lift_qubit, output = %s\n\n%!" (String.exact output);
  simplify output

let lift_monome ?(debug = false) monome =
  let monome = Monome.simplify monome in
  let output =
    match Monome.monome_to_scalar_monome monome with
    | Some (s, m) ->
        if debug then
          printf "Poly.lift_monome, s = %s, m = %s\n\n%!" (Q.to_string s)
            (Monome.String.exact m);
        lift_qubit s m
    | None -> to_poly monome
  in
  simplify output

let lift_poly ?(debug = false) poly =
  if debug then printf "Poly.lift_poly, poly =\n %s\n\n%!" (String.exact poly);
  let output = forall poly lift_monome in
  if debug then
    printf "Poly.lift_poly, output =\n %s\n\n%!" (String.exact output);
  output
