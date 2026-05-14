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
open Common
include Rational
include Path_sum
module PS = Poly.String
module QS = Qubit.String
module PSS = String
module Monome = Poly.Monome

type t = GP of Q.t * int | U1 of Q.t * int | X | H

let to_string g =
  match g with
  | H -> "H"
  | X -> "X"
  | U1 (s, k) -> sprintf "Rz(%s.2.pi/2^%d)" (Q.to_string s) k
  | GP (s, k) -> sprintf "GP(%s.2.pi/2^%d)" (Q.to_string s) k

let equal g1 g2 =
  match (g1, g2) with
  | H, H -> true
  | X, X -> true
  | U1 (s1, k1), U1 (s2, k2) when Q.equal s1 s2 -> k1 = k2
  | GP (s1, k1), GP (s2, k2) when Q.equal s1 s2 -> k1 = k2
  | _ -> false

module Apply_gates = struct
  type poly = Poly.PolyHeap.t

  let merge = Poly.merge
  let ( ++ ) (m : Monome.t) (p : Poly.t) : Poly.t = Poly.insert m p
  let ( @@ ) (p1 : poly) (p2 : poly) : poly = merge p1 p2
  let ( +++ ) p1 p2 : Qubit.t = SumMod2 (p1, p2)

  let rec apply_control (ket : Ket.t) co : Qubit.t =
    match co with
    | h :: [] -> ket.(h)
    | h :: co' -> Qubit.Prod (ket.(h), apply_control ket co')
    | [] -> Qubit.One

  let of_qubit ?(debug = false) (q : Qubit.t) (s : Q.t) : poly =
    Poly.of_qubit ~debug (Qubit.simplify q) s

  let of_qubit_2_pi (q : Qubit.t) : poly = Poly.of_qubit_2_pi (Qubit.simplify q)
  let distribution = Poly.distribution
  let int_sort l = List.fast_sort Int.compare l

  let apply_hadamard ps co ta : Path_sum.t =
    (* \(1/2 (x_{co} x_{ta} y) + 1/8 ((1-x_{co}) (1-2y)) \) *)
    let apply_hadamard_phase (xta : Qubit.t) (y0 : int) (control : Qubit.t) :
        poly =
      let p_control = of_qubit_2_pi control in
      Scal div8
      ++ (Prod (Scal divm4, Qubit (Var y0))
         ++ (distribution ~s1:div2 (Qubit (Var y0))
               (of_qubit_2_pi (Prod (control, xta)))
            @@ distribution (Scal divm8) p_control
            @@ distribution ~s1:div4 (Qubit (Var y0)) p_control))
    in
    let apply_hadamard_without_control ps ta y0 : Path_sum.t =
      let p : poly =
        distribution (Scal div2)
          (Poly.simplify_monomes (of_qubit_2_pi (Prod (Var y0, ps.ket.(ta)))))
        @@ ps.phase
      in
      ps.ket.(ta) <- Var y0;
      { phase = p; ket = ps.ket; path_var = int_sort (y0 :: ps.path_var) }
    in
    let apply_hadamard_ket (ket : Ket.t) ta y0 control : Ket.t =
      ket.(ta) <-
        Prod (control, Var y0) +++ (ket.(ta) +++ Prod (control, ket.(ta)));
      ket
    in
    let y0 =
      if List.equal Int.equal ps.path_var [] then Array.length ps.ket
      else ListBis.max_int ps.path_var + 1
    in
    let ps_output : Path_sum.t =
      match co with
      | [] -> apply_hadamard_without_control ps ta y0
      | _ ->
          let control = Qubit.simplify (apply_control ps.ket co) in
          let xta = ps.ket.(ta) in
          {
            phase = ps.phase @@ apply_hadamard_phase xta y0 control;
            ket = apply_hadamard_ket ps.ket ta y0 control;
            path_var = int_sort (y0 :: ps.path_var);
          }
    in
    Rules.Simplification.simplify ps_output

  let apply_not ps co ta =
    let (q : Qubit.t) =
      match co with
      | [] -> One +++ ps.ket.(ta)
      | _ -> apply_control ps.ket co +++ ps.ket.(ta)
    in
    ps.ket.(ta) <- q;
    let ps_output =
      { phase = ps.phase; ket = ps.ket; path_var = ps.path_var }
    in
    Rules.Simplification.simplify ps_output

  let apply_u1 ?(debug = false) (angle' : Q.t) ps co ta =
    let width = Array.length ps.ket in
    if debug then
      printf "Gates.apply_u1, angle' = %s\n\n%!" (Q.to_string angle');
    if debug then
      printf "Gates.apply_u1, co = %s, ta = %d\n\n%!" (ListBis.string_int co) ta;
    if debug then printf "Gates.apply_u1, ps =\n%s\n\n%!" (PSS.pretty ps);
    let angle =
      let k = find_k angle'.den in
      if Q.lt angle' Q.zero then
        Q.make (Z.sub (pow2Z k) (Z.neg angle'.num)) angle'.den
      else angle'
    in
    if debug then printf "Gates.apply_u1, angle = %s\n\n%!" (Q.to_string angle);
    let p_ta =
      if Q.equal angle div2 || Q.equal angle divm2 then
        of_qubit_2_pi ps.ket.(ta)
      else of_qubit ~debug ps.ket.(ta) angle
    in
    if debug then
      printf "Gates.apply_u1, p_ta = %s\n\n%!" (PS.pretty p_ta width);
    let p_output =
      match co with
      | [] ->
          let p = distribution (Scal angle) p_ta in
          if debug then
            printf "Gates.apply_u1, p = %s\n\n%!" (PS.pretty p width);
          ps.phase @@ Poly.simplify p
      | _ ->
          let p_control =
            if Q.equal angle div2 || Q.equal angle divm2 then
              of_qubit_2_pi (apply_control ps.ket co)
            else of_qubit (apply_control ps.ket co) angle
          in
          ps.phase @@ distribution (Scal angle) (Poly.prod p_control p_ta)
    in
    let ps_output =
      { phase = p_output; ket = ps.ket; path_var = ps.path_var }
    in
    Rules.Simplification.simplify ps_output

  let apply_gp (angle' : Q.t) ps co =
    let angle =
      let k = find_k angle'.den in
      if Q.lt angle' Q.zero then
        Q.make (Z.sub (pow2Z k) (Z.neg angle'.num)) angle'.den
      else angle'
    in
    let p_output =
      match co with
      | [] -> Scal angle ++ ps.phase
      | _ ->
          let p_control =
            if Q.equal angle Q.one then of_qubit_2_pi (apply_control ps.ket co)
            else of_qubit (apply_control ps.ket co) angle
          in
          ps.phase @@ distribution (Scal angle) p_control
    in
    let ps_output =
      { phase = p_output; ket = ps.ket; path_var = ps.path_var }
    in
    Rules.Simplification.simplify ps_output

  let apply_classical_not ps ta =
    (match ps.ket.(ta) with
    | Zero -> ps.ket.(ta) <- One
    | One -> ps.ket.(ta) <- Zero
    | _ ->
        failwith (sprintf "Path_sum.Not, ta = %d, ps = %s" ta (PSS.pretty ps)));
    { phase = ps.phase; ket = ps.ket; path_var = ps.path_var }
end
