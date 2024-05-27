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
 -v ${_pwd}/../qbricks.github.io/Case_studies:/home/opam/qbricks.github.io/Case_studies \
 -v ${_pwd}/../qbricks.github.io/Qbricks:/home/opam/qbricks.github.io/Qbricks \
 -v ${_pwd}/../qbricks.github.io/math_libs:/home/opam/qbricks.github.io/math_libs \
 -v ${_pwd}/../qbricks.github.io/extracted:/home/opam/qbricks.github.io/extracted \
 -v ${_pwd}/../qbricks.github.io/mb_extracted:/home/opam/qbricks.github.io/mb_extracted\
 -v ${_pwd}/../qbricks.github.io/Transpilation:/home/opam/qbricks.github.io/Transpilation \
 -v ${_pwd}/../qbricks.github.io:/home/opam/qbricks.github.io \
 --name="ctr3" image_qbricks