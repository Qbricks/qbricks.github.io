let rec control_delete_step (c: Wired_circuits__Circuit_c.wired_circuit)
                            (co: Z.t) (t: Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  match c with
  | Wired_circuits__Circuit_c.Sequence (c1,
    c2) ->
    Wired_circuits__Circuit_c.Sequence (control_delete_step c1 co t n,
    control_delete_step c2 co t n)
  | Wired_circuits__Circuit_c.Place (c1,
    k1,
    _) ->
    control_delete_step c1 co (Z.add k1 t) n
  | Wired_circuits__Circuit_c.Phase k ->
    Subcircuit_control__Cont_del.cont_phase k co t n
  | Wired_circuits__Circuit_c.Rx k ->
    Subcircuit_control__Cont_del.cont_rx k co t n
  | Wired_circuits__Circuit_c.Ry k ->
    Subcircuit_control__Cont_del.cont_ry k co t n
  | Wired_circuits__Circuit_c.Rz k ->
    Subcircuit_control__Cont_del.cont_rz k co t n
  | Wired_circuits__Circuit_c.Rzp k ->
    Subcircuit_control__Cont_del.cont_rzp k co t n
  | Wired_circuits__Circuit_c.Hadamard ->
    Subcircuit_control__Cont_del.cont_hadamard co t n
  | Wired_circuits__Circuit_c.S -> Subcircuit_control__Cont_del.cont_s co t n
  | Wired_circuits__Circuit_c.T -> Subcircuit_control__Cont_del.cont_t co t n
  | Wired_circuits__Circuit_c.X ->
    Subcircuit_control__Cont_del.cont_xx co t n
  | Wired_circuits__Circuit_c.Y ->
    Subcircuit_control__Cont_del.cont_yy co t n
  | Wired_circuits__Circuit_c.Z ->
    Subcircuit_control__Cont_del.cont_zz co t n
  | Wired_circuits__Circuit_c.Cnot (co1,
    t1,
    _) ->
    Subcircuit_control__Cont_del.toffoli_decomp co
    (Z.add t co1)
    (Z.add t t1)
    n
  | Wired_circuits__Circuit_c.Swap (t1,
    t2,
    _) ->
    Subcircuit_control__Cont_del.fredkin_decomp co
    (Z.add t t1)
    (Z.add t t2)
    n
  | Wired_circuits__Circuit_c.Bricks_Cnot ->
    Subcircuit_control__Cont_del.toffoli_decomp co t (Z.add t Z.one) n
  | Wired_circuits__Circuit_c.Bricks_Swap ->
    Subcircuit_control__Cont_del.fredkin_decomp co t (Z.add t Z.one) n
  | Wired_circuits__Circuit_c.Skip ->
    Circuits_equiv_pre__Neutral_circuit.cont_skip_to_place co t n
  | _ -> c

let rec control_delete_steps (c: Wired_circuits__Circuit_c.wired_circuit) :
  Wired_circuits__Circuit_c.wired_circuit =
  match c with
  | Wired_circuits__Circuit_c.Sequence (c1,
    c2) ->
    Wired_circuits__Circuit_c.Sequence (control_delete_steps c1,
    control_delete_steps c2)
  | Wired_circuits__Circuit_c.Cont (c1,
    co,
    k,
    n) ->
    if Z.equal (Commuting_lemmas__Cont_depth_pre.cont_depth c1) Z.zero
    then control_delete_step c1 co k n
    else control_delete_step (control_delete_steps c1) co k n
  | _ -> c

let rec control_delete (c: Wired_circuits__Circuit_c.wired_circuit) :
  Wired_circuits__Circuit_c.wired_circuit =
  match c with
  | Wired_circuits__Circuit_c.Sequence (c1,
    c2) ->
    Wired_circuits__Circuit_c.Sequence (control_delete_steps c1,
    control_delete_steps c2)
  | Wired_circuits__Circuit_c.Cont (c1,
    co,
    k,
    n) ->
    if Z.equal (Commuting_lemmas__Cont_depth_pre.cont_depth c1) Z.zero
    then c
    else Wired_circuits__Circuit_c.Cont (control_delete_steps c1, co, k, n)
  | _ -> c

let rec control_atom (circ: Wired_circuits__Circuit_c.wired_circuit)
                     (co: Z.t) (k': Z.t) (n: Z.t) :
  Wired_circuits__Circuit_c.wired_circuit =
  match circ with
  | Wired_circuits__Circuit_c.Sequence (circ1,
    circ2) ->
    Wired_circuits__Circuit_c.Sequence (control_atom circ1 co k' n,
    control_atom circ2 co k' n)
  | Wired_circuits__Circuit_c.Place (circ1,
    k1,
    _) ->
    control_atom circ1 co (Z.add k' k1) n
  | Wired_circuits__Circuit_c.Skip ->
    Circuits_equiv_pre__Neutral_circuit.cont_skip_to_place co k' n
  | Wired_circuits__Circuit_c.Phase k ->
    Subcircuit_control__Cont_del.cont_phase k co k' n
  | Wired_circuits__Circuit_c.Rx k ->
    Subcircuit_control__Cont_del.cont_rx k co k' n
  | Wired_circuits__Circuit_c.Ry k ->
    Subcircuit_control__Cont_del.cont_ry k co k' n
  | Wired_circuits__Circuit_c.Rz k ->
    Subcircuit_control__Cont_del.cont_rz k co k' n
  | Wired_circuits__Circuit_c.Rzp k ->
    Subcircuit_control__Cont_del.cont_rzp k co k' n
  | Wired_circuits__Circuit_c.Hadamard ->
    Subcircuit_control__Cont_del.cont_hadamard co k' n
  | Wired_circuits__Circuit_c.S ->
    Subcircuit_control__Cont_del.cont_s co k' n
  | Wired_circuits__Circuit_c.T ->
    Subcircuit_control__Cont_del.cont_t co k' n
  | Wired_circuits__Circuit_c.X ->
    Subcircuit_control__Cont_del.cont_xx co k' n
  | Wired_circuits__Circuit_c.Y ->
    Subcircuit_control__Cont_del.cont_yy co k' n
  | Wired_circuits__Circuit_c.Z ->
    Subcircuit_control__Cont_del.cont_zz co k' n
  | Wired_circuits__Circuit_c.Cnot (co1,
    t1,
    n1) ->
    Subcircuit_control__Cont_del.toffoli_decomp co
    (Z.add k' co1)
    (Z.add k' t1)
    n
  | Wired_circuits__Circuit_c.Swap (t1,
    t2,
    n1) ->
    Subcircuit_control__Cont_del.fredkin_decomp co
    (Z.add k' t1)
    (Z.add k' t2)
    n
  | Wired_circuits__Circuit_c.Bricks_Cnot ->
    Subcircuit_control__Cont_del.toffoli_decomp co k' (Z.add k' Z.one) n
  | Wired_circuits__Circuit_c.Bricks_Swap ->
    Subcircuit_control__Cont_del.fredkin_decomp co k' (Z.add k' Z.one) n
  | _ -> circ

let rec control_atomic (c: Wired_circuits__Circuit_c.wired_circuit) :
  Wired_circuits__Circuit_c.wired_circuit =
  match c with
  | Wired_circuits__Circuit_c.Sequence (c1,
    c2) ->
    Wired_circuits__Circuit_c.Sequence (control_atomic c1, control_atomic c2)
  | Wired_circuits__Circuit_c.Cont (c1, co, k, n) -> control_atom c1 co k n
  | _ -> c

let to_oqasm (c: Wired_circuits__Circuit_c.wired_circuit) :
  Wired_circuits__Circuit_c.wired_circuit =
  let exception QtReturn of Wired_circuits__Circuit_c.wired_circuit in
  try
    let c1 = ref (Parallel_delete__Parallel_del.parallel_del c) in
    c1 := Ternary_gates_delete__Ternary_gates_del.ternary_gates_del !c1;
    c1 := Atomic_place__Atomic_place.place_atomic !c1;
    c1 := control_delete !c1;
    c1 := control_atomic !c1;
    raise (QtReturn !c1)
  with
  | QtReturn r -> r

