type openqasm =
  | RX of (string)
  | RY of (string)
  | RZ of (string)
  | U1 of (string)
  | CRX of (string) * (string) * (string)
  | CRY of (string) * (string) * (string)
  | CRZ of (string) * (string) * (string)
  | CU1 of (string) * (string) * (string)
  | H
  | SS
  | TT
  | XX
  | YY
  | ZZ
  | ID
  | CH of (string) * (string)
  | CS of (string) * (string)
  | CT of (string) * (string)
  | CY of (string) * (string)
  | CZ of (string) * (string)
  | CX of (string) * (string)
  | CCX of (string) * (string) * (string)
  | SWAP of (string) * (string)
  | SEQUENCE of openqasm * openqasm
  | PLACE of openqasm * (string)

let string_rotation_oq_pos (k: Z.t) : string =
  Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf "(2 * pi / 2^("
                                (Draw_circuits__Draw.i_to_s k))
  "))"

let string_rotation_oq_neg (k: Z.t) : string =
  Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf "(- 2 * pi / 2^("
                                (Draw_circuits__Draw.i_to_s (Z.neg k)))
  "))"

let rec qbricks_to_openqasm (c: Wired_circuits__Circuit_c.wired_circuit) :
  openqasm =
  match c with
  | Wired_circuits__Circuit_c.Phase _ -> ID
  | Wired_circuits__Circuit_c.Skip -> ID
  | Wired_circuits__Circuit_c.Rx k ->
    RX (if Z.lt k Z.zero
        then string_rotation_oq_neg k
        else string_rotation_oq_pos k)
  | Wired_circuits__Circuit_c.Ry k ->
    RY (if Z.lt k Z.zero
        then string_rotation_oq_neg k
        else string_rotation_oq_pos k)
  | Wired_circuits__Circuit_c.Rz k ->
    RZ (if Z.lt k Z.zero
        then string_rotation_oq_neg k
        else string_rotation_oq_pos k)
  | Wired_circuits__Circuit_c.Rzp k ->
    U1 (if Z.lt k Z.zero
        then string_rotation_oq_neg k
        else string_rotation_oq_pos k)
  | Wired_circuits__Circuit_c.Hadamard -> H
  | Wired_circuits__Circuit_c.S -> SS
  | Wired_circuits__Circuit_c.T -> TT
  | Wired_circuits__Circuit_c.X -> XX
  | Wired_circuits__Circuit_c.Y -> YY
  | Wired_circuits__Circuit_c.Z -> ZZ
  | Wired_circuits__Circuit_c.Cnot (co,
    t,
    _) ->
    CX (Draw_circuits__Draw.i_to_s co, Draw_circuits__Draw.i_to_s t)
  | Wired_circuits__Circuit_c.Bricks_Cnot ->
    CX (Draw_circuits__Draw.i_to_s Z.zero, Draw_circuits__Draw.i_to_s Z.one)
  | Wired_circuits__Circuit_c.Swap (t1,
    t2,
    _) ->
    SWAP (Draw_circuits__Draw.i_to_s t1, Draw_circuits__Draw.i_to_s t2)
  | Wired_circuits__Circuit_c.Bricks_Swap ->
    SWAP (Draw_circuits__Draw.i_to_s Z.zero,
    Draw_circuits__Draw.i_to_s Z.one)
  | Wired_circuits__Circuit_c.Sequence (d,
    e) ->
    SEQUENCE (qbricks_to_openqasm d, qbricks_to_openqasm e)
  | Wired_circuits__Circuit_c.Place (c1,
    p,
    _) ->
    begin match c1 with
    | Wired_circuits__Circuit_c.Cnot (co1,
      ta1,
      n1) ->
      CX (Draw_circuits__Draw.i_to_s (Z.add co1 p),
      Draw_circuits__Draw.i_to_s (Z.add ta1 p))
    | Wired_circuits__Circuit_c.Bricks_Cnot ->
      CX (Draw_circuits__Draw.i_to_s p,
      Draw_circuits__Draw.i_to_s (Z.add Z.one p))
    | Wired_circuits__Circuit_c.Swap (ta1,
      ta2,
      n1) ->
      SWAP (Draw_circuits__Draw.i_to_s (Z.add ta1 p),
      Draw_circuits__Draw.i_to_s (Z.add ta2 p))
    | Wired_circuits__Circuit_c.Bricks_Swap ->
      SWAP (Draw_circuits__Draw.i_to_s p,
      Draw_circuits__Draw.i_to_s (Z.add Z.one p))
    | _ -> PLACE (qbricks_to_openqasm c1, Draw_circuits__Draw.i_to_s p)
    end
  | Wired_circuits__Circuit_c.Cont (c1,
    co,
    t,
    n) ->
    begin match c1 with
    | Wired_circuits__Circuit_c.Phase k ->
      CRZ (Draw_circuits__Draw.i_to_s co,
      Draw_circuits__Draw.i_to_s t,
      (if Z.lt k Z.zero
       then string_rotation_oq_neg k
       else string_rotation_oq_pos k))
    | Wired_circuits__Circuit_c.Skip ->
      PLACE (ID, Draw_circuits__Draw.i_to_s t)
    | Wired_circuits__Circuit_c.Rx k ->
      CRX (Draw_circuits__Draw.i_to_s co,
      Draw_circuits__Draw.i_to_s t,
      (if Z.lt k Z.zero
       then string_rotation_oq_neg k
       else string_rotation_oq_pos k))
    | Wired_circuits__Circuit_c.Ry k ->
      CRY (Draw_circuits__Draw.i_to_s co,
      Draw_circuits__Draw.i_to_s t,
      (if Z.lt k Z.zero
       then string_rotation_oq_neg k
       else string_rotation_oq_pos k))
    | Wired_circuits__Circuit_c.Rz k ->
      CRZ (Draw_circuits__Draw.i_to_s co,
      Draw_circuits__Draw.i_to_s t,
      (if Z.lt k Z.zero
       then string_rotation_oq_neg k
       else string_rotation_oq_pos k))
    | Wired_circuits__Circuit_c.Rzp k ->
      CU1 (Draw_circuits__Draw.i_to_s co,
      Draw_circuits__Draw.i_to_s t,
      (if Z.lt k Z.zero
       then string_rotation_oq_neg k
       else string_rotation_oq_pos k))
    | Wired_circuits__Circuit_c.Hadamard ->
      CH (Draw_circuits__Draw.i_to_s co, Draw_circuits__Draw.i_to_s t)
    | Wired_circuits__Circuit_c.S ->
      CRZ (Draw_circuits__Draw.i_to_s co,
      Draw_circuits__Draw.i_to_s t,
      "pi/2)")
    | Wired_circuits__Circuit_c.T ->
      CRZ (Draw_circuits__Draw.i_to_s co,
      Draw_circuits__Draw.i_to_s t,
      "pi/4)")
    | Wired_circuits__Circuit_c.X ->
      CX (Draw_circuits__Draw.i_to_s co, Draw_circuits__Draw.i_to_s t)
    | Wired_circuits__Circuit_c.Y ->
      CY (Draw_circuits__Draw.i_to_s co, Draw_circuits__Draw.i_to_s t)
    | Wired_circuits__Circuit_c.Z ->
      CZ (Draw_circuits__Draw.i_to_s co, Draw_circuits__Draw.i_to_s t)
    | Wired_circuits__Circuit_c.Bricks_Cnot ->
      CCX (Draw_circuits__Draw.i_to_s Z.zero,
      Draw_circuits__Draw.i_to_s (Z.add Z.one t),
      Draw_circuits__Draw.i_to_s (Z.add (Z.of_string "2") t))
    | Wired_circuits__Circuit_c.Cnot (co1,
      ta1,
      _) ->
      CCX (Draw_circuits__Draw.i_to_s co,
      Draw_circuits__Draw.i_to_s (Z.add co1 t),
      Draw_circuits__Draw.i_to_s (Z.add t ta1))
    | Wired_circuits__Circuit_c.Swap (ta1,
      ta2,
      n1) ->
      SEQUENCE (SEQUENCE (CCX (Draw_circuits__Draw.i_to_s co,
                          Draw_circuits__Draw.i_to_s (Z.add ta1 t),
                          Draw_circuits__Draw.i_to_s (Z.add ta2 t)),
                CCX (Draw_circuits__Draw.i_to_s co,
                Draw_circuits__Draw.i_to_s (Z.add ta2 t),
                Draw_circuits__Draw.i_to_s (Z.add ta1 t))),
      CCX (Draw_circuits__Draw.i_to_s co,
      Draw_circuits__Draw.i_to_s (Z.add ta1 t),
      Draw_circuits__Draw.i_to_s (Z.add ta2 t)))
    | Wired_circuits__Circuit_c.Bricks_Swap ->
      SEQUENCE (SEQUENCE (CCX (Draw_circuits__Draw.i_to_s co,
                          Draw_circuits__Draw.i_to_s t,
                          Draw_circuits__Draw.i_to_s (Z.add t Z.one)),
                CCX (Draw_circuits__Draw.i_to_s co,
                Draw_circuits__Draw.i_to_s (Z.add t Z.one),
                Draw_circuits__Draw.i_to_s t)),
      CCX (Draw_circuits__Draw.i_to_s co,
      Draw_circuits__Draw.i_to_s t,
      Draw_circuits__Draw.i_to_s (Z.add t Z.one)))
    | _ -> ID
    end
  | _ -> ID

let rec string_oq_rec (c: openqasm) : string =
  match c with
  | RX k -> Draw_circuits__Draw.infix_cf "rx " k
  | RY k -> Draw_circuits__Draw.infix_cf "ry " k
  | RZ k -> Draw_circuits__Draw.infix_cf "rz " k
  | U1 k -> Draw_circuits__Draw.infix_cf "u1 " k
  | CRX (co,
    t,
    k) ->
    Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf 
                                                                (Draw_circuits__Draw.infix_cf 
                                                                 (Draw_circuits__Draw.infix_cf 
                                                                  (Draw_circuits__Draw.infix_cf "crx("
                                                                   k)
                                                                  ") q[")
                                                                 co)
                                                                "], q[")
                                  t)
    "];\n"
  | CRY (co,
    t,
    k) ->
    Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf 
                                                                (Draw_circuits__Draw.infix_cf 
                                                                 (Draw_circuits__Draw.infix_cf 
                                                                  (Draw_circuits__Draw.infix_cf "cry("
                                                                   k)
                                                                  ") q[")
                                                                 co)
                                                                "], q[")
                                  t)
    "];\n"
  | CRZ (co,
    t,
    k) ->
    Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf 
                                                                (Draw_circuits__Draw.infix_cf 
                                                                 (Draw_circuits__Draw.infix_cf 
                                                                  (Draw_circuits__Draw.infix_cf "crz("
                                                                   k)
                                                                  ") q[")
                                                                 co)
                                                                "], q[")
                                  t)
    "];\n"
  | CU1 (co,
    t,
    k) ->
    Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf 
                                                                (Draw_circuits__Draw.infix_cf 
                                                                 (Draw_circuits__Draw.infix_cf 
                                                                  (Draw_circuits__Draw.infix_cf "cu1("
                                                                   k)
                                                                  ") q[")
                                                                 co)
                                                                "], q[")
                                  t)
    "];\n"
  | H -> "h"
  | SS -> "s"
  | TT -> "t"
  | XX -> "x"
  | YY -> "y"
  | ZZ -> "z"
  | ID -> "id"
  | CH (co,
    t) ->
    Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf 
                                                                (Draw_circuits__Draw.infix_cf "ch q["
                                                                 co)
                                                                "], q[")
                                  t)
    "];\n"
  | CS (co,
    t) ->
    Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf 
                                                                (Draw_circuits__Draw.infix_cf "cs q["
                                                                 co)
                                                                "], q[")
                                  t)
    "];\n"
  | CT (co,
    t) ->
    Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf 
                                                                (Draw_circuits__Draw.infix_cf "ct q["
                                                                 co)
                                                                "], q[")
                                  t)
    "];\n"
  | CX (co,
    t) ->
    Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf 
                                                                (Draw_circuits__Draw.infix_cf "cx q["
                                                                 co)
                                                                "], q[")
                                  t)
    "];\n"
  | CY (co,
    t) ->
    Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf 
                                                                (Draw_circuits__Draw.infix_cf "cy q["
                                                                 co)
                                                                "], q[")
                                  t)
    "];\n"
  | CZ (co,
    t) ->
    Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf 
                                                                (Draw_circuits__Draw.infix_cf "cz q["
                                                                 co)
                                                                "], q[")
                                  t)
    "];\n"
  | CCX (co1,
    co2,
    t) ->
    Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf 
                                                                (Draw_circuits__Draw.infix_cf 
                                                                 (Draw_circuits__Draw.infix_cf 
                                                                  (Draw_circuits__Draw.infix_cf "ccx q["
                                                                   co1)
                                                                  "], q[")
                                                                 co2)
                                                                "], q[")
                                  t)
    "];\n"
  | SWAP (t1,
    t2) ->
    Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf 
                                                                (Draw_circuits__Draw.infix_cf "swap q["
                                                                 t1)
                                                                "], q[")
                                  t2)
    "];\n"
  | SEQUENCE (d,
    e) ->
    Draw_circuits__Draw.infix_cf (string_oq_rec d) (string_oq_rec e)
  | PLACE (c1,
    p) ->
    begin match c1 with
    | ID -> ""
    | _ ->
      Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf 
                                                                  (string_oq_rec c1)
                                                                  " q[")
                                    p)
      "];\n"
    end

let print_oq (c: Wired_circuits__Circuit_c.wired_circuit) : string =
  Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf (Draw_circuits__Draw.infix_cf "OPENQASM 2.0;\ninclude \"qelib1.inc\";\nqreg q["
                                                              (Draw_circuits__Draw.i_to_s 
                                                               (Wired_circuits__Circuit_c.width_pre c)))
                                "];\n")
  (string_oq_rec (qbricks_to_openqasm c))

let string_oq (c: Wired_circuits__Circuit_c.circuit) : string =
  print_oq (Subcircuit_control__Subcircuit_control.to_oqasm c)

