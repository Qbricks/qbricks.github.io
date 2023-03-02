let rec cont_depth (c: Wired_circuits__Circuit_c.wired_circuit) : Z.t =
  match c with
  | Wired_circuits__Circuit_c.Cont (c1,
    _,
    _,
    _) ->
    Z.add (cont_depth c1) Z.one
  | Wired_circuits__Circuit_c.Sequence (d,
    e) ->
    Z.max (cont_depth d) (cont_depth e)
  | Wired_circuits__Circuit_c.Parallel (d,
    e) ->
    Z.max (cont_depth d) (cont_depth e)
  | Wired_circuits__Circuit_c.Place (c1, _, _) -> cont_depth c1
  | Wired_circuits__Circuit_c.Ancillas (c1, _) -> cont_depth c1
  | _ -> Z.zero

