let bin_to_int (f: Z.t -> Z.t) (n: Z.t) : Z.t =
  Binary__Bit_vector.bv_to_int (Binary__Bit_vector.make_bv f n)

let rec int_to_bin (i2: Z.t) (n: Z.t) : Z.t -> Z.t =
  Binary__Bit_vector.getbv (Binary__Int_to_bv.int_to_bv i2 n)

let rec my_map : type a b. (a -> b) -> (Set.Make(int)) ->  (Set.Make(int)) =
  fun f u -> if Z.equal (P_set__Fset.cardinal u) Z.zero
             then P_set__Fset.empty
             else
               (SS.add (f (P_set__Fset.choose u)) (my_map f
                                                   (P_set__Fset.remove 
                                                    (P_set__Fset.choose u) u)))

let mapz_pre (n: Z.t) (s: Set.Make(int)) : Set.Make(int) =
  my_map (fun (bv: Binary__Bit_vector.bitvec) ->
            Binary__Bit_vector.concat_l bv Z.zero)
  s

let mapo_pre (n: Z.t) (s: Set.Make(int)) : Set.Make(int) =
  my_map (fun (bv1: Binary__Bit_vector.bitvec) ->
            Binary__Bit_vector.concat_l bv1 Z.one)
  s

let rec n_bvs (n: Z.t) : Set.Make(int) =
  if Z.equal n Z.zero
  then
    P_set__IndexestoSet.to_set (Binary__Bit_vector.make_bv (fun (_1: Z.t) ->
                                                              Z.zero)
                                Z.zero)
  else
    begin
      let res = n_bvs (Z.sub n Z.one) in let mapz = mapz_pre n res in
      let mapo = mapo_pre n res in P_set__Fset.union mapz mapo end

let mapz (n: Z.t) : Set.Make(int) = mapz_pre n (n_bvs (Z.sub n Z.one))

let mapo (n: Z.t) : Set.Make(int) = mapo_pre n (n_bvs (Z.sub n Z.one))

let n_bvsz (_2: unit) : Set.Make(int) = n_bvs Z.zero

let n_bvso (_2: unit) : Set.Make(int) = n_bvs Z.one

