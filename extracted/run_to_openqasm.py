import matplotlib
matplotlib.use('TkAgg')  

import matplotlib.pyplot as plt
from qiskit import QuantumCircuit, ClassicalRegister, QuantumRegister
from qiskit.visualization import circuit_drawer
import sys

qc = QuantumCircuit.from_qasm_file(str(sys.argv[1]) + ".qasm")

print(qc)

qc.draw(output='mpl')
plt.show()