let qft (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  Reversion__Circuit_reverse.reverse (Qft__Rev_qft.qft_rev n)

let qft_rev_ (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  Qft__Rev_qft.qft_rev n

let apply_qft_as_mod (n: Z.t) (i: Z.t) : unit = ()

let place_qft_zero (n: Z.t) (k: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.place (qft n) Z.zero (Z.add n k)

let place_rev_qft_zero (n: Z.t) (k: Z.t) : Wired_circuits__Circuit_c.circuit
  = Reversion__Circuit_reverse.reverse (place_qft_zero n k)

let place_qft (n: Z.t) (k: Z.t) (size_reg: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.place (qft n) k size_reg

let place_rev_qft (n: Z.t) (k: Z.t) (size_reg: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Reversion__Circuit_reverse.reverse (place_qft n k size_reg)

let apply_function_in_qft_basis (c: Wired_circuits__Circuit_c.circuit)
                                (n: Z.t) (k: Z.t) (size_reg: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  let rev_qft_and_apply (_: unit) : Wired_circuits__Circuit_c.circuit =
    Wired_circuits__Qbricks_prim.infix_mnmn (place_qft n k size_reg) c in
  Wired_circuits__Qbricks_prim.infix_mnmn (rev_qft_and_apply ())
  (place_rev_qft n k size_reg)

let apply_function_in_qft_basis_gen (c: Wired_circuits__Circuit_c.circuit)
                                    (n: Z.t) (k: Z.t) (size_reg: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.infix_mnmn 
                                           (place_qft n k size_reg) c)
  (place_rev_qft n k size_reg)

let apply_function_in_qft_basis_zero (c: Wired_circuits__Circuit_c.circuit)
                                     (n: Z.t) (size_reg: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  let rev_qft_and_apply1 (_: unit) : Wired_circuits__Circuit_c.circuit =
    Wired_circuits__Qbricks_prim.infix_mnmn (place_qft_zero n
                                             (Z.sub size_reg n))
    c in
  Wired_circuits__Qbricks_prim.infix_mnmn (rev_qft_and_apply1 ())
  (place_rev_qft_zero n (Z.sub size_reg n))

let apply_from_qft_zero (n: Z.t) (k: Z.t)
                        (c: Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  let rev_qft_and_apply2 (_: unit) : Wired_circuits__Circuit_c.circuit =
    Wired_circuits__Qbricks_prim.infix_mnmn (place_rev_qft_zero n k) c in
  Wired_circuits__Qbricks_prim.infix_mnmn (rev_qft_and_apply2 ())
  (place_qft_zero n k)

let apply_in_qft_zero (n: Z.t) (k: Z.t)
                      (c: Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  let qft_and_apply (_: unit) : Wired_circuits__Circuit_c.circuit =
    Wired_circuits__Qbricks_prim.infix_mnmn (place_qft_zero n k) c in
  Wired_circuits__Qbricks_prim.infix_mnmn (qft_and_apply ())
  (place_rev_qft_zero n k)

let apply_from_qft_zero_path (n: Z.t) (k: Z.t)
                             (c: Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit = apply_from_qft_zero n k c

let apply_in_qft_zero_path (n: Z.t) (k: Z.t)
                           (c: Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit = apply_from_qft_zero n k c

