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

(** This module provides the main functions of SQbricks.

    Equivalence checking between:
    - Unitary circuits: [-sqv]
    - Hybrid circuits: [-sq]

    Specification verification: [-sqv_specs]

    Deferred Measurement transformation: [-sql]

    Conversions to:
    - {{:https://github.com/meamy/feynman}Feynman}: [-qasm_feynman]
    - {{:https://github.com/fmlab-iis/AutoQ/tree/main}AutoQ}: [qasm_to_autoq]
    - {{:https://pyzx.readthedocs.io/en/latest/}PyZX}: [-qasm_to_pyzx])

    Circuit transformations:
    - One-way measurement: [-qasm_owm]
    - Teleportation: [-qasm_tele]

    Path Sum Generation: [-qasm_to_ps] *)

(** {1 Main Command Line Interface}

    The tool is invoked with: [dune exec -- ./bin/main.exe [Options]] *)

(** {1 Options} *)

(** {2 Equivalence Checking} *)

(** [-sqv <a> <e> <c1.qasm> <c2.qasm> [in1] [in2] [out1] [out2] [m1] [m2] [v]]

    Runs equivalence checking between the {b unitary} circuits [c1] and [c2].

    - [a]: Algorithm type, ["seq"] (sequential) or ["par"] (parallel)
    - [e]: Equivalence type, ["s"] (SubCircuit), or ["g"] (GlobalPhase)
    - [c1]: Path to first QASM file (e.g. ["qft.qasm"])
    - [c2]: Path to second QASM file (e.g. ["qft_owm.qasm"])
    - [in1]: Input qubits for first circuit (e.g. ["[0;1]"])
    - [in2]: Input qubits for second circuit (e.g. ["[0;1]"])
    - [out1]: Output qubits for first circuit (e.g. ["[0;1]"])
    - [out2]: Output qubits for second circuit (e.g. ["[0;1]"])
    - [m1]: Measured qubits for first circuit (e.g. ["[0;1]"])
    - [m2]: Measured qubits for second circuit (e.g. ["[0;1]"])
    - [v]: Enable verbose output (e.g. ["true"])

    Example:
    {[
      dune exec -- ./bin/main.exe -sqv seq s \\
        benchmarks/minimal-examples/h.qasm benchmarks/minimal-examples/h.qasm \\
        "[0]" "[0]" "[0]" "[0]" "[]" "[]" true

      Return:
        ...
        Equiv: SubCircuitEquivalent,
        Execution time = 0.000918 seconds, Memory = 0.015037 MB
    ]} *)

(** [-sq <a> <e> <c1.qasm> <c2.qasm> [v]]

    Runs equivalence checking between the {b hybrid} circuits [c1] and [c2].

    - [a]: Algorithm type, ["seq"] (sequential) or ["par"] (parallel)
    - [e]: Equivalence type, ["s"] (SubCircuit), or ["g"] (GlobalPhase)
    - [c1]: Path to first QASM file (e.g. ["dynamic_qft.qasm"])
    - [c2]: Path to second QASM file (e.g. ["qft.qasm"])
    - [v]: Enable verbose output

    Example:
    {[
      dune exec -- ./bin/main.exe -sq par s \\
        benchmarks/minimal-examples/h-tele.qasm benchmarks/minimal-examples/h-owm.qasm true

      Return:
        ...
        Equiv: SubCircuitEquivalent,
        Execution time = 0.000170 seconds, Memory = 0.019487 MB
    ]} *)

(** {2 Specification Verification} *)

(** [-sqv_specs <pre.txt> <post.txt> <p.qasm>]

    Verifies circuit against formal specifications.

    - [pre.txt]: Precondition file
    - [post.txt]: Postcondition file
    - [p.qasm]: Circuit to verify

    Example:
    {[
      dune exec -- ./bin/main.exe -sqv_specs \\
        benchmarks/verif/h/circ.qasm  benchmarks/verif/h/pre.txt benchmarks/verif/h/post.txt

      Return:
        Main.sqv_specs,
        pre =
          phase = e^{2.π.i.(0)};
          ket =  |x0>;
          path_var = [];

        Main.sqv_specs, c = h 0

        Main.sqv_specs,
        post =
          phase = e^{2.π.i.(1/2 * [x0] * [y0])};
          ket =  |y0>;
          path_var = [y0];

        Main.sqv_specs,
        out ps =
          phase = e^{2.π.i.(1/2 * [x0] * [y0])};
          ket =  |y0>;
          path_var = [y0];

        OK
    ]} *)

(** {2 Deferred Measurement} *)

(** [-sql <in.qasm> <out.qasm> <dm>]

    Applies the deferred measurement to [in.qasm].

    - [in.qasm]: Input QASM file
    - [out.qasm]: Output QASM file
    - [dm]: Deferred Measurement type, ["u"] (unitary circuit) or ["ium"]
      (initialised-unitary-measurement circuit)
    - [Return]: List of measurements index

    Example:
    {[
      dune exec -- ./bin/main.exe -sql u \\
        benchmarks/minimal-examples/h-tele.qasm benchmarks/minimal-examples/h-tele-u.qasm

      Return: "[0;1]"
    ]} *)

(** {2 Circuit Conversions} *)

(** [-qasm_to_autoq <in.qasm> <out.qasm>] converts OpenQASM to AutoQ format.

    - [in.qasm] Input QASM file
    - [out.qasm] Output QASM file

    Example:
    {[
      dune exec -- ./bin/main.exe -qasm_to_autoq \\
        benchmarks/minimal-examples/h.qasm benchmarks/minimal-examples/h-autoq.qasm
    ]} *)

(** [-qasm_to_feynman <in.qasm> <out.qasm>] converts OpenQASM to
    Feynman-compatible format.

    - [in.qasm]: Input QASM file
    - [out.qasm]: Output QASM file

    Example:
    {[
      dune exec -- ./bin/main.exe -qasm_to_feynman \\
        benchmarks/minimal-examples/h.qasm benchmarks/minimal-examples/h-feynman.qasm
    ]} *)

(** [-qasm_to_pyzx <in.qasm> <out.qasm>] converts OpenQASM to PyZX format.

    - [in.qasm]: Input QASM file
    - [out.qasm]: Output QASM file

    Example:
    {[
      dune exec -- ./bin/main.exe -qasm_to_feynman \\
        benchmarks/minimal-examples/h.qasm benchmarks/minimal-examples/h-feynman.qasm
    ]} *)

(** {2 Circuit Transformations} *)

(** [-qasm_to_owm <in.qasm> <out.qasm> <dm>]

    Converts to One-Way Measurement model.

    - [in.qasm]: Input QASM file
    - [out.qasm]: Output QASM file
    - [dm]: Deferred measurement flag (true/false)
    - [Return]: list of inputs and outputs index

    Example:
    {[
      dune exec -- ./bin/main.exe -qasm_to_owm \\
        benchmarks/minimal-examples/h.qasm benchmarks/minimal-examples/h-owm.qasm false

      Return: "[0],[1]"
    ]} *)

(** [-qasm_to_tele <in.qasm> <out.qasm> <dm>]

    Generates quantum teleportation circuit.

    - [in.qasm]: Input QASM file
    - [out.qasm]: Output QASM file
    - [dm]: Deferred measurement flag (true/false)
    - [Return]: list of inputs and outputs index

    Example:
    {[
      dune exec -- ./bin/main.exe -qasm_to_tele \\
        benchmarks/minimal-examples/h.qasm benchmarks/minimal-examples/h-tele.qasm false

      Return: "[0],[2]"
    ]} *)

(** {2 Path Sum Generation} *)

(** [-qasm_to_ps <in.qasm>] converts QASM to path sum representation.

    - [in.qasm]: Input QASM file

    Example:
    {[
      dune exec -- ./bin/main.exe -qasm_to_ps circuit.qasm
    ]} *)

(**/**)

(** {1 Entry Point} *)

val run : unit -> unit
(** [run ()] is the main entry point.

    Parses command-line arguments and executes the requested command. *)
