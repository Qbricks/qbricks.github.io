# (**************************************************************************)
# (*  This file is part of QBRICKS.                                         *)
# (*                                                                        *)
# (*  Copyright (C) 2020-2022                                               *)
# (*    CEA (Commissariat à l'énergie atomique et aux énergies              *)
# (*         alternatives)                                                  *)
# (*    Université Paris-Saclay                                             *)
# (*                                                                        *)
# (*  you can redistribute it and/or modify it under the terms of the GNU   *)
# (*  Lesser General Public License as published by the Free Software       *)
# (*  Foundation, version 2.1.                                              *)
# (*                                                                        *)
# (*  It is distributed in the hope that it will be useful,                 *)
# (*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
# (*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
# (*  GNU Lesser General Public License for more details.                   *)
# (*                                                                        *)
# (*  See the GNU Lesser General Public License version 2.1                 *)
# (*  for more details (enclosed in the file licenses/LGPLv2.1).            *)
# (*                                                                        *)
# (**************************************************************************)

#!/bin/bash

DIR="-L ./Case_studies/ -L ./Case_studies/Shor/ -L ./math_libs/ -L ./Qbricks/ -L ./Qbricks_to_oqasm/"
DRV="-D to_string.drv -D ocaml64"


# 1) from WhyML to OCaml

why3_extract () {
   why3 extract --modular $DIR -o extracted/ $DRV $1
}

  why3_extract  math_libs/extr_int.mlw
  why3_extract  math_libs/arit.mlw
  why3_extract  math_libs/binary.mlw
  why3_extract  math_libs/int_expo.mlw
  why3_extract  Qbricks/qbricks_c.mlw
  why3_extract  Qbricks/derived_circuits_c.mlw
  why3_extract  Qbricks/cont_c.mlw
  why3_extract  Qbricks/wired_pps_c.mlw
  why3_extract  Qbricks/wired_circuits.mlw
  why3_extract  Qbricks/qbricks.mlw
  why3_extract  Qbricks/remarkable_fragments.mlw
  why3_extract  Qbricks/draw_circuits.mlw
  why3_extract  Qbricks/reversion.mlw
  why3_extract  Qbricks/circuits_equiv_pre.mlw
  why3_extract  Qbricks/circuits_equiv.mlw

  why3_extract  Qbricks_to_oqasm/commuting_lemmas.mlw
  why3_extract  Qbricks_to_oqasm/atomic_place.mlw
  why3_extract  Qbricks_to_oqasm/parallel_delete.mlw
  why3_extract  Qbricks_to_oqasm/subcircuit_control.mlw
  why3_extract  Qbricks_to_oqasm/ternary_gates_delete.mlw
  why3_extract  Qbricks_to_oqasm/transpilation.mlw


  why3_extract  Case_studies/qft.mlw
  why3_extract  Case_studies/Shor/shor_type.mlw
  why3_extract  Case_studies/Shor/shor_inst.mlw
  #  why3_extract  Case_studies/modular_adder.mlw
  #  why3_extract  Case_studies/modular_multiplier.mlw
  #  why3_extract  Case_studies/shor_circuit.mlw
  # why3_extract   Case_studies/test.mlw
  why3_extract "Qbricks_to_oqasm/Examples/$1.mlw"

cd extracted

echo "let () =
  let oq =
    open_out \"$1.qasm\" in 
      Printf.fprintf oq \"%s\" ($1__$2.run ());
    close_out oq;" > run_to_openqasm.ml

ocamlbuild -pkg zarith run_to_openqasm.byte

# 2) write .qasm file

./run_to_openqasm.byte

# 3) send .qasm file to ibm

python3 run_to_openqasm.py $1
