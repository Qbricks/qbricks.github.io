let rewrite_cnot (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.cont Wired_circuits__Qbricks_prim.xx co t n

let rz_not (k: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.infix_mnmn Wired_circuits__Qbricks_prim.xx
                                           (Wired_circuits__Qbricks_prim.rz k))
  Wired_circuits__Qbricks_prim.xx

let ry_not (k: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.infix_mnmn Wired_circuits__Qbricks_prim.xx
                                           (Wired_circuits__Qbricks_prim.ry k))
  Wired_circuits__Qbricks_prim.xx

let rewrite_rz (k: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.phase 
                                           (Z.neg (Arit__Incr_abs.incr_abs k)))
  (Wired_circuits__Qbricks_prim.rzp k)

let rewrite_rzp (k: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.phase 
                                           (Arit__Incr_abs.incr_abs k))
  (Wired_circuits__Qbricks_prim.rz k)

let rewrite_rx (k: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.infix_mnmn Wired_circuits__Qbricks_prim.hadamard
                                           (Wired_circuits__Qbricks_prim.rz k))
  Wired_circuits__Qbricks_prim.hadamard

let rewrite_ry (k: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.infix_mnmn 
                                           (Wired_circuits__Qbricks_prim.rzp 
                                            (Z.of_string "-2"))
                                           (Wired_circuits__Qbricks_prim.rx k))
  (Wired_circuits__Qbricks_prim.rzp (Z.of_string "2"))

let rewrite_ry_with_z (k: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.infix_mnmn 
                                           (Wired_circuits__Qbricks_prim.rzp 
                                            (Z.of_string "-2"))
                                           (rewrite_rx k))
  (Wired_circuits__Qbricks_prim.rzp (Z.of_string "2"))

let rewrite_s (_: unit) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.rzp (Z.of_string "2")

let rewrite_t (_: unit) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.rzp (Z.of_string "3")

let rewrite_zz (_: unit) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.rzp Z.one

let rewrite_xx (_: unit) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.infix_mnmn Wired_circuits__Qbricks_prim.hadamard
                                           Wired_circuits__Qbricks_prim.zz)
  Wired_circuits__Qbricks_prim.hadamard

let rewrite_yy (_: unit) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.phase 
                                           (Z.of_string "2"))
  (Wired_circuits__Qbricks_prim.ry Z.one)

let rewrite_hadamard (_: unit) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.ry 
                                           (Z.of_string "2"))
  Wired_circuits__Qbricks_prim.xx

let place_hadamard_with_ry (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.infix_mnmn 
                                           (Wired_circuits__Qbricks_prim.place 
                                            (Wired_circuits__Qbricks_prim.ry 
                                             (Z.of_string "3"))
                                            t n)
                                           (Wired_circuits__Qbricks_prim.place Wired_circuits__Qbricks_prim.xx
                                            t n))
  (Wired_circuits__Qbricks_prim.place (Wired_circuits__Qbricks_prim.ry 
                                       (Z.of_string "-3"))
   t n)

let cont_hadamard (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.infix_mnmn 
                                           (Wired_circuits__Qbricks_prim.place 
                                            (Wired_circuits__Qbricks_prim.ry 
                                             (Z.of_string "3"))
                                            t n)
                                           (Wired_circuits__Qbricks_prim.cnot co
                                            t n))
  (Wired_circuits__Qbricks_prim.place (Wired_circuits__Qbricks_prim.ry 
                                       (Z.of_string "-3"))
   t n)

let cont_ry (k: Z.t) (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.infix_mnmn 
                                           (Wired_circuits__Qbricks_prim.infix_mnmn 
                                            (Wired_circuits__Qbricks_prim.place 
                                             (Wired_circuits__Qbricks_prim.ry 
                                              (Arit__Incr_abs.incr_abs k))
                                             t n)
                                            (Wired_circuits__Qbricks_prim.cnot co
                                             t n))
                                           (Wired_circuits__Qbricks_prim.place 
                                            (Wired_circuits__Qbricks_prim.ry 
                                             (Z.neg (Arit__Incr_abs.incr_abs k)))
                                            t n))
  (Wired_circuits__Qbricks_prim.cnot co t n)

let cont_rz (k: Z.t) (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Remarkable_fragments__Flat_circuits.seq_flat (Remarkable_fragments__Flat_circuits.seq_flat 
                                                (Remarkable_fragments__Flat_circuits.seq_flat 
                                                 (Remarkable_fragments__Diag_circuits.place_diag 
                                                  (Wired_circuits__Qbricks_prim.rz 
                                                   (Arit__Incr_abs.incr_abs k))
                                                  t n)
                                                 (Wired_circuits__Qbricks_prim.cnot co
                                                  t n))
                                                (Remarkable_fragments__Diag_circuits.place_diag 
                                                 (Wired_circuits__Qbricks_prim.rz 
                                                  (Z.neg (Arit__Incr_abs.incr_abs k)))
                                                 t n))
  (Wired_circuits__Qbricks_prim.cnot co t n)

let cont_phase (k: Z.t) (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Remarkable_fragments__Diag_circuits.place_diag (Wired_circuits__Qbricks_prim.rzp k)
  co
  n

let cont_rzp (k: Z.t) (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Remarkable_fragments__Diag_circuits.seq_diag (cont_phase (Arit__Incr_abs.incr_abs k)
                                                co t n)
  (cont_rz k co t n)

let cont_xor_rz (k: Z.t) (co1: Z.t) (co2: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Remarkable_fragments__Flat_circuits.seq_flat (Remarkable_fragments__Flat_circuits.seq_flat 
                                                (Wired_circuits__Qbricks_prim.cnot co1
                                                 co2 n)
                                                (cont_rzp k co2 t n))
  (Wired_circuits__Qbricks_prim.cnot co1 co2 n)

let cont_rx (k: Z.t) (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.infix_mnmn 
                                           (cont_hadamard co t n)
                                           (cont_rz k co t n))
  (cont_hadamard co t n)

let swap_decomp (t1: Z.t) (t2: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Remarkable_fragments__Flat_mute_circuits.seq_flat_mute (Remarkable_fragments__Flat_mute_circuits.seq_flat_mute 
                                                          (Wired_circuits__Qbricks_prim.cnot t1
                                                           t2 n)
                                                          (Wired_circuits__Qbricks_prim.cnot t2
                                                           t1 n))
  (Wired_circuits__Qbricks_prim.cnot t1 t2 n)

let ccz (t1: Z.t) (t2: Z.t) (t3: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Remarkable_fragments__Diag_circuits.seq_diag (Remarkable_fragments__Diag_circuits.seq_diag 
                                                (cont_rzp (Z.of_string "2")
                                                 t1 t3 n)
                                                (cont_rzp (Z.of_string "2")
                                                 t2 t3 n))
  (cont_xor_rz (Z.of_string "-2") t1 t2 t3 n)

let toffoli_decomp (c1: Z.t) (c2: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.infix_mnmn 
                                           (Wired_circuits__Qbricks_prim.place Wired_circuits__Qbricks_prim.hadamard
                                            t n)
                                           (ccz c1 c2 t n))
  (Wired_circuits__Qbricks_prim.place Wired_circuits__Qbricks_prim.hadamard t
   n)

let fredkin_as_cont_swap (c: Z.t) (ta1: Z.t) (ta2: Z.t) (k: Z.t) (n1: Z.t)
                         (n2: Z.t) : Wired_circuits__Circuit_c.circuit =
  Remarkable_fragments__Flat_mute_circuits.cont_flat_mute (Wired_circuits__Qbricks_prim.swap 
                                                           (Z.sub ta1 k)
                                                           (Z.sub ta2 k) n1)
  c
  k
  n2

let toffoli_as_cont_cnot (c: Z.t) (ta1: Z.t) (ta2: Z.t) (k: Z.t) (n1: Z.t)
                         (n2: Z.t) : Wired_circuits__Circuit_c.circuit =
  Remarkable_fragments__Flat_mute_circuits.cont_flat_mute (Wired_circuits__Qbricks_prim.cnot 
                                                           (Z.sub ta1 k)
                                                           (Z.sub ta2 k) n1)
  c
  k
  n2

let fredkin_decomp (c: Z.t) (t1: Z.t) (t2: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  let interm =
    Remarkable_fragments__Flat_mute_circuits.seq_flat_mute (Wired_circuits__Qbricks_prim.cnot t2
                                                            t1 n)
    (Wired_circuits__Qbricks_prim.toffoli c t1 t2 n) in
  Remarkable_fragments__Flat_mute_circuits.seq_flat_mute interm
  (Wired_circuits__Qbricks_prim.cnot t2 t1 n)

let fredkin_decomp_toffoli (c: Z.t) (t1: Z.t) (t2: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.infix_mnmn 
                                           (Wired_circuits__Qbricks_prim.cnot t2
                                            t1 n)
                                           (toffoli_decomp c t1 t2 n))
  (Wired_circuits__Qbricks_prim.cnot t2 t1 n)

let unbricks_fredkin (_: unit) : unit = ()

let unbricks_toffoli (_: unit) : unit = ()

let unbricks_swap (_: unit) : unit = ()

let unbricks_cnot (_: unit) : unit = ()

