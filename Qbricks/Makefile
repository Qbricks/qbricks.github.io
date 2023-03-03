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

DIRS?= --library=../math_libs --library=../Qbricks --library=../Case_studies --library=../extracted


ide_circuits_equiv:
	why3 ide $(DIRS) circuits_equiv.mlw

ide_cont_c:
	why3 ide $(DIRS) cont_c.mlw

ide_wired_circuits:
	why3 ide --library=../math_libs --library=../Qbricks wired_circuits.mlw

ide_qbricks_c:
	why3 ide $(DIRS) qbricks_c.mlw

ide_qbricks:
	why3 ide $(DIRS) qbricks.mlw

ide_derived_circuits_c:
	why3 ide $(DIRS) derived_circuits_c.mlw

ide_pps:
	why3 ide $(DIRS) pps.mlw

ide_qdata:
	why3 ide $(DIRS) ../math_libs/qdata.mlw

ide_binary:
	why3 ide $(DIRS) ../math_libs/binary.mlw

ide_reversion:
	why3 ide $(DIRS) reversion.mlw

prove_circuits_equiv:
	why3 prove $(DIRS) circuits_equiv.mlw

# Print dependencies tree of `qbricks.mlw`
dep_qbricks:
	why3 pp --output dep qbricks.mlw >> qbricks_dep.mlw
	dot -Tps qbricks_dep.mlw -o qbricks_dep.ps
	gmt psconvert qbricks_dep.ps  -A -P -Tg
	xviewer qbricks_dep.png