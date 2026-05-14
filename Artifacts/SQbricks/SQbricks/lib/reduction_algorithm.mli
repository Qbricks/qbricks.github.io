(**************************************************************************)
(*  This file is part of SQbricks.                                        *)
(*                                                                        *)
(*  Copyright (C) 2022-2026                                               *)
(*  CEA (Commissariat à l'énergie atomique et aux énergies alternatives)  *)
(*  Université Paris-Saclay                                               *)
(*                                                                        *)
(*  you can redistribute it and/or modify it under the terms of the GNU   *)
(*  Lesser General Public License as published by the Free Software       *)
(*  Foundation, version 2.1.                                              *)
(*                                                                        *)
(*  It is distributed in the hope that it will be useful,                 *)
(*  but WITHOUT ANY WARRANTY; without even the implied warranty of        *)
(*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *)
(*  GNU Lesser General Public License for more details.                   *)
(*                                                                        *)
(*  See the GNU Lesser General Public License version 2.1                 *)
(*  for more details (enclosed in the file licenses/LGPLv2.1).            *)
(*                                                                        *)
(**************************************************************************)

(** Module for reducing quantum circuit path sums to normal form.

    This module implements a complete reduction algorithm for path sums
    representing quantum states, applying a sequence of reduction rules to
    simplify the representation. *)

module PSS = Path_sum.String

val reduction_algorithm : ?debug:bool -> Path_sum.t -> Path_sum.t
(** [reduction_algorithm ?debug ps] applies a complete sequence of reduction
    rules to simplify a path sum. The reduction process follows these steps: 1.
    Simplification: Algebraic simplification of expressions 2. HH rule:
    Elimination of certain path variables 3. Variable replacement:
    Simplification of XOR expressions 4. Factorization: Reduction of phase terms
    5. Constant conversion: Standardization of ket expressions 6. Normalization:
    Path variable indexing

    Example transformation: Initial state:
    - Phase: 1/2*y2 + 1/2*y2 + 1/2*y2*y3 + 1/2*y3*y1 + 1/2*y4*y5 + 1/2*y4*x2
    - Ket: |x0 + x0 + x1, y2 + y1, y5, y8+y10, 1+y0>

    Step-by-step reduction: 1. Simplification:
    - Phase: 1/2*y2 + 1/2*y2 → 0
    - Ket: x0 + x0 + x1 → x1 Intermediate:
    - Phase: 1/2*y2*y3 + 1/2*y3*y1 + 1/2*y4*y5 + 1/2*y4*x2
    - Ket: |x1, y2 + y1, y5, y8+y10, 1+y0>

    2. HH rule (with y0 = y4):
    - Eliminates terms with y4 coefficient 1/2 Intermediate:
    - Phase: 1/2*y2*y3 + 1/2*y3*y1
    - Ket: |x1, y2 + y1, x2, y8+y10, 1+y0>

    3. Variable replacement:
    - Replaces y8+y10 with new variable y11 Intermediate:
    - Phase: 1/2*y2*y3 + 1/2*y3*y1
    - Ket: |x1, y2 + y1, x2, y11, 1+y0>

    4. Factorization:
    - Replaces y2 + y1 with new variable y12
    - Substitutes y12 in phase: 1/2*y12*y3 Intermediate:
    - Phase: 1/2*y12*y3
    - Ket: |x1, y12, x2, y11, 1+y0>

    5. Constant conversion:
    - Converts 1+y0 to new variable y13 Intermediate:
    - Phase: 1/2*y12*y3
    - Ket: |x1, y12, x2, y11, y13>

    6. Normalization: Final state:
    - Phase: 1/2*y0*y3
    - Ket: |x1, y0, x2, y1, y2>

    Note: The algorithm preserves quantum state equivalence while reducing
    complexity. *)

(**/**)

val _condition_to_continue : ?debug:bool -> Path_sum.t -> Path_sum.t -> bool
(** Internal function for determining whether to continue reduction. Returns
    [true] if the output state is simpler than input. *)
