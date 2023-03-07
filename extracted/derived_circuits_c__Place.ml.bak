let rec ids (n: Z.t) : Qbricks_c__Circuit_c.circuit =
  if Z.equal n Z.one
  then Qbricks_c__Circuit_c.id
  else
    Qbricks_c__Circuit_c.parallel (ids (Z.sub n Z.one))
    Qbricks_c__Circuit_c.id

let place_zero (c: Qbricks_c__Circuit_c.circuit) (n: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  if Z.equal n (Qbricks_c__Circuit_c.width c)
  then c
  else
    Qbricks_c__Circuit_c.parallel c
    (ids (Z.sub n (Qbricks_c__Circuit_c.width c)))

let place (c: Qbricks_c__Circuit_c.circuit) (k: Z.t) (n: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  if Z.equal k Z.zero
  then place_zero c n
  else Qbricks_c__Circuit_c.parallel (ids k) (place_zero c (Z.sub n k))

let place_hadamard (k: Z.t) (n: Z.t) : Qbricks_c__Circuit_c.circuit =
  place Qbricks_c__Circuit_c.hadamard k n

let place_hadamard_bv (k: Z.t) (n: Z.t) : Qbricks_c__Circuit_c.circuit =
  place_hadamard k n

let cont_size : Z.t = Z.of_string "100"

let rz_ (k: Z.t) : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Correct_circuit_c.seq_pps (Qbricks_c__Circuit_c.phase (Z.neg 
                                                                    (Arit__Incr_abs.incr_abs k)))
  (Qbricks_c__Circuit_c.rz k)

let rx (k: Z.t) : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Correct_circuit_c.seq_pps Qbricks_c__Circuit_c.hadamard
  (Qbricks_c__Correct_circuit_c.seq_pps (rz_ k)
   Qbricks_c__Circuit_c.hadamard)

let zz : Qbricks_c__Circuit_c.circuit = Qbricks_c__Circuit_c.rz Z.one

let xx : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.sequence (Qbricks_c__Circuit_c.sequence Qbricks_c__Circuit_c.hadamard
                                 zz)
  Qbricks_c__Circuit_c.hadamard

let yy : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Correct_circuit_c.seq_pps xx (rz_ Z.one)

let ry (k: Z.t) : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Correct_circuit_c.seq_pps (Qbricks_c__Correct_circuit_c.seq_pps 
                                        (Qbricks_c__Circuit_c.rz (Z.of_string "-2"))
                                        (rx k))
  (Qbricks_c__Circuit_c.rz (Z.of_string "2"))

