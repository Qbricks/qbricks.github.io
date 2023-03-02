let incr_abs (k: Z.t) : Z.t =
  if Z.leq Z.zero k then Z.add k Z.one else Z.sub k Z.one

let decr_abs (k: Z.t) : Z.t =
  if Z.leq k Z.zero then Z.add k Z.one else Z.sub k Z.one

