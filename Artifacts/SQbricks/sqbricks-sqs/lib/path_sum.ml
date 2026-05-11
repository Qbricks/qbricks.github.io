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

open Printf
open Common
include Rational
open Poly.Monome
module PS = Poly.String
open Qubit
module QS = Qubit.String

module Ket = struct
  type t = Qubit.t array

  let copy input = Array.copy input

  let equal ?(debug = false) ?(outputs1 = []) ?(outputs2 = []) (k1 : t) (k2 : t)
      : bool * int IntMap.t * int IntMap.t =
    if debug then
      printf "Ket.equal, outputs1 = %s\n\n%!" (ListBis.string_int outputs1);
    if debug then
      printf "Ket.equal, outputs2 = %s\n\n%!" (ListBis.string_int outputs2);

    let map_path_var1 = IntMap.empty in
    let map_path_var2 = IntMap.empty in
    if List.length outputs1 <> List.length outputs2 then
      (false, map_path_var1, map_path_var2)
    else
      let wq1 = Array.length k1 in
      let wq2 = Array.length k2 in
      (* If we don't provide a list of qubits, we check all qubits *)
      if List.is_empty outputs1 then (
        if not (Int.equal wq1 wq2) then (false, map_path_var1, map_path_var2)
        else
          let i = ref 0 in
          let result = ref true in
          while !result && !i < wq1 do
            if not (Qubit.equal k1.(!i) k2.(!i)) then result := false;
            incr i
          done;
          (!result, map_path_var1, map_path_var2))
      else
        let rec aux m1 m2 = function
          | hd1 :: tl1, hd2 :: tl2 ->
              if debug then printf "Ket.equal, hd1 = %d, hd2 = %d\n%!" hd1 hd2;
              if debug then
                printf "Ket.equal, k1.(hd1) = %s, k2.(hd2) = %s\n\n%!"
                  (QS.pretty k1.(hd1) wq1)
                  (QS.pretty k2.(hd2) wq2);

              let qubits_equal m1 m2 =
                match (k1.(hd1), k2.(hd2)) with
                | q1, q2 -> (Qubit.equal ~debug ~wq1 ~wq2 q1 q2, m1, m2)
              in

              let equal, new_m1, new_m2 = qubits_equal m1 m2 in
              if debug then printf "Ket.equal, qubits_equal = %b\n\n%!" equal;
              if equal then aux new_m1 new_m2 (tl1, tl2)
              else (false, new_m1, new_m2)
          | [], [] -> (true, m1, m2)
          | _ -> (false, m1, m2)
        in
        let result, out_m1, out_m2 =
          aux map_path_var1 map_path_var2 (outputs1, outputs2)
        in
        if debug then printf "Ket.equal, result = %b\n\n%!" result;
        if debug then
          printf "Ket.equal.IntMap, out_m1 = %s, out_m2 = %s\n%!"
            (Common.to_string_int_map out_m1)
            (Common.to_string_int_map out_m2);
        (result, out_m1, out_m2)

  (* if \( v \in k \) then `true` else `false` *)
  (* Don't look in `k.(except)`. *)
  let member ?(except = -1) v k =
    let width = Array.length k in
    let rec aux i =
      if Int.equal i width then false
      else if Int.equal i except then aux (i + 1)
      else if Qubit.member v k.(i) then true
      else aux (i + 1)
    in
    aux 0

  let simplify k =
    let n = Array.length k in
    let result = Array.make n Qubit.Zero in
    for i = 0 to n - 1 do
      result.(i) <- Qubit.simplify k.(i)
    done;
    result

  let extract_path_var ?(debug = false) ?(outputs = []) ket =
    let width = Array.length ket in
    let l = if outputs = [] then ListBis.range 0 width else outputs in
    if debug then
      printf "Path_sum.Ket.extract_path_var, l = %s\n\n%!"
        (ListBis.string_int l);
    let rec aux acc = function
      | hd :: tl ->
          if debug then
            printf "Path_sum.Ket.extract_path_var, hd = %d, tl = %s\n%!" hd
              (ListBis.string_int tl);
          if debug then
            printf "Path_sum.Ket.extract_path_var, ket.(hd) = %s\n%!"
              (QS.pretty ket.(hd) width);
          let qubit_extract_path_var =
            Qubit.extract_path_var ket.(hd) (width - 1)
          in
          if debug then
            printf
              "Path_sum.Ket.extract_path_var, qubit_extract_path_var = %s\n\n%!"
              (ListBis.string_int qubit_extract_path_var);
          aux (List.sort_uniq Int.compare (qubit_extract_path_var @ acc)) tl
      | [] -> acc
    in
    aux [] l

  let extract_var ket l =
    let rec aux = function
      | hd :: tl -> Qubit.extract_var ket.(hd) @ aux tl
      | [] -> []
    in
    aux l

  module String = struct
    module QS = Qubit.String

    let pretty (k : t) : string =
      let s = ref "" in
      let n = Array.length k in
      s := !s ^ " |";
      for i = 0 to n - 1 do
        if Int.equal i (n - 1) then s := !s ^ QS.pretty k.(i) n
        else s := !s ^ QS.pretty k.(i) n ^ ","
      done;
      !s ^ ">"

    let exact (k : t) =
      let w = Array.length k in
      let s = ref "" in
      s := !s ^ "[|";
      for i = 0 to w - 1 do
        if Int.equal i (w - 1) then s := !s ^ QS.exact k.(i)
        else s := !s ^ QS.exact k.(i) ^ ";"
      done;
      !s ^ "|]"
  end

  (* ket[variable_indice <- qubit_to_substitute] *)
  let substitute ?(debug = false) (input : t) (variable_indice : int)
      qubit_to_substitute =
    let rec aux (q : Qubit.t) : Qubit.t =
      if debug then printf "Path_sum.Ket.substitute.aux, q = %s\n" (QS.exact q);
      match q with
      | Qubit.SumMod2 (q1', q2') -> Qubit.SumMod2 (aux q1', aux q2')
      | Qubit.Prod (q1', q2') -> Qubit.Prod (aux q1', aux q2')
      | Qubit.Var variable_indice'
        when Int.equal variable_indice variable_indice' ->
          qubit_to_substitute
      | _ -> q
    in
    if debug then
      printf "Path_sum.Ket.substitute, input = %s\n" (String.pretty input);
    for i = 0 to Array.length input - 1 do
      if debug then printf "Path_sum.Ket.substitute, i = %d\n" i;
      input.(i) <- Qubit.simplify (aux input.(i))
    done;
    if debug then
      printf "Path_sum.Ket.substitute.end, input = %s\n\n" (String.pretty input);
    input

  (* 
Need to have an input "Renamed" 
Return (tmp_array_pvs * final_array_pvs) 
Compute the ordering of path variables in a given ket.
*)
  let path_var_order ?(debug = false) (ket : Qubit.t array) (nb_pvs : int) :
      int array * int array =
    let wq = Array.length ket in

    (* Initialization *)
    let pvs = Array.make nb_pvs Int.min_int in
    let tmp_pvs = Array.make nb_pvs Int.max_int in

    if debug then (
      printf "Path_sum.path_var_order, nb_pvs = %d\n%!" nb_pvs;
      printf "Path_sum.path_var_order, path_vars = %s\n%!"
        (ArrayBis.string_int pvs);
      printf "Path_sum.path_var_order, tmp_path_vars = %s\n%!"
        (ArrayBis.string_int tmp_pvs));

    if nb_pvs = 0 then (pvs, tmp_pvs)
    else
      (* Update the path-variable order given a list of variable indices. *)
      let rec update_pvs pv_curr tmp_pvs pvs = function
        | [] -> (pv_curr, tmp_pvs, pvs)
        | hd :: tl ->
            let i = hd - wq in
            if i < 0 || i >= nb_pvs then
              failwith "Path_sum.path_var_order.update: path var index overflow";

            if pvs.(i) = Int.min_int && tmp_pvs.(i) = Int.max_int then (
              pvs.(i) <- pv_curr;
              tmp_pvs.(i) <- -pv_curr;
              update_pvs (pv_curr + 1) tmp_pvs pvs tl)
            else update_pvs pv_curr tmp_pvs pvs tl
      in

      (* Traverse all qubits and accumulate variable ordering. *)
      let rec traverse pv_curr i tmp_pvs pvs =
        if i >= wq then (tmp_pvs, pvs)
        else
          let path_vars = Qubit.extract_path_var ket.(i) (wq - 1) in
          let pv_curr, tmp_pvs, pvs =
            update_pvs pv_curr tmp_pvs pvs path_vars
          in
          traverse pv_curr (i + 1) tmp_pvs pvs
      in

      let tmp_pvs, pvs = traverse wq 0 tmp_pvs pvs in

      if debug then
        printf "Path_sum.path_var_order, tmp_pvs = %s, pvs = %s\n\n%!"
          (ArrayBis.string_int tmp_pvs)
          (ArrayBis.string_int pvs);

      (tmp_pvs, pvs)

  let list_of_qubits_to_ket list =
    let ket = Array.make (List.length list) Qubit.Zero in
    let _ =
      List.fold_left
        (fun i q ->
          ket.(i) <- q;
          i + 1)
        0 list
    in
    ket

  let number_of_sum k =
    let w = Array.length k in
    let rec aux nb i =
      if i < w then aux (nb + Qubit.number_of_sum k.(i)) (i + 1) else nb
    in
    aux 0 0
end

module KS = Ket.String

type t = { phase : Poly.t; ket : Ket.t; path_var : int list }

let copy input : t =
  let phase = input.phase in
  let ket = Ket.copy input.ket in
  let path_var = input.path_var in
  { phase; ket; path_var }

module String = struct
  let exact (ps : t) =
    sprintf "phase = %s;" (PS.exact ps.phase)
    ^ sprintf "ket = %s;" (KS.exact ps.ket)
    ^ sprintf "path_var = %s;" (ListBis.string_int ps.path_var)

  let pretty (ps : t) =
    let n = Array.length ps.ket in
    sprintf "  phase = e^{2.π.i.%s};\n" (PS.pretty ps.phase n)
    ^ sprintf "  ket = %s;\n" (KS.pretty ps.ket)
    ^ sprintf "  path_var = %s;" (ListBis.y_string_int ps.path_var n)

  let path_var pvs w = ListBis.string_int (List.map (Int.add (Int.neg w)) pvs)
end

let equal ?(debug = false) ?(outputs1 = []) ?(outputs2 = [])
    ?(global_phase = false) ps1 ps2 =
  let wq1, wq2 = (Array.length ps1.ket, Array.length ps2.ket) in
  let width_outputs1 = List.length outputs1 in
  let width_outputs2 = List.length outputs2 in
  if width_outputs1 <> width_outputs2 then
    failwith "Path_sum.equal, width_outputs1 <> width_outputs2";

  let p1 = ps1.phase in
  let p2 = ps2.phase in

  if debug then printf "Path_sum.equal, ps1 =\n%s\n%!" (String.pretty ps1);
  if debug then printf "Path_sum.equal, ps2 =\n%s\n\n%!" (String.pretty ps2);

  let outputs1, outputs2 =
    let tmp = if width_outputs1 = 0 then ListBis.range 0 wq1 else [] in
    if debug then
      printf "Path_sum.equal, tmp = %s\n\n%!" (ListBis.string_int tmp);
    if List.is_empty tmp then (outputs1, outputs2) else (tmp, tmp)
  in

  if debug then
    printf "Path_sum.equal, outputs1 = %s\n\n%!" (ListBis.string_int outputs1);
  if debug then
    printf "Path_sum.equal, outputs2 = %s\n\n%!" (ListBis.string_int outputs2);

  let kets_equal, map_path_var1, map_path_var2 =
    Ket.equal ~debug ~outputs1 ~outputs2 ps1.ket ps2.ket
  in

  if debug then
    printf "Path_sum.equal.IntMap, map_path_var1 = %s, map_path_var2 = %s\n%!"
      (Common.to_string_int_map map_path_var1)
      (Common.to_string_int_map map_path_var2);

  if debug then printf "Path_sum.equal, kets_equals = %b\n" kets_equal;

  if kets_equal then (
    let var_outputs1 =
      List.sort_uniq Int.compare (Ket.extract_var ps1.ket outputs1)
    in
    let var_outputs2 =
      List.sort_uniq Int.compare (Ket.extract_var ps2.ket outputs2)
    in

    if debug then printf "Path_sum.equal, p1 = %s\n%!" (PS.pretty p1 wq1);
    if debug then printf "Path_sum.equal, p2 = %s\n%!" (PS.pretty p2 wq2);

    let extract_poly p var_outputs wq =
      if Poly.is_constant_superior_zero p then p
      else
        let m = Poly.find p in
        let p =
          Poly.extract p
            (List.sort_uniq Int.compare (var_outputs @ ListBis.range 0 wq))
        in
        match m with
        | Poly.Monome.Scal x when not (Q.equal x Q.zero) -> Poly.insert m p
        | _ -> p
    in

    let poly_output1 = extract_poly p1 var_outputs1 wq1 in
    let poly_output2 = extract_poly p2 var_outputs2 wq2 in

    (* Sub-Circuit-Partial-Equivalence *)
    let polys_equal =
      Poly.equal ~global_phase ~debug ~wq1 ~wq2 ~map_path_var1 ~map_path_var2
        poly_output1 poly_output2
    in
    if debug then printf "Path_sum.equal, polys_equal = %b\n" polys_equal;
    polys_equal)
  else false

let zero = Poly.zero

let ofSize w : t =
  let k = Array.make w (Qubit.Var 0) in
  for i = 0 to w - 1 do
    k.(i) <- Qubit.Var i
  done;
  { phase = zero; ket = k; path_var = [] }

let ofSize_init ?(debug = false) width inits_0 =
  if debug then
    printf "Path_sum.ofSize_init, width = %d, inits_0 = %s\n\n" width
      (ListBis.string_int inits_0);
  let ps = ofSize width in
  if debug then printf "Path_sum.ofSize_init, ps =\n%s\n\n" (String.pretty ps);
  let ket = ps.ket in

  let inputs = ListBis.missing_in_range inits_0 width in
  let inputs_value_curr = ref 0 in

  let aux value_to_init l =
    let rec aux' = function
      | ta :: l' ->
          if debug then printf "Path_sum.ofSize_init.aux, ta =\n%d\n\n" ta;
          if Int.equal value_to_init 0 then ket.(ta) <- Qubit.Zero
          else if Int.equal value_to_init 1 then ket.(ta) <- Qubit.One
          else if Int.equal value_to_init (-1) then (
            ket.(ta) <- Var !inputs_value_curr;
            inputs_value_curr := !inputs_value_curr + 1)
          else failwith "Path_sum.ofSize_init, value_to_init forbidden";
          aux' l'
      | [] -> ()
    in
    aux' l
  in
  (* Initialization by 0 *)
  aux 0 inits_0;
  (* Normalization of inputs variables *)
  aux (-1) inputs;

  if debug then printf "Path_sum.ofSize_init, ket = %s\n\n" (KS.pretty ket);

  let output = { phase = ps.phase; ket; path_var = ps.path_var } in

  if debug then
    printf "Path_sum.ofSize_init, output =\n%s\n\n" (String.pretty output);

  output

let remove_path_var ps y =
  { phase = ps.phase; ket = ps.ket; path_var = ListBis.remove y ps.path_var }

let substitute ?(debug = false) ?(except_path_var = false) path_sum
    indice_to_subst qubit_to_subst =
  let new_path_var =
    if except_path_var then path_sum.path_var
    else
      match qubit_to_subst with
      | Var v -> ListBis.substitute path_sum.path_var indice_to_subst v
      | _ -> failwith "Path_sum.substitute, qubit_to_subst must be a variable"
  in

  if debug then
    printf "Path_sum.substitute, new_path_var = %s\n"
      (ListBis.string_int new_path_var);

  let new_phase =
    Poly.substitute ~debug indice_to_subst path_sum.phase qubit_to_subst
  in
  let new_ket =
    Ket.substitute ~debug path_sum.ket indice_to_subst qubit_to_subst
  in

  let output : t =
    { phase = new_phase; ket = new_ket; path_var = new_path_var }
  in
  if debug then
    printf "Path_sum.substitute, output =\n%s\n\n" (String.pretty output);
  output

module Path_sum_library = struct
  (*
In order to keep phase polynomials with positive coefficients,
we use the following transformation:
e^{-2πi(s/2^k)} = e^{2πi((2^k - s)/2^k)}
*)

  let ( ++ ) = Poly.( ++ )
  let empty = Poly.empty

  let xx ta w : Qubit.t =
    if ta < w then Var ta
    else failwith (sprintf "Path_sum.Library.xx, w = %d < ta = %d\n" w ta)

  let yy n w : Qubit.t = Var (n + w)

  (* \( 1 / \sqrt{2} \sum_{y_0 \in \{0,1\}} e^{2 \pi i (x_0 y_0) / 2} \ket{y_0} \) *)
  let h ta w =
    {
      phase = Prod (Scal div2, Prod (Qubit (xx ta w), Qubit (yy 0 w))) ++ empty;
      ket = [| yy 0 w |];
      path_var = [ w ];
    }

  let x ta w =
    {
      phase = Scal Q.zero ++ empty;
      ket = [| SumMod2 (One, xx ta w) |];
      path_var = [];
    }

  let apply_angle sQ k = if sQ < Q.zero then Q.add (pow2Q k) sQ else sQ

  (* \( u1 s k  : |x0> -> e^{2.pi.i. x0.s / 2^k} \) |x0> *)
  let u1 ?(s = 1) k ta w =
    let p =
      if s = 0 || k = 0 then Scal Q.zero ++ empty
      else
        Prod (Scal (Q.div_2exp (apply_angle (Q.of_int s) k) k), Qubit (xx ta w))
        ++ empty
    in
    { phase = p; ket = [| xx ta w |]; path_var = [] }

  let z ta w = u1 1 ta w
  let s ta w = u1 2 ta w
  let t ta w = u1 3 ta w
  let zinv ta w = u1 ~s:(-1) 1 ta w
  let sinv ta w = u1 ~s:(-1) 2 ta w
  let tinv ta w = u1 ~s:(-1) 3 ta w

  (* \( rz s k  : |x0> -> e^{2.pi.i. (x0.s/2^k - s/2^{k+1})} |x0> \) *)
  let rz ?(s = 1) k ta w =
    let sQ = Q.of_int s in
    let p =
      if sQ = Q.zero then Scal Q.zero ++ empty
        (* if sQ = Q.zero || k = 0 then Scal Q.zero ++ empty *)
      else
        Scal (Q.div_2exp (apply_angle (Q.neg sQ) (k + 1)) (k + 1))
        ++ (Prod (Scal (Q.div_2exp (apply_angle sQ k) k), Qubit (xx ta w))
           ++ empty)
    in
    { phase = p; ket = [| xx ta w |]; path_var = [] }

  (* \( rx s k : |x0> -> e^{2.pi.i. (x0.y0/2 + s.y0/2^k - s/2^{k+1} + y0.y1/2)} |y1> \) *)
  let rx ?(s = 1) k ta w =
    let sQ = Q.of_int s in
    let p =
      if sQ = Q.zero then Scal Q.zero ++ empty
        (* if sQ = Q.zero || k = 0 then Scal Q.zero ++ empty *)
      else if Q.zero < sQ then
        let pow2kp1 = pow2Q (k + 1) in
        Prod (Scal div2, Prod (Qubit (xx ta w), Qubit (yy 0 w)))
        ++ (Prod (Scal (Q.div_2exp sQ k), Qubit (yy 0 w))
           ++ (Scal (Q.div (Q.sub pow2kp1 sQ) pow2kp1)
              ++ (Prod (Scal div2, Prod (Qubit (yy 0 w), Qubit (yy 1 w)))
                 ++ empty)))
      else
        let pow2k = pow2Q k in
        Prod (Scal div2, Prod (Qubit (xx ta w), Qubit (yy 0 w)))
        ++ (Prod (Scal (Q.div (Q.sub pow2k (Q.neg sQ)) pow2k), Qubit (yy 0 w))
           ++ (Scal (Q.div_2exp (Q.neg sQ) (k + 1))
              ++ (Prod (Scal div2, Prod (Qubit (yy 0 w), Qubit (yy 1 w)))
                 ++ empty)))
    in

    let q = if sQ = Q.zero || k = 0 then xx ta w else yy 1 w in
    let pv = if sQ = Q.zero then [] else [ 1; 2 ] in
    { phase = p; ket = [| q |]; path_var = pv }

  (* \( ry s k : |x0> -> e^{2.pi.i.
     (-x0/4 + y0/2 - x0.y0/2 + s.y0/2^k - s/2^{k+1} + y0.y1/2 + y1/2)}
     |y1> \) *)
  let ry ?(s = 1) k ta w =
    let sQ = Q.of_int s in
    let p =
      if sQ = Q.zero then Scal Q.zero ++ empty
        (* if sQ = Q.zero || k = 0 then Scal Q.zero ++ empty *)
      else if Q.zero < sQ then
        let pow2kp1 = pow2Q (k + 1) in
        Scal (7 /// 4)
        ++ (Prod (Scal div4, Qubit (xx ta w))
           ++ (Prod (Scal div2, Qubit (yy 0 w))
              ++ (Prod (Scal (3 /// 2), Prod (Qubit (xx ta w), Qubit (yy 0 w)))
                 ++ (Prod (Scal (Q.div_2exp sQ k), Qubit (yy 0 w))
                    ++ (Scal (Q.div (Q.sub pow2kp1 sQ) pow2kp1)
                       ++ (Prod
                             (Scal div2, Prod (Qubit (yy 0 w), Qubit (yy 1 w)))
                          ++ (Prod (Scal div4, Qubit (yy 1 w)) ++ empty)))))))
      else
        let pow2k = pow2Q k in
        Scal (7 /// 4)
        ++ (Prod (Scal div4, Qubit (xx ta w))
           ++ (Prod (Scal div2, Qubit (yy 0 w))
              ++ (Prod (Scal (3 /// 2), Prod (Qubit (xx ta w), Qubit (yy 0 w)))
                 ++ (Prod
                       ( Scal (Q.div (Q.sub pow2k (Q.neg sQ)) pow2k),
                         Qubit (yy 0 w) )
                    ++ (Scal (Q.div_2exp (Q.neg sQ) (k + 1))
                       ++ (Prod
                             (Scal div2, Prod (Qubit (yy 0 w), Qubit (yy 1 w)))
                          ++ (Prod (Scal div4, Qubit (yy 1 w)) ++ empty)))))))
    in

    let q = if sQ = Q.zero || k = 0 then xx ta w else SumMod2 (One, yy 1 w) in
    let pv = if sQ = Q.zero then [] else [ 1; 2 ] in
    { phase = p; ket = [| q |]; path_var = pv }

  (* let xxb ta w : Qubit.t = SumMod2 (One, xx ta w) *)

  (* \( (1 ++ x_0) (1 - 2 y_0) / 8 =
        (1 - x_0) (1 - 2 y_0) / 8 =
        ( 1     -   x_0     + 2 x_0 y_0     - 2 y_0) / 8 =
          1 / 8 -   x_0 / 8 +   x_0 y_0 / 4 -   y_0 / 4  =
          1 / 8 + 7 x_0 / 8 +   x_0 y_0 / 4 + 3 y_0 / 4\) *)
  let normalisation_factor co w : Poly.t =
    Scal div8
    ++ (Prod (Scal divm8, Qubit (xx co w))
       ++ (Prod (Scal div4, Prod (Qubit (xx co w), Qubit (yy 0 w)))
          ++ (Prod (Scal divm4, Qubit (yy 0 w)) ++ empty)))

  (* \( x_0 y_0 ++ (1 ++ x_0) x_1 = x_0 x_1 ++ x_0 y_0 ++ x_1} \) *)
  let q2 co ta w : Qubit.t =
    SumMod2 (Prod (xx co w, xx ta w), SumMod2 (Prod (xx co w, yy 0 w), xx ta w))

  (* \( 1 / \sqrt{2}
     \sum_{y_0 \in \{0,1\}}
     e^{2 \pi i ((x_0 x_1 y_0) / 2 + ((1 ++ x_0) (1 - 2 y_0)) / 8)}
     \ket{x_0, x_0 y_0 ++ (1 ++ x_0) x_1} \) *)
  let ch co ta w =
    {
      phase =
        Poly.simplify
          (Prod
             ( Scal div2,
               Prod (Qubit (xx co w), Prod (Qubit (xx ta w), Qubit (yy 0 w))) )
          ++ normalisation_factor co w);
      ket = Ket.simplify [| xx co w; q2 co ta w |];
      path_var = [ w ];
    }

  let cx co ta w =
    {
      phase = Scal Q.zero ++ empty;
      ket = [| xx co w; SumMod2 (xx co w, xx ta w) |];
      path_var = [];
    }

  let crz k co ta w =
    {
      phase =
        Prod (Scal (divk k), Prod (Qubit (xx co w), Qubit (xx ta w))) ++ empty;
      ket = [| xx co w; xx ta w |];
      path_var = [];
    }

  let cz co ta w = crz 1 co ta w
  let cs co ta w = crz 2 co ta w
  let ct co ta w = crz 3 co ta w

  let ccx co1 co2 ta w =
    {
      phase = Scal Q.zero ++ empty;
      ket =
        [| xx co1 w; xx co2 w; SumMod2 (Prod (xx co1 w, xx co2 w), xx ta w) |];
      path_var = [];
    }

  let ccrz k co1 co2 ta w =
    {
      phase =
        Prod
          ( Scal (divk k),
            Prod (Qubit (xx co1 w), Prod (Qubit (xx co2 w), Qubit (xx ta w))) )
        ++ empty;
      ket = [| xx co1 w; xx co2 w; xx ta w |];
      path_var = [];
    }

  let ccz co1 co2 ta w = ccrz 1 co1 co2 ta w
  let sh3 = { phase = Scal div8 ++ empty; ket = [| Var 0 |]; path_var = [] }
end
