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

docker create --name="qbricks" -ti \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v ${_pwd}/Case_studies:/qbricks/Case_studies \
  -v ${_pwd}/scripts:/qbricks/scripts \
  -v ${_pwd}/Qbricks:/qbricks/Qbricks \
  -v ${_pwd}/Qbricks_to_oqasm:/qbricks/Qbricks_to_oqasm \
  -v ${_pwd}/Qbricks_to_oqasm/Examples:/qbricks/Qbricks_to_oqasm/Examples \
  -v ${_pwd}/math_libs:/qbricks/math_libs \
  -v ${_pwd}/extracted:/qbricks/extracted \
  qbricks
