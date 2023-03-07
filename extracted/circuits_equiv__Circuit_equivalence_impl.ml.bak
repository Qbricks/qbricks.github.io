let remove_parallel (c: Wired_circuits__Circuit_c.circuit)
                    (c': Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn (Wired_circuits__Qbricks_prim.place c
                                           Z.zero
                                           (Z.add (Wired_circuits__Circuit_c.width c)
                                            (Wired_circuits__Circuit_c.width c')))
  (Wired_circuits__Qbricks_prim.place c' (Wired_circuits__Circuit_c.width c)
   (Z.add (Wired_circuits__Circuit_c.width c)
    (Wired_circuits__Circuit_c.width c')))

