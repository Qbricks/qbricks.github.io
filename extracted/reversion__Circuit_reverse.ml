let rec ancilla_free_pre (c: Wired_circuits__Circuit_c.wired_circuit) : 
  bool =
  match c with
  | Wired_circuits__Circuit_c.Skip -> true
  | Wired_circuits__Circuit_c.Phase _ -> true
  | Wired_circuits__Circuit_c.Rx _ -> true
  | Wired_circuits__Circuit_c.Ry _ -> true
  | Wired_circuits__Circuit_c.Rz _ -> true
  | Wired_circuits__Circuit_c.Rzp _ -> true
  | Wired_circuits__Circuit_c.Hadamard -> true
  | Wired_circuits__Circuit_c.S -> true
  | Wired_circuits__Circuit_c.T -> true
  | Wired_circuits__Circuit_c.X -> true
  | Wired_circuits__Circuit_c.Y -> true
  | Wired_circuits__Circuit_c.Z -> true
  | Wired_circuits__Circuit_c.Bricks_Cnot -> true
  | Wired_circuits__Circuit_c.Bricks_Toffoli -> true
  | Wired_circuits__Circuit_c.Bricks_Fredkin -> true
  | Wired_circuits__Circuit_c.Bricks_Swap -> true
  | Wired_circuits__Circuit_c.Cnot (_, _, _) -> true
  | Wired_circuits__Circuit_c.Swap (_, _, _) -> true
  | Wired_circuits__Circuit_c.Toffoli (_, _, _, _) -> true
  | Wired_circuits__Circuit_c.Fredkin (_, _, _, _) -> true
  | Wired_circuits__Circuit_c.Place (c1, _, _) -> ancilla_free_pre c1
  | Wired_circuits__Circuit_c.Cont (c1, _, _, _) -> ancilla_free_pre c1
  | Wired_circuits__Circuit_c.Sequence (d,
    e) ->
    ancilla_free_pre d && ancilla_free_pre e
  | Wired_circuits__Circuit_c.Parallel (d,
    e) ->
    ancilla_free_pre d && ancilla_free_pre e
  | Wired_circuits__Circuit_c.Ancillas (_, _) -> false

let ancilla_free (c: Wired_circuits__Circuit_c.circuit) : bool =
  ancilla_free_pre c

let rec reverse_pre (c: Wired_circuits__Circuit_c.wired_circuit) :
  Wired_circuits__Circuit_c.wired_circuit =
  match c with
  | Wired_circuits__Circuit_c.Skip -> Wired_circuits__Circuit_c.Skip
  | Wired_circuits__Circuit_c.Phase k ->
    Wired_circuits__Circuit_c.Phase (Z.neg k)
  | Wired_circuits__Circuit_c.Rx k -> Wired_circuits__Circuit_c.Rx (Z.neg k)
  | Wired_circuits__Circuit_c.Ry k -> Wired_circuits__Circuit_c.Ry (Z.neg k)
  | Wired_circuits__Circuit_c.Rz k -> Wired_circuits__Circuit_c.Rz (Z.neg k)
  | Wired_circuits__Circuit_c.Rzp k ->
    Wired_circuits__Circuit_c.Rzp (Z.neg k)
  | Wired_circuits__Circuit_c.Hadamard -> Wired_circuits__Circuit_c.Hadamard
  | Wired_circuits__Circuit_c.S ->
    Wired_circuits__Circuit_c.Rzp (Z.of_string "-2")
  | Wired_circuits__Circuit_c.T ->
    Wired_circuits__Circuit_c.Rzp (Z.of_string "-3")
  | Wired_circuits__Circuit_c.X -> Wired_circuits__Circuit_c.X
  | Wired_circuits__Circuit_c.Y -> Wired_circuits__Circuit_c.Y
  | Wired_circuits__Circuit_c.Z -> Wired_circuits__Circuit_c.Z
  | Wired_circuits__Circuit_c.Bricks_Cnot ->
    Wired_circuits__Circuit_c.Bricks_Cnot
  | Wired_circuits__Circuit_c.Bricks_Toffoli ->
    Wired_circuits__Circuit_c.Bricks_Toffoli
  | Wired_circuits__Circuit_c.Bricks_Fredkin ->
    Wired_circuits__Circuit_c.Bricks_Fredkin
  | Wired_circuits__Circuit_c.Bricks_Swap ->
    Wired_circuits__Circuit_c.Bricks_Swap
  | Wired_circuits__Circuit_c.Cnot (c1,
    t,
    n) ->
    Wired_circuits__Circuit_c.Cnot (c1, t, n)
  | Wired_circuits__Circuit_c.Swap (t1,
    t2,
    n) ->
    Wired_circuits__Circuit_c.Swap (t1, t2, n)
  | Wired_circuits__Circuit_c.Toffoli (c1,
    c2,
    t,
    n) ->
    Wired_circuits__Circuit_c.Toffoli (c1, c2, t, n)
  | Wired_circuits__Circuit_c.Fredkin (c1,
    t1,
    t2,
    n) ->
    Wired_circuits__Circuit_c.Fredkin (c1, t1, t2, n)
  | Wired_circuits__Circuit_c.Place (c1,
    p,
    n) ->
    Wired_circuits__Circuit_c.Place (reverse_pre c1, p, n)
  | Wired_circuits__Circuit_c.Cont (c1,
    co,
    t,
    n) ->
    Wired_circuits__Circuit_c.Cont (reverse_pre c1, co, t, n)
  | Wired_circuits__Circuit_c.Sequence (d,
    e) ->
    Wired_circuits__Circuit_c.Sequence (reverse_pre e, reverse_pre d)
  | Wired_circuits__Circuit_c.Parallel (d,
    e) ->
    Wired_circuits__Circuit_c.Parallel (reverse_pre d, reverse_pre e)
  | Wired_circuits__Circuit_c.Ancillas (d,
    l) ->
    Wired_circuits__Circuit_c.Ancillas (d, l)

let reverse (c: Wired_circuits__Circuit_c.circuit) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Circuit_c.to_qc (reverse_pre c)

