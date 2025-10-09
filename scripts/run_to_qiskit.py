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

matplotlib.use("TkAgg")
import matplotlib.pyplot as plt
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator

import sys

verbose = "-v" in sys.argv
all = "-a" in sys.argv
shots = 1

i = 1

if verbose or all:
    i = len(sys.argv) - 1


def run_simulation(
    num_qubits, qc_original, simulator, all=False, verbose=False, input_state=0
):
    if all:
        for input_state in range(2**num_qubits):
            return _run_single_simulation(
                num_qubits, qc_original, simulator, input_state, verbose
            )
    else:
        return _run_single_simulation(
            num_qubits, qc_original, simulator, input_state, verbose
        )


def _run_single_simulation(num_qubits, qc_original, simulator, input_state, verbose):
    # Prepare the quantum circuit
    qc = QuantumCircuit(num_qubits, num_qubits)

    # Set the initial state based on input_state
    for qubit in range(num_qubits):
        if input_state & (1 << qubit):
            qc.x(qubit)

    # Compose with the original circuit and add measurements if needed
    qc.compose(qc_original, inplace=True)
    if not qc.count_ops().get("measure", 0):
        qc.measure(range(num_qubits), range(num_qubits))

    # Run the simulation
    if verbose:
        input_bits = bin(input_state)[2:].zfill(num_qubits)
        print(f"Circuit for input state {input_bits}:")
        print(qc)

    job = simulator.run(qc, shots=shots)
    result = job.result()
    counts = result.get_counts(qc)

    # Process and print results
    input_bits = bin(input_state)[2:].zfill(num_qubits)
    output_bits = next(iter(counts))
    nb_shots = sum(counts.values())

    if verbose:
        input_qubits = ", ".join([f"q{i}" for i in reversed(range(len(input_bits)))])
        output_qubits = ", ".join([f"q{i}" for i in reversed(range(len(output_bits)))])
        print(f"Input:                      {input_bits} ({input_qubits or 'none'})")
        print(f"Output for the last shot:   {output_bits} ({output_qubits or 'none'})")
        print("-" * 40)

    return nb_shots


if all:
    print("Testing all possible input states for the given quantum circuit:")

qc_original = QuantumCircuit.from_qasm_file(str(sys.argv[i]))
num_qubits = qc_original.num_qubits
simulator = AerSimulator()

start_time = time.time()

nb_shots = run_simulation(num_qubits, qc_original, simulator, all, verbose)


verification_time = time.time() - start_time
print(
    f"Aer Qiskit simulation in {verification_time:.2f} seconds, for {nb_shots:d} shot(s)."
)

if verbose:
    qc_original.draw(output="mpl")
    plt.show()
