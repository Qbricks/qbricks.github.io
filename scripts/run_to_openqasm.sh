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

if [ -z "$1" ]; then
  echo "Error : file examples not defined." >&2
  exit 1
fi

if [ -z "$2" ]; then
  echo "Error : module example not defined." >&2
  exit 1
fi

if [ -z "$3" ]; then
  echo "Error : extraction not defined." >&2
  exit 1
fi

DIR="-L ./Case_studies/ -L ./Case_studies/Shor/ -L ./math_libs/ -L ./Qbricks/ -L ./Qbricks_to_oqasm/"

echo "* Library declared"

DRV="-D to_string.drv -D ocaml64"

echo "* Driver defined"

# 1) from WhyML to OCaml

start_time=$(date +%s%N)

why3_extract() {
  echo "*** start extract $1"
  why3 extract --modular $DIR -o extracted/ $DRV $1 || echo "error extraction $1"
  echo "*** end extract $1"
}

if [ "$3" = "extraction" ]; then
  echo "* Libraries extracted: start"

  why3_extract math_libs/extr_int.mlw
  why3_extract math_libs/arit.mlw
  why3_extract math_libs/binary.mlw
  why3_extract math_libs/int_expo.mlw

  echo "** 'math_libs': extracted"

  why3_extract Qbricks/qbricks_c.mlw
  why3_extract Qbricks/derived_circuits_c.mlw
  why3_extract Qbricks/cont_c.mlw
  why3_extract Qbricks/wired_pps_c.mlw
  why3_extract Qbricks/wired_circuits.mlw
  why3_extract Qbricks/qbricks.mlw
  why3_extract Qbricks/remarkable_fragments.mlw
  why3_extract Qbricks/draw_circuits.mlw
  why3_extract Qbricks/reversion.mlw
  why3_extract Qbricks/circuits_equiv_pre.mlw
  why3_extract Qbricks/circuits_equiv.mlw

  echo "** 'Qbricks': extracted"

  why3_extract Qbricks_to_oqasm/commuting_lemmas.mlw
  why3_extract Qbricks_to_oqasm/atomic_place.mlw
  why3_extract Qbricks_to_oqasm/parallel_delete.mlw
  why3_extract Qbricks_to_oqasm/subcircuit_control.mlw
  why3_extract Qbricks_to_oqasm/ternary_gates_delete.mlw
  why3_extract Qbricks_to_oqasm/transpilation.mlw

  echo "** 'Qbricks_to_oqasm': extracted"

  why3_extract Case_studies/qft.mlw
  why3_extract Case_studies/qft_test.mlw
  why3_extract Case_studies/Shor/shor_type.mlw
  why3_extract Case_studies/qpe.mlw
  # why3_extract Case_studies/Shor/shor_circ.mlw

  echo "** 'Case_studies': extracted"
fi

why3_extract Case_studies/Shor/shor_inst.mlw
why3_extract "Qbricks_to_oqasm/Examples/$1.mlw"

echo "** Qbricks_to_oqasm/Examples/$1.mlw: extracted"

if [ "$3" = "extraction" ]; then
  echo "* Libraries extracted: end"
  end_time=$(date +%s%N)
  extraction_time=$((end_time - start_time))
  extraction_time_seconds=$(echo | awk -v time=$extraction_time 'BEGIN { printf "%.3f\n", time / 1000000000 }')
  echo "OCaml extraction : $execution_time_seconds secondes"
fi

cd extracted

echo "* Enter in the 'extracted' folder"

echo "let () =
  let oq =
    open_out \"$1.qasm\" in 
      Printf.fprintf oq \"%s\" ($1__$2.run ());
    close_out oq;" >run_to_openqasm.ml

echo "* 'run_to_openqasm.ml': generated"

start_time=$(date +%s%N)
ocamlbuild -pkg zarith -cflags -w,-26 run_to_openqasm.byte
end_time=$(date +%s%N)
execution_time=$((end_time - start_time))
execution_time_seconds=$(echo | awk -v time=$execution_time 'BEGIN { printf "%.3f\n", time / 1000000000 }')
echo "Compilation : $execution_time_seconds secondes"

echo "* build done"

# 2) write .qasm file

start_time=$(date +%s%N)

/qbricks/extracted/run_to_openqasm.byte

end_time=$(date +%s%N)
execution_time=$((end_time - start_time))
execution_time_seconds=$(echo | awk -v time=$execution_time 'BEGIN { printf "%.3f\n", time / 1000000000 }')
echo "QASM Generation : $execution_time_seconds secondes"

