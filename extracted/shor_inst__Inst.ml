let shor_instance (_: unit) : Shor_type__Shor_type.shor_ ref =
  ref { Shor_type__Shor_type.composite = Z.of_string "5";
        Shor_type__Shor_type.compos_log = Z.of_string "3";
        Shor_type__Shor_type.picked = Z.of_string "3" }

let bound : Z.t = !(shor_instance ()).Shor_type__Shor_type.composite

let n : Z.t = !(shor_instance ()).Shor_type__Shor_type.compos_log

let pick : Z.t = !(shor_instance ()).Shor_type__Shor_type.picked

let pre_adder_const_ (y: Binary__Bit_vector.bitvec) :
  Wired_circuits__Circuit_c.circuit =
  let exception QtReturn of Wired_circuits__Circuit_c.circuit in
  try
    let k = ref Z.zero in
    let c = ref (Qbricks__Circuit_macros.m_skip (Z.add n Z.one)) in
    while Z.leq !k n do
      let i = ref (Z.sub n !k) in
      let cl = ref (Qbricks__Circuit_macros.m_skip (Z.add n Z.one)) in
      while Z.lt !i (Z.add n Z.one) do
        i := Z.add !i Z.one;
        cl := Remarkable_fragments__Diag_circuits.seq_diag !cl
              (Qbricks__Circuit_macros.prz (Z.mul (Binary__Bit_vector.getbv y 
                                            (Z.sub !i Z.one))
                                            (Z.sub (Z.add !k !i) n))
               !k (Z.add n Z.one))
      done;
      c := Remarkable_fragments__Diag_circuits.seq_diag !c !cl;
      k := Z.add !k Z.one
    done;
    raise (QtReturn !c)
  with
  | QtReturn r -> r

let add_in_qft (added: Z.t) : Wired_circuits__Circuit_c.circuit =
  pre_adder_const_ (Binary__Int_to_bv.int_to_bv (Z.erem added
                                                 (Int_expo__Int_Exponentiation.power 
                                                  (Z.of_string "2")
                                                  (Z.add n Z.one)))
                    (Z.add n Z.one))

let place_add_in_qft (added: Z.t) (k: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Wired_circuits__Qbricks_prim.place (add_in_qft added)
  Z.zero
  (Z.add (Z.add n Z.one) k)

let place_add_in_comput_basis (added: Z.t) (size_reg: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  Qft__Qft.apply_function_in_qft_basis_zero (place_add_in_qft added
                                             (Z.sub (Z.sub size_reg n) Z.one))
  (Z.add n Z.one)
  size_reg

let div_bound (added: Z.t) (value: Z.t) : Z.t =
  Z.ediv (Z.add value added) bound

let modular_adder (post: Z.t) : Wired_circuits__Circuit_c.circuit =
  let mod_post = Z.erem post bound in
  let modular_adder_ (pre: Z.t) : Wired_circuits__Circuit_c.circuit =
    let exception QtReturn1 of Wired_circuits__Circuit_c.circuit in
    try
      let c = ref (place_add_in_qft (Z.sub mod_post bound) Z.one) in
      c := Qbricks__Circuit_semantics.path_seq !c
           (Qft__Qft.apply_from_qft_zero_path (Z.add n Z.one) Z.one
            (Wired_circuits__Qbricks_prim.cnot Z.zero (Z.add n Z.one)
             (Z.add n (Z.of_string "2"))));
      c := Qbricks__Circuit_semantics.path_seq !c
           (Qbricks__Circuit_semantics.cont_last_qbit_kron_path (add_in_qft bound));
      c := Qbricks__Circuit_semantics.path_seq !c
           (place_add_in_qft (Z.neg mod_post) Z.one);
      c := Qbricks__Circuit_semantics.path_seq !c
           (Qft__Qft.apply_from_qft_zero_path (Z.add n Z.one) Z.one
            (Qbricks__Circuit_macros.ind_neg_cnot Z.zero (Z.add n Z.one)
             (Z.add n (Z.of_string "2"))));
      c := Qbricks__Circuit_semantics.path_seq !c
           (place_add_in_qft mod_post Z.one);
      raise (QtReturn1 !c)
    with
    | QtReturn1 r1 -> r1 in
  modular_adder_ Z.zero

let multiplier_qft_pre (p: Z.t) : Wired_circuits__Circuit_c.circuit =
  let j = ref Z.zero in
  let c =
    ref (Qbricks__Circuit_macros.m_skip (Z.add (Z.mul (Z.of_string "2") n)
                                         (Z.of_string "2"))) in
  while Z.lt !j n do
    c := Wired_circuits__Qbricks_prim.infix_mnmn !c
         (Wired_circuits__Qbricks_prim.cont (modular_adder (Z.mul p
                                                            (Int_expo__Int_Exponentiation.power 
                                                             (Z.of_string "2")
                                                             (Z.sub (Z.sub n
                                                                    !j)
                                                              Z.one))))
          !j n (Z.add (Z.mul (Z.of_string "2") n) (Z.of_string "2")));
    j := Z.add !j Z.one
  done;
  c := Qft__Qft.apply_function_in_qft_basis_gen !c
       (Z.add n Z.one)
       n
       (Z.add (Z.mul (Z.of_string "2") n) (Z.of_string "2"));
  !c

let cont_restricted_modular_multiplier (p: Z.t) :
  Wired_circuits__Circuit_c.circuit =
  let c = ref (multiplier_qft_pre p) in
  c := Wired_circuits__Qbricks_prim.infix_mnmn !c
       (Qbricks__Circuit_macros.swap_lists Z.zero (Z.add n Z.one) n
        (Z.add (Z.mul (Z.of_string "2") n) (Z.of_string "2")));
  c := Wired_circuits__Qbricks_prim.infix_mnmn !c
       (multiplier_qft_pre (Z.erem (Z.neg (Arit__Inverse.modular_inverse p
                                           bound))
                            bound));
  c := Qbricks__Circuit_semantics.cont_last_qbit_kron_path !c;
  c := Wired_circuits__Qbricks_prim.place !c
       Z.one
       (Z.add (Z.mul (Z.of_string "2") n) (Z.of_string "4"));
  !c

let modular_multiplier (p: Z.t) : Wired_circuits__Circuit_c.circuit =
  let modib (j: Z.t) : Z.t =
    Z.erem (Z.sub j bound)
    (Int_expo__Int_Exponentiation.power (Z.of_string "2") (Z.add n Z.one)) in
  let check_order =
    let check_ =
      ref (place_add_in_comput_basis (Z.neg bound)
           (Z.add (Z.mul (Z.of_string "2") n) (Z.of_string "4"))) in
    check_ := Wired_circuits__Qbricks_prim.infix_mnmn !check_
              (Qbricks__Circuit_macros.insert_qbits (Wired_circuits__Qbricks_prim.cnot Z.zero
                                                     (Z.add n Z.one)
                                                     (Z.add n
                                                      (Z.of_string "2")))
               (Z.add n Z.one) (Z.add n (Z.of_string "2"))
               (Z.add n (Z.of_string "2")));
    check_ := Wired_circuits__Qbricks_prim.infix_mnmn !check_
              (place_add_in_comput_basis bound
               (Z.add (Z.mul (Z.of_string "2") n) (Z.of_string "4")));
    !check_ in
  let c =
    ref (Wired_circuits__Qbricks_prim.infix_mnmn check_order
         (cont_restricted_modular_multiplier p)) in
  c := Wired_circuits__Qbricks_prim.infix_mnmn !c
       (Reversion__Circuit_reverse.reverse check_order);
  c := Qbricks__Circuit_macros.with_permutation !c
       (fun (i: Z.t) ->
          if Z.lt i Z.one
          then
            Z.sub (Z.add i
                   (Z.add (Z.mul (Z.of_string "2") n) (Z.of_string "4")))
            Z.one
          else Z.sub i Z.one);
  !c

let shor_circuit : Wired_circuits__Circuit_c.circuit =
  let create_superposition =
    Wired_circuits__Qbricks_prim.place (Qbricks__Circuit_macros.repeat_had 
                                        (Z.mul (Z.of_string "2") n))
    Z.zero
    (Z.add (Z.mul (Z.of_string "4") n) (Z.of_string "4")) in
  let k = ref Z.zero in
  let c =
    ref (Qbricks__Circuit_macros.m_skip (Z.add (Z.mul (Z.of_string "4") n)
                                         (Z.of_string "4"))) in
  while Z.lt !k (Z.mul (Z.of_string "2") n) do
    c := Wired_circuits__Qbricks_prim.infix_mnmn !c
         (Wired_circuits__Qbricks_prim.cont (modular_multiplier (Z.erem 
                                                                 (Int_expo__Int_Exponentiation.power pick
                                                                  (Int_expo__Int_Exponentiation.power 
                                                                   (Z.of_string "2")
                                                                   (Z.sub 
                                                                    (Z.sub 
                                                                    (Z.mul 
                                                                    (Z.of_string "2")
                                                                    n) !k)
                                                                    Z.one)))
                                                                 bound))
          !k (Z.mul (Z.of_string "2") n)
          (Z.add (Z.mul (Z.of_string "4") n) (Z.of_string "4")));
    k := Z.add !k Z.one
  done;
  c := Qbricks__Circuit_semantics.path_seq create_superposition !c;
  c := Qbricks__Circuit_semantics.path_seq !c
       (Wired_circuits__Qbricks_prim.place (Qft__Rev_qft.qft_rev (Z.mul 
                                                                  (Z.of_string "2")
                                                                  n))
        Z.zero (Z.add (Z.mul (Z.of_string "4") n) (Z.of_string "4")));
  !c

