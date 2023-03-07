let remove_parallel (c: Wired_circuits__Circuit_c.wired_circuit)
                    (c': Wired_circuits__Circuit_c.wired_circuit) :
  Wired_circuits__Circuit_c.wired_circuit =
  Wired_circuits__Circuit_c.Sequence (Wired_circuits__Circuit_c.Place (c,
                                      Z.zero,
                                      Z.add (Wired_circuits__Circuit_c.width_pre c)
                                      (Wired_circuits__Circuit_c.width_pre c')),
  Wired_circuits__Circuit_c.Place (c',
  Wired_circuits__Circuit_c.width_pre c,
  Z.add (Wired_circuits__Circuit_c.width_pre c)
  (Wired_circuits__Circuit_c.width_pre c')))

