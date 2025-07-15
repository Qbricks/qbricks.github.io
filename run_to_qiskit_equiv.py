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

def inverse_circuit(qc):
    qc_inverse = qc.inverse()
    return qc_inverse

# Check if verbose option is provided
verbose = len(sys.argv) > 3 and sys.argv[3].lower() == 'true'

# Load the two quantum circuits from QASM files
qc1 = QuantumCircuit.from_qasm_file(str(sys.argv[1]))
qc2 = QuantumCircuit.from_qasm_file(str(sys.argv[2]))

assert qc1.num_qubits == qc2.num_qubits, "Both circuits must have the same number of qubits."

num_qubits = qc1.num_qubits
simulator = AerSimulator()

qc2_inverse = inverse_circuit(qc2)
qc_combined = qc1.compose(qc2_inverse)

if verbose:
    print("Testing equivalence by checking if the combined circuit results in identity for all input states:")

all_identities = True
start_time = time.time()

for input_state in range(2**num_qubits):
    qc = QuantumCircuit(num_qubits, num_qubits)

    for qubit in range(num_qubits):
        if input_state & (1 << qubit):
            qc.x(qubit)

    qc.compose(qc_combined, inplace=True)
    qc.measure(range(num_qubits), range(num_qubits))

    if verbose:
        print(f"Circuit for input state {bin(input_state)[2:].zfill(num_qubits)}:")
        print(qc)

    job = simulator.run(qc, shots=1)
    result = job.result()
    counts = result.get_counts(qc)

    input_bits = bin(input_state)[2:].zfill(num_qubits)
    output_bits = next(iter(counts))

    if input_bits != output_bits:
        all_identities = False
        if verbose:
            print(f"Input: {input_bits}, Output: {output_bits} - FAIL")
        else:
            break

    if verbose:
        print(f"Input: {input_bits}, Output: {output_bits} - PASS")
        print("-" * 40)

verification_time = time.time() - start_time

if all_identities:
    print("All input states result in identity. The two circuits are equivalent.")
else:
    print("Not all input states result in identity. The two circuits are not equivalent.")

print(f"Verification time: {verification_time:.2f} seconds")

if verbose:
    qc1.draw(output='mpl')
    plt.show()

    qc2.draw(output='mpl')
    plt.show()
