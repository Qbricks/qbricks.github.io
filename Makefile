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

.PHONY: run_to_openqasm run_to_openqasm_ne

DIRS?= -L ./Case_studies/ -L ./math_libs/ -L ./Qbricks/

build:
	docker build -t qbricks .

pull:
	docker pull jricc/qbricks:latest

container:
	-docker container rm qbricks
	bash container.sh

start:
	xhost +local:docker
	docker start -ai qbricks

clean:
	cd extracted; rm -f *.bak *.pdf *.byte *.txt exe.* *__*.ml *.qasm run_to_openqasm.ml

run_to_openqasm:
	./scripts/run_to_openqasm.sh To_openqasm_examples Test_oq2 extraction

run_to_openqasm_ne:
	./scripts/run_to_openqasm.sh To_openqasm_examples Test_oq2 no_extraction

