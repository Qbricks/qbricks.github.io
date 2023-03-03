let rec atomic_place (c: Wired_circuits__Circuit_c.wired_circuit) : bool =
  match c with
  | Wired_circuits__Circuit_c.Parallel (c1,
    d) ->
    atomic_place c1 && atomic_place d
  | Wired_circuits__Circuit_c.Sequence (c1,
    d) ->
    atomic_place c1 && atomic_place d
  | Wired_circuits__Circuit_c.Place (c1,
    _,
    _) ->
    Commuting_lemmas__Place_atomic_def.skip_atomic c1
  | Wired_circuits__Circuit_c.Cont (c1, _, _, _) -> atomic_place c1
  | Wired_circuits__Circuit_c.Ancillas (_, _) -> false
  | (Wired_circuits__Circuit_c.Skip | (Wired_circuits__Circuit_c.Phase _ | 
                                       (Wired_circuits__Circuit_c.Rx _ | 
                                        (Wired_circuits__Circuit_c.Ry _ | 
                                         (Wired_circuits__Circuit_c.Rz _ | 
                                          (Wired_circuits__Circuit_c.Rzp _ | 
                                           (Wired_circuits__Circuit_c.Hadamard | 
                                            (Wired_circuits__Circuit_c.S | 
                                             (Wired_circuits__Circuit_c.T | 
                                              (Wired_circuits__Circuit_c.X | 
                                               (Wired_circuits__Circuit_c.Y | 
                                                (Wired_circuits__Circuit_c.Z | 
                                                 (Wired_circuits__Circuit_c.Bricks_Cnot | 
                                                  (Wired_circuits__Circuit_c.Bricks_Toffoli | 
                                                   (Wired_circuits__Circuit_c.Bricks_Fredkin | 
                                                    (Wired_circuits__Circuit_c.Bricks_Swap | 
                                                     (Wired_circuits__Circuit_c.Swap (_,
                                                      _,
                                                      _) | (Wired_circuits__Circuit_c.Cnot (_,
                                                            _,
                                                            _) | (Wired_circuits__Circuit_c.Toffoli (_,
                                                                  _, _,
                                                                  _) | Wired_circuits__Circuit_c.Fredkin (_,
                                                                  _, _, _)))))))))))))))))))) ->
    true

let rec placed_atomic (c: Wired_circuits__Circuit_c.wired_circuit) (k: Z.t)
                      (n: Z.t) : Wired_circuits__Circuit_c.wired_circuit =
  match c with
  | Wired_circuits__Circuit_c.Sequence (c1,
    c2) ->
    Wired_circuits__Circuit_c.Sequence (placed_atomic c1 k n,
    placed_atomic c2 k n)
  | Wired_circuits__Circuit_c.Place (c1,
    k1,
    _) ->
    placed_atomic c1 (Z.add k k1) n
  | Wired_circuits__Circuit_c.Cont (c1,
    co,
    t,
    _) ->
    Wired_circuits__Circuit_c.Cont (placed_atomic c1
                                    Z.zero
                                    (Wired_circuits__Circuit_c.width_pre c1),
    Z.add co k,
    Z.add t k,
    n)
  | _ -> Wired_circuits__Circuit_c.Place (c, k, n)

let rec place_atomic (c: Wired_circuits__Circuit_c.wired_circuit) :
  Wired_circuits__Circuit_c.wired_circuit =
  match c with
  | Wired_circuits__Circuit_c.Sequence (c1,
    c2) ->
    Wired_circuits__Circuit_c.Sequence (place_atomic c1, place_atomic c2)
  | Wired_circuits__Circuit_c.Ancillas (c1,
    i) ->
    Wired_circuits__Circuit_c.Ancillas (place_atomic c1, i)
  | Wired_circuits__Circuit_c.Place (c1, k, n) -> placed_atomic c1 k n
  | Wired_circuits__Circuit_c.Cont (c1,
    c2,
    t,
    n) ->
    Wired_circuits__Circuit_c.Cont (place_atomic c1, c2, t, n)
  | _ -> c

let rec atomic_control (ci: Wired_circuits__Circuit_c.wired_circuit) : 
  bool =
  match ci with
  | Wired_circuits__Circuit_c.Parallel (c,
    d) ->
    atomic_control c && atomic_control d
  | Wired_circuits__Circuit_c.Sequence (c,
    d) ->
    atomic_control c && atomic_control d
  | Wired_circuits__Circuit_c.Place (c,
    _,
    _) ->
    Commuting_lemmas__Place_atomic_def.skip_atomic c
  | Wired_circuits__Circuit_c.Cont (c,
    _,
    _,
    _) ->
    Commuting_lemmas__Place_atomic_def.skip_atomic c
  | Wired_circuits__Circuit_c.Ancillas (_, _) -> false
  | _ -> true

