let cont_hadamard (co1: Z.t) (ta1: Z.t) (n1: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv_pre__Gate_decomp.cont_hadamard co1 ta1 n1

let cont_ry (k: Z.t) (co1: Z.t) (ta1: Z.t) (n1: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv_pre__Gate_decomp.cont_ry k co1 ta1 n1

let cont_rz (k: Z.t) (co1: Z.t) (ta1: Z.t) (n1: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv_pre__Gate_decomp.cont_rz k co1 ta1 n1

let cont_phase (k: Z.t) (co1: Z.t) (ta1: Z.t) (n1: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv_pre__Gate_decomp.cont_phase k co1 ta1 n1

let cont_rzp (k: Z.t) (co1: Z.t) (ta1: Z.t) (n1: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv_pre__Gate_decomp.cont_rzp k co1 ta1 n1

let cont_rx (k: Z.t) (co1: Z.t) (ta1: Z.t) (n1: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv_pre__Gate_decomp.cont_rx k co1 ta1 n1

let toffoli_decomp (co1: Z.t) (co2: Z.t) (ta1: Z.t) (n1: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv_pre__Gate_decomp.toffoli_decomp co1 co2 ta1 n1

let fredkin_decomp (co1: Z.t) (ta1: Z.t) (ta2: Z.t) (n1: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv_pre__Gate_decomp.fredkin_decomp_toffoli co1 ta1 ta2 n1

let cont_s (co1: Z.t) (ta1: Z.t) (n1: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  cont_rzp (Z.of_string "2") co1 ta1 n1

let cont_t (co1: Z.t) (ta1: Z.t) (n1: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  cont_rzp (Z.of_string "3") co1 ta1 n1

let cont_zz (co1: Z.t) (ta1: Z.t) (n1: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit = cont_rzp Z.one co1 ta1 n1

let cont_xx (co1: Z.t) (ta1: Z.t) (n1: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Wired_circuits__Circuit_c.Sequence (Wired_circuits__Circuit_c.Sequence (
                                      cont_hadamard co1
                                      ta1
                                      n1,
                                      cont_zz co1 ta1 n1),
  cont_hadamard co1 ta1 n1)

let cont_yy (co1: Z.t) (ta1: Z.t) (n1: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Wired_circuits__Circuit_c.Sequence (cont_phase (Z.of_string "2") co1 ta1 n1,
  cont_ry Z.one co1 ta1 n1)

