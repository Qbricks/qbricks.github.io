let contph (k: Z.t) : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.parallel (Qbricks_c__Circuit_c.rz k)
  Qbricks_c__Circuit_c.id

let contrz_pre (k: Z.t) : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.sequence (Qbricks_c__Circuit_c.sequence (Derived_circuits_c__Place.place 
                                                                (Qbricks_c__Circuit_c.rz 
                                                                 (Arit__Incr_abs.incr_abs k))
                                                                Z.one
                                                                (Z.of_string "2"))
                                 Qbricks_c__Circuit_c.cnot)
  (Derived_circuits_c__Place.place (Qbricks_c__Circuit_c.rz (Z.neg (Arit__Incr_abs.incr_abs k)))
   Z.one (Z.of_string "2"))

let contrz_ (k: Z.t) : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.sequence (contrz_pre k) Qbricks_c__Circuit_c.cnot

let contrz (k: Z.t) : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.sequence (contrz_ k)
  (contph (Arit__Incr_abs.incr_abs k))

let contrz1_2 (k: Z.t) : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.parallel (contrz k) Qbricks_c__Circuit_c.id

let swap_1_2_in3 : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.parallel Qbricks_c__Circuit_c.swap
  Qbricks_c__Circuit_c.id

let swap_2_3_in3 : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.parallel Qbricks_c__Circuit_c.id
  Qbricks_c__Circuit_c.swap

let contrz1_3 (k: Z.t) : Qbricks_c__Circuit_c.circuit =
  Derived_circuits_c__Qbit_permutations.insert_qbits (contrz k)
  Z.one
  (Z.of_string "2")
  Z.one

let contrz2_3 (k: Z.t) : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.parallel Qbricks_c__Circuit_c.id (contrz k)

let contrz_xor_3 (k: Z.t) : Qbricks_c__Circuit_c.circuit =
  let apply_cnot =
    Qbricks_c__Circuit_c.parallel Qbricks_c__Circuit_c.cnot
    Qbricks_c__Circuit_c.id in
  Qbricks_c__Circuit_c.sequence (Qbricks_c__Circuit_c.sequence apply_cnot
                                 (contrz2_3 k))
  apply_cnot

let contry_pre_ (k: Z.t) : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.sequence (Qbricks_c__Circuit_c.sequence (Derived_circuits_c__Place.place 
                                                                (Derived_circuits_c__Place.ry 
                                                                 (Z.neg 
                                                                  (Arit__Incr_abs.incr_abs k)))
                                                                Z.one
                                                                (Z.of_string "2"))
                                 Qbricks_c__Circuit_c.cnot)
  (Derived_circuits_c__Place.place (Derived_circuits_c__Place.ry (Arit__Incr_abs.incr_abs k))
   Z.one (Z.of_string "2"))

let contry_pre (k: Z.t) : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.sequence (Qbricks_c__Circuit_c.sequence (Derived_circuits_c__Place.place 
                                                                (Derived_circuits_c__Place.ry 
                                                                 (Z.neg 
                                                                  (Arit__Incr_abs.incr_abs k)))
                                                                Z.one
                                                                (Z.of_string "2"))
                                 Qbricks_c__Circuit_c.cnot)
  (Derived_circuits_c__Place.place (Derived_circuits_c__Place.ry (Arit__Incr_abs.incr_abs k))
   Z.one (Z.of_string "2"))

let contry (k: Z.t) : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.sequence (contry_pre k) Qbricks_c__Circuit_c.cnot

let conth : Qbricks_c__Circuit_c.circuit = contry_pre (Z.of_string "-2")

let lemma_conth_path_sem_bv (_: unit) : unit = ()

let conth1_3 : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.sequence (Qbricks_c__Circuit_c.sequence swap_1_2_in3
                                 (Qbricks_c__Circuit_c.parallel Qbricks_c__Circuit_c.id
                                  conth))
  swap_1_2_in3

let ccz : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.sequence (Qbricks_c__Circuit_c.sequence (contrz1_3 
                                                                (Z.of_string "2"))
                                 (contrz2_3 (Z.of_string "2")))
  (contrz_xor_3 (Z.of_string "-2"))

let toffoli : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.sequence (Qbricks_c__Circuit_c.sequence (Derived_circuits_c__Place.place_hadamard 
                                                                (Z.of_string "2")
                                                                (Z.of_string "3"))
                                 ccz)
  (Derived_circuits_c__Place.place_hadamard (Z.of_string "2")
   (Z.of_string "3"))

let toffoli_cont_1_3 : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.sequence (Qbricks_c__Circuit_c.sequence swap_2_3_in3
                                 toffoli)
  swap_2_3_in3

let fredkin : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.sequence (Qbricks_c__Circuit_c.sequence toffoli
                                 toffoli_cont_1_3)
  toffoli

let notc : Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.sequence (Qbricks_c__Circuit_c.sequence Qbricks_c__Circuit_c.swap
                                 Qbricks_c__Circuit_c.cnot)
  Qbricks_c__Circuit_c.swap

let place_cnot (c: Z.t) (t: Z.t) (n: Z.t) : Qbricks_c__Circuit_c.circuit =
  let place_cnot_pre =
    if Z.lt c t
    then
      Derived_circuits_c__Qbit_permutations.insert_qbits_gen Qbricks_c__Circuit_c.cnot
      Z.one
      (Z.of_string "2")
      (Z.sub (Z.sub t c) Z.one)
    else
      Derived_circuits_c__Qbit_permutations.insert_qbits_gen notc
      Z.one
      (Z.of_string "2")
      (Z.sub (Z.sub c t) Z.one) in
  Derived_circuits_c__Place.place place_cnot_pre (Z.min c t) n

let rec cont_zero (c: Qbricks_c__Circuit_c.circuit) :
  Qbricks_c__Circuit_c.circuit =
  match c with
  | Qbricks_c__Circuit_c.Id ->
    Qbricks_c__Circuit_c.parallel Qbricks_c__Circuit_c.id
    Qbricks_c__Circuit_c.id
  | Qbricks_c__Circuit_c.Swap -> fredkin
  | Qbricks_c__Circuit_c.Cnot -> toffoli
  | Qbricks_c__Circuit_c.Hadamard -> conth
  | Qbricks_c__Circuit_c.Phase k -> contph k
  | Qbricks_c__Circuit_c.Rz k -> contrz k
  | Qbricks_c__Circuit_c.Sequence (d,
    e) ->
    Qbricks_c__Circuit_c.sequence (cont_zero (Qbricks_c__Circuit_c.to_qc d))
    (cont_zero (Qbricks_c__Circuit_c.to_qc e))
  | Qbricks_c__Circuit_c.Parallel (d,
    e) ->
    (let right_control =
       Derived_circuits_c__Qbit_permutations.insert_qbits (cont_zero 
                                                           (Qbricks_c__Circuit_c.to_qc e))
       Z.one
       (Z.add (Qbricks_c__Circuit_c.width (Qbricks_c__Circuit_c.to_qc e))
        Z.one)
       (Qbricks_c__Circuit_c.width (Qbricks_c__Circuit_c.to_qc d)) in
     let left_control =
       Derived_circuits_c__Place.place (cont_zero (Qbricks_c__Circuit_c.to_qc d))
       Z.zero
       (Z.add (Qbricks_c__Circuit_c.width c) Z.one) in
     Qbricks_c__Circuit_c.sequence left_control right_control)
  | Qbricks_c__Circuit_c.Ancillas (d,
    k) ->
    Qbricks_c__Circuit_c.ancilla_spec (cont_zero (Qbricks_c__Circuit_c.to_qc d))
    k

let cont_zero_sem_kron (c: Qbricks_c__Circuit_c.circuit) :
  Qbricks_c__Circuit_c.circuit = cont_zero c

let cont_last_qbit (c: Qbricks_c__Circuit_c.circuit) :
  Qbricks_c__Circuit_c.circuit =
  Derived_circuits_c__Qbit_permutations.with_permutation (cont_zero c)
  (fun (i: Z.t) ->
     if Z.lt i Z.one
     then Z.add i (Qbricks_c__Circuit_c.width c)
     else Z.sub i Z.one)

let cont_last_qbit_kron (c: Qbricks_c__Circuit_c.circuit) :
  Qbricks_c__Circuit_c.circuit = cont_last_qbit c

let cont_zero_gen (c: Qbricks_c__Circuit_c.circuit) (k: Z.t) (n: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  cont_zero (Derived_circuits_c__Place.place c (Z.sub k Z.one)
             (Z.sub n Z.one))

let cont_before (c: Qbricks_c__Circuit_c.circuit) (co: Z.t) (k: Z.t) (n: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  Derived_circuits_c__Place.place (cont_zero_gen c (Z.sub k co) (Z.sub n co))
  co
  n

let cont_last_gen (c: Qbricks_c__Circuit_c.circuit) (k: Z.t) (co: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  cont_last_qbit (Derived_circuits_c__Place.place c k co)

let cont_after (c: Qbricks_c__Circuit_c.circuit) (co: Z.t) (k: Z.t) (n: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  Derived_circuits_c__Place.place (cont_last_gen c k co) Z.zero n

let cont (c: Qbricks_c__Circuit_c.circuit) (co: Z.t) (k: Z.t) (n: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  if Z.lt co k then cont_before c co k n else cont_after c co k n

