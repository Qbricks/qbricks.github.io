let rewrite_cnot (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.rewrite_cnot co t n

let rz_not (k: Z.t) : Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.rz_not k

let ry_not (k: Z.t) : Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.ry_not k

let rewrite_rz (k: Z.t) : Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.rewrite_rz k

let rewrite_rzp (k: Z.t) : Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.rewrite_rzp k

let rewrite_rx (k: Z.t) : Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.rewrite_rx k

let rewrite_ry (k: Z.t) : Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.rewrite_ry k

let rewrite_ry_with_z (k: Z.t) : Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.rewrite_ry_with_z k

let rewrite_s (_: unit) : Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.rewrite_s ()

let rewrite_t (_: unit) : Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.rewrite_t ()

let rewrite_zz (_: unit) : Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.rewrite_zz ()

let rewrite_xx (_: unit) : Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.rewrite_xx ()

let rewrite_yy (_: unit) : Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.rewrite_yy ()

let rewrite_hadamard (_: unit) : Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.rewrite_hadamard ()

let place_hadamard_with_ry (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.place_hadamard_with_ry t n

let cont_hadamard (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.cont_hadamard co t n

let cont_ry (k: Z.t) (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.cont_ry k co t n

let cont_rz (k: Z.t) (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.cont_rz k co t n

let cont_phase (k: Z.t) (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.cont_phase k co t n

let cont_rzp (k: Z.t) (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.cont_rzp k co t n

let cont_xor_rz (k: Z.t) (co1: Z.t) (co2: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.cont_xor_rz k co1 co2 t n

let cont_rx (k: Z.t) (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.cont_rx k co t n

let swap_decomp (t1: Z.t) (t2: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.swap_decomp t1 t2 n

let ccz (t1: Z.t) (t2: Z.t) (t3: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.ccz t1 t2 t3 n

let toffoli_decomp (c1: Z.t) (c2: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.toffoli_decomp c1 c2 t n

let fredkin_decomp (c: Z.t) (t1: Z.t) (t2: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.fredkin_decomp c t1 t2 n

let fredkin_decomp_toffoli (c: Z.t) (t1: Z.t) (t2: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  Circuits_equiv__Gate_decomp.fredkin_decomp_toffoli c t1 t2 n

let fredkin_as_cont_swap (c: Z.t) (ta1: Z.t) (ta2: Z.t) (k: Z.t) (n1: Z.t)
                         (n2: Z.t) : Wired_circuits__Circuit_c.wired_circuit
  = Circuits_equiv__Gate_decomp.fredkin_as_cont_swap c ta1 ta2 k n1 n2

let toffoli_as_cont_cnot (c: Z.t) (ta1: Z.t) (ta2: Z.t) (k: Z.t) (n1: Z.t)
                         (n2: Z.t) : Wired_circuits__Circuit_c.wired_circuit
  = Circuits_equiv__Gate_decomp.toffoli_as_cont_cnot c ta1 ta2 k n1 n2

