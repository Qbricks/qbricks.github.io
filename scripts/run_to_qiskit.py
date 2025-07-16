# (**************************************************************************)
# (*  This file is part of QBRICKS.                                         *)
# (*                                                                        *)
# (*  Copyright (C) 2020-2022                                               *)
# (*    CEA (Commissariat à l'énergie atomique et aux énergies              *)
# (*         alternatives)                                                  *)
# (*    Université Paris-Saclay                                             *)
# (*                                                                        *)
# (*  you can redistribute it and/or modify it under the terms of the GNU   *)
# (*  Lesser General Public License as published by the Free Software       *)
# (*  Foundation, version 2.1.                                              *)
# (*                                                                        *)
# (*  It is distributed in the hope that it will be useful,                 *)
# (*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
# (*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
# (*  GNU Lesser General Public License for more details.                   *)
# (*                                                                        *)
# (*  See the GNU Lesser General Public License version 2.1                 *)
# (*  for more details (enclosed in the file licenses/LGPLv2.1).            *)
# (*                                                                        *)
# (**************************************************************************)

import sys
import time
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator

# Check if verbose option is provided
verbose = len(sys.argv) > 2 and sys.argv[2].lower() == 'true'

print("Testing all possible input states for the given quantum circuit:")

qc_original = QuantumCircuit.from_qasm_file(str(sys.argv[1]))
num_qubits = qc_original.num_qubits
simulator = AerSimulator()

start_time = time.time()

for input_state in range(2**num_qubits):
    qc = QuantumCircuit(num_qubits, num_qubits)
    for qubit in range(num_qubits):
        if input_state & (1 << qubit):
            qc.x(qubit)

    qc.compose(qc_original, inplace=True)

    if not qc.count_ops().get('measure', 0):
        qc.measure(range(num_qubits), range(num_qubits))

    if verbose:
        print(f"Circuit for input state {bin(input_state)[2:].zfill(num_qubits)}:")
        print(qc)

    job = simulator.run(qc, shots=1)
    result = job.result()
    counts = result.get_counts(qc)

    input_bits = bin(input_state)[2:].zfill(num_qubits)
    input_qubits = ', '.join([f"q{i}" for i in reversed(range(len(input_bits)))])
    output_bits = next(iter(counts))
    output_qubits = ', '.join([f"q{i}" for i in reversed(range(len(output_bits)))])

    if verbose:
        print(f"Input: {input_bits} ({input_qubits or 'none'})")
        print(f"Output: {output_bits} ({output_qubits or 'none'})")
        print("-" * 40)

verification_time = time.time() - start_time
print(f"Verification completed in {verification_time:.2f} seconds.")

if verbose:
    qc_original.draw(output='mpl')
    plt.show()
