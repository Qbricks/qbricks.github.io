let rec cascade_cont_rz_neg (first_k: Z.t) (first_c: Z.t) (t: Z.t) (l: Z.t)
                            (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  if Z.equal l Z.zero
  then Qbricks__Circuit_macros.crzn_up first_c t (Z.neg first_k) n
  else
    Remarkable_fragments__Diag_circuits.seq_diag (cascade_cont_rz_neg first_k
                                                  first_c t (Z.sub l Z.one)
                                                  n)
    (Qbricks__Circuit_macros.crzn_up (Z.add first_c l) t
     (Z.neg (Z.add first_k l)) n)

let cascade_cont_qft (t: Z.t) (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  cascade_cont_rz_neg (Z.of_string "2")
  (Z.add t Z.one)
  t
  (Z.sub n (Z.add t (Z.of_string "2")))
  n

let qft_rev_line (t: Z.t) (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  if Z.equal t (Z.sub n Z.one)
  then Qbricks__Circuit_semantics.place_hadamard t n
  else
    Remarkable_fragments__Diag_circuits.seq_diag_right (Qbricks__Circuit_semantics.place_hadamard t
                                                        n)
    (cascade_cont_qft t n)

let qft_rev_be (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  let rec qft_rev_lines (k: Z.t) : Wired_circuits__Circuit_c.circuit =
    if Z.equal k (Z.sub n Z.one)
    then qft_rev_line k n
    else
      Wired_circuits__Qbricks_prim.infix_mnmn (qft_rev_line k n)
      (qft_rev_lines (Z.add k Z.one)) in
  qft_rev_lines Z.zero

let rec qft_rev (n: Z.t) : Wired_circuits__Circuit_c.circuit =
  if Z.equal n Z.one
  then qft_rev_be n
  else
    begin
      if Z.equal n (Z.of_string "2")
      then
        Wired_circuits__Qbricks_prim.infix_mnmn (qft_rev_be n)
        Wired_circuits__Qbricks_prim.bricks_swap
      else
        Wired_circuits__Qbricks_prim.infix_mnmn (qft_rev_be n)
        (Qbricks__Circuit_macros.permutation_circuit n
         (fun (i: Z.t) -> Z.sub (Z.sub n Z.one) i)) end

