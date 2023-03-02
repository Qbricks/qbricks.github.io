let seq_diag (d: Wired_circuits__Circuit_c.circuit)
             (e: Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn d e

let cont_diag (c: Wired_circuits__Circuit_c.circuit) (co: Z.t) (t: Z.t)
              (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.cont c co t n

let place_diag (c: Wired_circuits__Circuit_c.circuit) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.place c t n

let seq_diag_right (d: Wired_circuits__Circuit_c.circuit)
                   (e: Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn d e

let seq_diag_left (d: Wired_circuits__Circuit_c.circuit)
                  (e: Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.infix_mnmn d e

