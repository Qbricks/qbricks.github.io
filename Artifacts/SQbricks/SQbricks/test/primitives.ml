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
module QS = Qubit.String
module PS = Poly.String
open Path_sum
module KS = Ket.String
module PSS = String
module Monome = Poly.Monome
open Common
include Rational
open Program
module ProgS = String
include Macros

type poly = Poly.t
type monome = Monome.t

let to_poly (m : monome) : poly = Poly.to_poly m
let reduction = Reduction_algorithm.reduction_algorithm
let ( ++ ) (q1 : Qubit.t) (q2 : Qubit.t) : Qubit.t = Qubit.SumMod2 (q1, q2)
let zero : Qubit.t = Qubit.Zero
let one : Qubit.t = Qubit.One

(* Insert with duplication *)
let ( +++ ) (m : Monome.t) (p : Poly.t) : Poly.t = Poly.insert m p
let x0 = Qubit.Var 0
let x1 = Qubit.Var 1
let x2 = Qubit.Var 2
let x0x1 = Monome.Qubit (Prod (Var 0, Var 1))
let x0x2 = Monome.Qubit (Prod (Var 0, Var 2))
let x1x2 = Monome.Qubit (Prod (Var 1, Var 2))
let x0x1x2 = Monome.Prod (Qubit x0, x1x2)
let v i = Qubit.Var i

(* let test_normalise_path_var ?(debug = true) ?(outputs1 = []) ?(outputs2 = [])
    (input : Path_sum.t) (expect : Path_sum.t) () =
  if debug then
    printf "Primitives.test_normalise_path_var, expect =\n%s\n\n%!"
      (PSS.pretty expect);
  if debug then
    printf "Primitives.test_normalise_path_var, input =\n%s\n\n%!"
      (PSS.pretty input);
  let input_normalised = Rules.Rename.normalise_path_var ~debug input in
  if debug then
    printf "Primitives.test_normalise_path_var, input_normalised =\n%s\n\n%!"
      (PSS.pretty input_normalised);
  let greet =
    Path_sum.equal ~debug ~outputs1 ~outputs2 input_normalised expect
  in
  let expect = true in
  check bool (sprintf "Primitives.test_normalise_path_var") expect greet *)

let p0 = Poly.zero
(* let out_1_qubit = [ 0 ]
let out_2_qubits = [ 0; 1 ] *)
(* 
let normalise_path_var =
  [
    ( "0, x0 -> 0, x0",
      `Quick,
      test_normalise_path_var ~outputs1:out_1_qubit ~outputs2:out_1_qubit
        { phase = p0; ket = [| v 0 |]; path_var = [] }
        { phase = p0; ket = [| v 0 |]; path_var = [] } );
    ( "x0, x0 -> x0, x0",
      `Quick,
      let x0 = v 0 in
      let p_x0 = to_poly (Qubit x0) in
      test_normalise_path_var ~outputs1:out_1_qubit ~outputs2:out_1_qubit
        { phase = p_x0; ket = [| x0 |]; path_var = [] }
        { phase = p_x0; ket = [| x0 |]; path_var = [] } );
    ( "1/4, 1 -> 1/4, 1",
      `Quick,
      let p = to_poly (Scal div4) in
      test_normalise_path_var ~outputs1:out_1_qubit ~outputs2:out_1_qubit
        { phase = p; ket = [| Qubit.One |]; path_var = [] }
        { phase = p; ket = [| Qubit.One |]; path_var = [] } );
    ( "1/4 x0, x0 -> 1/4 x0, x0",
      `Quick,
      let x0 = v 0 in
      let p = to_poly (Prod (Scal div4, Qubit x0)) in
      test_normalise_path_var ~outputs1:out_1_qubit ~outputs2:out_1_qubit
        { phase = p; ket = [| x0 |]; path_var = [] }
        { phase = p; ket = [| x0 |]; path_var = [] } );
    ( "1/2 y0, y0 -> 1/2 y0, y0",
      `Quick,
      let y0 = v 1 in
      let p = to_poly (Monome.Prod (Scal div2, Qubit y0)) in
      test_normalise_path_var
        { phase = p; ket = [| y0 |]; path_var = [ 1 ] }
        { phase = p; ket = [| y0 |]; path_var = [ 1 ] } );
    ( "0, |x0,x1> -> 0, |x0,x1>",
      `Quick,
      let x0 = v 1 in
      test_normalise_path_var ~outputs1:out_2_qubits ~outputs2:out_2_qubits
        { phase = p0; ket = [| x0; x1 |]; path_var = [] }
        { phase = p0; ket = [| x0; x1 |]; path_var = [] } );
    ( "0, |x0,y0> -> 0, |x0,y0>",
      `Quick,
      let x0 = v 0 in
      let y0 = v 2 in
      test_normalise_path_var ~outputs1:out_2_qubits ~outputs2:out_2_qubits
        { phase = p0; ket = [| x0; y0 |]; path_var = [ 2 ] }
        { phase = p0; ket = [| x0; y0 |]; path_var = [ 2 ] } );
    ( "0, |y0,x0> -> 0, |y0,x0>",
      `Quick,
      let x0 = v 0 in
      let y0 = v 2 in
      test_normalise_path_var ~outputs1:out_2_qubits ~outputs2:out_2_qubits
        { phase = p0; ket = [| y0; x0 |]; path_var = [ 2 ] }
        { phase = p0; ket = [| y0; x0 |]; path_var = [ 2 ] } );
    ( "0, |y0,y1> -> 0, |y0,y1>",
      `Quick,
      let y0 = v 2 in
      let y1 = v 3 in
      test_normalise_path_var ~outputs1:out_2_qubits ~outputs2:out_2_qubits
        { phase = p0; ket = [| y0; y1 |]; path_var = [ 2; 3 ] }
        { phase = p0; ket = [| y0; y1 |]; path_var = [ 2; 3 ] } );
    ( "0, |y0,y0> -> 0, |y0,y0>",
      `Quick,
      let y0 = v 2 in
      test_normalise_path_var ~outputs1:out_2_qubits ~outputs2:out_2_qubits
        { phase = p0; ket = [| y0; y0 |]; path_var = [ 2 ] }
        { phase = p0; ket = [| y0; y0 |]; path_var = [ 2 ] } );
    ( "0, |y1,y0> -> 0, |y0,y1>",
      `Quick,
      let y0 = v 2 in
      let y1 = v 3 in
      test_normalise_path_var ~outputs1:out_2_qubits ~outputs2:out_2_qubits
        { phase = p0; ket = [| y1; y0 |]; path_var = [ 2; 3 ] }
        { phase = p0; ket = [| y0; y1 |]; path_var = [ 2; 3 ] } );
    ( "1/2 y0, |y1,y0> -> 1/2 y0, |y0,y1>",
      `Quick,
      let y0 = v 2 in
      let y1 = v 3 in
      let p = to_poly (Monome.Prod (Scal div2, Qubit y0)) in
      let p' = to_poly (Monome.Prod (Scal div2, Qubit y1)) in
      test_normalise_path_var ~outputs1:out_2_qubits ~outputs2:out_2_qubits
        { phase = p; ket = [| y1; y0 |]; path_var = [ 2; 3 ] }
        { phase = p'; ket = [| y0; y1 |]; path_var = [ 2; 3 ] } );
    ( "1/2 y1, |y1,y1> -> 1/2 y0, |y0,y0>",
      `Quick,
      let y0 = v 2 in
      let y1 = v 3 in
      let p = to_poly (Monome.Prod (Scal div2, Qubit y1)) in
      let p' = to_poly (Monome.Prod (Scal div2, Qubit y0)) in
      test_normalise_path_var ~outputs1:out_2_qubits ~outputs2:out_2_qubits
        { phase = p; ket = [| y1; y1 |]; path_var = [ 3 ] }
        { phase = p'; ket = [| y0; y0 |]; path_var = [ 2 ] } );
  ] *)

let test_poly_normalize ?(debug = true) (input : Path_sum.t)
    (expect : Path_sum.t) () =
  if debug then
    printf "Primitives.test_normalise_path_var, expect =\n%s\n\n%!"
      (PSS.pretty expect);
  if debug then
    printf "Primitives.test_normalise_path_var, input =\n%s\n\n%!"
      (PSS.pretty input);
  let input_normalised =
    Rules.Variable_replacement.poly_normalized ~debug input
  in
  if debug then
    printf "Primitives.test_normalise_path_var, input_normalised =\n%s\n\n%!"
      (PSS.pretty input_normalised);
  let greet = Path_sum.equal ~debug input_normalised expect in
  let expect = true in
  check bool (sprintf "Primitives.test_normalise_path_var") expect greet

let poly_normalize =
  [
    ( "0, x0 -> 0, x0",
      `Quick,
      test_poly_normalize
        { phase = p0; ket = [| v 0 |]; path_var = [] }
        { phase = p0; ket = [| v 0 |]; path_var = [] } );
    ( "x0, x0 -> x0, x0",
      `Quick,
      let x0 = v 0 in
      let p_x0 = to_poly (Qubit x0) in
      test_poly_normalize
        { phase = p_x0; ket = [| x0 |]; path_var = [] }
        { phase = p_x0; ket = [| x0 |]; path_var = [] } );
    ( "1/4, 1 -> 1/4, 1",
      `Quick,
      let p = to_poly (Scal div4) in
      test_poly_normalize
        { phase = p; ket = [| Qubit.One |]; path_var = [] }
        { phase = p; ket = [| Qubit.One |]; path_var = [] } );
    ( "1/4 x0, x0 -> 1/4 x0, x0",
      `Quick,
      let x0 = v 0 in
      let p = to_poly (Prod (Scal div4, Qubit x0)) in
      test_poly_normalize
        { phase = p; ket = [| x0 |]; path_var = [] }
        { phase = p; ket = [| x0 |]; path_var = [] } );
    ( "1/2 y0, y0 -> 1/2 y0, y0",
      `Quick,
      let y0 = v 1 in
      let p = to_poly (Monome.Prod (Scal div2, Qubit y0)) in
      test_poly_normalize
        { phase = p; ket = [| y0 |]; path_var = [ 1 ] }
        { phase = p; ket = [| y0 |]; path_var = [ 1 ] } );
    ( "0, |x0,x1> -> 0, |x0,x1>",
      `Quick,
      let x0 = v 1 in
      test_poly_normalize
        { phase = p0; ket = [| x0; x1 |]; path_var = [] }
        { phase = p0; ket = [| x0; x1 |]; path_var = [] } );
    ( "0, |x0,y0> -> 0, |x0,y0>",
      `Quick,
      let x0 = v 0 in
      let y0 = v 2 in
      test_poly_normalize
        { phase = p0; ket = [| x0; y0 |]; path_var = [ 2 ] }
        { phase = p0; ket = [| x0; y0 |]; path_var = [ 2 ] } );
    ( "0, |y0,x0> -> 0, |y0,x0>",
      `Quick,
      let x0 = v 0 in
      let y0 = v 2 in
      test_poly_normalize
        { phase = p0; ket = [| y0; x0 |]; path_var = [ 2 ] }
        { phase = p0; ket = [| y0; x0 |]; path_var = [ 2 ] } );
    ( "0, |y0,y1> -> 0, |y0,y1>",
      `Quick,
      let y0 = v 2 in
      let y1 = v 3 in
      test_poly_normalize
        { phase = p0; ket = [| y0; y1 |]; path_var = [ 2; 3 ] }
        { phase = p0; ket = [| y0; y1 |]; path_var = [ 2; 3 ] } );
    ( "0, |y0,y0> -> 0, |y0,y0>",
      `Quick,
      let y0 = v 2 in
      test_poly_normalize
        { phase = p0; ket = [| y0; y0 |]; path_var = [ 2 ] }
        { phase = p0; ket = [| y0; y0 |]; path_var = [ 2 ] } );
    ( "0, |y1,y0> -> 0, |y1,y0>",
      `Quick,
      let y0 = v 2 in
      let y1 = v 3 in
      test_poly_normalize
        { phase = p0; ket = [| y1; y0 |]; path_var = [ 2; 3 ] }
        { phase = p0; ket = [| y1; y0 |]; path_var = [ 2; 3 ] } );
    ( "1/2 y0, |y1,y0> -> 1/2 y0, |y1,y0>",
      `Quick,
      let y0 = v 2 in
      let y1 = v 3 in
      let p = to_poly (Monome.Prod (Scal div2, Qubit y0)) in
      test_poly_normalize
        { phase = p; ket = [| y1; y0 |]; path_var = [ 2; 3 ] }
        { phase = p; ket = [| y1; y0 |]; path_var = [ 2; 3 ] } );
    ( "1/2 x0y1, |y0,y1> -> 1/2 x0y0, |y1,y0>",
      `Quick,
      let y0 = v 2 in
      let y1 = v 3 in
      let p = to_poly (Monome.Prod (Scal div2, Prod (Qubit x0, Qubit y1))) in
      let p' = to_poly (Monome.Prod (Scal div2, Prod (Qubit x0, Qubit y0))) in
      test_poly_normalize
        { phase = p; ket = [| y0; y1 |]; path_var = [ 2; 3 ] }
        { phase = p'; ket = [| y1; y0 |]; path_var = [ 2; 3 ] } );
    ( "1/2 y1, |y1,y1> -> 1/2 y0, |y0,y0>",
      `Quick,
      let y0 = v 2 in
      let y1 = v 3 in
      let p = to_poly (Monome.Prod (Scal div2, Qubit y1)) in
      let p' = to_poly (Monome.Prod (Scal div2, Qubit y0)) in
      test_poly_normalize
        { phase = p; ket = [| y1; y1 |]; path_var = [ 3 ] }
        { phase = p'; ket = [| y0; y0 |]; path_var = [ 2 ] } );
  ]

let test_monome_to_scalar_monome ?(debug = true) (input : Monome.t)
    (expect : Q.t * Monome.t) () =
  let greet, expect =
    match Monome.monome_to_scalar_monome input with
    | Some (s, m) ->
        if debug then
          printf "Primitives.test_monome_to_scalar_monome, s = %s, m = %s\n"
            (Q.to_string s) (Monome.String.exact m);
        let s', m' = expect in
        if debug then
          printf "Primitives.test_monome_to_scalar_monome, s' = %s, m' = %s\n"
            (Q.to_string s') (Monome.String.exact m');
        let s_eq = Q.equal s s' in
        let m_eq = Monome.equal m m' in
        if debug then
          printf
            "Primitives.test_monome_to_scalar_monome, s_eq = %b, m_eq = %b\n"
            s_eq m_eq;
        (s_eq && m_eq, true)
    | None -> (false, false)
  in
  check bool (sprintf "Primitives.test_monome_to_scalar_monome") expect greet

let monome_to_scalar_monome =
  [
    ( "1/2 x0 -> 1/2, x0",
      `Quick,
      test_monome_to_scalar_monome
        (Monome.Prod (Scal div2, Qubit (Var 0)))
        (div2, Qubit (Var 0)) );
    ( "-1/8 x5 -> -1/8, x0",
      `Quick,
      test_monome_to_scalar_monome
        (Monome.Prod (Scal divm8, Qubit (Var 6)))
        (divm8, Qubit (Var 6)) );
    ( "-1/8 x0x2x3 -> -1/8, x0x2x3",
      `Quick,
      test_monome_to_scalar_monome
        (Monome.Prod
           ( Scal divm8,
             Prod (Qubit (Var 0), Prod (Qubit (Var 2), Qubit (Var 3))) ))
        (divm8, Prod (Qubit (Var 0), Prod (Qubit (Var 2), Qubit (Var 3)))) );
    ( "x0 -> None",
      `Quick,
      test_monome_to_scalar_monome (Qubit (Var 0))
        (Q.of_int 0, Monome.Scal (Q.of_int 0)) );
  ]

let test_lift_poly ?(debug = true) (p : Poly.t) (expect : Poly.t) (wq : int) ()
    =
  if debug then printf "Primitives.test_lift_poly, p = %s\n%!" (PS.pretty p wq);
  if debug then
    printf "Primitives.test_lift_poly, expect = %s\n%!" (PS.pretty expect wq);
  let expect = Poly.simplify expect in
  let greet = Poly.simplify (Poly.lift_poly ~debug (Poly.simplify p)) in
  if debug then
    printf "Primitives.test_lift_poly, greet = %s\n\n%!" (PS.pretty greet wq);
  let greet = Poly.equal greet expect in
  let expect = true in
  check bool (sprintf "Primitives.test_lift_poly") expect greet

let mx0x1 = Monome.Prod (Scal div4, x0x1)

let poly0 s =
  Prod (Scal s, Qubit x0)
  +++ (Prod (Scal s, Qubit x1)
      +++ to_poly (Prod (Scal (Q.mul minus_two s), x0x1)))

let poly0' s = to_poly (Monome.Prod (Scal s, Qubit (SumMod2 (Var 0, Var 1))))

let poly1 s =
  Prod (Scal s, Qubit x0)
  +++ (Prod (Scal s, Qubit x1)
      +++ (Prod (Scal s, Qubit x2)
          +++ (Prod (Scal (Q.mul s minus_two), x0x1)
              +++ (Prod (Scal (Q.mul s minus_two), x1x2)
                  +++ (Prod (Scal (Q.mul s minus_two), x0x2) +++ Poly.empty))))
      )

let poly1' s = to_poly (Monome.Prod (Scal s, Qubit (x0 ++ (x1 ++ x2))))

let poly2 s =
  Poly.insert
    (Prod (Scal s, Qubit x0))
    (Poly.insert (Prod (Scal s, Qubit x1)) (to_poly mx0x1))

let poly2' s = to_poly (Monome.Prod (Scal s, Qubit (SumMod2 (Var 0, Var 1))))

let lift_poly =
  [
    ( "1/2 -> 1/2",
      `Quick,
      let s = div2 in
      test_lift_poly (to_poly (Monome.Scal s)) (to_poly (Scal s)) 1 );
    ( "1/2 0 -> 0",
      `Quick,
      test_lift_poly (to_poly (Monome.Scal Q.zero)) Poly.zero 1 );
    ( "1/2 [0] -> 0",
      `Quick,
      let s = div2 in
      test_lift_poly (to_poly (Prod (Scal s, Qubit Qubit.Zero))) Poly.zero 1 );
    ( "1/2 x0 -> 1/2 x0",
      `Quick,
      let s = div2 in
      test_lift_poly
        (to_poly (Prod (Scal s, Qubit x0)))
        (to_poly (Prod (Scal s, Qubit x0)))
        1 );
    ( "1/2 x0 ++ x1 -> 1/2 x0 + 1/2 x1",
      `Quick,
      let s = div2 in
      test_lift_poly (poly0' s) (poly0 s) 2 );
    ( "-1/8, x0 ++ x1 -> 7/8 x0 + 7/8 x1 + 1/4 x0x1",
      `Quick,
      let s = divm8 in
      test_lift_poly (poly2' s) (poly2 s) 2 );
    ( "1/8, x0 ++ x1x2 -> 1/8 x0 + 1/8 x1x2 - 1/4 x0x1x2",
      `Quick,
      let s = div8 in
      let s' = divm4 in
      let x =
        to_poly
          (Monome.Prod (Scal s, Qubit (SumMod2 (x0, Monome.to_qubit x1x2))))
      in
      test_lift_poly x
        (Poly.insert
           (Prod (Scal s, Qubit x0))
           (Poly.insert
              (Prod (Scal s, x1x2))
              (to_poly (Prod (Scal s', x0x1x2)))))
        3 );
    ( "1/4, x0++x1++x2 -> 1/4x0+1/4x1+1/4x2 -1/2x0x1-1/2x0x2-1/2x1x2",
      `Quick,
      let s = div4 in
      test_lift_poly (poly1' s) (poly1 s) 3 );
    ( "1/8, x0++x1++x2 -> 1/8x0+1/8x1+1/8x2 -1/4x0x1-1/4x0x2-1/4x1x2 +1/2x0x1x2",
      `Quick,
      let s = div8 in
      let x =
        to_poly (Monome.Prod (Scal s, Qubit (SumMod2 (x0, SumMod2 (x1, x2)))))
      in
      test_lift_poly x
        (Prod (Scal s, Qubit x0)
        +++ (Prod (Scal s, Qubit x1)
            +++ (Prod (Scal s, Qubit x2)
                +++ (Prod (Scal (Q.mul s minus_two), x0x1)
                    +++ (Prod (Scal (Q.mul s minus_two), x1x2)
                        +++ (Prod (Scal (Q.mul s minus_two), x0x2)
                            +++ (Prod (Scal (Q.mul s four), x0x1x2)
                                +++ Poly.empty)))))))
        3 );
    ( "1/4 lift (p1 + p1) = 1/4 lift p1 + 1/4 lift p1",
      `Quick,
      let s = div4 in
      test_lift_poly
        (Poly.merge (poly1' s) (poly1' s))
        (Poly.merge (poly1 s) (poly1 s))
        3 );
    ( "1/4 lift (p0 + p0) = 1/4 lift p0 + 1/4 lift p0",
      `Quick,
      let s = div4 in
      test_lift_poly
        (Poly.merge (poly0' s) (poly0' s))
        (Poly.merge (poly0 s) (poly0 s))
        3 );
    ( "1/8 lift (p0 + p0) = 1/8 lift p0 + 1/8 lift p0",
      `Quick,
      let s = div8 in
      let p = Poly.merge (poly0' s) (poly0' s) in
      let expect = Poly.merge (poly0 s) (poly0 s) in
      test_lift_poly p expect 3 );
    ( "lift (1/2p0 + 1/4p0 + 1/8p0) = 1/2 lift p0 + 1/4 lift p0 + 18 lift p0",
      `Quick,
      let s0 = div2 in
      let s1 = div4 in
      let s2 = divm8 in
      let p = Poly.merge (poly0' s0) (Poly.merge (poly0' s1) (poly0' s2)) in
      let expect = Poly.merge (poly0 s0) (Poly.merge (poly0 s1) (poly0 s2)) in
      test_lift_poly p expect 3 );
  ]

let test_lift_monome ?(debug = true) (m : Monome.t) (expect : Poly.t) (wq : int)
    () =
  if debug then
    printf "Primitives.test_lift_monome, m = %s\n%!" (Monome.String.pretty m wq);
  let expect = Poly.simplify expect in
  if debug then
    printf "Primitives.test_lift_monome, expect = %s\n%!"
      (Poly.String.pretty expect wq);
  let greet = Poly.lift_monome ~debug m in
  if debug then
    printf "Primitives.test_lift_monome, greet = %s\n\n%!"
      (Poly.String.pretty greet wq);
  let greet = Poly.equal greet expect in
  let expect = true in
  check bool (sprintf "Primitives.test_lift_monome") expect greet

let lift_monome =
  [
    ( "1/2 -> 1/2",
      `Quick,
      let s = div2 in
      test_lift_monome (Monome.Scal s) (to_poly (Scal s)) 1 );
    ("1/2 0 -> 0", `Quick, test_lift_monome (Monome.Scal Q.zero) Poly.zero 1);
    ( "1/2 [0] -> 0",
      `Quick,
      let s = div2 in
      test_lift_monome (Prod (Scal s, Qubit Qubit.Zero)) Poly.zero 1 );
    ( "1/2 x0 -> 1/2 x0",
      `Quick,
      let s = div2 in
      test_lift_monome
        (Prod (Scal s, Qubit x0))
        (to_poly (Prod (Scal s, Qubit x0)))
        1 );
    ( "1/2 x0 ++ x1 -> 1/2 x0 + 1/2 x1",
      `Quick,
      let s = div2 in
      let x = Monome.Prod (Scal s, Qubit (SumMod2 (Var 0, Var 1))) in
      test_lift_monome x
        (Poly.insert
           (Prod (Scal s, Qubit x0))
           (to_poly (Prod (Scal s, Qubit x1))))
        2 );
    ( "-1/8, x0 ++ x1 -> 7/8 x0 + 7/8 x1 + 1/4 x0x1",
      `Quick,
      let s = divm8 in
      let x = Monome.Prod (Scal s, Qubit (SumMod2 (Var 0, Var 1))) in
      let mx0x1 = Monome.Prod (Scal div4, x0x1) in
      test_lift_monome x
        (Poly.insert
           (Prod (Scal s, Qubit x0))
           (Poly.insert (Prod (Scal s, Qubit x1)) (to_poly mx0x1)))
        2 );
    ( "1/8, x0 ++ x1x2 -> 1/8 x0 + 1/8 x1x2 - 1/4 x0x1x2",
      `Quick,
      let s = div8 in
      let s' = divm4 in
      let x =
        Monome.Prod (Scal s, Qubit (SumMod2 (x0, Monome.to_qubit x1x2)))
      in
      test_lift_monome x
        (Poly.insert
           (Prod (Scal s, Qubit x0))
           (Poly.insert
              (Prod (Scal s, x1x2))
              (to_poly (Prod (Scal s', x0x1x2)))))
        3 );
    ( "1/4, x0++x1++x2 -> 1/4x0+1/4x1+1/4x2 -1/2x0x1-1/2x0x2-1/2x1x2",
      `Quick,
      let s = div4 in
      let x = Monome.Prod (Scal s, Qubit (SumMod2 (x0, SumMod2 (x1, x2)))) in
      test_lift_monome x
        (Prod (Scal s, Qubit x0)
        +++ (Prod (Scal s, Qubit x1)
            +++ (Prod (Scal s, Qubit x2)
                +++ (Prod (Scal (Q.mul s minus_two), x0x1)
                    +++ (Prod (Scal (Q.mul s minus_two), x1x2)
                        +++ (Prod (Scal (Q.mul s minus_two), x0x2)
                            +++ Poly.empty))))))
        3 );
    ( "1/8, x0++x1++x2 -> 1/8x0+1/8x1+1/8x2 -1/4x0x1-1/4x0x2-1/4x1x2 +1/2x0x1x2",
      `Quick,
      let s = div8 in
      let x = Monome.Prod (Scal s, Qubit (SumMod2 (x0, SumMod2 (x1, x2)))) in
      test_lift_monome x
        (Prod (Scal s, Qubit x0)
        +++ (Prod (Scal s, Qubit x1)
            +++ (Prod (Scal s, Qubit x2)
                +++ (Prod (Scal (Q.mul s minus_two), x0x1)
                    +++ (Prod (Scal (Q.mul s minus_two), x1x2)
                        +++ (Prod (Scal (Q.mul s minus_two), x0x2)
                            +++ (Prod (Scal (Q.mul s four), x0x1x2)
                                +++ Poly.empty)))))))
        3 );
  ]

let test_lift_qubit ?(debug = true) (s : Q.t) (m : Monome.t) (expect : Poly.t)
    (wq : int) () =
  if debug then
    printf "Primitives.test_lift_qubit, m = %s\n%!" (Monome.String.pretty m wq);
  let expect = Poly.simplify expect in
  if debug then
    printf "Primitives.test_lift_qubit, expect = %s\n%!"
      (Poly.String.pretty expect wq);
  let greet = Poly.lift_qubit ~debug s m in
  if debug then
    printf "Primitives.test_lift_qubit, greet = %s\n\n%!"
      (Poly.String.pretty greet wq);
  let greet = Poly.equal greet expect in
  let expect = true in
  check bool (sprintf "Primitives.test_lift_qubit") expect greet

let lift_qubit =
  [
    ( "1/2, 1 -> 1/2",
      `Quick,
      let s = div2 in
      test_lift_qubit s (Qubit Qubit.One) (to_poly (Scal s)) 1 );
    ( "1/2, 0 -> 0",
      `Quick,
      let s = div2 in
      test_lift_qubit s (Qubit Qubit.Zero) Poly.zero 1 );
    ( "1/2, x0 -> 1/2 x0",
      `Quick,
      let s = div2 in
      test_lift_qubit s (Qubit x0) (to_poly (Prod (Scal s, Qubit x0))) 1 );
    ( "1/2, x0 ++ x1 -> 1/2 x0 + 1/2 x1",
      `Quick,
      let s = div2 in
      let x = Monome.Qubit (SumMod2 (Var 0, Var 1)) in
      test_lift_qubit s x
        (Poly.insert
           (Prod (Scal s, Qubit x0))
           (to_poly (Prod (Scal s, Qubit x1))))
        2 );
    ( "-1/8, x0 ++ x1 -> 7/8 x0 + 7/8 x1 + 1/4 x0x1",
      `Quick,
      let s = divm8 in
      let x = Monome.Qubit (SumMod2 (Var 0, Var 1)) in
      let mx0x1 = Monome.Prod (Scal div4, x0x1) in
      test_lift_qubit s x
        (Poly.insert
           (Prod (Scal s, Qubit x0))
           (Poly.insert (Prod (Scal s, Qubit x1)) (to_poly mx0x1)))
        2 );
    ( "1/8, x0 ++ x1x2 -> 1/8 x0 + 1/8 x1x2 - 1/4 x0x1x2",
      `Quick,
      let s = div8 in
      let s' = divm4 in
      let x = Qubit.SumMod2 (x0, Monome.to_qubit x1x2) in
      test_lift_qubit s (Qubit x)
        (Poly.insert
           (Prod (Scal s, Qubit x0))
           (Poly.insert
              (Prod (Scal s, x1x2))
              (to_poly (Prod (Scal s', x0x1x2)))))
        3 );
    ( "1/4, x0++x1++x2 -> 1/4x0+1/4x1+1/4x2 -1/2x0x1-1/2x0x2-1/2x1x2",
      `Quick,
      let s = div4 in
      let x = Qubit.SumMod2 (x0, SumMod2 (x1, x2)) in
      test_lift_qubit s (Qubit x)
        (Prod (Scal s, Qubit x0)
        +++ (Prod (Scal s, Qubit x1)
            +++ (Prod (Scal s, Qubit x2)
                +++ (Prod (Scal (Q.mul s minus_two), x0x1)
                    +++ (Prod (Scal (Q.mul s minus_two), x1x2)
                        +++ (Prod (Scal (Q.mul s minus_two), x0x2)
                            +++ Poly.empty))))))
        3 );
    ( "1/8, x0++x1++x2 -> 1/8x0+1/8x1+1/8x2 -1/4x0x1-1/4x0x2-1/4x1x2 +1/2x0x1x2",
      `Quick,
      let s = div8 in
      let x = Qubit.SumMod2 (x0, SumMod2 (x1, x2)) in
      test_lift_qubit s (Qubit x)
        (Prod (Scal s, Qubit x0)
        +++ (Prod (Scal s, Qubit x1)
            +++ (Prod (Scal s, Qubit x2)
                +++ (Prod (Scal (Q.mul s minus_two), x0x1)
                    +++ (Prod (Scal (Q.mul s minus_two), x1x2)
                        +++ (Prod (Scal (Q.mul s minus_two), x0x2)
                            +++ (Prod (Scal (Q.mul s four), x0x1x2)
                                +++ Poly.empty)))))))
        3 );
  ]

(* phase = x0y0 + x0y1, ket = |y0 + y1> *)
(* phase[y0 <- y0 + y1] = x0y0, ket[y0 <- y0 + y1] = |y0> *)
let test_variable_replacement_factorisation ?(debug = true) (input : Path_sum.t)
    (expect : Path_sum.t) () =
  if debug then
    printf "Test.test_variable_replacement_factorisation, input =\n%s\n\n"
      (PSS.pretty input);
  let greet_repl =
    Rules.Variable_replacement.variable_replacement_factorisation input
  in
  if debug then
    printf "Test.test_variable_replacement_factorisation, greet_repl =\n%s\n\n"
      (PSS.pretty greet_repl);
  let greet = Rules.Simplification.simplify greet_repl in
  if debug then
    printf "Test.test_variable_replacement_factorisation, greet =\n%s\n\n"
      (PSS.pretty greet);
  let expect = Rules.Simplification.simplify expect in
  if debug then
    printf "Test.test_variable_replacement_factorisation, expect =\n%s\n\n"
      (PSS.pretty expect);
  let greeting = greet = expect in
  let expected = true in
  check bool
    (sprintf "test_variable_replacement_factorisation")
    expected greeting

let variable_replacement_factorisation =
  [
    ( "|x0> -> |x0>",
      `Quick,
      test_variable_replacement_factorisation
        { phase = to_poly (Scal Q.zero); ket = [| Var 0 |]; path_var = [] }
        { phase = to_poly (Scal Q.zero); ket = [| Var 0 |]; path_var = [] } );
    ( "|x0+x1> -> |x0+x1>",
      `Quick,
      test_variable_replacement_factorisation
        {
          phase = to_poly (Scal Q.zero);
          ket = [| Var 0; Var 1 |];
          path_var = [];
        }
        {
          phase = to_poly (Scal Q.zero);
          ket = [| Var 0; Var 1 |];
          path_var = [];
        } );
    ( "|y0> -> |y0>",
      `Quick,
      test_variable_replacement_factorisation
        { phase = to_poly (Scal Q.zero); ket = [| Var 1 |]; path_var = [ 1 ] }
        { phase = to_poly (Scal Q.zero); ket = [| Var 1 |]; path_var = [ 1 ] }
    );
    ( "|0> -> |0>",
      `Quick,
      test_variable_replacement_factorisation
        { phase = to_poly (Scal Q.zero); ket = [| Qubit.Zero |]; path_var = [] }
        { phase = to_poly (Scal Q.zero); ket = [| Qubit.Zero |]; path_var = [] }
    );
    ( "|1> -> |1>",
      `Quick,
      test_variable_replacement_factorisation
        { phase = to_poly (Scal Q.zero); ket = [| Qubit.One |]; path_var = [] }
        { phase = to_poly (Scal Q.zero); ket = [| Qubit.One |]; path_var = [] }
    );
    ( "|1+x0> -> |1+x0>",
      `Quick,
      test_variable_replacement_factorisation
        { phase = to_poly (Scal Q.zero); ket = [| one ++ x0 |]; path_var = [] }
        { phase = to_poly (Scal Q.zero); ket = [| one ++ x0 |]; path_var = [] }
    );
    ( "|0+x0> -> |x0>",
      `Quick,
      test_variable_replacement_factorisation
        { phase = to_poly (Scal Q.zero); ket = [| zero ++ x0 |]; path_var = [] }
        { phase = to_poly (Scal Q.zero); ket = [| x0 |]; path_var = [] } );
    ( "|0+y0> -> |y1>",
      `Quick,
      test_variable_replacement_factorisation
        {
          phase = to_poly (Scal Q.zero);
          ket = [| zero ++ Var 1 |];
          path_var = [ 1 ];
        }
        { phase = to_poly (Scal Q.zero); ket = [| Var 1 |]; path_var = [ 1 ] }
    );
    ( "|1+y0,y0> -> |1+y0,y0>",
      `Quick,
      test_variable_replacement_factorisation
        {
          phase = to_poly (Scal Q.zero);
          ket = [| one ++ Var 2; Var 2 |];
          path_var = [ 2 ];
        }
        {
          phase = to_poly (Scal Q.zero);
          ket = [| one ++ Var 2; Var 2 |];
          path_var = [ 2 ];
        } );
    ( "|x0+y0+y1,y0,y1> -> |x0+y0+y1,y0,y1>",
      `Quick,
      test_variable_replacement_factorisation
        {
          phase = to_poly (Scal Q.zero);
          ket = [| x0 ++ Var 3 ++ Var 4; Var 3; Var 4 |];
          path_var = [ 3; 4 ];
        }
        {
          phase = to_poly (Scal Q.zero);
          ket = [| x0 ++ Var 3 ++ Var 4; Var 3; Var 4 |];
          path_var = [ 3; 4 ];
        } );
    ( "|x0+y0+y1> -> |x0+y0+y1>",
      `Quick,
      test_variable_replacement_factorisation
        {
          phase = to_poly (Scal Q.zero);
          ket = [| x0 ++ Var 1 ++ Var 2 |];
          path_var = [ 1; 2 ];
        }
        {
          phase = to_poly (Scal Q.zero);
          ket = [| x0 ++ Var 1 ++ Var 2 |];
          path_var = [ 1; 2 ];
        } );
    ( "1/2 x0y0 + 1/2 x0y1 |x0+y0+y1> -> 1/2 x0y0 |x0+y0>",
      `Quick,
      let p =
        Prod (Scal div2, Prod (Qubit x0, Qubit (v 1)))
        +++ to_poly (Prod (Scal div2, Prod (Qubit x0, Qubit (v 2))))
      in
      let p' = to_poly (Prod (Scal div2, Prod (Qubit x0, Qubit (v 1)))) in
      let ps : Path_sum.t =
        { phase = p; ket = [| x0 ++ Var 1 ++ Var 2 |]; path_var = [ 1; 2 ] }
      in
      let ps' : Path_sum.t =
        { phase = p'; ket = [| x0 ++ Var 1 |]; path_var = [ 1 ] }
      in
      test_variable_replacement_factorisation ps ps' );
    ( "1/2 x0y0 + 1/2 x0y1 |x0+y0+y1> -> 1/2 x0y0 |x0+y0>",
      `Quick,
      let p =
        Prod (Scal div2, Prod (Qubit x0, Qubit (v 1)))
        +++ to_poly (Prod (Scal div2, Prod (Qubit x0, Qubit (v 2))))
      in
      let p' = to_poly (Prod (Scal div2, Prod (Qubit x0, Qubit (v 1)))) in
      let ps : Path_sum.t =
        { phase = p; ket = [| x0 ++ Var 1 ++ Var 2 |]; path_var = [ 1; 2 ] }
      in
      let ps' : Path_sum.t =
        { phase = p'; ket = [| x0 ++ Var 1 |]; path_var = [ 1 ] }
      in
      test_variable_replacement_factorisation ps ps' );
    ( "1/4 x0y0 + 1/4 x0y1 |x0+y0+y1> -> 1/4 x0y0 + 1/4 x0y1 |x0+y0+y1>",
      `Quick,
      let p =
        Prod (Scal div4, Prod (Qubit x0, Qubit (v 1)))
        +++ to_poly (Prod (Scal div4, Prod (Qubit x0, Qubit (v 2))))
      in
      let ps : Path_sum.t =
        { phase = p; ket = [| x0 ++ Var 1 ++ Var 2 |]; path_var = [ 1; 2 ] }
      in
      test_variable_replacement_factorisation ps ps );
  ]

let test_variable_replacement ?(debug = true) (input : Path_sum.t)
    (expect : Path_sum.t) () =
  if debug then
    printf "Test.test_variable_replacement, input =\n%s\n\n" (PSS.pretty input);
  let greet_repl =
    match Rules.Variable_replacement.variable_replacement ~debug input with
    | Some ps -> ps
    | None -> input
  in
  if debug then
    printf "Test.test_variable_replacement, greet_repl =\n%s%!\n\n"
      (PSS.pretty greet_repl);
  let greet =
    Rules.Simplification.simplify greet_repl
    (* (Rules.Rename.normalise_path_var ~debug greet_repl) *)
  in
  if debug then
    printf "Test.test_variable_replacement, greet =\n%s%!\n\n"
      (PSS.pretty greet);
  let expect = Rules.Simplification.simplify expect in
  if debug then
    printf "Test.test_variable_replacement, expect =\n%s%!\n\n"
      (PSS.pretty expect);
  let greeting = greet = expect in
  let expected = true in
  check bool (sprintf "test_variable_replacement") expected greeting

let v i = Qubit.Var i
let mdiv s = Monome.Scal s

(* TODO : restore variable replacement without reordening *)

let variable_replacement =
  [
    ( "|x0> -> |x0>",
      `Quick,
      test_variable_replacement
        { phase = to_poly (Scal Q.zero); ket = [| Var 0 |]; path_var = [] }
        { phase = to_poly (Scal Q.zero); ket = [| Var 0 |]; path_var = [] } );
    ( "|x0+x1> -> |x0+x1>",
      `Quick,
      test_variable_replacement
        {
          phase = to_poly (Scal Q.zero);
          ket = [| Var 0; Var 1 |];
          path_var = [];
        }
        {
          phase = to_poly (Scal Q.zero);
          ket = [| Var 0; Var 1 |];
          path_var = [];
        } );
    ( "|y0> -> |y0>",
      `Quick,
      test_variable_replacement
        { phase = to_poly (Scal Q.zero); ket = [| Var 1 |]; path_var = [ 1 ] }
        { phase = to_poly (Scal Q.zero); ket = [| Var 1 |]; path_var = [ 1 ] }
    );
    ( "|0> -> |0>",
      `Quick,
      test_variable_replacement
        { phase = to_poly (Scal Q.zero); ket = [| Qubit.Zero |]; path_var = [] }
        { phase = to_poly (Scal Q.zero); ket = [| Qubit.Zero |]; path_var = [] }
    );
    ( "|1> -> |1>",
      `Quick,
      test_variable_replacement
        { phase = to_poly (Scal Q.zero); ket = [| Qubit.One |]; path_var = [] }
        { phase = to_poly (Scal Q.zero); ket = [| Qubit.One |]; path_var = [] }
    );
    ( "|1+x0> -> |1+x0>",
      `Quick,
      test_variable_replacement
        { phase = to_poly (Scal Q.zero); ket = [| one ++ x0 |]; path_var = [] }
        { phase = to_poly (Scal Q.zero); ket = [| one ++ x0 |]; path_var = [] }
    );
    ( "|1+y0> -> |y0>",
      `Quick,
      test_variable_replacement
        { phase = Poly.zero; ket = [| one ++ Var 1 |]; path_var = [ 1 ] }
        { phase = Poly.zero; ket = [| Var 1 |]; path_var = [ 1 ] } );
    ( "|1+y0>,y0 -> |y0>,1+y0",
      `Quick,
      test_variable_replacement
        {
          phase = to_poly (Qubit (v 1));
          ket = [| one ++ v 1 |];
          path_var = [ 1 ];
        }
        {
          phase = Scal Q.one +++ to_poly (Qubit (v 1));
          ket = [| v 1 |];
          path_var = [ 1 ];
        } );
    ( "|1+y0>,y0/2 -> |y0>,1/2 + y0/2",
      `Quick,
      test_variable_replacement
        {
          phase = to_poly (Prod (mdiv two, Qubit (v 1)));
          ket = [| one ++ v 1 |];
          path_var = [ 1 ];
        }
        {
          phase = mdiv two +++ to_poly (Prod (mdiv two, Qubit (v 1)));
          ket = [| v 1 |];
          path_var = [ 1 ];
        } );
    ( "|0+x0> -> |x0>",
      `Quick,
      test_variable_replacement
        { phase = to_poly (Scal Q.zero); ket = [| zero ++ x0 |]; path_var = [] }
        { phase = to_poly (Scal Q.zero); ket = [| x0 |]; path_var = [] } );
    ( "|0+y0> -> |y0>",
      `Quick,
      test_variable_replacement
        {
          phase = to_poly (Scal Q.zero);
          ket = [| zero ++ v 1 |];
          path_var = [ 1 ];
        }
        { phase = to_poly (Scal Q.zero); ket = [| v 1 |]; path_var = [ 1 ] } );
    ( "|1+y0,y0> -> |1+y0,y0>",
      `Quick,
      test_variable_replacement
        {
          phase = to_poly (Scal Q.zero);
          ket = [| one ++ Var 2; Var 2 |];
          path_var = [ 2 ];
        }
        {
          phase = to_poly (Scal Q.zero);
          ket = [| one ++ Var 2; Var 2 |];
          path_var = [ 2 ];
        } );
    (* ( "|1+y0,y1> -> |y0,y1>",
      `Quick,
      test_variable_replacement
        {
          phase = to_poly (Scal Q.zero);
          ket = [| one ++ Var 2; Var 3 |];
          path_var = [ 2; 3 ];
        }
        {
          phase = to_poly (Scal Q.zero);
          ket = [| Var 2; Var 3 |];
          path_var = [ 2; 3 ];
        } ); *)
    (* ( "|x0+y0,y1> -> |x0+y0,y1>",
      `Quick,
      test_variable_replacement
        {
          phase = to_poly (Scal Q.zero);
          ket = [| x0 ++ v 2; v 3 |];
          path_var = [ 2; 3 ];
        }
        {
          phase = to_poly (Scal Q.zero);
          ket = [| v 2; v 3 |];
          path_var = [ 2; 3 ];
        } ); *)
    ( "1/4 y0, |x0+y0,y1> -> 1/4 y0, |x0+y0,y1>",
      `Quick,
      let p = to_poly (Prod (Scal div4, Qubit (v 2))) in
      let ps : Path_sum.t =
        { phase = p; ket = [| x0 ++ v 2; v 3 |]; path_var = [ 2; 3 ] }
      in
      test_variable_replacement ps ps );
    ( "1/4 y0, |x0+y0, y0+y1> -> 1/4 y0, |x0+y0, y1>",
      `Quick,
      let p = to_poly (Prod (Scal div4, Qubit (v 2))) in
      let ps : Path_sum.t =
        { phase = p; ket = [| x0 ++ v 2; v 2 ++ v 3 |]; path_var = [ 2; 3 ] }
      in
      let ps' : Path_sum.t =
        { phase = p; ket = [| x0 ++ v 2; v 3 |]; path_var = [ 2; 3 ] }
      in
      test_variable_replacement ps ps' );
    ( "1/4 x0, |x0+y0, y0+y1> -> 1/4 x0, |x0+y0, y0+y1>",
      `Quick,
      let p = to_poly (Prod (Scal div4, Qubit (v 0))) in
      let ps : Path_sum.t =
        { phase = p; ket = [| x0 ++ v 2; v 2 ++ v 3 |]; path_var = [ 2; 3 ] }
      in
      let ps' : Path_sum.t =
        { phase = p; ket = [| x0 ++ v 2; v 3 |]; path_var = [ 2; 3 ] }
      in
      test_variable_replacement ps ps' );
    (* ( "|x0+y0+y1,y1> -> |y0,y1>",
      `Quick,
      test_variable_replacement
        {
          phase = to_poly (Scal Q.zero);
          ket = [| x0 ++ Var 2 ++ Var 3; Var 3 |];
          path_var = [ 2; 3 ];
        }
        {
          phase = to_poly (Scal Q.zero);
          ket = [| Var 2; Var 3 |];
          path_var = [ 2; 3 ];
        } ); *)
    ( "|x0+y0+y1,y0,y1> -> |x0+y0+y1,y0,y1>",
      `Quick,
      let ps : Path_sum.t =
        {
          phase = to_poly (Scal Q.zero);
          ket = [| x0 ++ Var 3 ++ Var 4; Var 3; Var 4 |];
          path_var = [ 3; 4 ];
        }
      in
      test_variable_replacement ps ps );
    ( "|x0+y0+y1> -> |x0+y0+y1>",
      `Quick,
      let ps : Path_sum.t =
        {
          phase = to_poly (Scal Q.zero);
          ket = [| x0 ++ Var 1 ++ Var 2 |];
          path_var = [ 1; 2 ];
        }
      in
      test_variable_replacement ps ps );
  ]

(* let ( ++ ) (m : monome) (p : poly) : poly = Poly.insert m p *)

let test_find_update_pvs (ps : Path_sum.t) update_pvs () =
  let greet =
    Rules.Rename._string_update_pvs (Rules.Rename._find_update_path_var ps)
  in
  let expect = Rules.Rename._string_update_pvs update_pvs in
  let greeting = greet in
  let expected = expect in
  check string (sprintf "generate update pvs ok") expected greeting

let test_path_var_substitute (pvs_input : int list) update pvs_expect () =
  let pvs_greet = Rules.Rename._path_var_substitute pvs_input update in
  let greet = pvs_greet = pvs_expect in
  let greeting = greet in
  let expected = true in
  check bool
    (sprintf
       "Test.test_path_var_substitute,\npvs_greet =\n%s\npvs_expect =\n%s\n"
       (ListBis.string_int pvs_greet)
       (ListBis.string_int pvs_expect))
    expected greeting

let test_substitute_path_var (ps : Path_sum.t) ps_expect () =
  let ps_input = ps in
  let update_pvs = Rules.Rename._find_update_path_var ps_input in
  let ps_greet = Rules.Rename._substitute_path_var ps_input update_pvs in
  let greet = ps_greet = ps_expect in
  let greeting = greet in
  let expected = true in
  check bool
    (sprintf "Test.test_substitute_path_var,\nps_greet =\n%s\nps_expect =\n%s\n"
       (PSS.pretty ps_greet) (PSS.pretty ps_expect))
    expected greeting

let update_pvs =
  [
    ( "find_pvs ps1",
      `Quick,
      test_find_update_pvs
        { phase = to_poly (Scal Q.zero); ket = [| Var 0 |]; path_var = [ 1 ] }
        [ (1, 1) ] );
    ( "find_pvs ps2",
      `Quick,
      test_find_update_pvs
        {
          phase = to_poly (Scal Q.zero);
          ket = [| Var 0 |];
          path_var = [ 1; 2 ];
        }
        [ (1, 1); (2, 2) ] );
    ( "find_pvs ps3",
      `Quick,
      test_find_update_pvs
        {
          phase = to_poly (Scal Q.zero);
          ket = [| Var 0 |];
          path_var = [ 1; 3 ];
        }
        [ (1, 1); (3, 2) ] );
    ( "find_pvs ps4",
      `Quick,
      test_find_update_pvs
        {
          phase = to_poly (Scal Q.zero);
          ket = [| Var 0 |];
          path_var = [ 1; 5; 10; 15 ];
        }
        [ (1, 1); (5, 2); (10, 3); (15, 4) ] );
    ( "find_pvs ps5",
      `Quick,
      test_find_update_pvs
        {
          phase = to_poly (Scal Q.zero);
          ket = [| Var 0; Var 4; Var 10; Var 2 |];
          path_var = [ 4; 10 ];
        }
        [ (4, 4); (10, 5) ] );
    ( "pvs_subst pvs1",
      `Quick,
      test_path_var_substitute [ 4; 10 ] [ (4, 2) ] [ 2; 10 ] );
    ( "pvs_subst pvs1",
      `Quick,
      test_path_var_substitute [ 4; 10 ] [ (10, 5) ] [ 4; 5 ] );
    ( "subst_pv ps1",
      `Quick,
      test_substitute_path_var
        {
          phase = to_poly (Scal Q.zero);
          ket = [| Var 0; Var 4; Var 10; Var 2 |];
          path_var = [ 4; 10 ];
        }
        {
          phase = to_poly (Scal Q.zero);
          ket = [| Var 0; Var 4; Var 5; Var 2 |];
          path_var = [ 4; 5 ];
        } );
  ]

let test_qubit q1 q2 () =
  let greeting = QS.exact q1 in
  let expected = QS.exact q2 in
  check string "same string" expected greeting

let qubit =
  [
    ( "simplify: x0.(1 ++ x0) -> Zero",
      `Quick,
      test_qubit (Qubit.simplify (Prod (Var 0, One ++ Var 0))) Zero );
    ( "simplify: (x0.(1 ++ x0) ++ x1.x0) -> x0.x1",
      `Quick,
      test_qubit
        (Qubit.simplify
           (SumMod2 (Prod (Var 0, One ++ Var 0), Prod (Var 1, Var 0))))
        (Prod (Var 0, Var 1)) );
    ( "simplify: (x0.(1 ++ x0) ++ x1.One) -> x1",
      `Quick,
      test_qubit
        (Qubit.simplify
           (SumMod2 (Prod (Var 5, One ++ Var 5), Prod (Var 2, One))))
        (Var 2) );
  ]

let test_ket k1 k2 () =
  let greeting = KS.exact k1 in
  let expected = KS.exact k2 in
  check string "same string" expected greeting

let k1 =
  [|
    Qubit.Var 0;
    SumMod2
      ( Prod (Prod (Var 0, Var 1), Var 2),
        SumMod2 (Prod (Prod (Var 0, Var 1), Var 2), Var 2) );
    Var 3;
  |]

let k1_simplified = Ket.simplify k1
let k2 = [| Qubit.Var 0; Var 2; Var 3 |]

let k3 =
  [|
    Qubit.Var 0;
    SumMod2
      ( Prod (Var 0, Prod (Var 1, Var 2)),
        SumMod2 (Prod (Prod (Var 1, Var 2), Var 0), Var 2) );
    Var 3;
  |]

let k3_simplified = Ket.simplify k3
let k4 = [| Qubit.Var 0; Var 2; Var 3 |]

let ket =
  [
    ("(x0.x1 ++ (x0.x1 ++ x2) -> x2", `Quick, test_ket k1_simplified k2);
    ("(x0.x1.x2 ++ (x1.x2.x0 ++ x3) -> x3", `Quick, test_ket k3_simplified k4);
    ( "(x0,(x0.(1 ++ x0) ++ x1.One) -> x1",
      `Quick,
      test_ket
        (Ket.simplify
           [| Var 0; SumMod2 (Prod (Var 5, One ++ Var 5), Prod (Var 2, One)) |])
        [| Var 0; Var 2 |] );
    ( "(x0,(x0.(1 ++ x0) ++ x1.x2) -> x1",
      `Quick,
      test_ket
        (Ket.simplify
           [|
             Var 0; SumMod2 (Prod (Var 5, One ++ Var 5), Prod (Var 2, Var 3));
           |])
        [| Var 0; Prod (Var 2, Var 3) |] );
  ]

let test_gates_apply ?(debug = true) (p : Program.t) (ps : Path_sum.t) () =
  let greeting =
    printf "Test.test_gates_apply, ps =\n%s\n\n" (PSS.pretty ps);
    printf "Test.test_gates_apply, p =\n%s\n\n" (ProgS.pretty p);

    let ps_exe = Program.execution p in
    if debug then
      printf "Test.test_apply_gates, ps_exe =\n%s\n\n" (PSS.pretty ps_exe);
    let ps_greet = reduction ~debug ps_exe in
    if debug then
      printf "Test.test_apply_gates, ps_greet =\n%s\n\n" (PSS.pretty ps_greet);
    let ps_expect = reduction ~debug ps in
    printf "\nTest.test_gates_apply, ps_expect =\n%s\n\n" (PSS.pretty ps_expect);
    Path_sum.equal ~debug ps_greet ps_expect
  in
  let expected = true in
  check bool
    (sprintf "Test.test_gates_apply\np = %s\n" (ProgS.pretty p))
    expected greeting

let gates_apply =
  [
    ("id", `Quick, test_gates_apply id (Path_sum.ofSize 0));
    ("h", `Quick, test_gates_apply (h 0) (Path_sum_library.h 0 1));
    ("x", `Quick, test_gates_apply (x 0) (Path_sum_library.x 0 1));
    ("z", `Quick, test_gates_apply (zz 0) (Path_sum_library.z 0 1));
    ("s", `Quick, test_gates_apply (ss 0) (Path_sum_library.s 0 1));
    ("t", `Quick, test_gates_apply (tt 0) (Path_sum_library.t 0 1));
    ("zinv", `Quick, test_gates_apply (zinv 0) (Path_sum_library.zinv 0 1));
    ("sinv", `Quick, test_gates_apply (sinv 0) (Path_sum_library.sinv 0 1));
    ("tinv", `Quick, test_gates_apply (tinv 0) (Path_sum_library.tinv 0 1));
    ("u1 4", `Quick, test_gates_apply (u1 0 0) (Path_sum_library.u1 0 0 1));
    ( "u1 -1",
      `Quick,
      test_gates_apply (u1 ~s:(-1) 1 0) (Path_sum_library.u1 ~s:(-1) 1 0 1) );
    ( "u1 -2",
      `Quick,
      test_gates_apply (u1 ~s:(-1) 2 0) (Path_sum_library.u1 ~s:(-1) 2 0 1) );
    ( "u1 -3 2",
      `Quick,
      test_gates_apply (u1 ~s:(-3) 2 0) (Path_sum_library.u1 ~s:(-3) 2 0 1) );
    ("u1 4", `Quick, test_gates_apply (u1 4 0) (Path_sum_library.u1 4 0 1));
    ("rz 0", `Quick, test_gates_apply (rz 0 0) (Path_sum_library.rz 0 0 1));
    ("rz 4", `Quick, test_gates_apply (rz 4 0) (Path_sum_library.rz 4 0 1));
    ( "rz (-4)",
      `Quick,
      test_gates_apply (rz ~s:(-1) 4 0) (Path_sum_library.rz ~s:(-1) 4 0 1) );
    ("rx 0", `Quick, test_gates_apply (rx 0 0) (Path_sum_library.rx 0 0 1));
    ("rx 1", `Quick, test_gates_apply (rx 1 0) (Path_sum_library.rx 1 0 1));
    ("rx 5", `Quick, test_gates_apply (rx 5 0) (Path_sum_library.rx 5 0 1));
    ( "rx (-5)",
      `Quick,
      test_gates_apply (rx ~s:(-1) 5 0) (Path_sum_library.rx ~s:(-1) 5 0 1) );
    ( "rx (-2,3)",
      `Quick,
      test_gates_apply (rx ~s:(-2) 3 0) (Path_sum_library.rx ~s:(-2) 3 0 1) );
    ("ry 0", `Quick, test_gates_apply (ry 0 0) (Path_sum_library.ry 0 0 1));
    ("ry 1", `Quick, test_gates_apply (ry 1 0) (Path_sum_library.ry 1 0 1));
    ("ry 5", `Quick, test_gates_apply (ry 5 0) (Path_sum_library.ry 5 0 1));
    ( "ry -5",
      `Quick,
      test_gates_apply (ry ~s:(-1) 5 0) (Path_sum_library.ry ~s:(-1) 5 0 1) );
    ( "ry -3/5",
      `Quick,
      test_gates_apply (ry ~s:(-3) 5 0) (Path_sum_library.ry ~s:(-3) 5 0 1) );
    ("ch", `Quick, test_gates_apply (ch 0 1) (Path_sum_library.ch 0 1 2));
    ("cx", `Quick, test_gates_apply (cx 0 1) (Path_sum_library.cx 0 1 2));
    ("cz", `Quick, test_gates_apply (cz 0 1) (Path_sum_library.cz 0 1 2));
    ("cs", `Quick, test_gates_apply (cs 0 1) (Path_sum_library.cs 0 1 2));
    ("ct", `Quick, test_gates_apply (ct 0 1) (Path_sum_library.ct 0 1 2));
    ("ccx", `Quick, test_gates_apply (ccx 0 1 2) (Path_sum_library.ccx 0 1 2 3));
    ("ccz", `Quick, test_gates_apply (ccz 0 1 2) (Path_sum_library.ccz 0 1 2 3));
  ]

let () =
  Alcotest.run "Symbolic execution"
    [
      ("Poly Normalise", poly_normalize);
      (* ("Normalise Path Variables", normalise_path_var); *)
      ("Lift Poly", lift_poly);
      ("Lift Monome", lift_monome);
      ("Lift Qubit", lift_qubit);
      ("Monome to scalar monome", monome_to_scalar_monome);
      ("Variable replacement Factorisation", variable_replacement_factorisation);
      ("Variable replacement", variable_replacement);
      ("Update Path-vars", update_pvs);
      ("Qubit", qubit);
      ("Ket", ket);
      ("Gates application", gates_apply);
    ]
