let seq_pps (c: Qbricks_c__Circuit_c.circuit)
            (c': Qbricks_c__Circuit_c.circuit) : Qbricks_c__Circuit_c.circuit
  = Qbricks_c__Circuit_c.sequence c c'

let sequence_ghost_pps (c: Qbricks_c__Circuit_c.circuit)
                       (c': Qbricks_c__Circuit_c.circuit) :
  Qbricks_c__Circuit_c.circuit = Qbricks_c__Circuit_c.sequence c c'

let parallel_ghost_pps (c: Qbricks_c__Circuit_c.circuit)
                       (c': Qbricks_c__Circuit_c.circuit) :
  Qbricks_c__Circuit_c.circuit = Qbricks_c__Circuit_c.parallel c c'

