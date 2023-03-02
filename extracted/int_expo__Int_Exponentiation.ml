let rec power_pre (e: Z.t) (i: Z.t) : Z.t =
  if Z.equal i Z.zero then Z.one else Z.mul e (power_pre e (Z.sub i Z.one))

let power (e: Z.t) (i: Z.t) : Z.t =
  if Z.lt i Z.zero then Z.zero else power_pre e i

let polysquare (n: Z.t) (a2: Z.t) (a1: Z.t) (a0: Z.t) : Z.t =
  Z.add (Z.add (Z.mul a2 (power n (Z.of_string "2"))) (Z.mul a1 n)) a0

