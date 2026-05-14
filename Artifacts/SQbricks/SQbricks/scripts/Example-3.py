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

import time
import matplotlib
matplotlib.use("TkAgg")
import matplotlib.pyplot as plt
import qiskit.qasm2
from qiskit.visualization import circuit_drawer
import pyzx

def load_qasm_circuit(file_path):
    return qiskit.qasm2.load(file_path)

qasm1 = "benchmarks/minimal-examples/fig3-pyzx.qasm"
qasm2 = "benchmarks/minimal-examples/fig4-pyzx.qasm"

circuit1 = load_qasm_circuit(qasm1)
circuit2 = load_qasm_circuit(qasm2)

fig, axes = plt.subplots(1, 2, figsize=(7, 3))
circuit_drawer(circuit1, output="mpl", justify="none", ax=axes[0])
axes[0].set_title("Fig. 3", y=0.9) 
circuit_drawer(circuit2, output="mpl", justify="none", ax=axes[1])
axes[1].set_title("Fig. 4", y=0.9)  

c1 = pyzx.Circuit.from_qasm_file(qasm1)
c2 = pyzx.Circuit.from_qasm_file(qasm2)
start_time = time.time()
result = c1.verify_equality(c2)
end_time = time.time()
if result:
    equivalence_result = "Equivalent"
else:
    equivalence_result = "Inconclusive"


plt.tight_layout(rect=[0, 0.15, 1, 0.95])  

fig.suptitle(f"PyZX Equivalence Verification: Circuits from Fig. 3 and Fig. 4\nResult: {equivalence_result}",
             fontsize=12, y=0.17)  

plt.show()

print("=================================================")
print(" Workshop paper - Services and Quantum Software  ")
print("PyZX verification between Fig. 3 and Fig. 4")
print(f"Result: {equivalence_result}")
print(f"Verification time: {end_time - start_time:.2f} seconds")
print("=================================================")
