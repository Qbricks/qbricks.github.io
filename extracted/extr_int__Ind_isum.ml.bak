let rec ind_isum (f: Z.t -> Z.t) (i: Z.t) (j: Z.t) : Z.t =
  if Z.leq j i
  then Z.zero
  else
    begin
      if Z.equal j (Z.add i Z.one)
      then f i
      else Z.add (f i) (ind_isum f (Z.add i Z.one) j) end

