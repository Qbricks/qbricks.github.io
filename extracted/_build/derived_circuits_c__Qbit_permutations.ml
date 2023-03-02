let c_inverse_pre (f: Z.t -> Z.t) (n: Z.t) (i: Z.t) : Z.t =
  let rec inner (j: Z.t) : Z.t =
    if Z.equal (f j) i then j else inner (Z.add j Z.one) in
  inner Z.zero

let c_inverse (f: Z.t -> Z.t) (n: Z.t) : Z.t -> Z.t =
  fun (x: Z.t) ->
    if Z.leq Z.zero x && Z.lt x n then c_inverse_pre f n x else x

let c_inv_func_int (f: Z.t -> Z.t) (n: Z.t) : Z.t -> Z.t = c_inverse f n

let rec qbit_permutes (c: Qbricks_c__Circuit_c.circuit) : bool =
  match c with
  | Qbricks_c__Circuit_c.Sequence (d,
    e) ->
    qbit_permutes (Qbricks_c__Circuit_c.to_qc d) && qbit_permutes (Qbricks_c__Circuit_c.to_qc e)
  | Qbricks_c__Circuit_c.Parallel (d,
    e) ->
    qbit_permutes (Qbricks_c__Circuit_c.to_qc d) && qbit_permutes (Qbricks_c__Circuit_c.to_qc e)
  | Qbricks_c__Circuit_c.Swap -> true
  | Qbricks_c__Circuit_c.Id -> true
  | Qbricks_c__Circuit_c.Phase _ -> false
  | Qbricks_c__Circuit_c.Rz _ -> false
  | Qbricks_c__Circuit_c.Hadamard -> false
  | Qbricks_c__Circuit_c.Cnot -> false
  | Qbricks_c__Circuit_c.Ancillas (_, _) -> false

let rec qbit_permutation (c: Qbricks_c__Circuit_c.circuit) : Z.t -> Z.t =
  match c with
  | Qbricks_c__Circuit_c.Sequence (d,
    e) ->
    (let comp_func (f: Z.t -> Z.t) (g: Z.t -> Z.t) : Z.t -> Z.t =
       fun (i: Z.t) -> f (g i) in
     comp_func (qbit_permutation (Qbricks_c__Circuit_c.to_qc d))
     (qbit_permutation (Qbricks_c__Circuit_c.to_qc e)))
  | Qbricks_c__Circuit_c.Parallel (d,
    e) ->
    (let concat_func (f: Z.t -> Z.t) (g: Z.t -> Z.t) : Z.t -> Z.t =
       fun (i1: Z.t) ->
         if Z.lt i1
            (Qbricks_c__Circuit_c.width (Qbricks_c__Circuit_c.to_qc d))
         then f i1
         else
           Z.add (g (Z.sub i1
                     (Qbricks_c__Circuit_c.width (Qbricks_c__Circuit_c.to_qc d))))
           (Qbricks_c__Circuit_c.width (Qbricks_c__Circuit_c.to_qc d)) in
     concat_func (qbit_permutation (Qbricks_c__Circuit_c.to_qc d))
     (qbit_permutation (Qbricks_c__Circuit_c.to_qc e)))
  | Qbricks_c__Circuit_c.Swap ->
    (fun (i2: Z.t) ->
       if Z.equal i2 Z.zero
       then Z.one
       else begin if Z.equal i2 Z.one then Z.zero else i2 end)
  | _ -> (fun (i3: Z.t) -> i3)

let qbit_permute_sequence (d: Qbricks_c__Circuit_c.circuit)
                          (e: Qbricks_c__Circuit_c.circuit) :
  Qbricks_c__Circuit_c.circuit = Qbricks_c__Circuit_c.sequence d e

let qbit_permute_parallel (d: Qbricks_c__Circuit_c.circuit)
                          (e: Qbricks_c__Circuit_c.circuit) :
  Qbricks_c__Circuit_c.circuit = Qbricks_c__Circuit_c.parallel d e

let rec ids_permute (n: Z.t) : Qbricks_c__Circuit_c.circuit =
  if Z.equal n Z.one
  then Qbricks_c__Circuit_c.id
  else
    qbit_permute_parallel (ids_permute (Z.sub n Z.one))
    Qbricks_c__Circuit_c.id

let permute_place (c: Qbricks_c__Circuit_c.circuit) (k: Z.t) (n: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  let place_zero (_: unit) : Qbricks_c__Circuit_c.circuit =
    if Z.equal n (Z.add k (Qbricks_c__Circuit_c.width c))
    then c
    else
      qbit_permute_parallel c
      (ids_permute (Z.sub (Z.sub n k) (Qbricks_c__Circuit_c.width c))) in
  if Z.equal k Z.zero
  then place_zero ()
  else qbit_permute_parallel (ids_permute k) (place_zero ())

let permute_plus_one (k: Z.t) (n: Z.t) : Qbricks_c__Circuit_c.circuit =
  permute_place Qbricks_c__Circuit_c.swap k n

let rec up_to_image (k: Z.t) (fk: Z.t) (n: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  if Z.equal k fk
  then ids_permute n
  else
    qbit_permute_sequence (up_to_image (Z.add k Z.one) fk n)
    (permute_plus_one k n)

let rec down_to_image (k: Z.t) (fk: Z.t) (n: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  if Z.equal k fk
  then ids_permute n
  else
    qbit_permute_sequence (down_to_image (Z.sub k Z.one) fk n)
    (permute_plus_one (Z.sub k Z.one) n)

let permute_up (k: Z.t) (fk: Z.t) (n: Z.t) : Qbricks_c__Circuit_c.circuit =
  if Z.equal k fk
  then ids_permute n
  else
    qbit_permute_sequence (down_to_image (Z.sub fk Z.one) k n)
    (up_to_image k fk n)

let permute_atom (k: Z.t) (fk: Z.t) (n: Z.t) : Qbricks_c__Circuit_c.circuit =
  if Z.leq k fk then permute_up k fk n else permute_up fk k n

let rec permutation_circuit_pre (k: Z.t) (n: Z.t) (f: Z.t -> Z.t) :
  Qbricks_c__Circuit_c.circuit =
  if Z.equal k (Z.sub n Z.one)
  then permute_atom (c_inv_func_int f n (Z.sub n Z.one)) (Z.sub n Z.one) n
  else
    begin
      let o = permutation_circuit_pre (Z.add k Z.one) n f in
      qbit_permute_sequence (permute_atom k
                             (qbit_permutation o (c_inv_func_int f n k)) n)
      o end

let permutation_circuit (n: Z.t) (f: Z.t -> Z.t) :
  Qbricks_c__Circuit_c.circuit = permutation_circuit_pre Z.zero n f

let with_permutation (c: Qbricks_c__Circuit_c.circuit) (f: Z.t -> Z.t) :
  Qbricks_c__Circuit_c.circuit =
  let permut_apply (_: unit) : Qbricks_c__Circuit_c.circuit =
    Qbricks_c__Circuit_c.sequence (permutation_circuit (Qbricks_c__Circuit_c.width c)
                                   f)
    c in
  Qbricks_c__Circuit_c.sequence (permut_apply ())
  (permutation_circuit (Qbricks_c__Circuit_c.width c)
   (c_inv_func_int f (Qbricks_c__Circuit_c.width c)))

let c_swap_int (t1: Z.t) (t2: Z.t) (n: Z.t) : Z.t -> Z.t =
  fun (i4: Z.t) ->
    if Z.equal i4 t1 then t2 else begin if Z.equal i4 t2 then t1 else i4 end

let with_int_swap (c: Qbricks_c__Circuit_c.circuit) (t1: Z.t) (t2: Z.t) :
  Qbricks_c__Circuit_c.circuit =
  with_permutation c (c_swap_int t1 t2 (Qbricks_c__Circuit_c.width c))

let insert_qbits (c: Qbricks_c__Circuit_c.circuit) (k: Z.t) (n: Z.t)
                 (i5: Z.t) : Qbricks_c__Circuit_c.circuit =
  with_permutation (Qbricks_c__Circuit_c.parallel c
                    (Derived_circuits_c__Place.ids i5))
  (fun (j: Z.t) ->
     if Z.lt j k
     then j
     else begin if Z.lt j n then Z.add j i5 else Z.add (Z.sub j n) k end)

let insert_qbits_gen (c: Qbricks_c__Circuit_c.circuit) (k: Z.t) (n: Z.t)
                     (i5: Z.t) : Qbricks_c__Circuit_c.circuit =
  if Z.lt Z.zero i5 then insert_qbits c k n i5 else c

