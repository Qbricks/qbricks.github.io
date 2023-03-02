from qiskit import *

import sys

# qc = QuantumCircuit.from_qasm_file("run_test_to_openqasm.qasm")
qc = QuantumCircuit.from_qasm_file(str(sys.argv[1]) + ".qasm")


print(qc)

# # Draw circuit

# # Without transpilation
from qiskit.tools.visualization import circuit_drawer
import matplotlib.pyplot as plt
qc.draw(output='mpl')
plt.show()

# # With transpilation - "qasm_simulator"
# from qiskit.tools.visualization import circuit_drawer
# import matplotlib.pyplot as plt
# backend = Aer.get_backend("qasm_simulator")
# compiled_circuit = transpile(qc, backend)
# compiled_circuit.draw(output='mpl')
# plt.show()

# # # # With transpilation - "ibmq_manila"
# # Use a real machine of 5 qubits
# # # # With transpilation - "ibmq_nairobi"
# # Use a real machine of 7 qubits
# IBMQ.save_account('your_token')
# #  Only for the first run
# provider = IBMQ.load_account()
# from qiskit.tools.visualization import circuit_drawer
# import matplotlib.pyplot as plt
# backend = provider.get_backend('ibm_nairobi')
# compiled_circuit = transpile(qc, backend)
# compiled_circuit.draw(output='mpl')
# plt.show()

# Print matrix
# provided all the elements in the circuit are unitary operations.
# This backend calculates the 2𝑛×2𝑛 matrix representing the gates in the quantum circuit
# backend = Aer.get_backend('unitary_simulator')
# job = backend.run(qc)
# result = job.result()
# print(result.get_unitary(qc, decimals=3))




# # With measurement:

# Print result
# backend = Aer.get_backend("qasm_simulator")
# job = execute(qc, backend)
# result = job.result()
# print(result.get_counts())

# # Print histogram
# from qiskit.visualization import plot_histogram
# import matplotlib.pyplot as plt
# backend = BasicAer.get_backend("qasm_simulator")
# job = execute(qc, backend)
# result = job.result()
# # With transpilation
# # compiled_circuit = transpile(qc, backend)
# # counts = result.get_counts(compiled_circuit)
# # Without transpilation
# counts = result.get_counts(qc)
# plot_histogram(counts)
# plt.show()

# Print Bloch sphere
# from qiskit.visualization import plot_state_city, plot_bloch_multivector
# from qiskit.visualization import plot_state_paulivec, plot_state_hinton
# from qiskit.visualization import plot_state_qsphere
# import matplotlib.pyplot as plt
# backend = BasicAer.get_backend('statevector_simulator')
# job = execute(qc, backend)
# result = job.result()
# psi  = result.get_statevector(qc)
# # plot_state_qsphere(psi)
# plot_bloch_multivector(psi)
# plt.show()












# # Use a real machine of 5 qubits
# # This is mine token (JR):
# # IBMQ.save_account('a4aa1bb7b44a5874c3415082a3c789ebed678ceda59aee1264cabdb3791dd4dc32a5f030bff111f7356984d6aec532b5574124efec80651879cc01dcb1706391')
# # Only for the first run
# provider = IBMQ.load_account()
# backend = provider.get_backend('ibmq_manila')
# job = execute(qc, backend)
# result = job.result()
# print(result.get_counts())













# TODO : Bloch sphere
# from qiskit.quantum_info import Statevector
# from qiskit.visualization import plot_state_qsphere, plot_bloch_multivector
# # get state vector
# sv = Statevector.from_instruction(qc).data
# # plots
# plot_state_qsphere(sv)
# plot_bloch_multivector(sv)


# show the list of backends
# IBMQ.load_account()
# IBMQ.providers()
# provider = IBMQ.get_provider('ibm-q')
# provider.backends()
# [<IBMQSimulator('ibmq_qasm_simulator') from IBMQ(hub='ibm-q', group='open', project='main')>,
#  <IBMQBackend('ibmq_armonk') from IBMQ(hub='ibm-q', group='open', project='main')>,
#  <IBMQBackend('ibmq_santiago') from IBMQ(hub='ibm-q', group='open', project='main')>,
#  <IBMQBackend('ibmq_bogota') from IBMQ(hub='ibm-q', group='open', project='main')>,
#  <IBMQBackend('ibmq_lima') from IBMQ(hub='ibm-q', group='open', project='main')>,
#  <IBMQBackend('ibmq_belem') from IBMQ(hub='ibm-q', group='open', project='main')>,
#  <IBMQBackend('ibmq_quito') from IBMQ(hub='ibm-q', group='open', project='main')>,
#  <IBMQSimulator('simulator_statevector') from IBMQ(hub='ibm-q', group='open', project='main')>,
#  <IBMQSimulator('simulator_mps') from IBMQ(hub='ibm-q', group='open', project='main')>,
#  <IBMQSimulator('simulator_extended_stabilizer') from IBMQ(hub='ibm-q', group='open', project='main')>,
#  <IBMQSimulator('simulator_stabilizer') from IBMQ(hub='ibm-q', group='open', project='main')>,
#  <IBMQBackend('ibmq_manila') from IBMQ(hub='ibm-q', group='open', project='main')>]