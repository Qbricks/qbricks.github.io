let concat (bv11: Binary__Bit_vector.bitvec) (bv2: Binary__Bit_vector.bitvec) :
  Binary__Bit_vector.bitvec =
  Binary__Bit_vector.make_bv (fun (i2: Z.t) ->
                                if Z.leq bv11.Binary__Bit_vector.length i2 && 
                                   Z.lt i2
                                   (Z.add bv11.Binary__Bit_vector.length
                                    bv2.Binary__Bit_vector.length)
                                then
                                  Binary__Bit_vector.getbv bv2 (Z.sub i2
                                                                bv11.Binary__Bit_vector.length)
                                else Binary__Bit_vector.getbv bv11 i2)
  (Z.add bv11.Binary__Bit_vector.length bv2.Binary__Bit_vector.length)

let hpart (bv2: Binary__Bit_vector.bitvec) (m: Z.t) :
  Binary__Bit_vector.bitvec =
  Binary__Bit_vector.make_bv (Binary__Bit_vector.getbv bv2) m

let tpart (bv2: Binary__Bit_vector.bitvec) (m: Z.t) :
  Binary__Bit_vector.bitvec =
  if Z.geq bv2.Binary__Bit_vector.length m
  then
    Binary__Bit_vector.make_bv (fun (k4: Z.t) ->
                                  Binary__Bit_vector.getbv bv2 (Z.add k4 m))
    (Z.sub bv2.Binary__Bit_vector.length m)
  else
    Binary__Bit_vector.make_bv (fun (k5: Z.t) ->
                                  Binary__Bit_vector.getbv bv2 (Z.add k5 m))
    Z.zero

let bv_tail (bv2: Binary__Bit_vector.bitvec) (m: Z.t) :
  Binary__Bit_vector.bitvec =
  tpart bv2 (Z.sub bv2.Binary__Bit_vector.length m)

let last (bv2: Binary__Bit_vector.bitvec) : Z.t =
  Binary__Bit_vector.getbv bv2 (Z.sub bv2.Binary__Bit_vector.length Z.one)

let bv_head (bv2: Binary__Bit_vector.bitvec) (m: Z.t) :
  Binary__Bit_vector.bitvec =
  hpart bv2 (Z.sub bv2.Binary__Bit_vector.length m)

let htpart (bv2: Binary__Bit_vector.bitvec) (k6: Z.t) (n: Z.t) :
  Binary__Bit_vector.bitvec =
  Binary__Bit_vector.make_bv (fun (i3: Z.t) ->
                                Binary__Bit_vector.getbv bv2 (Z.add k6 i3))
  n

