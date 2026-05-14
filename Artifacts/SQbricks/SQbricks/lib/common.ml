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

module IntMap = Map.Make (Int)

let to_string_int_map map =
  let bindings = IntMap.bindings map in
  let string_of_binding (key, value) = Printf.sprintf "(%d, %d)" key value in
  "[" ^ String.concat "; " (List.map string_of_binding bindings) ^ "]"

module ArrayBis = struct
  let string a str =
    let n = Array.length a in
    let res = ref "" in
    for i = 0 to n - 1 do
      res := !res ^ str a.(i) ^ if Int.equal i (n - 1) then "" else ";"
    done;
    !res

  let string_int a = string a Int.to_string

  let max_int a =
    let length = Array.length a in
    let max = ref Int.min_int in
    for i = 0 to length - 1 do
      max := if !max < a.(i) then a.(i) else !max
    done;
    !max
end

module ListBis = struct
  open List

  let string l string_of =
    let rec aux l string_of =
      match l with
      | h :: [] -> string_of h
      | h :: t -> string_of h ^ ";" ^ aux t string_of
      | [] -> ""
    in
    "[" ^ aux l string_of ^ "]"

  let string_int l = string l string_of_int

  let y_string_of_int n i =
    if i >= n then "y" ^ string_of_int (i - n)
    else failwith (Printf.sprintf "ListBis.y_string_of_int, i = %d, n = %d" i n)

  let y_string_int l n = string (List.sort Int.compare l) (y_string_of_int n)

  let rec max' l max ge =
    match l with
    | h :: l' when ge h max -> max' l' h ge
    | _ :: l' -> max' l' max ge
    | [] -> max

  let max_int l = max' l 0 ( > )

  let rec min' l min le =
    match l with
    | h :: l' when le h min -> min' l' h le
    | _ :: l' -> min' l' min le
    | [] -> min

  let min_int l = min' l 0 ( < )

  let rec member (e : 'a) (l : 'a list) (equal : 'a -> 'a -> bool) =
    match l with
    | h :: _ when equal h e -> true
    | _ :: l' -> member e l' equal
    | [] -> false

  let increment lst k = List.map (fun x -> x + k) lst
  let increment_by_coeff lst k = List.map (fun x -> x * k) lst

  let increment_by_coeff_and_add lst k1 k2 =
    List.map (fun x -> (x * k1) + k2) lst

  (* [lower; 1; ...; w-1] - l *)
  let missing_in_range ?(lower = 0) l w =
    let rec aux i acc =
      if i < w then
        if member i l ( = ) then aux (i + 1) acc else aux (i + 1) (i :: acc)
      else acc
    in
    List.rev (aux lower [])

  (* [n1; n1+1; ...; n2-1] *)
  let range n1 n2 =
    let rec aux n1 acc = if n1 >= n2 then acc else aux (n1 + 1) (n1 :: acc) in
    List.rev (aux n1 [])

  (* forall i in lst -> i in [a,b] *)
  let check_bounds a b lst = not (List.for_all (fun x -> a <= x && x < b) lst)

  let generate_int_list_from_a_to_b_with_step a b step =
    let rec aux i acc = if i < b then aux (i + step) (i :: acc) else acc in
    List.rev (aux a [])

  let remove ?(eq = Int.equal) i l =
    let rec aux acc = function
      | hd :: tl -> if eq hd i then aux acc tl else aux (hd :: acc) tl
      | [] -> acc
    in
    aux [] l

  let remove_duplicate l =
    let rec aux acc = function
      | hd :: tl when not (List.mem hd acc) -> aux (hd :: acc) tl
      | _ :: tl -> aux acc tl
      | [] -> acc
    in
    List.rev (aux [] l)

  let is_decrease ?(lower = 0) l =
    let rec aux = function
      | hd1 :: hd2 :: tl -> hd2 < hd1 && aux tl
      | hd :: [] -> hd = lower
      | [] -> true
    in
    aux l

  let substitute old old_val new_val =
    List.map (fun v -> if v = old_val then new_val else v) old

  let remove_list l_to_remove l =
    let rec aux acc = function hd :: tl -> aux (remove hd l) tl | [] -> acc in
    aux [] l_to_remove

  let of_string_to_int_list s =
    if String.equal s "" then []
    else
      (* Removes square brackets *)
      let s = String.sub s 1 (String.length s - 2) in
      (* Separates the string into a list of substrings *)
      let str_list = String.split_on_char ';' s in
      (* Converts each element to an integer *)
      if String.equal (String.concat "; " str_list) "" then []
      else List.map int_of_string str_list

  let extract_upper_bound_list bound list =
    let rec aux acc = function
      | hd :: tl -> if bound <= hd then aux (hd :: acc) tl else aux acc tl
      | [] -> acc
    in
    aux [] list

  let extract_lower_bound_list bound list =
    let rec aux acc = function
      | hd :: tl -> if hd < bound then aux (hd :: acc) tl else aux acc tl
      | [] -> acc
    in
    aux [] list

  let intersect l1 l2 =
    let l2_sorted = List.sort_uniq Int.compare l2 in
    let common_elements = List.filter (fun x -> List.mem x l2_sorted) l1 in
    List.sort_uniq Int.compare common_elements
end

module Rational = struct
  open Printf

  let divk k = Q.div_2exp Q.one k
  let div2 = divk 1
  let div4 = divk 2
  let div8 = divk 3
  let divmk k = Q.div_2exp Q.minus_one k
  let divm2 = divmk 1
  let divm4 = divmk 2
  let divm8 = divmk 3
  let two = Q.of_int 2
  let four = Q.of_int 4
  let minus_two = Q.of_int (-2)
  let pow2Q k = Q.mul_2exp Q.one k
  let pow2Z k = Z.pow (Z.of_int 2) k

  (* Function for calculating the exponent k such that den = 2^k *)
  let find_k den =
    if Z.(logand den (den - one)) = Z.zero then Z.log2 den
    else failwith (sprintf "ZarithBis. find_k, den = %s\n" (Z.to_string den))

  let coef_lift (s : Q.t) : Q.t =
    let den : Z.t = Q.den s in
    let k : int = find_k den in
    let result = Q.sub (pow2Q k) two in
    result

  let ( /// ) num den = Q.make (Z.of_int num) (Z.of_int den)
end

module StringBis = struct
  let capitalize_first_character (s : string) : string =
    match String.length s with
    | 0 -> s (* Returns string unchanged if empty *)
    | _ ->
        let first_char = Char.uppercase_ascii s.[0] in
        let rest_of_string = String.sub s 1 (String.length s - 1) in
        String.make 1 first_char ^ rest_of_string

  let extract_filename (path : string) : string =
    let parts = String.split_on_char '/' path in
    match List.rev parts with
    | [] -> "" (* Path is empty, returns an empty string *)
    | hd :: _ -> (
        match String.split_on_char '.' hd with
        | filename :: _ -> filename
        | _ -> hd)
end

module FileBis = struct
  let find_root_path input =
    let possible_paths = [ "../../../../"; "../../../"; "../../"; "../"; "" ] in
    List.find_opt
      (fun prefix -> Sys.file_exists (prefix ^ input))
      possible_paths
    |> Option.value ~default:""
end
