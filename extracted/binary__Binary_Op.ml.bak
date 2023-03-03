let nary_length (i: Z.t) (n: Z.t) : Z.t =
  if Z.lt i n
  then Z.one
  else
    begin
      let j = ref Z.zero in let kp = ref i in
      while Z.geq i (Int_expo__Int_Exponentiation.power n (Z.add !j Z.one)) do
        j := Z.add !j Z.one;
        kp := Z.ediv i (Int_expo__Int_Exponentiation.power n !j)
      done;
      Z.add !j Z.one end

let binary_length (i: Z.t) : Z.t = nary_length i (Z.of_string "2")

