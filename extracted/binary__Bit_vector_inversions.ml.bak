let bv_inversion (bv2: Binary__Bit_vector.bitvec) : Binary__Bit_vector.bitvec
  =
  Binary__Bit_vector.make_bv (fun (k3: Z.t) ->
                                Binary__Bit_vector.getbv bv2 (Z.sub (Z.sub 
                                                                    bv2.Binary__Bit_vector.length
                                                                    k3)
                                                              Z.one))
  bv2.Binary__Bit_vector.length

let int_bit_inversion (i2: Z.t) (n: Z.t) : Z.t =
  Binary__Bit_vector.bv_to_int (bv_inversion (Binary__Int_to_bv.int_to_bv i2
                                              n))

let int_bit_inversion_ext (i2: Z.t) (n: Z.t) : Z.t =
  if Z.equal i2 (Int_expo__Int_Exponentiation.power (Z.of_string "2") n)
  then i2
  else
    Binary__Bit_vector.bv_to_int (bv_inversion (Binary__Int_to_bv.int_to_bv i2
                                                n))

