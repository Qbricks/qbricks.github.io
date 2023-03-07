let rec min_filter_b (i: Z.t) (j: Z.t) (p: Z.t -> bool) : Z.t =
  if p i then i else min_filter_b (Z.add i Z.one) j p

