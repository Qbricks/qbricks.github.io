let rec ternary_gates_free (c: Wired_circuits__Circuit_c.wired_circuit) :
  bool =
  match c with
  | Wired_circuits__Circuit_c.Parallel (c1,
    c2) ->
    ternary_gates_free c1 && ternary_gates_free c2
  | Wired_circuits__Circuit_c.Sequence (c1,
    c2) ->
    ternary_gates_free c1 && ternary_gates_free c2
  | Wired_circuits__Circuit_c.Place (c1, _, _) -> ternary_gates_free c1
  | Wired_circuits__Circuit_c.Cont (c1, _, _, _) -> ternary_gates_free c1
  | Wired_circuits__Circuit_c.Ancillas (c1, _) -> ternary_gates_free c1
  | Wired_circuits__Circuit_c.Toffoli (_, _, _, _) -> false
  | Wired_circuits__Circuit_c.Fredkin (_, _, _, _) -> false
  | Wired_circuits__Circuit_c.Bricks_Toffoli -> false
  | Wired_circuits__Circuit_c.Bricks_Fredkin -> false
  | _ -> true

let rec ternary_gates_del (c: Wired_circuits__Circuit_c.wired_circuit) :
  Wired_circuits__Circuit_c.wired_circuit =
  match c with
  | Wired_circuits__Circuit_c.Place (c1,
    t,
    n) ->
    Wired_circuits__Circuit_c.Place (ternary_gates_del c1, t, n)
  | Wired_circuits__Circuit_c.Cont (c1,
    co,
    t,
    n) ->
    Wired_circuits__Circuit_c.Cont (ternary_gates_del c1, co, t, n)
  | Wired_circuits__Circuit_c.Sequence (d,
    e) ->
    Wired_circuits__Circuit_c.Sequence (ternary_gates_del d,
    ternary_gates_del e)
  | Wired_circuits__Circuit_c.Parallel (d,
    e) ->
    Wired_circuits__Circuit_c.Parallel (ternary_gates_del d,
    ternary_gates_del e)
  | Wired_circuits__Circuit_c.Toffoli (a,
    b,
    c1,
    d) ->
    Circuits_equiv_pre__Gate_decomp.toffoli_decomp a b c1 d
  | Wired_circuits__Circuit_c.Fredkin (a,
    b,
    c1,
    d) ->
    Circuits_equiv_pre__Gate_decomp.fredkin_decomp_toffoli a b c1 d
  | Wired_circuits__Circuit_c.Bricks_Toffoli ->
    Circuits_equiv_pre__Gate_decomp.toffoli_decomp Z.zero
    Z.one
    (Z.of_string "2")
    (Z.of_string "3")
  | Wired_circuits__Circuit_c.Bricks_Fredkin ->
    Circuits_equiv_pre__Gate_decomp.fredkin_decomp_toffoli Z.zero
    Z.one
    (Z.of_string "2")
    (Z.of_string "3")
  | _ -> c

