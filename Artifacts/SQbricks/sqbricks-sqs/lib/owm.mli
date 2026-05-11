(** This module provides types and functions for working with measurement-based
    quantum computing (One-Way Model), based on the measurement calculus
    formalism. Reference: Danos et al. (2007),
    ({{:https://arxiv.org/abs/0704.1263} arXiv:0704.1263}) *)

val to_owm :
  ?debug:bool -> ?dm:bool -> Program.t -> Program.t * int list * int list
(** [to_owm ?debug ?dm prog] converts [prog] to measurement-based quantum
    computing format.

    Parameters:
    - [dm]: if true, enables Deferred Measurement mode.
    - [prog]: the input quantum program to be converted.

    Returns a tuple [(teleported_circuit, input_qubits, output_qubits)], where:
    - [owm_circuit] is the resulting owm-based circuit.
    - [input_qubits] is a list of input qubit indices.
    - [output_qubits] is a list of output qubit indices.

    Returns [(program_in_owm, input_qubits, output_qubits)]. *)
