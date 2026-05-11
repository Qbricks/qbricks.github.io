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
from mqt import qcec
import qiskit.qasm2


def load_qasm_circuit(file_path):
    # https://docs.quantum.ibm.com/api/qiskit/qasm2#qiskit.qasm2.loads
    circuit = qiskit.qasm2.load(file_path)
    return circuit


def main():
    if len(sys.argv) < 4:
        print("Usage: script.py <file1.qasm> <file2.qasm> <dynamic> <partial>")
        sys.exit(1)

    file1 = sys.argv[1]
    file2 = sys.argv[2]
    dynamic = sys.argv[3] in ["DM"]
    partial = sys.argv[4] in ["OE"]

    circuit1 = load_qasm_circuit(file1)
    circuit2 = load_qasm_circuit(file2)

    result = qcec.verify(
        circuit1,
        circuit2,
        transform_dynamic_circuit=dynamic,
        check_partial_equivalence=partial,
    )

    time = result.check_time + result.preprocessing_time

    if result.equivalence == qcec.EquivalenceCriterion.equivalent:
        print(time)
    elif result.equivalence == qcec.EquivalenceCriterion.equivalent_up_to_global_phase:
        print(str(time) + "GP")
    elif result.equivalence == qcec.EquivalenceCriterion.equivalent_up_to_phase:
        print(str(time) + "P")
    elif result.equivalence == qcec.EquivalenceCriterion.no_information:
        print(str(time) + "NC")
    elif result.equivalence == qcec.EquivalenceCriterion.not_equivalent:
        print(str(time) + "NE")
    elif result.equivalence == qcec.EquivalenceCriterion.probably_equivalent:
        print(str(time) + "PE")
    elif result.equivalence == qcec.EquivalenceCriterion.probably_not_equivalent:
        print(str(time) + "PNE")
    else:
        print("NA")


if __name__ == "__main__":
    main()
