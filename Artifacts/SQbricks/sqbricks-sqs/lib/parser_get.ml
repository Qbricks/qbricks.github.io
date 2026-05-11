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

module GetProg = struct
  open Parser_OpenQASM
  open Lexer_OpenQASM
  open Common

  let getProg file =
    let c = open_in file in
    let lb = Lexing.from_channel c in
    program token lb

  let to_prog ?(debug = false) input =
    let extension = Filename.extension input in
    if extension = ".qasm" then (
      let root_path = FileBis.find_root_path input in
      if debug then
        Printf.printf "Verif.input_to_prog, root_path = %s%!" root_path;
      let prog = getProg (root_path ^ input) in
      prog)
    else
      failwith
        (Printf.sprintf "Test.verif.input_to_prog, Not authorized, input = %s\n"
           input)
end

module GetPs = struct
  open Parser_Path_sum
  open Lexer_Path_sum
  open Common

  let getPS file =
    let c = open_in file in
    let lb = Lexing.from_channel c in
    path_sum token lb

  let to_ps ?(debug = false) input =
    let extension = Filename.extension input in
    if extension = ".txt" then (
      let root_path = FileBis.find_root_path input in
      if debug then
        Printf.printf "Verif.input_to_ps, root_path = %s%!" root_path;
      let prog = getPS (root_path ^ input) in
      prog)
    else
      failwith
        (Printf.sprintf "Test.verif.input_to_ps, Not authorized, input = %s\n"
           input)
end
