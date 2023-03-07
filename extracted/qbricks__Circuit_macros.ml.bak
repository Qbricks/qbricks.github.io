let rec m_skip (k: Z.t) : Wired_circuits__Circuit_c.circuit =
  if Z.equal k Z.one
  then Wired_circuits__Qbricks_prim.skip
  else
    Wired_circuits__Qbricks_prim.infix_slsl (m_skip (Z.sub k Z.one))
    Wired_circuits__Qbricks_prim.skip

let swap_gen (k: Z.t) (k': Z.t) (n: Z.t) : Wired_circuits__Circuit_c.circuit
  =
  if Z.equal k k' then m_skip n else Wired_circuits__Qbricks_prim.swap k k' n

let rec permutation_circuit_pre (k: Z.t) (n: Z.t) (f: Z.t -> Z.t) :
  Wired_circuits__Circuit_c.circuit =
  if Z.equal k (Z.sub n Z.one)
  then
    swap_gen (Derived_circuits_c__Qbit_permutations.c_inv_func_int f n 
    (Z.sub n Z.one))
    (Z.sub n Z.one)
    n
  else
    Wired_circuits__Qbricks_prim.infix_mnmn (swap_gen k
                                             (Derived_circuits_c__Qbit_permutations.qbit_permutation 
                                              (Derived_circuits_c__Qbit_permutations.permutation_circuit_pre 
                                               (Z.add k Z.one) n f) (
                                             Derived_circuits_c__Qbit_permutations.c_inv_func_int f
                                             n k)) n)
    (permutation_circuit_pre (Z.add k Z.one) n f)

let permutation_circuit (n: Z.t) (f: Z.t -> Z.t) :
  Wired_circuits__Circuit_c.circuit = permutation_circuit_pre Z.zero n f

let gen_phase (k: Z.t) (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.place (Wired_circuits__Qbricks_prim.phase k)
  Z.zero
  n

let crz (c: Z.t) (t: Z.t) (k: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.cont (Wired_circuits__Qbricks_prim.rzp k)
  c
  t
  n

let prz (k: Z.t) (t: Z.t) (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.place (Wired_circuits__Qbricks_prim.rzp k) t n

let crzn (c: Z.t) (t: Z.t) (k: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.cont (Wired_circuits__Qbricks_prim.rzp k)
  c
  t
  n

let crzn_up (c: Z.t) (t: Z.t) (k: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.cont (Wired_circuits__Qbricks_prim.rzp k)
  c
  t
  n

let c_rzp_one (c: Z.t) (t: Z.t) (n: Z.t) : Wired_circuits__Circuit_c.circuit
  = crz c t Z.one n

let rec repeat_had (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  if Z.equal n Z.one
  then Wired_circuits__Qbricks_prim.hadamard
  else
    Wired_circuits__Qbricks_prim.infix_slsl (repeat_had (Z.sub n Z.one))
    Wired_circuits__Qbricks_prim.hadamard

let ind_neg_cnot (c: Z.t) (k: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  let ind_neg_cnot_pre (c1: Z.t) (k1: Z.t) (n1: Z.t) :
    Wired_circuits__Circuit_c.circuit =
    Remarkable_fragments__Flat_mute_circuits.seq_flat_mute (Wired_circuits__Qbricks_prim.place Wired_circuits__Qbricks_prim.xx
                                                            c1 n1)
    (Wired_circuits__Qbricks_prim.cnot c1 k1 n1) in
  Remarkable_fragments__Flat_mute_circuits.seq_flat_mute (ind_neg_cnot_pre c
                                                          k n)
  (Wired_circuits__Qbricks_prim.place Wired_circuits__Qbricks_prim.xx c n)

let rec repeat_xx (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  if Z.equal n Z.one
  then Wired_circuits__Qbricks_prim.xx
  else
    Wired_circuits__Qbricks_prim.infix_slsl (repeat_xx (Z.sub n Z.one))
    Wired_circuits__Qbricks_prim.xx

let with_permutation (c: Wired_circuits__Circuit_c.circuit) (f: Z.t -> Z.t) :
  Wired_circuits__Circuit_c.circuit =
  let permut_apply (_: unit) : Wired_circuits__Circuit_c.circuit =
    Wired_circuits__Qbricks_prim.infix_mnmn (permutation_circuit (Wired_circuits__Circuit_c.width c)
                                             f)
    c in
  Wired_circuits__Qbricks_prim.infix_mnmn (permut_apply ())
  (permutation_circuit (Wired_circuits__Circuit_c.width c)
   (Derived_circuits_c__Qbit_permutations.c_inv_func_int f
    (Wired_circuits__Circuit_c.width c)))

let unwire_with_permutation (c: Wired_circuits__Circuit_c.circuit)
                            (f: Z.t -> Z.t) : unit = ()

let permutation_three_blocks (n1: Z.t) (n2: Z.t) (n3: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  permutation_circuit n
  (fun (j: Z.t) ->
     if Z.lt j n1
     then j
     else begin if Z.lt j (Z.add n1 n3) then Z.add j n2 else Z.sub j n3 end)

let insert_qbits (c: Wired_circuits__Circuit_c.circuit) (k: Z.t) (n: Z.t)
                 (i: Z.t) : Wired_circuits__Circuit_c.circuit =
  with_permutation (Wired_circuits__Qbricks_prim.infix_slsl c (m_skip i))
  (fun (j1: Z.t) ->
     if Z.lt j1 k
     then j1
     else begin if Z.lt j1 n then Z.add j1 i else Z.add (Z.sub j1 n) k end)

let insert_qbits_gen (c: Wired_circuits__Circuit_c.circuit) (k: Z.t) 
                     (n: Z.t) (i: Z.t) : Wired_circuits__Circuit_c.circuit =
  if Z.lt Z.zero i then insert_qbits c k n i else c

let swap_lists (c1: Z.t) (c2: Z.t) (l: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.place (insert_qbits_gen (permutation_three_blocks Z.zero
                                                        l l
                                                        (Z.mul (Z.of_string "2")
                                                         l))
                                      l (Z.mul (Z.of_string "2") l)
                                      (Z.sub c2 l))
  Z.zero
  n

let notc : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.cnot Z.one Z.zero (Z.of_string "2")

