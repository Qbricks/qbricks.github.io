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

DIRS?= --library=../math_libs --library=../Qbricks --library=../Case_studies --library=../extracted --library=../Qbricks_to_oqasm


ide_parallel_delete:
	why3 ide $(DIRS) parallel_delete.mlw

ide_atomic_place:
	why3 ide $(DIRS) atomic_place.mlw

ide_commuting_lemmas:
	why3 ide $(DIRS) commuting_lemmas.mlw

ide_cont_decomp:
	why3 ide $(DIRS) cont_decomp.mlw

ide_subcircuit_control:
	why3 ide $(DIRS) subcircuit_control.mlw

ide_ternary_gates_delete:
	why3 ide $(DIRS) ternary_gates_delete.mlw

ide_transpilation:
	why3 ide $(DIRS) transpilation.mlw

ide_to_openqasm_examples:
	why3 ide $(DIRS) To_openqasm_examples.mlw


prove_parallel_delete:
	why3 prove $(DIRS) parallel_delete.mlw

prove_atomic_place:
	why3 prove $(DIRS) atomic_place.mlw

prove_commuting_lemmas:
	why3 prove $(DIRS) commuting_lemmas.mlw

prove_subcircuit_control:
	why3 prove $(DIRS) subcircuit_control.mlw

prove_ternary_gates_delete:
	why3 prove $(DIRS) ternary_gates_delete.mlw

prove_transpilation:
	why3 prove $(DIRS) transpilation.mlw

prove_to_openqasm_examples:
	why3 prove $(DIRS) Examples/To_openqasm_examples.mlw

prove_all: prove_parallel_delete prove_atomic_place prove_commuting_lemmas prove_subcircuit_control prove_ternary_gates_delete prove_transpilation prove_to_openqasm_examples