type wired_circuit =
  | Skip
  | Phase of (Z.t)
  | Rx of (Z.t)
  | Ry of (Z.t)
  | Rz of (Z.t)
  | Rzp of (Z.t)
  | Hadamard
  | S
  | T
  | X
  | Y
  | Z
  | Bricks_Cnot
  | Bricks_Toffoli
  | Bricks_Fredkin
  | Bricks_Swap
  | Swap of (Z.t) * (Z.t) * (Z.t)
  | Cnot of (Z.t) * (Z.t) * (Z.t)
  | Toffoli of (Z.t) * (Z.t) * (Z.t) * (Z.t)
  | Fredkin of (Z.t) * (Z.t) * (Z.t) * (Z.t)
  | Place of wired_circuit * (Z.t) * (Z.t)
  | Cont of wired_circuit * (Z.t) * (Z.t) * (Z.t)
  | Sequence of wired_circuit * wired_circuit
  | Parallel of wired_circuit * wired_circuit
  | Ancillas of wired_circuit * (Z.t)

let rec width_pre_ (c: wired_circuit) : Z.t =
  match c with
  | Skip -> Z.one
  | Bricks_Cnot -> Z.of_string "2"
  | Bricks_Toffoli -> Z.of_string "3"
  | Bricks_Fredkin -> Z.of_string "3"
  | Bricks_Swap -> Z.of_string "2"
  | Swap (_, _, n) -> n
  | Cnot (_, _, n) -> n
  | Toffoli (_, _, _, n) -> n
  | Fredkin (_, _, _, n) -> n
  | Place (_, _, n) -> n
  | Cont (_, _, _, n) -> n
  | Sequence (d, _) -> width_pre_ d
  | Parallel (d, e) -> Z.add (width_pre_ d) (width_pre_ e)
  | Ancillas (d, i) -> Z.sub (width_pre_ d) i
  | _ -> Z.one

let rec build_correct_ (c: wired_circuit) : bool =
  match c with
  | Cnot (c1,
    t,
    n) ->
    (Z.leq Z.zero c1 && Z.lt c1 n) && (Z.leq Z.zero t && Z.lt t n) && 
                                      not (Z.equal c1 t)
  | Swap (t1,
    t2,
    n) ->
    (Z.leq Z.zero t1 && Z.lt t1 n) && (Z.leq Z.zero t2 && Z.lt t2 n) && 
                                      not (Z.equal t1 t2)
  | Toffoli (c1,
    c2,
    t,
    n) ->
    (Z.leq Z.zero c1 && Z.lt c1 n) && (Z.leq Z.zero c2 && Z.lt c2 n) && 
                                      (Z.leq Z.zero t && Z.lt t n) && 
                                      not (Z.equal c1 t) && not (Z.equal c2
                                                                 t) && 
                                                            not (Z.equal c1
                                                                 c2)
  | Fredkin (c1,
    c2,
    t,
    n) ->
    (Z.leq Z.zero c1 && Z.lt c1 n) && (Z.leq Z.zero c2 && Z.lt c2 n) && 
                                      (Z.leq Z.zero t && Z.lt t n) && 
                                      not (Z.equal c1 t) && not (Z.equal c2
                                                                 t) && 
                                                            not (Z.equal c1
                                                                 c2)
  | Place (c1,
    t,
    n) ->
    build_correct_ c1 && (Z.leq Z.zero t && Z.lt t n) && Z.leq (Z.add t
                                                                (width_pre_ c1))
                                                         n
  | Cont (c1,
    co,
    t,
    n) ->
    build_correct_ c1 && (Z.leq Z.zero co && Z.lt co n) && (Z.leq Z.zero t && 
                                                            Z.leq t
                                                            (Z.sub n
                                                             (width_pre_ c1))) && 
                                                           (Z.lt co t || 
                                                            Z.leq (Z.add t
                                                                   (width_pre_ c1))
                                                            co)
  | Sequence (d,
    e) ->
    Z.equal (width_pre_ d) (width_pre_ e) && build_correct_ d && build_correct_ e
  | Parallel (d, e) -> build_correct_ d && build_correct_ e
  | Ancillas (d,
    i) ->
    Z.leq Z.one i && Z.leq (Z.add i Z.one) (width_pre_ d) && build_correct_ d
  | _ -> true

let rec width_pre (c: wired_circuit) : Z.t =
  match c with
  | Skip -> Z.one
  | Bricks_Cnot -> Z.of_string "2"
  | Bricks_Toffoli -> Z.of_string "3"
  | Bricks_Fredkin -> Z.of_string "3"
  | Bricks_Swap -> Z.of_string "2"
  | Swap (_, _, n) -> n
  | Cnot (_, _, n) -> n
  | Toffoli (_, _, _, n) -> n
  | Fredkin (_, _, _, n) -> n
  | Place (_, _, n) -> n
  | Cont (_, _, _, n) -> n
  | Sequence (d, _) -> width_pre d
  | Parallel (d, e) -> Z.add (width_pre d) (width_pre e)
  | Ancillas (d, i) -> Z.sub (width_pre d) i
  | _ -> Z.one

let rec build_correct (c: wired_circuit) : bool =
  match c with
  | Cnot (c1,
    t,
    n) ->
    (Z.leq Z.zero c1 && Z.lt c1 n) && (Z.leq Z.zero t && Z.lt t n) && 
                                      not (Z.equal c1 t)
  | Swap (t1,
    t2,
    n) ->
    (Z.leq Z.zero t1 && Z.lt t1 n) && (Z.leq Z.zero t2 && Z.lt t2 n) && 
                                      not (Z.equal t1 t2)
  | Toffoli (c1,
    c2,
    t,
    n) ->
    (Z.leq Z.zero c1 && Z.lt c1 n) && (Z.leq Z.zero c2 && Z.lt c2 n) && 
                                      (Z.leq Z.zero t && Z.lt t n) && 
                                      not (Z.equal c1 t) && not (Z.equal c2
                                                                 t) && 
                                                            not (Z.equal c1
                                                                 c2)
  | Fredkin (c1,
    c2,
    t,
    n) ->
    (Z.leq Z.zero c1 && Z.lt c1 n) && (Z.leq Z.zero c2 && Z.lt c2 n) && 
                                      (Z.leq Z.zero t && Z.lt t n) && 
                                      not (Z.equal c1 t) && not (Z.equal c2
                                                                 t) && 
                                                            not (Z.equal c1
                                                                 c2)
  | Place (c1,
    t,
    n) ->
    build_correct c1 && (Z.leq Z.zero t && Z.lt t n) && Z.leq (Z.add t
                                                               (width_pre c1))
                                                        n
  | Cont (c1,
    co,
    t,
    n) ->
    build_correct c1 && (Z.leq Z.zero co && Z.lt co n) && (Z.leq Z.zero t && 
                                                           Z.leq t
                                                           (Z.sub n
                                                            (width_pre c1))) && 
                                                          (Z.lt co t || 
                                                           Z.leq (Z.add t
                                                                  (width_pre c1))
                                                           co)
  | Sequence (d,
    e) ->
    build_correct d && build_correct e && Z.equal (width_pre d) (width_pre e)
  | Parallel (d, e) -> build_correct d && build_correct e
  | Ancillas (d,
    i) ->
    build_correct d && Z.leq Z.one i && Z.leq (Z.add i Z.one) (width_pre d)
  | _ -> true

let rec depth_pre (c: wired_circuit) : Z.t =
  match c with
  | Skip -> Z.zero
  | Place (c1, _, _) -> depth_pre c1
  | Cont (c1, _, _, _) -> depth_pre c1
  | Sequence (d, e) -> Z.add (depth_pre d) (depth_pre e)
  | Parallel (d, e) -> Z.max (depth_pre d) (depth_pre e)
  | Ancillas (d, _) -> depth_pre d
  | _ -> Z.one

let cont_size : Z.t = Z.one 

let rec ancillas_pre (c: wired_circuit) : Z.t =
  match c with
  | Place (c1, _, _) -> ancillas_pre c1
  | Cont (c1, _, _, _) -> ancillas_pre c1
  | Sequence (d, e) -> Z.max (ancillas_pre d) (ancillas_pre e)
  | Parallel (d, e) -> Z.add (ancillas_pre d) (ancillas_pre e)
  | Ancillas (d, i) -> Z.add (ancillas_pre d) i
  | _ -> Z.zero

let rec atomic (c: wired_circuit) : bool =
  match c with
  | Phase _ -> true
  | Rx _ -> true
  | Ry _ -> true
  | Rz _ -> true
  | Rzp _ -> true
  | Hadamard -> true
  | S -> true
  | T -> true
  | X -> true
  | Y -> true
  | Z -> true
  | _ -> false

let rec size_pre (c: wired_circuit) : Z.t =
  match c with
  | Skip -> Z.zero
  | Place (c1, _, _) -> size_pre c1
  | Cont (c1, _, _, _) -> Z.mul (size_pre c1) cont_size
  | Sequence (d, e) -> Z.add (size_pre d) (size_pre e)
  | Parallel (d, e) -> Z.add (size_pre d) (size_pre e)
  | Ancillas (d, _) -> size_pre d
  | _ -> Z.one

let rec range_pre (c: wired_circuit) : Z.t =
  match c with
  | Skip -> Z.zero
  | Ry _ -> Z.of_string "2"
  | Rx _ -> Z.of_string "2"
  | Hadamard -> Z.one
  | Place (c1, _, _) -> range_pre c1
  | Cont (c1, _, _, _) -> range_pre c1
  | Sequence (d, e) -> Z.add (range_pre d) (range_pre e)
  | Parallel (d, e) -> Z.add (range_pre d) (range_pre e)
  | Ancillas (d, _) -> range_pre d
  | _ -> Z.zero

type circuit = wired_circuit

let rec to_qc (c: wired_circuit) : circuit = c

let rec range (c: circuit) : Z.t =
  match c with
  | Skip -> Z.zero
  | Ry _ -> Z.of_string "2"
  | Rx _ -> Z.of_string "2"
  | Hadamard -> Z.one
  | Place (c1, _, _) -> range (to_qc c1)
  | Cont (c1, _, _, _) -> range (to_qc c1)
  | Sequence (d, e) -> Z.add (range (to_qc d)) (range (to_qc e))
  | Parallel (d, e) -> Z.add (range (to_qc d)) (range (to_qc e))
  | Ancillas (d, _) -> range (to_qc d)
  | _ -> Z.zero

let rec size (c: circuit) : Z.t =
  match c with
  | Skip -> Z.zero
  | Place (c1, _, _) -> size_pre c1
  | Cont (c1, _, _, _) -> Z.mul (size (to_qc c1)) cont_size
  | Sequence (d, e) -> Z.add (size (to_qc d)) (size (to_qc e))
  | Parallel (d, e) -> Z.add (size (to_qc d)) (size (to_qc e))
  | Ancillas (d, _) -> size_pre d
  | _ -> Z.one

let rec ancillas (c: circuit) : Z.t =
  match c with
  | Place (c1, _, _) -> ancillas (to_qc c1)
  | Cont (c1, _, _, _) -> ancillas (to_qc c1)
  | Sequence (d, e) -> Z.max (ancillas (to_qc d)) (ancillas (to_qc e))
  | Parallel (d, e) -> Z.add (ancillas (to_qc d)) (ancillas (to_qc e))
  | Ancillas (d, i) -> Z.add (ancillas (to_qc d)) i
  | _ -> Z.zero

let rec width (c: circuit) : Z.t =
  match c with
  | Skip -> Z.one
  | Bricks_Cnot -> Z.of_string "2"
  | Bricks_Toffoli -> Z.of_string "3"
  | Bricks_Fredkin -> Z.of_string "3"
  | Bricks_Swap -> Z.of_string "2"
  | Swap (_, _, n) -> n
  | Cnot (_, _, n) -> n
  | Toffoli (_, _, _, n) -> n
  | Fredkin (_, _, _, n) -> n
  | Place (_, _, n) -> n
  | Cont (_, _, _, n) -> n
  | Sequence (d, _) -> width (to_qc d)
  | Parallel (d, e) -> Z.add (width (to_qc d)) (width (to_qc e))
  | Ancillas (d, i) -> Z.sub (width (to_qc d)) i
  | _ -> Z.one

let rec basis_ket (c: circuit) (x: Z.t -> Z.t) (y: Z.t -> Z.t) (i: Z.t) : 
  Z.t =
  match c with
  | Skip -> x i
  | Phase _ -> x i
  | Rx _ -> y Z.one
  | Ry _ -> y Z.one
  | Rz _ -> x i
  | Rzp _ -> x i
  | Hadamard -> y i
  | S -> x i
  | T -> x i
  | X -> Z.sub Z.one (x i)
  | Y -> Z.sub Z.one (x i)
  | Z -> x i
  | Bricks_Cnot ->
    if Z.equal i Z.one
    then
      Z.add (Z.mul (x Z.zero) (Z.sub Z.one (x Z.one)))
      (Z.mul (x Z.one) (Z.sub Z.one (x Z.zero)))
    else x i
  | Bricks_Toffoli ->
    if Z.equal i (Z.of_string "2")
    then
      Z.add (Z.mul (Z.mul (x Z.zero) (x Z.one))
             (Z.sub Z.one (x (Z.of_string "2"))))
      (Z.mul (x (Z.of_string "2"))
       (Z.sub Z.one (Z.mul (x Z.zero) (x Z.one))))
    else x i
  | Bricks_Fredkin ->
    if Z.equal i Z.one
    then
      Z.add (Z.mul (x Z.zero) (x (Z.of_string "2")))
      (Z.mul (Z.sub Z.one (x Z.zero)) (x Z.one))
    else
      begin
        if Z.equal i (Z.of_string "2")
        then
          Z.add (Z.mul (x Z.zero) (x Z.one))
          (Z.mul (Z.sub Z.one (x Z.zero)) (x (Z.of_string "2")))
        else x i end
  | Bricks_Swap ->
    if Z.equal i Z.zero
    then x Z.one
    else begin if Z.equal i Z.one then x Z.zero else x i end
  | Cnot (c1,
    t,
    _) ->
    if Z.equal i t
    then
      Z.add (Z.mul (x c1) (Z.sub Z.one (x t)))
      (Z.mul (x t) (Z.sub Z.one (x c1)))
    else x i
  | Toffoli (c1,
    c2,
    t,
    _) ->
    if Z.equal i t
    then
      Z.add (Z.mul (Z.mul (x c1) (x c2)) (Z.sub Z.one (x t)))
      (Z.mul (x t) (Z.sub Z.one (Z.mul (x c1) (x c2))))
    else x i
  | Fredkin (c1,
    t1,
    t2,
    _) ->
    if Z.equal i t1
    then Z.add (Z.mul (x c1) (x t2)) (Z.mul (Z.sub Z.one (x c1)) (x t1))
    else
      begin
        if Z.equal i t2
        then Z.add (Z.mul (x c1) (x t1)) (Z.mul (Z.sub Z.one (x c1)) (x t2))
        else x i end
  | Place (c1,
    k,
    _) ->
    if Z.leq k i && Z.lt i (Z.add k (width (to_qc c1)))
    then basis_ket (to_qc c1) (fun (j: Z.t) -> x (Z.add j k)) y (Z.sub i k)
    else x i
  | Cont (c1,
    co,
    t,
    _) ->
    if Z.equal (x co) Z.one && Z.leq t i && Z.lt i
                                            (Z.add t (width (to_qc c1)))
    then basis_ket (to_qc c1) (fun (j1: Z.t) -> x (Z.add j1 t)) y (Z.sub i t)
    else x i
  | Swap (t1,
    t2,
    _) ->
    if Z.equal i t1
    then x t2
    else begin if Z.equal i t2 then x t1 else x i end
  | Sequence (d,
    e) ->
    basis_ket (to_qc e)
    (basis_ket (to_qc d) x y)
    (fun (k: Z.t) -> y (Z.add k (range (to_qc d))))
    i
  | Parallel (d,
    e) ->
    if Z.lt i (width (to_qc d))
    then basis_ket (to_qc d) x y i
    else
      basis_ket (to_qc e)
      (fun (k1: Z.t) -> x (Z.add k1 (width (to_qc d))))
      (fun (k2: Z.t) -> y (Z.add k2 (range (to_qc d))))
      (Z.sub i (width (to_qc d)))
  | Ancillas (d,
    l) ->
    basis_ket (to_qc d)
    (fun (k3: Z.t) ->
       if Z.lt k3 (Z.sub (width (to_qc d)) l) then x k3 else Z.zero)
    y
    i

let rec unwire_pre (c: wired_circuit) : Qbricks_c__Circuit_c.circuit =
  match c with
  | Skip -> Qbricks_c__Circuit_c.id
  | Phase k4 -> Qbricks_c__Circuit_c.phase k4
  | Rx k4 -> Derived_circuits_c__Place.rx k4
  | Ry k4 -> Derived_circuits_c__Place.ry k4
  | Rz k4 -> Derived_circuits_c__Place.rz_ k4
  | Rzp k4 -> Qbricks_c__Circuit_c.rz k4
  | Hadamard -> Qbricks_c__Circuit_c.hadamard
  | S -> Qbricks_c__Circuit_c.rz (Z.of_string "2")
  | T -> Qbricks_c__Circuit_c.rz (Z.of_string "3")
  | X -> Derived_circuits_c__Place.xx
  | Y -> Derived_circuits_c__Place.yy
  | Z -> Derived_circuits_c__Place.zz
  | Bricks_Cnot -> Qbricks_c__Circuit_c.cnot
  | Bricks_Toffoli -> Cont_c__Cont.toffoli
  | Bricks_Fredkin -> Cont_c__Cont.fredkin
  | Bricks_Swap -> Qbricks_c__Circuit_c.swap
  | Cnot (c1, t, n) -> Cont_c__Cont.place_cnot c1 t n
  | Swap (t1, t2, n) -> Wired_pps_c__Place_toffoli.swap_c t1 t2 n
  | Toffoli (c1,
    c2,
    t,
    n) ->
    Wired_pps_c__Place_toffoli.place_toffoli c1 c2 t n
  | Fredkin (c1,
    t1,
    t2,
    n) ->
    Wired_pps_c__Place_toffoli.place_fredkin c1 t1 t2 n
  | Place (c1,
    p,
    n) ->
    (let uc = unwire_pre c1 in Derived_circuits_c__Place.place uc p n)
  | Cont (c1,
    co,
    t,
    n) ->
    (let uc = unwire_pre c1 in Cont_c__Cont.cont uc co t n)
  | Sequence (d,
    e) ->
    (let dd = unwire_pre d in let ee = unwire_pre e in
     Qbricks_c__Circuit_c.sequence dd ee)
  | Parallel (d,
    e) ->
    (let dd = unwire_pre d in let ee = unwire_pre e in
     Qbricks_c__Circuit_c.parallel dd ee)
  | Ancillas (d,
    l) ->
    (let dd = unwire_pre d in Qbricks_c__Circuit_c.ancilla dd l)

let unwire (c: circuit) : Qbricks_c__Circuit_c.circuit = unwire_pre c

