let rec ancilla_free (c: Wired_circuits__Circuit_c.wired_circuit) : bool =
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
  | Wired_circuits__Circuit_c.Place (c1, _, _) -> ancilla_free c1
  | Wired_circuits__Circuit_c.Cont (c1, _, _, _) -> ancilla_free c1
  | Wired_circuits__Circuit_c.Sequence (d,
    e) ->
    ancilla_free d && ancilla_free e
  | Wired_circuits__Circuit_c.Parallel (d,
    e) ->
    ancilla_free d && ancilla_free e
  | Wired_circuits__Circuit_c.Ancillas (_, _) -> false

