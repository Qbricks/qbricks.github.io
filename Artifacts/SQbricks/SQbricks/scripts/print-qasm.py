#  This file is part of SQbricks.
#
#  Copyright (C) 2022-2026
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
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pyplot as plt
from qiskit import QuantumCircuit

def main():
    if len(sys.argv) < 2:
        print("Usage: python script.py <qasm_file> [legend]")
        sys.exit(1)

    qasm_file = sys.argv[1]
    legend = sys.argv[2] if len(sys.argv) > 2 else qasm_file.split('/')[-1].replace('.qasm', '')

    qc_original = QuantumCircuit.from_qasm_file(qasm_file)

    fig, ax = plt.subplots(figsize=(7, 4))
    qc_original.draw(output="mpl", ax=ax)

    plt.subplots_adjust(bottom=0.15)
    fig.text(0.5, 0.15, legend, ha='center', va='center', fontsize=12, style='italic')
    plt.tight_layout(rect=[0, 0.15, 1, 0.95])
    plt.show()

if __name__ == "__main__":
    main()
