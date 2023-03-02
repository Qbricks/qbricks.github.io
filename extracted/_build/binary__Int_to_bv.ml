let int_to_bv (i4: Z.t) (n: Z.t) : Binary__Bit_vector.bitvec =
  Binary__Bit_vector.make_bv (fun (k6: Z.t) ->
                                if Z.leq Z.zero k6 && Z.lt k6 n
                                then
                                  Z.ediv (Z.erem i4
                                          (Int_expo__Int_Exponentiation.power 
                                           (Z.of_string "2") (Z.sub n k6)))
                                  (Int_expo__Int_Exponentiation.power 
                                   (Z.of_string "2")
                                   (Z.sub (Z.sub n k6) Z.one))
                                else Z.zero)
  n

