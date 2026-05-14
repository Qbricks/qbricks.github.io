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
module PS = Poly.String
module QS = Qubit.String
module Ket = Path_sum.Ket
module KS = Ket.String
module PSS = Path_sum.String
module Monome = Poly.Monome

module Simplification = struct
  let simplify ?(debug = false) (ps : Path_sum.t) : Path_sum.t =
    {
      path_var = ps.path_var;
      ket = Path_sum.Ket.simplify ps.ket;
      phase = Poly.simplify ~debug ps.phase;
    }
end

module Elim = struct
  let elim ?(debug = false) ps =
    if debug then printf "Reduction_rule.elim,\nps =\n%s\n" (PSS.pretty ps);
    let p, k = (ps.phase, ps.ket) in
    let rec aux path_var acc =
      match path_var with
      | y :: path_var' ->
          let condition_ket = lazy (not (Path_sum.Ket.member y k)) in
          let condition_poly = lazy (not (Poly.member y p)) in
          if Lazy.force condition_ket then
            if Lazy.force condition_poly then aux path_var' acc
            else aux path_var' (y :: acc)
          else aux path_var' (y :: acc)
      | [] -> acc
    in
    let ps' : Path_sum.t =
      {
        phase = ps.phase;
        ket = ps.ket;
        path_var = List.rev (aux ps.path_var []);
      }
    in
    if debug then printf "Reduction_rule.elim,\nps' =\n%s\n" (PSS.pretty ps');
    ps'
end

module HH = struct
  let empty = Poly.empty
  let find = Poly.find
  let del = Poly.del
  let ( ++ ) = Poly.( ++ )
  let zero : Poly.t = Poly.zero
  let member = Monome.member
  let remove = Monome.remove
  let occurrence_couple = Poly.occurrence
  let simplify p = Poly.simplify p
  let qsimplify p = Qubit.simplify p

  let extract_R_monome (m : Monome.t) y0 : Monome.t option =
    if Monome.member y0 m then None else Some m

  let extract_R ?(debug = false) (p : Poly.t) y0 : Poly.t option =
    if debug then printf "Rule_common.extract_R, p = %s\n" (PS.exact p);
    let rec aux (p : Poly.t) (acc : Poly.t) : Poly.t option =
      if Poly.equal p Poly.empty then
        if Poly.equal acc Poly.empty then None
        else (
          if debug then
            printf "Rule_common.extract_R, acc = %s\n" (PS.exact acc);
          Some acc)
      else
        let m, p_remain = (Poly.find p, Poly.del p) in
        match extract_R_monome m y0 with
        | Some m1 -> aux p_remain (m1 ++ acc)
        | None -> aux p_remain acc
    in
    aux p Poly.empty

  (* Checks whether a monome contains both y0 and yi, and returns 1 if so, otherwise 0 *)
  let y0_yi_occurrence_monome (y0 : int) (yi : int) (m : Monome.t) : int =
    match m with
    | Prod (_, m1)
      when let y0_member_m1 = lazy (member y0 m1) in
           let yi_member_m1 = lazy (member yi m1) in
           if Lazy.force y0_member_m1 then Lazy.force yi_member_m1 else false ->
        1
    | _ -> 0

  (* Calculate the number of monomials in a polynomial that contain both y0 and yi *)
  let y0_yi_occurrence (y0 : int) (yi : int) (p : Poly.t) : int =
    occurrence_couple
      (fun (y0, yi) m -> y0_yi_occurrence_monome y0 yi m)
      (y0, yi) p

  let condition_to_extract_yi s v1 v2 n p y0 =
    let s_equal_div2 = Q.equal s div2 in
    let v1_equal_y0 = Int.equal v1 y0 in
    let n1_leq_v2 = n <= v2 in
    let occurrence_y0_yi_eq_1 = lazy (Int.equal (y0_yi_occurrence v1 v2 p) 1) in
    if s_equal_div2 && v1_equal_y0 && n1_leq_v2 then
      Lazy.force occurrence_y0_yi_eq_1
    else false

  let extract_yi y0 ?(debug = false) p_input n : int option =
    if n <= 0 then
      failwith
        (sprintf "Rule_hh.hh_aux.extract_yi, n must be > 0, n = %d\n%!" n);
    let extract_yi_monome y0 (m : Monome.t) : int option =
      match m with
      | Prod (Scal s, Prod (Qubit (Var v1), Qubit (Var v2)))
        when condition_to_extract_yi s v1 v2 n p_input y0 ->
          if debug then
            printf "1. Rule_hh.extract_yi\np =%s\nv1 = %d, v2 = %d\n%!"
              (Monome.String.exact m) v1 v2;
          Some v2
      | Prod (Scal s, Prod (Qubit (Var v1), Qubit (Var v2)))
        when condition_to_extract_yi s v2 v1 n p_input y0 ->
          if debug then
            printf "2. Rule_hh.extract_yi\np =%s\nv2 = %d, v1 = %d\n%!"
              (Monome.String.exact m) v2 v1;
          Some v1
      | _ ->
          if debug then
            printf "6. Rule_hh.extract_yi\np =%s\n%!" (Monome.String.exact m);
          None
    in
    let extract_yi_rec y0 (p : Poly.t) : int option =
      let rec aux p =
        if Poly.equal p empty then None
        else
          match extract_yi_monome y0 (find p) with
          | Some yi -> Some yi
          | None -> aux (del p)
      in
      aux p
    in
    extract_yi_rec y0 p_input

  let extract_Q_monome ?(debug = false) (m : Monome.t) y0 yi : Monome.t option =
    if debug then printf "Rule_hh.extract_Q, y0 = %d, yi = %d\n%!" y0 yi;
    if debug then
      printf "Rule_hh.extract_Q_monome, m = %s\n%!" (Monome.String.exact m);
    match m with
    | Prod (Scal s, m1) when if s = div2 then not (member yi m1) else false -> (
        if debug then
          printf "Rule_hh.extract_Q_monome, m1 = %s\n%!"
            (Monome.String.exact m1);
        match remove y0 m1 with
        | Some m1_without_y0 ->
            if debug then
              printf "Rule_hh.extract_Q_monome.Some, m1_without_y0 = %s\n%!"
                (Monome.String.exact m1_without_y0);
            Some m1_without_y0
        | None ->
            if debug then
              printf "Rule_hh.extract_Q_monome.None, m1 = %s\n%!"
                (Monome.String.exact m1);
            None)
    | _ -> None

  let extract_Q ?(debug = false) (p : Poly.t) n y0 yi : Poly.t option =
    if n <= 0 then
      failwith (sprintf "Rule_hh.hh_aux.extract_Q, n must be > 0, n = %d\n%!" n);
    if debug then printf "Rule_hh.extract_Q, p = %s\n%!" (PS.exact p);
    if debug then
      printf "Rule_hh.extract_Q, n = %d, y0 = %d, yi = %d\n%!" n y0 yi;
    let rec aux (p : Poly.t) (acc : Poly.t) : Poly.t option =
      if Poly.equal p empty then (
        if debug then printf "Rule_hh.extract_Q, acc = %s\n%!" (PS.exact acc);
        Some acc)
      else
        let m, p_remain = (find p, del p) in
        match extract_Q_monome ~debug m y0 yi with
        | Some m1 ->
            if debug then
              printf "Rule_hh.extract_Q, m1 = %s\n%!" (Monome.String.exact m1);
            aux p_remain (m1 ++ acc)
        | None -> aux p_remain acc
    in
    aux p empty

  let y0_member_unauthorized y0 (p : Poly.t) =
    let y0_member_unauthorized_monome y0 (m : Monome.t) : bool =
      match m with
      | Prod (Scal s, m1) when s <> div2 -> member y0 m1
      | _ -> false
    in
    Poly.exists (y0_member_unauthorized_monome y0) p

  (* y0 must not be in the ket and its only scalar must be 1/2 *)
  let y0_accepted y0 (ps : Path_sum.t) : bool =
    let condition_ket = not (Path_sum.Ket.member y0 ps.ket) in
    let condition_poly = lazy (not (y0_member_unauthorized y0 ps.phase)) in
    if condition_ket then Lazy.force condition_poly else false

  let hh_aux y0 ?(debug = false) (ps : Path_sum.t) =
    if debug then
      printf "Rule_hh.hh_aux, y0 = y%d\n%!" (y0 - Array.length ps.ket);
    if debug then printf "Rule_hh.hh_aux, ps =\n%!%s\n%!" (PSS.pretty ps);
    let n = Array.length ps.ket in
    match extract_yi ~debug y0 ps.phase n with
    | Some yi -> (
        if debug then
          printf "Rule_hh.hh_aux, yi = y%d\n%!" (yi - Array.length ps.ket);
        match extract_Q ~debug ps.phase n y0 yi with
        | Some q -> (
            if debug then printf "Rule_hh.hh_aux, q = %s\n%!" (PS.pretty q n);
            if debug then
              printf "Rule_hh.hh_aux, ps.phase = %s\n%!" (PS.pretty ps.phase n);
            match extract_R ~debug ps.phase y0 with
            | Some r ->
                if debug then
                  printf "Rule_hh.hh_aux, r = %s\n%!" (PS.pretty r n);
                let r_simplified = simplify r in
                if debug then
                  printf "Rule_hh.hh_aux, r_simplified = %s\n%!"
                    (PS.pretty r_simplified n);
                (* \( 1/2 y_0 (y_i + Q) -> (Q = q1 ++ q2) -> Q = q1 + q2 \) *)
                let ps_output_simplified : Path_sum.t =
                  {
                    phase =
                      simplify
                        (Poly.substitute_rules_hh r_simplified yi q ~debug);
                    ket =
                      Path_sum.Ket.substitute ps.ket yi
                        (qsimplify (Poly.to_qubit q));
                    path_var = ps.path_var;
                  }
                in
                Some ps_output_simplified
            | None ->
                let ps_output : Path_sum.t =
                  {
                    phase = zero;
                    ket = Path_sum.Ket.substitute ps.ket yi (Poly.to_qubit q);
                    path_var = ps.path_var;
                  }
                in
                Some ps_output)
        | None -> None)
    | None -> None

  let hh ?(debug = false) ?(y0_to_remove = -1) (ps : Path_sum.t) =
    let width = Array.length ps.ket in
    if Int.equal y0_to_remove (-1) then
      (* Try y0 in order of arrival *)
      let rec aux (acc : Path_sum.t) = function
        | y0 :: y0_remain ->
            if debug then
              printf "Rule_hh.hh.accepted, y0 candidate = %d\n\n%!" (y0 - width);
            if y0_accepted y0 acc then (
              if debug then
                printf "Rule_hh.hh.accepted, y0 = %d\n\n%!" (y0 - width);
              match hh_aux y0 acc ~debug with
              | Some acc_reduced ->
                  (if debug then
                     printf "Rule_hh.hh.accepted.match hh_aux, y0 = %d\n%!"
                       (y0 - width);
                   if debug then
                     printf
                       "Rule_hh.hh.accepted.match hh_aux, acc_reduced =\n\
                        %s\n\n\
                        %!"
                       (PSS.pretty acc_reduced);
                   aux
                     (Path_sum.remove_path_var
                        (Simplification.simplify acc_reduced)
                        y0))
                    y0_remain
              | None -> aux acc y0_remain)
            else aux acc y0_remain
        | _ -> Elim.elim acc
      in
      aux ps ps.path_var
    else if
      (* The user proposes y0 *)
      y0_accepted y0_to_remove ps
    then
      match hh_aux y0_to_remove ps with
      | Some ps_output ->
          let ps_output : Path_sum.t =
            {
              phase = ps_output.phase;
              ket = ps_output.ket;
              path_var = ListBis.remove y0_to_remove ps_output.path_var;
            }
          in
          ps_output
      | None -> ps
    else ps
end

module Rename = struct
  (** [_string_update_pvs substitutions] converts a list of path variable
      substitutions to a string representation. Format:
      "(old,new);(old,new);..." Example:
      [_string_update_pvs [(5, 2); (7, 3); (9, 4)]] returns
      ["(5,2);(7,3);(9,4)"] *)
  let _string_update_pvs update_pvs =
    let rec string_update_pvs_rec update_pvs =
      match update_pvs with
      | (pv, pv') :: [] ->
          "(" ^ string_of_int pv ^ "," ^ string_of_int pv' ^ ")"
      | (pv, pv') :: update_pvs' ->
          "(" ^ string_of_int pv ^ "," ^ string_of_int pv' ^ ");"
          ^ string_update_pvs_rec update_pvs'
      | [] -> ""
    in
    "[" ^ string_update_pvs_rec update_pvs ^ "]"

  (* y0,y3,y6 -> (y0,y0);(y3,y1);(y6,y2) *)

  (** [_find_update_path_var ps] creates substitution pairs mapping path
      variables to new contiguous indices. The new indices start from the number
      of qubits in the path sum. For a path sum with 3 qubits and path variables
      [10; 12; 15], returns [(10, 3); (12, 4); (15, 5)] *)
  let _find_update_path_var (ps' : Path_sum.t) =
    let rec aux pvs indice acc =
      match pvs with
      | pv :: [] -> (pv, indice) :: acc
      | pv :: pvs' -> aux pvs' (indice + 1) ((pv, indice) :: acc)
      | [] -> acc
    in
    List.rev
      (aux (List.fast_sort compare ps'.path_var) (Array.length ps'.ket) [])

  (** [_path_var_substitute vars substitutions] applies multiple substitutions
      to a list of path variables. Each substitution (old, new) replaces all
      occurrences of old with new. Example:
      [_path_var_substitute [10; 12; 15] [(10, 3); (12, 4); (15, 5)]] returns
      [3; 4; 5] *)
  let _path_var_substitute pvs update_pvs =
    let rec substitute_rec pvs pv1 pv2 (acc : int list) : int list =
      match pvs with
      | [] -> acc
      | pv :: pvs' when Int.equal pv pv1 ->
          substitute_rec pvs' pv1 pv2 (pv2 :: acc)
      | pv :: pvs' -> substitute_rec pvs' pv1 pv2 (pv :: acc)
    in
    let rec path_sum_update update pvs_output =
      match update with
      | (pv1, pv2) :: [] -> List.rev (substitute_rec pvs_output pv1 pv2 [])
      | (pv1, pv2) :: update' ->
          path_sum_update update'
            (List.rev (substitute_rec pvs_output pv1 pv2 []))
      | [] -> pvs_output
    in
    path_sum_update update_pvs pvs

  let q v = Poly.q v

  let _substitute_path_var_rec ket_input phase_input update_input =
    let rec aux ket phase update_pvs =
      match update_pvs with
      | (pv, pv') :: [] ->
          if Int.equal pv pv' then (ket, phase)
          else
            ( Path_sum.Ket.substitute ket pv (Var pv'),
              Poly.substitute_poly phase pv (q pv') )
      | (pv, pv') :: update_pvs' ->
          if Int.equal pv pv' then aux ket phase update_pvs'
          else
            aux
              (Path_sum.Ket.substitute ket pv (Var pv'))
              (Poly.substitute_poly phase pv (q pv'))
              update_pvs'
      | [] -> (ket, phase)
    in
    aux ket_input phase_input update_input

  (** [_substitute_path_var ?debug ps substitutions] applies substitutions to
      all components of a path sum. Updates path variables in phase polynomial,
      ket, and path_var list. Example: For path sum with:
      - 3 qubits
      - path variables [10; 12]
      - phase containing terms with y7 and y9 (10 - 3 and 12 - 3)
      - ket containing |y7 + y9> [_substitute_path_var ps [(10, 3); (12, 4)]]
        produces a path sum where:
      - path variables become [3; 4]
      - phase terms use y0 and y1 (3 - 3 and 4 - 3)
      - ket becomes |y0 + y1> *)
  let _substitute_path_var ?(debug = false) (ps : Path_sum.t) update_pvs =
    let k, p = _substitute_path_var_rec ps.ket ps.phase update_pvs in
    let ps_output : Path_sum.t =
      {
        phase = p;
        ket = k;
        path_var = _path_var_substitute ps.path_var update_pvs;
      }
    in
    if debug then
      printf "Reduction_rules.substitute_path, update_pvs = %s\n"
        (_string_update_pvs update_pvs);
    if debug then
      printf "Reduction_rules.substitute_path,\nps_output =\n%s\n"
        (PSS.pretty ps_output);
    ps_output

  let rename ?(debug = false) (ps : Path_sum.t) =
    _substitute_path_var ~debug ps (_find_update_path_var ps)
end

module Variable_replacement = struct
  (** [condition_to_substitute ?debug q except ps] takes as input a qubit [q], a
      path sum [ps], and an integer [except]. Returns [Some v] if the path
      variables of [q] appear exactly once in [ps] (excluding the qubit at index
      [except] in the ket), and [None] otherwise. Raises an exception in case of
      an unexpected error. *)

  let condition_to_substitute ?(debug = false) (q : Qubit.t) except
      (ps : Path_sum.t) =
    let width = Array.length ps.ket in
    let rec number_of_path_var_of_q_outside_q (q : Qubit.t) : int * int =
      match q with
      | Var v ->
          let condition_ket = lazy (Path_sum.Ket.member ~except v ps.ket) in
          let condition_phase = lazy (Poly.member v ps.phase) in
          if debug then
            printf "Reduction_rules.condition_to_substitute, ps.phase = %s\n\n"
              (PS.pretty ps.phase width);
          if v < width then (0, -1)
          else if Lazy.force condition_ket then (0, -1)
          else if Lazy.force condition_phase then (0, -1)
          else (1, v)
      | Qubit.One | Qubit.Zero -> (0, -1)
      | SumMod2 (Qubit.One, q1) ->
          if debug then
            printf
              "Reduction_rules.condition_to_substitute.SumMod2(1+q1), q1 = %s\n\n"
              (QS.pretty q1 width);
          let nb, v = number_of_path_var_of_q_outside_q q1 in
          if debug then
            printf
              "Reduction_rules.condition_to_substitute.SumMod2(1+q1), nb = %d\n\n"
              nb;
          (nb, v)
      | SumMod2 (q1, q2) | Prod (q1, q2) ->
          let nb1, v1 = number_of_path_var_of_q_outside_q q1 in
          if 1 < nb1 then (nb1, -1)
          else
            let nb2, v2 = number_of_path_var_of_q_outside_q q2 in
            let nb = nb1 + nb2 in
            if 1 < nb then (nb, -1)
            else if 1 < nb2 then (nb2, -1)
            else if nb1 = 1 then (nb1, v1)
            else if nb2 = 1 then (nb2, v2)
            else if nb1 = 0 then (0, -1)
            else if nb2 = 0 then (0, -1)
            else
              failwith
                "Rule_variable_replacement.number_of_path_var_of_q_outside_q.SumMod2"
    in
    let nb, v = number_of_path_var_of_q_outside_q q in
    if nb = 1 then Some v else None

  (* original_qubit[qubit_to_substitute <- new_qubit] *)
  let substitute_qubit_in_qubit original_qubit new_qubit qubit_to_substitute :
      Qubit.t =
    let rec aux (q : Qubit.t) : Qubit.t =
      match q with
      | q when Qubit.equal q qubit_to_substitute -> new_qubit
      | SumMod2 (q1, q2) -> SumMod2 (aux q1, aux q2)
      | _ -> q
    in
    aux original_qubit

  (* original_ket[qubit_to_substitute <- new_qubit] *)
  let substitute_qubit_in_ket (original_ket : Path_sum.Ket.t) new_qubit
      qubit_to_substitute =
    let width = Array.length original_ket in
    for i = 0 to width - 1 do
      original_ket.(i) <-
        substitute_qubit_in_qubit original_ket.(i) new_qubit qubit_to_substitute
    done;
    original_ket

  let variable_replacement ?(debug = false) (input : Path_sum.t) =
    let width = Array.length input.ket in

    if debug then
      printf "Reduction_rules.variable_replacement, input.phase = %s\n\n"
        (PS.pretty input.phase width);

    let ps = Simplification.simplify input in

    if debug then
      printf "Reduction_rules.variable_replacement, ps.phase = %s\n\n"
        (PS.pretty ps.phase width);

    if List.equal Int.equal ps.path_var [] then None
    else
      let new_y = ListBis.max_int ps.path_var + 1 in

      let rec iterate_over_qubits indice =
        if Int.equal indice width then None
        else
          let process_qubit (qubit_i : Qubit.t) =
            match qubit_i with
            | SumMod2 _ -> (
                match condition_to_substitute ~debug qubit_i indice ps with
                | Some v ->
                    Some (substitute_qubit_in_ket ps.ket (Var new_y) qubit_i, v)
                | None -> iterate_over_qubits (indice + 1))
            | _ -> iterate_over_qubits (indice + 1)
          in
          process_qubit ps.ket.(indice)
      in

      match iterate_over_qubits 0 with
      | Some (k, v) ->
          let output : Path_sum.t =
            {
              phase = ps.phase;
              ket = k;
              path_var =
                List.sort_uniq Int.compare
                  (new_y :: ListBis.remove v ps.path_var);
            }
          in
          Some (Rename.rename output)
      | None -> None

  (* Factorization by variable replacement.
   Example: phase = x0y0 + x0y1, ket = |y0 + y1>
   After replacement: phase[y0 <- y0 + y1] = x0y0, ket[y0 <- y0 + y1] = |y0> *)
  let variable_replacement_factorisation ?(debug = false) (state : Path_sum.t) =
    if debug then
      printf "Rules.variable_replacement_factorisation, state =\n%s\n%!"
        (PSS.pretty state);

    let width = Array.length state.ket in

    (* Try to factorize one step in the polynomial *)
    let rec factorize_step (p : Poly.t) (acc_state : Path_sum.t) :
        Path_sum.t option =
      if debug then (
        printf
          "Rules.variable_replacement_factorisation.factorize_step, p = %s\n\n\
           %!"
          (PS.pretty p width);
        printf
          "Rules.variable_replacement_factorisation.factorize_step, acc_state =\n\
           %s\n\n\
           %!"
          (PSS.pretty acc_state));

      let ket = Ket.copy acc_state.ket in
      let poly = acc_state.phase in

      if Poly.size p < 2 then
        (* if ok then Some acc_state else  *)
        None
      else
        let m1 = Poly.find p in
        let p1 = Poly.del p in
        let m2 = Poly.find p1 in

        if debug then (
          printf "Rules.variable_replacement_factorisation, m1 = %s\n\n%!"
            (Monome.String.pretty m1 width);
          printf "Rules.variable_replacement_factorisation, m2 = %s\n\n%!"
            (Monome.String.pretty m2 width));

        match (m1, m2) with
        | ( Prod (Scal q1, Prod (Qubit (Var v1), Qubit (Var v2))),
            Prod (Scal q2, Prod (Qubit (Var v3), Qubit (Var v4))) )
          when Q.equal q1 q2 && Q.equal q1 Rational.div2 && v1 = v3
               && width <= v2 && width <= v4 ->
            let new_qubit : Qubit.t = SumMod2 (Var v2, Var v4) in

            let new_poly : Poly.t =
              Poly.insert (Monome.Qubit (Var v2))
                (Poly.insert (Monome.Qubit (Var v4))
                   (Poly.insert
                      (Monome.Prod
                         ( Scal (Q.of_int (-2)),
                           Prod (Qubit (Var v2), Qubit (Var v4)) ))
                      Poly.empty))
            in

            if debug then (
              printf
                "Rules.variable_replacement_factorisation, new_qubit = %s\n\n%!"
                (QS.pretty new_qubit width);
              printf
                "Rules.variable_replacement_factorisation, new_poly = %s\n\n%!"
                (PS.pretty new_poly width));

            let poly_subst = Poly.substitute_poly poly v2 new_poly in
            let ket_subst = substitute_qubit_in_ket ket new_qubit (Var v2) in

            if debug then (
              printf
                "Rules.variable_replacement_factorisation, ket_subst = %s\n\n%!"
                (KS.pretty ket_subst);
              printf "Rules.variable_replacement_factorisation, poly = %s\n\n%!"
                (PS.pretty poly width);
              printf
                "Rules.variable_replacement_factorisation, poly_subst = %s\n\n\
                 %!"
                (PS.pretty poly_subst width));

            let out_state : Path_sum.t =
              {
                phase = poly_subst;
                ket = ket_subst;
                path_var = acc_state.path_var;
              }
            in

            if debug then
              printf
                "Rules.variable_replacement_factorisation, out_state =\n\
                 %s\n\n\
                 %!"
                (PSS.pretty out_state);

            let out_state_simplified = Simplification.simplify out_state in

            if debug then
              printf
                "Rules.variable_replacement_factorisation, \
                 out_state_simplified =\n\
                 %s\n\n\
                 %!"
                (PSS.pretty out_state_simplified);

            let number_of_sum_input = Ket.number_of_sum ket + Poly.size poly in
            let number_of_sum_out_state_simplified =
              Ket.number_of_sum out_state_simplified.ket
              + Poly.size out_state_simplified.phase
            in

            if debug then
              printf
                "Rules.variable_replacement_factorisation, number_of_sum_input \
                 = %d, number_of_sum_out_state_simplified = %d\n\n\
                 %!"
                number_of_sum_input number_of_sum_out_state_simplified;

            if number_of_sum_input <= number_of_sum_out_state_simplified then
              (* simplification not useful, continue with next monome *)
              factorize_step p1 acc_state
            (* else if number_of_sum_input = number_of_sum_out_state_simplified
            then Some acc_state *)
              else
              (* simplification done, restart from scratch with new state *)
              Some out_state_simplified
            (* factorize_step out_state_simplified.phase out_state_simplified true *)
        | _, _ ->
            (* no simplification, continue with next monome *)
            factorize_step p1 acc_state
    in

    match factorize_step state.phase state with
    | Some new_state -> Elim.elim new_state
    | None -> state

  let replace_not_path_var_by_var ?(debug = false) (input_state : Path_sum.t) =
    let k : Path_sum.Ket.t = input_state.ket in
    let width = Array.length k in

    let rec aux (i : int) (acc : Path_sum.t) =
      if i = width then acc
      else
        match k.(i) with
        | Qubit.SumMod2 (One, Var v) when width < v ->
            k.(i) <- Qubit.Var v;
            let p_from_q : Poly.t =
              Poly.insert
                Monome.(Scal (Q.of_int 1))
                (Poly.insert
                   (Prod (Scal (Q.of_int (-1)), Qubit (Var v)))
                   Poly.empty)
            in
            if debug then
              printf
                "Rules.replace_not_path_var_by_var, input_state.phase = %s\n\n\
                 %!"
                (PS.pretty input_state.phase width);
            if debug then
              printf "Rules.replace_not_path_var_by_var, v = %d\n\n%!" v;
            if debug then
              printf "Rules.replace_not_path_var_by_var, p_from_q = %s\n\n%!"
                (PS.pretty p_from_q width);
            let new_p =
              Poly.substitute_poly ~debug input_state.phase v p_from_q
            in
            let output_state : Path_sum.t =
              { phase = new_p; ket = k; path_var = input_state.path_var }
            in
            if debug then
              printf
                "Rules.replace_not_path_var_by_var, output_state =\n%s\n\n%!"
                (PSS.pretty output_state);
            let simplified_state = Simplification.simplify output_state in
            if debug then
              printf
                "Rules.replace_not_path_var_by_var, simplified_state =\n\
                 %s\n\n\
                 %!"
                (PSS.pretty simplified_state);
            aux (i + 1) simplified_state
        | _ -> aux (i + 1) acc
    in
    aux 0 input_state

  module Ket = Path_sum.Ket
  module ArrayBis = Common.ArrayBis

  (* Poly normalized :
    (1/2 * [x0] * [y1] + 1/2 * [y1] + 1/2 * [y2] * [y3])
    ->
    (1/2 * [x0] * [y0] + 1/2 * [y0] + 1/2 * [y1] * [y2]) *)
  let poly_normalized ?(debug = false) (ps : Path_sum.t) =
    if debug then
      printf "Rules.poly_normalised, input ps =\n%s\n%!" (PSS.pretty ps);

    let ps = Rename.rename ps in

    if debug then
      printf "Rules.poly_normalised, rename ps =\n%s\n%!" (PSS.pretty ps);

    let poly = ref ps.phase in
    let ket = ref ps.ket in
    let pvs = ps.path_var in
    if debug then
      printf "Rules.poly_normalised, pvs = %s\n%!" (ListBis.string_int pvs);

    let wq = Array.length !ket in
    (* Path var memoisation *)
    let nb_pvs = List.length pvs in
    let tmp = Array.make nb_pvs (-1) in

    if debug then printf "Rules.poly_normalised, wq = %d\n%!" wq;

    let path_var_poly =
      ListBis.remove_duplicate (Poly.extract_path_var !poly wq)
    in

    if debug then
      printf "Rules.poly_normalised, path_var_poly = %s\n%!"
        (ListBis.string_int path_var_poly);

    let path_var_ket = Ket.extract_path_var !ket in

    if debug then
      printf "Rules.poly_normalised, path_var_ket = %s\n%!"
        (ListBis.string_int path_var_ket);
    if debug then
      printf "Rules.poly_normalised, path_var_poly = %s\n\n%!"
        (ListBis.string_int path_var_poly);

    let tmp_construct path_var =
      let rec aux i l =
        if debug then
          printf
            "Rules.poly_normalised.tmp_construct, i = %d, l = %s, tmp = %s\n%!"
            i (ListBis.string_int l) (ArrayBis.string_int tmp);
        if wq <= i && i < wq + nb_pvs then
          match l with
          | hd :: tl ->
              if hd < wq || wq + nb_pvs < wq then
                failwith
                  "Rules Variable_replacement.polynormalized hd out of bounds";

              if tmp.(hd - wq) = -1 then (
                tmp.(hd - wq) <- i;
                aux (i + 1) tl)
              else aux i tl
          | [] -> ()
      in
      let starting_value = Int.max wq (ArrayBis.max_int tmp + 1) in
      if debug then
        printf "Rules.poly_normalised.tmp_construct, starting_value = %d\n%!"
          starting_value;
      aux starting_value path_var
    in

    if debug then printf "Rules.poly_normalised, wq = %d\n%!" wq;
    if debug then
      printf "Rules.poly_normalised, tmp = %s\n%!" (ArrayBis.string_int tmp);

    tmp_construct path_var_poly;

    if debug then
      printf "Rules.poly_normalised. path_var_poly, tmp = %s\n%!"
        (ArrayBis.string_int tmp);

    let tmp_list =
      List.rev
        (ListBis.remove (-1) (List.sort_uniq Int.compare (Array.to_list tmp)))
    in

    if debug then
      printf "Rules.poly_normalised. path_var_poly, tmp_list = %s\n%!"
        (ListBis.string_int tmp_list);

    let path_var_available =
      ListBis.missing_in_range ~lower:wq tmp_list (wq + nb_pvs)
    in

    if debug then
      printf "Rules.poly_normalised. path_var_poly, path_var_available = %s\n%!"
        (ListBis.string_int path_var_available);

    let complete_tmp_with_path_var_missing path_var_available =
      let rec aux i l =
        if nb_pvs <= i then ()
        else if tmp.(i) = -1 then
          match l with
          | hd :: tl ->
              tmp.(i) <- hd;
              aux (i + 1) tl
          | [] -> ()
        else aux (i + 1) l
      in
      aux 0 path_var_available
    in
    complete_tmp_with_path_var_missing path_var_available;

    if debug then
      printf "Rules.poly_normalised.aux path_var_available, tmp = %s\n\n%!"
        (ArrayBis.string_int tmp);

    for i = 0 to nb_pvs - 1 do
      if debug then printf "Rules.poly_normalised, -tmp(%d) = -%d\n%!" i tmp.(i);
      if tmp.(i) <> -1 then (
        poly := Poly.substitute (i + wq) !poly (Var (-tmp.(i)));
        ket := Ket.substitute !ket (i + wq) (Var (-tmp.(i))));

      if debug then
        printf "Rules.poly_normalised, [%d <- -%d]\n%!" (i + wq) tmp.(i);
      if debug then
        printf "Rules.poly_normalised, poly_acc = %s\n%!" (PS.pretty !poly wq);
      if debug then
        printf "Rules.poly_normalised, ket_acc = %s\n%!" (KS.pretty !ket)
    done;

    if debug then
      printf "Rules.poly_normalised, new_poly = %s\n%!" (PS.pretty !poly wq);
    if debug then
      printf "Rules.poly_normalised, new_ket = %s\n\n%!" (KS.pretty !ket);

    for i = 0 to nb_pvs - 1 do
      if debug then printf "Rules.poly_normalised, tmp(%d) = %d\n%!" i tmp.(i);
      if tmp.(i) <> -1 then (
        poly := Poly.substitute (-tmp.(i)) !poly (Var tmp.(i));
        ket := Ket.substitute !ket (-tmp.(i)) (Var tmp.(i)));

      if debug then
        printf "Rules.poly_normalised, [%d <- %d]\n%!" (i + wq) tmp.(i);
      if debug then
        printf "Rules.poly_normalised, poly_acc = %s\n%!" (PS.pretty !poly wq);
      if debug then
        printf "Rules.poly_normalised, ket_acc = %s\n%!" (KS.pretty !ket)
    done;

    if debug then
      printf "Rules.poly_normalised, new_poly = %s\n%!" (PS.pretty !poly wq);
    if debug then
      printf "Rules.poly_normalised, new_ket = %s\n\n%!" (KS.pretty !ket);

    let output : Path_sum.t =
      { phase = !poly; ket = !ket; path_var = ps.path_var }
    in
    output
end
