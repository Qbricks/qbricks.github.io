let rec parallel_free (c: Wired_circuits__Circuit_c.wired_circuit) : 
  bool =
  match c with
  | Wired_circuits__Circuit_c.Parallel (_, _) -> false
  | Wired_circuits__Circuit_c.Ancillas (c1, _) -> parallel_free c1
  | Wired_circuits__Circuit_c.Sequence (c1,
    c2) ->
    parallel_free c1 && parallel_free c2
  | Wired_circuits__Circuit_c.Place (c1, _, _) -> parallel_free c1
  | Wired_circuits__Circuit_c.Cont (c1, _, _, _) -> parallel_free c1
  | _ -> true

let rec parallel_del (c: Wired_circuits__Circuit_c.wired_circuit) :
  Wired_circuits__Circuit_c.wired_circuit =
  match c with
  | Wired_circuits__Circuit_c.Place (c1,
    t,
    n) ->
    Wired_circuits__Circuit_c.Place (parallel_del c1, t, n)
  | Wired_circuits__Circuit_c.Cont (c1,
    co,
    t,
    n) ->
    Wired_circuits__Circuit_c.Cont (parallel_del c1, co, t, n)
  | Wired_circuits__Circuit_c.Sequence (d,
    e) ->
    Wired_circuits__Circuit_c.Sequence (parallel_del d, parallel_del e)
  | Wired_circuits__Circuit_c.Parallel (d,
    e) ->
    Circuits_equiv_pre__Circuit_equivalence_impl.remove_parallel (parallel_del d)
    (parallel_del e)
  | _ -> c

