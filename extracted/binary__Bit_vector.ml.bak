type bitvec = {
  value: Z.t -> Z.t;
  length: Z.t;
  }

let getbv (a: bitvec) : Z.t -> Z.t = a.value

let to_bool (i: Z.t) : bool = not (Z.equal i Z.zero)

let in_range (bv: bitvec) (r: Z.t) : bool =
  Z.leq Z.zero r && Z.lt r bv.length

let make_bv (f: Z.t -> Z.t) (s: Z.t) : bitvec =
  { value =
    (fun (i: Z.t) -> if Z.leq Z.zero i && Z.lt i s then f i else Z.zero);
    length = s }

let make_bv_m (f: Z.t -> Z.t) (s: Z.t) : bitvec =
  make_bv (fun (k: Z.t) -> Z.erem (f k) (Z.of_string "2")) s

let bitvec_null : bitvec = make_bv (fun (_: Z.t) -> Z.zero) Z.zero

let makes_bv (f: Z.t -> Z.t) (s: Z.t) : bitvec =
  make_bv (fun (i1: Z.t) ->
             if let q1_ = f i1 in
                Z.leq Z.zero q1_ && Z.lt q1_ (Z.of_string "2")
             then f i1
             else Z.zero)
  s

let concat_l (bv: bitvec) (i2: Z.t) : bitvec =
  make_bv (fun (k1: Z.t) ->
             if Z.equal k1 Z.zero then i2 else getbv bv (Z.sub k1 Z.one))
  (Z.add bv.length Z.one)

let bv_to_int (bv: bitvec) : Z.t =
  Extr_int__Ind_isum.ind_isum (fun (k2: Z.t) ->
                                 if in_range bv k2
                                 then
                                   Z.mul (getbv bv k2)
                                   (Int_expo__Int_Exponentiation.power 
                                    (Z.of_string "2")
                                    (Z.sub (Z.sub bv.length Z.one) k2))
                                 else Z.one)
  Z.zero
  bv.length

