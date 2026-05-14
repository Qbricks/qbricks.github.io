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
import time
import matplotlib

matplotlib.use("TkAgg")
import matplotlib.pyplot as plt
from qiskit import QuantumCircuit
from qiskit.visualization import circuit_drawer
from mqt.qcec import verify

# Fig. 7.a
qc1 = QuantumCircuit(2, 2)
qc1.measure(0, 0)
qc1.z(1).c_if(qc1.clbits[0], 1)
qc1.h(1)
qc1.measure(1, 1)

# Fig. 7.b
qc2 = QuantumCircuit(2, 2)
qc2.cz(0, 1)
qc2.h(1)
qc2.measure(0, 0)
qc2.measure(1, 1)

# Create figure with 2 side-by-side subplots
fig, axes = plt.subplots(1, 2, figsize=(8, 4))
circuit_drawer(qc1, output="mpl", justify="none", ax=axes[0])
axes[0].set_title("Fig. 5", y=1.05)
circuit_drawer(qc2, output="mpl", justify="none", ax=axes[1])
axes[1].set_title("Fig. 6", y=1.05)

# Check equivalence with QCEC
start_time = time.time()
result = verify(qc1, qc2, transform_dynamic_circuit=True)
end_time = time.time()
equivalence_result = result.equivalence

# Ajoute un espace pour le message en bas
plt.tight_layout(rect=[0, 0.15, 1, 0.95])

# Ajoute le message dans la figure
fig.suptitle(
    f"SQS Paper - QCEC Equivalence Verification: Circuits from Fig. 5 and Fig. 6\nResult: {equivalence_result}",
    fontsize=12,
    y=0.17,
)

plt.show()

# Affiche aussi dans les logs/terminal
print("=================================================")
print(" Workshop paper - Services and Quantum Software  ")
print("QCEC verification between Fig. 5 and Fig. 6")
print(f"Result: {equivalence_result}")
print(f"Verification time: {end_time - start_time:.2f} seconds")
print("=================================================")
