let modular_inverse (pick: Z.t) (bound: Z.t) : Z.t =
  Extr_int__P_minmax_b.min_filter_b Z.zero
  bound
  (fun (i: Z.t) -> Z.equal (Z.erem (Z.mul i pick) bound) Z.one)

let multi_order (pick: Z.t) (bound: Z.t) : Z.t =
  Extr_int__P_minmax_b.min_filter_b Z.one
  bound
  (fun (i1: Z.t) ->
     Z.equal (Z.erem (Int_expo__Int_Exponentiation.power pick i1) bound)
     Z.one)

