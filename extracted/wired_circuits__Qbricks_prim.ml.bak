let phase (k4: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Phase k4

let skip : Wired_circuits__Circuit_c.circuit = Wired_circuits__Circuit_c.Skip

let rz (k4: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Rz k4

let rzp (k4: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Rzp k4

let rx (k4: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Rx k4

let ry (k4: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Ry k4

let hadamard : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Hadamard

let s : Wired_circuits__Circuit_c.circuit = Wired_circuits__Circuit_c.S

let t : Wired_circuits__Circuit_c.circuit = Wired_circuits__Circuit_c.T

let xx : Wired_circuits__Circuit_c.circuit = Wired_circuits__Circuit_c.X

let yy : Wired_circuits__Circuit_c.circuit = Wired_circuits__Circuit_c.Y

let zz : Wired_circuits__Circuit_c.circuit = Wired_circuits__Circuit_c.Z

let bricks_cnot : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Bricks_Cnot

let bricks_toffoli : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Bricks_Toffoli

let bricks_fredkin : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Bricks_Fredkin

let bricks_swap : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Bricks_Swap

let cnot (co: Z.t) (t: Z.t) (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Cnot (co, t, n)

let toffoli (c1: Z.t) (c2: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Toffoli (c1, c2, t, n)

let fredkin (c: Z.t) (t1: Z.t) (t2: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Fredkin (c, t1, t2, n)

let swap (t1: Z.t) (t2: Z.t) (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Swap (t1, t2, n)

let place (c: Wired_circuits__Circuit_c.circuit) (k4: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Place (c, k4, n)

let cont (c: Wired_circuits__Circuit_c.circuit) (co: Z.t) (k4: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Cont (c, co, k4, n)

let infix_mnmn (d: Wired_circuits__Circuit_c.circuit)
               (e: Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Sequence (d, e)

let infix_slsl (d: Wired_circuits__Circuit_c.circuit)
               (e: Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Parallel (d, e)

let ancilla_pre (c: Wired_circuits__Circuit_c.circuit) (l: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.Ancillas (c, l)

let ancilla (c: Wired_circuits__Circuit_c.circuit) (l: Z.t) :
  Wired_circuits__Circuit_c.circuit = ancilla_pre c l

