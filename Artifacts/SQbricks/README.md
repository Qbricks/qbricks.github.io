**SQbricks** is a verification tool for hybrid circuits.

In SQbricks, a *hybrid circuit* refers to a quantum circuit that includes both quantum operations (unitaries), measurements, and classical control.

SQbricks is composed of two complementary tools: **SQbricks-Lift (SQL)** and **SQbricks-Verif (SQV)**.

---

## SQbricks-Lift (SQL)

**SQbricks-Lift** implements a transformation based on the *deferred measurement* principle, which pushes all *Initialization (I)* to the beginning and *Measurements (M)* to the end of the circuit. This enables the use of standard unitary verification tools in the broader context of hybrid circuits — effectively *lifting* them to this extended setting.

Two transformation modes are provided:

- **IUM**: Returns an *Initialization–Unitary–Measurement (IUM)* decomposition of the circuit.
- **U**: Returns only the unitary part of the circuit.

---

## SQbricks-Verif (SQV)

**SQbricks-Verif** is used to verify the equivalence of two unitary circuits, even if they differ in the number of qubits. This supports the common scenario where auxiliary or "garbage" qubits are added for intermediate computations.

Two verification algorithms are available:

- **Parallel Algorithm (`p`)**:
  Executes both circuits on the same input and compares their outputs.

- **Sequence Algorithm (`s`)**:
  Executes one circuit followed by the inverse of the other and verifies that the output matches the initial input state.
  **The `s` algorithm typically yields better results than `p`, but requires that at least one of the circuits has no ancilla.**

---

## Licence

- Docker: [licence](https://www.docker.com/legal/docker-software-end-user-license-agreement/)
- OCaml: [licence](https://github.com/ocaml/ocaml/blob/trunk/LICENSE)
- Qiskit: [licence](https://github.com/Qiskit/qiskit/blob/main/LICENSE.txt)
- OpenQASM: [licence](https://github.com/openqasm/openqasm/blob/main/LICENSE)
- Matplotlib: [licence](https://github.com/matplotlib/matplotlib/blob/main/LICENSE/LICENSE)
- AutoQ: [licence](https://github.com/fmlab-iis/AutoQ/blob/main/LICENSE)
- Feynman: [licence](https://github.com/meamy/feynman/blob/master/LICENSE.md)
- PyZX: [licence](https://github.com/zxcalc/pyzx/blob/master/LICENSE)
- QCEC: [licence](https://github.com/munich-quantum-toolkit/qcec/blob/main/LICENSE.md)

---

## Features

- Supports input in **OpenQASM 2.0** format.
- Packaged as a **Docker container** with all necessary dependencies.

## Source code

The SQbricks source code will be available as an open source archive in this repository once authorization has been obtained.