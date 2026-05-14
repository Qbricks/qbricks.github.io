#  This file is part of SQbricks.
#
#  Copyright (C) 2022-2026
#  CEA (Commissariat à l'énergie atomique et aux énergies alternatives)
#  Université Paris-Saclay
#
#  you can redistribute it and/or modify it under the terms of the GNU
#  Lesser General Public License as published by the Free Software
#  Foundation, version 2.1.
#
#  It is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  See the GNU Lesser General Public License version 2.1
#  for more details (enclosed in the file licenses/LGPLv2.1).

import sys
import time
import pyzx as zx

c1 = zx.Circuit.from_qasm_file(sys.argv[1])
c2 = zx.Circuit.from_qasm_file(sys.argv[2])

start_time = time.time()
result = c1.verify_equality(c2, up_to_swaps=True, up_to_global_phase=False)
end_time = time.time()

if result:
    print(end_time - start_time)
else:
    print("NC")
