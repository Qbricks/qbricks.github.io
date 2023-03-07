let rec skip_atomic (c: Wired_circuits__Circuit_c.wired_circuit) : bool =
  match c with
  | (Wired_circuits__Circuit_c.Parallel (_,
     _) | (Wired_circuits__Circuit_c.Sequence (_,
           _) | (Wired_circuits__Circuit_c.Place (_, _,
                 _) | (Wired_circuits__Circuit_c.Cont (_, _, _,
                       _) | Wired_circuits__Circuit_c.Ancillas (_, _))))) ->
    false
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

let rec place_free (c: Wired_circuits__Circuit_c.wired_circuit) : bool =
  match c with
  | Wired_circuits__Circuit_c.Place (_, _, _) -> false
  | Wired_circuits__Circuit_c.Parallel (c1,
    d) ->
    place_free c1 && place_free d
  | Wired_circuits__Circuit_c.Sequence (c1,
    d) ->
    place_free c1 && place_free d
  | Wired_circuits__Circuit_c.Cont (c1, _, _, _) -> place_free c1
  | Wired_circuits__Circuit_c.Ancillas (c1, _) -> place_free c1
  | _ -> true

