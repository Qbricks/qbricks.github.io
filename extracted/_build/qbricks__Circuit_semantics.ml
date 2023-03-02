let ancilla_g (c: Wired_circuits__Circuit_c.circuit) (i: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.ancilla c i

let sequence_ghost_pps (c: Wired_circuits__Circuit_c.circuit)
                       (c': Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn c c'

let parallel_ghost_pps (c: Wired_circuits__Circuit_c.circuit)
                       (c': Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_slsl c c'

let seq_pps_bv (c: Wired_circuits__Circuit_c.circuit)
               (c': Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn c c'

let path_seq (d: Wired_circuits__Circuit_c.circuit)
             (e: Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn d e

let place_hadamard (k: Z.t) (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.place Wired_circuits__Qbricks_prim.hadamard
  k
  n

let place_hadamard_bv (k: Z.t) (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  place_hadamard k n

let cont_last_qbit_kron (c: Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.cont c
  (Wired_circuits__Circuit_c.width c)
  Z.zero
  (Z.add (Wired_circuits__Circuit_c.width c) Z.one)

let cont_last_qbit_kron_path (c: Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.cont c
  (Wired_circuits__Circuit_c.width c)
  Z.zero
  (Z.add (Wired_circuits__Circuit_c.width c) Z.one)

