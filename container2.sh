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

_pwd="$(pwd)"

docker create -ti -e DISPLAY=$DISPLAY \
 -v /tmp/.X11-unix:/tmp/.X11-unix \
 -v ${_pwd}/../wqbricks/Case_studies:/home/opam/wqbricks/Case_studies \
 -v ${_pwd}/../wqbricks/Qbricks:/home/opam/wqbricks/Qbricks \
 -v ${_pwd}/../wqbricks/math_libs:/home/opam/wqbricks/math_libs \
 -v ${_pwd}/../wqbricks/extracted:/home/opam/wqbricks/extracted \
 -v ${_pwd}/../wqbricks/mb_extracted:/home/opam/wqbricks/mb_extracted\
 -v ${_pwd}/../wqbricks/Transpilation:/home/opam/wqbricks/Transpilation \
 -v ${_pwd}/../wqbricks:/home/opam/wqbricks \
 -v ${_pwd}/../wqbricks-transpilation/Case_studies:/home/opam/wqbricks-transpilation/Case_studies \
 -v ${_pwd}/../wqbricks-transpilation/Qbricks:/home/opam/wqbricks-transpilation/Qbricks \
 -v ${_pwd}/../wqbricks-transpilation/math_libs:/home/opam/wqbricks-transpilation/math_libs \
 -v ${_pwd}/../wqbricks-transpilation/extracted:/home/opam/wqbricks-transpilation/extracted \
 -v ${_pwd}/../wqbricks-transpilation/mb_extracted:/home/opam/wqbricks-transpilation/mb_extracted\
 -v ${_pwd}/../wqbricks-transpilation:/home/opam/wqbricks-transpilation \
 --name="container2" wqbricks_why3_git