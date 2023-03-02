let place_xx (t: Z.t) (n: Z.t) : Qbricks_c__Circuit_c.circuit =
  Derived_circuits_c__Place.place Derived_circuits_c__Place.xx t n

let place_cnot_ps (c: Z.t) (t: Z.t) (n: Z.t) : Qbricks_c__Circuit_c.circuit =
  Cont_c__Cont.place_cnot c t n

let place_toffoli_tcc (c1: Z.t) (c2: Z.t) (t: Z.t) (n: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  Cont_c__Cont.cont (place_cnot_ps (Z.sub c1 t) Z.zero
                     (Z.add (Z.sub c1 t) Z.one))
  c2
  t
  n

let place_toffoli_ctc (c1: Z.t) (c2: Z.t) (t: Z.t) (n: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  Cont_c__Cont.cont (place_cnot_ps Z.zero (Z.sub t c1)
                     (Z.add (Z.sub t c1) Z.one))
  c2
  c1
  n

let place_toffoli_cct (c1: Z.t) (c2: Z.t) (t: Z.t) (n: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  Cont_c__Cont.cont (place_cnot_ps Z.zero (Z.sub t c2)
                     (Z.add (Z.sub t c2) Z.one))
  c1
  c2
  n

let place_toffoli (c1: Z.t) (c2: Z.t) (t: Z.t) (n: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  let mincont = Z.min c1 c2 in
  let maxcont = Z.max c1 c2 in
  if Z.lt t mincont
  then place_toffoli_tcc mincont maxcont t n
  else
    begin
      if Z.lt t maxcont
      then place_toffoli_ctc mincont maxcont t n
      else place_toffoli_cct mincont maxcont t n end

let place_fredkin (c: Z.t) (t1: Z.t) (t2: Z.t) (n: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  Qbricks_c__Circuit_c.sequence (Qbricks_c__Circuit_c.sequence (place_toffoli c
                                                                t1 t2 n)
                                 (place_toffoli c t2 t1 n))
  (place_toffoli c t1 t2 n)

let swap_c (t1: Z.t) (t2: Z.t) (n: Z.t) : Qbricks_c__Circuit_c.circuit =
  Derived_circuits_c__Qbit_permutations.permute_atom t1 t2 n

