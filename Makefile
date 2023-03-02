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

DIRS?= -L ./Case_studies/ -L ./math_libs/ -L ./Qbricks/

build: Dockerfile
	docker build --tag image_qbricks .

container1:
	-docker container rm ctr1
	bash container1.sh

container2:
	-docker container rm ctr2
	bash container2.sh

container3:
	-docker container rm ctr3
	bash container3.sh

start1:
	@xhost +local:`docker inspect --format='{{ .Config.Hostname }}' ctr1` >> /dev/null
	docker start --attach --interactive ctr1

start2:
	@xhost +local:`docker inspect --format='{{ .Config.Hostname }}' ctr2` >> /dev/null
	docker start --attach --interactive ctr2

start3:
	@xhost +local:`docker inspect --format='{{ .Config.Hostname }}' ctr3` >> /dev/null
	docker start --attach --interactive ctr3

print:
	bash ./run_test.sh

# don't clean `run_test.ml`
clean:
	cd extracted; rm -f *.bak *.pdf *.byte *.txt exe.* *__*.ml *.qasm run_to_openqasm.ml

run_to_openqasm:
	./run_to_openqasm.sh To_openqasm_examples Test_oq2

clean_run_to_openqasm: clean run_to_openqasm

run_qiskit:
	python3 extracted/run_to_openqasm.py extracted/To_openqasm_examples