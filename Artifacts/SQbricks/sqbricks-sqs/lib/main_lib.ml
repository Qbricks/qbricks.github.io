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

(** Quantum Circuit Analysis and Transformation Tool.

    This program provides the following functionalities:
    - Equivalence checking between quantum circuits
    - Conversion of quantum circuits (written in QASM) to formats compatible
      with other tools
    - Transformation of unitary circuits to measurement-based quantum computing
      models
    - Analysis of hybrid quantum circuits
    - Generation of circuit metrics and statistics *)

open Printf
module PSS = Path_sum.String
module ProgS = Program.String
include Program.Macros
open Parser_get.GetProg
open Parser_get.GetPs
open Common

(** Prints equivalence result with performance metrics. *)
let print_result res start_time end_time start_mem end_mem =
  printf "Equiv: %s, \n" (Equiv.result_to_string res);
  printf "Execution time = %f seconds, Memory = %f MB\n" (end_time -. start_time)
    ((end_mem -. start_mem) /. (1024.0 *. 1024.0))

(** Prints result in CSV format (time or status). Outputs execution time for
    equivalent circuits, or status otherwise. *)
let print_result_csv res start_time end_time =
  match res with
  | Equiv.SubCircuitEquivalent | Equiv.FullCircuitEquivalent
  | Equiv.GlobalPhaseEquivalent ->
      printf "%f%!" (end_time -. start_time)
  | _ -> printf "%s%!" (Equiv.result_to_string res)

(** Parses a quantum program from QASM file. *)
let parse_prog input =
  let extension = Filename.extension input in
  if extension = ".qasm" then
    let prog = Program.format (to_prog input) in
    prog
  else failwith (sprintf "Unsupported file format: %s" input)

(** Parses a path sum from text file. *)
let input_to_ps input =
  let extension = Filename.extension input in
  if extension = ".txt" then
    let ps = to_ps input in
    ps
  else failwith (sprintf "Unsupported file format: %s" input)

(** Converts equivalence relation string to type. s -> SubCircuit, f ->
    FullCircuit, g -> GlobalPhase *)
let parse_equiv eq =
  match eq with
  | "s" -> Equiv.SubCircuit
  | "f" -> Equiv.FullCircuit
  | "g" -> Equiv.GlobalPhase
  | _ -> failwith (sprintf "Unknown equivalence relation: %s" eq)

(** Converts algorithm string to type. seq -> Sequence, par -> Parallel *)
let parse_algo algo =
  match algo with
  | "seq" -> Equiv.Sequence
  | "par" -> Equiv.Parallel
  | _ -> failwith (sprintf "Unknown algorithm: %s" algo)

(** Safely parses optional integer list string. Returns empty list for empty
    string, parsed list otherwise. *)
let parse_list_opt s =
  match s with "" -> [] | s -> ListBis.of_string_to_int_list s

let debug = false
let input_files = ref []
let nb_gates_csv = ref false

(* let nb_gates = ref false *)
let qasm_to_ps = ref false
let qasm_to_feynman = ref false
let qasm_to_pyzx = ref false
let qasm_to_autoq = ref false
let sql = ref false
let qasm_to_owm = ref false
let qasm_to_tele = ref false
let sqv = ref false
let sq = ref false
let sqv_specs = ref false
let metrics = ref false
let usage_msg = "append [-verbose] <file1> [<file2>] ... -o <output>"
let anon_fun filename = input_files := filename :: !input_files

let speclist =
  [
    ( "-sqv",
      Arg.Set sqv,
      "<algo> <equiv> <c1.qasm> <c2.qasm> [inputs1] [inputs2] [outputs1] \
       [outputs2] [meas1] [meas2] verbose\n"
      ^ "Example: -sqv seq s c1.qasm c2.qasm \"[0;1]\" \"[0;1]\" \"[0]\" \
         \"[0]\" \"[0;1]\" \"[]\" true" );
    ( "-sql",
      Arg.Set sql,
      "<dm> <p-input.qasm> <p-output.qasm>\n"
      ^ "Example: -sql u input.qasm output.qasm" );
    ( "-sq",
      Arg.Set sq,
      "<algo> <equiv> <c1.qasm> <c2.qasm> verbose\n"
      ^ "Example: -sq seq s c1.qasm c2.qasm true" );
    ( "-sqv_specs",
      Arg.Set sqv_specs,
      "<p.qasm> <precondition.txt> <postcondition.txt>\n"
      ^ "Example: -sqv_specs circuit.qasm pre.txt post.txt" );
    ( "-qasm_to_ps",
      Arg.Set qasm_to_ps,
      "<input.qasm>\n" ^ "Example: -qasm_to_ps circuit.qasm" );
    ( "-qasm_to_feynman",
      Arg.Set qasm_to_feynman,
      "-qasm_to_feynman <input.qasm> <output.qasm>\n"
      ^ "Example: -qasm_to_feynman output.qasm input.qasm" );
    ( "-qasm_to_pyzx",
      Arg.Set qasm_to_pyzx,
      "-qasm_to_pyzx <input.qasm> <output.qasm>\n"
      ^ "Example: -qasm_to_pyzx output.qasm input.qasm" );
    ( "-qasm_to_autoq",
      Arg.Set qasm_to_autoq,
      "-qasm_to_autoq <input.qasm> <output.qasm>\n"
      ^ "Example: -qasm_to_autoq output.qasm input.qasm" );
    ( "-qasm_to_owm",
      Arg.Set qasm_to_owm,
      "-qasm_to_owm <input.qasm> <output.qasm> <dm>\n"
      ^ "Example: -qasm_to_owm output.qasm input.qasm true" );
    ( "-qasm_to_tele",
      Arg.Set qasm_to_tele,
      "-qasm_to_tele <input.qasm> <output.qasm> <dm>\n"
      ^ "Example: -qasm_to_tele true output.qasm input.qasm" );
    ( "-nb_gates_csv",
      Arg.Set nb_gates_csv,
      "<circuit1.qasm> <circuit2.qasm>\n"
      ^ "Example: -nb_gates_csv circuit1.qasm circuit2.qasm" );
    ( "-metrics",
      Arg.Set metrics,
      "<circuit.qasm>\n" ^ "Example: -metrics circuit.qasm" );
  ]

let run () =
  Arg.parse speclist anon_fun usage_msg;
  if !sqv then
    (* --- Helper: print usage --- *)
    let usage () =
      eprintf
        {|
  Usage:
    dune exec -- ./bin/main.exe -sqv <algo> <equiv> <p1.qasm> <p2.qasm>
         [inputs1] [inputs2] [outputs1] [outputs2] [meas1] [meas2] [verbose]
  
  Arguments:
    <algo>        : "seq" | "par"
    <equiv>       : "s" | "f" | "g"
    <p1.qasm>     : Path to first QASM file
    <p2.qasm>     : Path to second QASM file
    [inputs1]     : Integer list (e.g. "[0;1]")
    [inputs2]     : Integer list (e.g. "[0;1]")
    [outputs1]    : Integer list (e.g. "[0;1]")
    [outputs2]    : Integer list (e.g. "[0;1]")
    [meas1]       : Integer list (e.g. "[0;1]")
    [meas2]       : Integer list (e.g. "[0;1]")
    [verbose]     : "true" or "false"
  |};
      exit 1
    in

    (* --- Main function --- *)
    let run_sqv_test ?(debug = false) ?(inputs1_str = "") ?(inputs2_str = "")
        ?(outputs1_str = "") ?(outputs2_str = "") ?(meas1_str = "")
        ?(meas2_str = "") ?(equivalence = "-s") ?(algo = "-seq") p1 p2 =
      let equivalence = parse_equiv equivalence in
      let algo = parse_algo algo in
      let p1 = parse_prog p1 in
      let p2 = parse_prog p2 in

      let inputs1 = parse_list_opt inputs1_str in
      let inputs2 = parse_list_opt inputs2_str in
      let outputs1 = parse_list_opt outputs1_str in
      let outputs2 = parse_list_opt outputs2_str in
      let meas1 = parse_list_opt meas1_str in
      let meas2 = parse_list_opt meas2_str in

      if debug then (
        printf "Main.sqv:\n  p1 =\n%s\n  p2 =\n%s\n\n%!" (ProgS.pretty p1)
          (ProgS.pretty p2);
        printf
          "inputs1=%s, inputs2=%s, outputs1=%s, outputs2=%s, meas1=%s, meas2=%s\n\
           %!"
          inputs1_str inputs2_str outputs1_str outputs2_str meas1_str meas2_str);

      let start_time = Unix.gettimeofday () in
      let start_mem = Gc.allocated_bytes () in

      let result =
        Equiv.sqv ~debug ~algo ~equivalence ~inputs1 ~inputs2 ~outputs1
          ~outputs2 ~meas1 ~meas2 p1 p2
      in

      let end_time = Unix.gettimeofday () in
      let end_mem = Gc.allocated_bytes () in

      if debug then print_result result start_time end_time start_mem end_mem
      else print_result_csv result start_time end_time
    in

    (* --- Argument parsing --- *)
    match List.rev !input_files with
    | [
     algo;
     equivalence;
     p1;
     p2;
     inputs1;
     inputs2;
     outputs1;
     outputs2;
     meas1;
     meas2;
     verbose;
    ] ->
        let debug = verbose = "true" in
        run_sqv_test ~debug ~inputs1_str:inputs1 ~inputs2_str:inputs2
          ~outputs1_str:outputs1 ~outputs2_str:outputs2 ~meas1_str:meas1
          ~meas2_str:meas2 ~equivalence ~algo p1 p2
    | [
     algo;
     equivalence;
     p1;
     p2;
     inputs1;
     inputs2;
     outputs1;
     outputs2;
     meas1;
     meas2;
    ] ->
        run_sqv_test ~inputs1_str:inputs1 ~inputs2_str:inputs2
          ~outputs1_str:outputs1 ~outputs2_str:outputs2 ~meas1_str:meas1
          ~meas2_str:meas2 ~equivalence ~algo p1 p2
    | [ algo; equivalence; p1; p2; verbose ] ->
        let debug = verbose = "true" in
        run_sqv_test ~debug ~equivalence ~algo p1 p2
    | [ algo; equivalence; p1; p2 ] -> run_sqv_test ~equivalence ~algo p1 p2
    | _ -> usage ()
  else if !sq then
    (* Measured qubits are discarded *)
    let test ?(debug = false) ?(inputs1 = []) ?(inputs2 = []) ?(outputs1 = [])
        ?(outputs2 = []) equivalence algo p1 p2 =
      if debug then printf "Main.sqv, p1 =\n%s\n\n%!" (ProgS.pretty p1);
      if debug then printf "Main.sqv, p2 =\n%s\n\n%!" (ProgS.pretty p2);
      let algo = parse_algo algo in
      let equivalence = parse_equiv equivalence in

      let start_time = Unix.gettimeofday () in
      let start_mem = Gc.allocated_bytes () in
      let result =
        match algo with
        | Parallel ->
            Equiv.parallel ~debug ~equivalence ~inputs1 ~inputs2 ~outputs1
              ~outputs2 p1 p2
        | Sequence ->
            Equiv.seq ~debug ~equivalence ~inputs1 ~inputs2 ~outputs1 ~outputs2
              p1 p2
      in
      let end_time = Unix.gettimeofday () in
      let end_mem = Gc.allocated_bytes () in
      if debug then print_result result start_time end_time start_mem end_mem
      else print_result_csv result start_time end_time
    in
    let usage () =
      eprintf
        {|
  Usage:
    dune exec -- ./bin/main.exe -sqv <algo> <equiv> <p1.qasm> <p2.qasm>
         [inputs1] [inputs2] [outputs1] [outputs2] [verbose]

  Arguments:
    <algo>        : seq | par
    <equiv>       : s | f | g
    <p1.qasm>     : Path to first QASM file
    <p2.qasm>     : Path to second QASM file
    [verbose]     : "true" or "false"
  |};
      exit 1
    in

    let dm ?(debug = false) p1 p2 =
      let u1, inits1, meas1 =
        To_deferred_measurement.to_deferred_measurements (parse_prog p1)
      in
      let u2, inits2, meas2 =
        To_deferred_measurement.to_deferred_measurements (parse_prog p2)
      in
      let _, wq1 = Program.widths u1 in
      let _, wq2 = Program.widths u2 in
      let inputs1 = ListBis.missing_in_range inits1 wq1 in
      let inputs2 = ListBis.missing_in_range inits2 wq2 in
      let outputs1 = ListBis.missing_in_range meas1 wq1 in
      let outputs2 = ListBis.missing_in_range meas2 wq2 in
      if debug then
        Printf.printf
          "Main.sq, inits1 = %s, inits2 = %s, meas1 = %s, meas2 = %s, inputs1 \
           = %s, inputs2 = %s, outputs1 = %s, outputs2 = %s\n\n\
           %!"
          (ListBis.string_int inits1)
          (ListBis.string_int inits2)
          (ListBis.string_int meas1) (ListBis.string_int meas2)
          (ListBis.string_int inputs1)
          (ListBis.string_int inputs2)
          (ListBis.string_int outputs1)
          (ListBis.string_int outputs2);
      (u1, u2, inputs1, inputs2, outputs1, outputs2)
    in
    match List.rev !input_files with
    | [ algo; equivalence; p1; p2; verbose ] ->
        let debug = verbose = "true" in
        let u1, u2, inputs1, inputs2, outputs1, outputs2 = dm ~debug p1 p2 in
        test ~debug ~inputs1 ~inputs2 ~outputs1 ~outputs2 equivalence algo u1 u2
    | [ algo; equivalence; p1; p2 ] ->
        let u1, u2, inputs1, inputs2, outputs1, outputs2 = dm ~debug p1 p2 in
        test ~inputs1 ~inputs2 ~outputs1 ~outputs2 equivalence algo u1 u2
    | _ -> usage ()
  else if !qasm_to_feynman then
    let input_file = List.nth !input_files 1 in
    let output_file = List.nth !input_files 0 in
    let prog = to_prog input_file in
    let wq, wc = Program.widths prog in
    let inputs =
      List.rev (ListBis.missing_in_range (Program.inits prog) (wq + wc))
    in
    To_feynman.print_to_file_fm output_file prog ~inputs
  else if !qasm_to_pyzx then (
    let input_file = List.nth !input_files 1 in
    let output_file = List.nth !input_files 0 in
    if debug then printf "Main.qasm_to_pyzx, input_file = %s\n\n%!" input_file;
    if debug then printf "Main.qasm_to_pyzx, output_file = %s\n\n%!" output_file;
    let p = Program.format (to_prog input_file) in
    if debug then printf "Main.qasm_to_pyzx, p =\n%s\n\n%!" (ProgS.pretty p);
    To_openqasm.print_to_file_oq_free_folder ~for_pyzx:true output_file p)
  else if !qasm_to_autoq then (
    let input_file = List.nth !input_files 1 in
    let output_file = List.nth !input_files 0 in
    if debug then printf "Main.qasm_to_autoq, input_file = %s\n\n%!" input_file;
    if debug then
      printf "Main.qasm_to_autoq, output_file = %s\n\n%!" output_file;
    let p = Program.format (to_prog input_file) in
    if debug then printf "Main.qasm_to_autoq, p =\n%s\n\n%!" (ProgS.pretty p);
    To_openqasm.print_to_file_oq_free_folder ~for_autoq:true output_file p)
  else if !sql then (
    let debug = false in
    let algo = List.nth !input_files 2 in
    let input_file = List.nth !input_files 1 in
    let output_file = List.nth !input_files 0 in
    if debug then printf "Main.sql, input_file = %s\n\n%!" input_file;
    let p = Program.format (to_prog input_file) in
    if debug then printf "Main.sql, p =\n%s\n\n%!" (ProgS.pretty p);
    let dm, inits, meas = To_deferred_measurement.to_deferred_measurements p in
    if debug then
      printf "Main.qasm_to_ium, inits = %s, meas = %s\n%!"
        (ListBis.string_int inits) (ListBis.string_int meas);
    let output =
      if algo = "u" then Program.format dm
      else if algo = "ium" then
        Program.format (apply_inits (apply_measure dm meas 0) inits)
      else
        failwith
          "choose \"u\" for unitary and \"ium\" for initialized-unitary-measure"
    in
    if debug then
      printf "Main.qasm_to_ium, output =\n%s\n\n%!" (ProgS.pretty output);
    (* Return a qasm file and a list of measured qubits *)
    printf "%s" (ListBis.string_int meas);
    To_openqasm.print_to_file_oq_free_folder output_file output)
  else if !qasm_to_owm then (
    let debug = false in
    let input_file = List.nth !input_files 2 in

    let output_file_by_meas = List.nth !input_files 1 in
    let dm = bool_of_string (List.nth !input_files 0) in
    let p = Program.format (to_prog input_file) in
    if debug then printf "Main.qasm_to_owm, p =\n%s\n\n" (ProgS.pretty p);

    let by_meas, inputs, outputs = Owm.to_owm p ~dm in
    printf "%s,%s" (ListBis.string_int inputs) (ListBis.string_int outputs);

    let by_meas = Program.format by_meas in

    To_openqasm.print_to_file_oq_free_folder output_file_by_meas by_meas)
  else if !qasm_to_tele then (
    let debug = false in
    let input_file = List.nth !input_files 2 in
    let output_file_by_meas = List.nth !input_files 1 in
    let dm = bool_of_string (List.nth !input_files 0) in
    let p = Program.format (to_prog input_file) in
    if debug then printf "Main.qasm_to_tele, p =\n%s\n\n" (ProgS.pretty p);

    let by_meas, inputs, outputs = Teleportation.to_teleport p ~dm in
    printf "%s,%s" (ListBis.string_int inputs) (ListBis.string_int outputs);

    let by_meas = Program.format by_meas in

    To_openqasm.print_to_file_oq_free_folder output_file_by_meas by_meas)
  else if !qasm_to_ps then (
    let p = parse_prog (List.nth !input_files 0) in
    let ps = Reduction_algorithm.reduction_algorithm (Program.execution p) in
    printf "p =\n%s\n\n" (ProgS.pretty p);
    printf "ps =\n%s\n\n" (PSS.pretty ps))
  else if !nb_gates_csv then (
    let debug = false in
    let prog1 = parse_prog (List.nth !input_files 0) in
    let prog2 = parse_prog (List.nth !input_files 1) in

    let nb_ch, nb_cs, nb_cz, nb_ccz, nb_ccx, nb_cu1, nb_total =
      Program.nb_gate_and_gates_decomposition prog1
    in

    let nb_ch', nb_cs', nb_cz', nb_ccz', nb_ccx', nb_cu1', nb_total' =
      Program.nb_gate_and_gates_decomposition prog2
    in
    if debug then
      printf
        "ch = %d, cs = %d, cz = %d, ccz = %d, ccx = %d, cu1 = %d, total = %d\n"
        (nb_ch + nb_ch') (nb_cs + nb_cs') (nb_cz + nb_cz') (nb_ccz + nb_ccz')
        (nb_ccx + nb_ccx') (nb_cu1 + nb_cu1') (nb_total + nb_total');

    printf "%d;%d;%d;%d;%d;%d;%d\n" (nb_ch + nb_ch') (nb_cs + nb_cs')
      (nb_cz + nb_cz') (nb_ccz + nb_ccz') (nb_ccx + nb_ccx') (nb_cu1 + nb_cu1')
      (nb_total + nb_total'))
  else if !metrics then
    let p = parse_prog (List.nth !input_files 0) in

    let _, _, _, _, _, _, nb_total =
      Program.nb_gate_and_gates_decomposition p
    in
    let wc, wq = Program.widths p in
    printf "number of qubits = %d, number of bits = %d, nb gates = %d\n\n%!" wq
      wc nb_total
  else if !sqv_specs then (
    let debug = true in
    let prog = List.nth !input_files 2 in
    let pre = List.nth !input_files 1 in
    let post = List.nth !input_files 0 in
    let pre = input_to_ps pre in
    if debug then printf "Main.sqv_specs,\npre =\n%s\n\n" (PSS.pretty pre);
    let prog = parse_prog prog in
    if debug then printf "Main.sqv_specs, c = %s\n\n" (ProgS.pretty prog);
    let post = input_to_ps post in
    if debug then printf "Main.sqv_specs,\npost =\n%s\n\n" (PSS.pretty post);
    let unit, _, _ = To_deferred_measurement.to_deferred_measurements prog in
    let ps = Program.execution ~input_state:pre unit in
    if debug then printf "Main.sqv_specs,\nout ps =\n%s\n\n" (PSS.pretty ps);
    let result = Path_sum.equal ps post in
    if result then printf "OK\n" else printf "KO\n")
