let greatest_factor_in_n (multi: Z.t) (n: Z.t) (i: Z.t) : Z.t =
  if Z.lt i
     (Z.erem (Int_expo__Int_Exponentiation.power (Z.of_string "2") n) multi)
  then
    Z.add (Z.ediv (Int_expo__Int_Exponentiation.power (Z.of_string "2") n)
           multi)
    Z.one
  else Z.ediv (Int_expo__Int_Exponentiation.power (Z.of_string "2") n) multi

