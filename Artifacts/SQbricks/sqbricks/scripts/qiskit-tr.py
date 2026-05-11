#  This file is part of SQbricks.
#
#  Copyright (C) 2022-2025
#  CEA (Commissariat à l'énergie atomique et aux énergies alternatives)
#  Université Paris-Saclay
#
#  you can redistribute it and/or modify it under the terms of the GNU
#  Lesser General Public License as published by the Free Software
#  Foundation, version 2.1.
#
#  It is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  See the GNU Lesser General Public License version 2.1
#  for more details (enclosed in the file licenses/LGPLv2.1).

import sys
from qiskit import qasm2
from qiskit.circuit import QuantumCircuit
from qiskit.transpiler.preset_passmanagers import generate_preset_pass_manager
import os


def qiskit_tr(input_file, output_file):
    with open(input_file, "r") as file:
        qasm = file.read()
    qc = QuantumCircuit.from_qasm_str(qasm)

    gates = [
        "h",
        "x",
        "z",
        "s",
        "t",
        "rz",
        "u1",
        "sdg",
        "tdg",
        "sx" "cx",
        "cz",
        "cu1",
        "crz",
        "ccx",
    ]

    pass_manager = generate_preset_pass_manager(3, basis_gates=gates)
    optimized_qc = pass_manager.run(qc)

    open(output_file, "w")
    qasm2.dump(optimized_qc, output_file)


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python qiskit-tr.py input_file output_file")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    output_dir = os.path.dirname(output_file)

    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir)

    qiskit_tr(input_file, output_file)
