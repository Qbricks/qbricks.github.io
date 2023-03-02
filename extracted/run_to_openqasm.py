from qiskit import *

import sys

qc = QuantumCircuit.from_qasm_file(str(sys.argv[1]) + ".qasm")

print(qc)

from qiskit.tools.visualization import circuit_drawer
import matplotlib.pyplot as plt
qc.draw(output='mpl')
plt.show()