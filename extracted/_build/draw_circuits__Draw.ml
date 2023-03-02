let infix_cf (a: string) (b: string) : string = a ^ b

let i_to_s (i: Z.t) : string =
  if Z.lt i Z.zero
  then infix_cf (infix_cf "(" (Z.to_string i)) ")"
  else (Z.to_string i)

let rec circ_to_string_pre_ (c: Wired_circuits__Circuit_c.wired_circuit) :
  string =
  match c with
  | Wired_circuits__Circuit_c.Skip -> "SKIP"
  | Wired_circuits__Circuit_c.Phase k -> infix_cf "Ph_" (i_to_s k)
  | Wired_circuits__Circuit_c.Rx k -> infix_cf "Rx_" (i_to_s k)
  | Wired_circuits__Circuit_c.Ry k -> infix_cf "Ry_" (i_to_s k)
  | Wired_circuits__Circuit_c.Rz k -> infix_cf "Rz_" (i_to_s k)
  | Wired_circuits__Circuit_c.Rzp k -> infix_cf "Rzp_" (i_to_s k)
  | Wired_circuits__Circuit_c.Hadamard -> "HAD"
  | Wired_circuits__Circuit_c.S -> "S"
  | Wired_circuits__Circuit_c.T -> "T"
  | Wired_circuits__Circuit_c.X -> "X"
  | Wired_circuits__Circuit_c.Y -> "Y"
  | Wired_circuits__Circuit_c.Z -> "Z"
  | Wired_circuits__Circuit_c.Bricks_Cnot -> "Bricks_Cnot"
  | Wired_circuits__Circuit_c.Bricks_Toffoli -> "Bricks_Toffoli"
  | Wired_circuits__Circuit_c.Bricks_Fredkin -> "Bricks_fredkin"
  | Wired_circuits__Circuit_c.Bricks_Swap -> "Bricks_swap"
  | Wired_circuits__Circuit_c.Cnot (c1,
    t,
    _) ->
    infix_cf (infix_cf (infix_cf "Cnot" (i_to_s c1)) " ") (i_to_s t)
  | Wired_circuits__Circuit_c.Toffoli (c1,
    c2,
    t,
    _) ->
    infix_cf (infix_cf (infix_cf (infix_cf (infix_cf "Toffoli" (i_to_s c1))
                                  ",")
                        (i_to_s c2))
              " ")
    (i_to_s t)
  | Wired_circuits__Circuit_c.Fredkin (c1,
    t1,
    t2,
    _) ->
    infix_cf (infix_cf (infix_cf (infix_cf (infix_cf "Fredkin" (i_to_s c1))
                                  " ")
                        (i_to_s t1))
              " ")
    (i_to_s t2)
  | Wired_circuits__Circuit_c.Swap (t1,
    t2,
    _) ->
    infix_cf (infix_cf (infix_cf "Swap " (i_to_s t1)) " ") (i_to_s t2)
  | Wired_circuits__Circuit_c.Place (c1,
    p,
    _) ->
    infix_cf (infix_cf (infix_cf "PLACE " (circ_to_string_pre_ c1)) " at ")
    (i_to_s p)
  | Wired_circuits__Circuit_c.Cont (c1,
    co,
    t,
    _) ->
    infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf "WITH_CONT "
                                                      (i_to_s co))
                                            ": ")
                                  "PLACE ")
                        (circ_to_string_pre_ c1))
              " at ")
    (i_to_s t)
  | Wired_circuits__Circuit_c.Sequence (d,
    e) ->
    infix_cf (infix_cf (circ_to_string_pre_ d) ";\n") (circ_to_string_pre_ e)
  | Wired_circuits__Circuit_c.Parallel (d,
    e) ->
    infix_cf (infix_cf (infix_cf (infix_cf "PAR(" (circ_to_string_pre_ d))
                        ",")
              (circ_to_string_pre_ e))
    ")"
  | Wired_circuits__Circuit_c.Ancillas (d,
    _) ->
    infix_cf (infix_cf "ANC(" (circ_to_string_pre_ d)) ")"

let circ_to_string_pre (c: Wired_circuits__Circuit_c.wired_circuit) : 
  string = infix_cf (circ_to_string_pre_ c) "\n"

let circ_to_string (c: Wired_circuits__Circuit_c.circuit) : string =
  circ_to_string_pre c

let indent : string = "    "

let rec circ_to_tikz_pre (c: Wired_circuits__Circuit_c.wired_circuit) :
  string =
  match c with
  | Wired_circuits__Circuit_c.Skip -> ""
  | Wired_circuits__Circuit_c.Phase k ->
    infix_cf (infix_cf "\\node[draw,rectangle,fill=white] at (0, 0){$\\textit{Ph}_{"
              (i_to_s k))
    "}$};\n"
  | Wired_circuits__Circuit_c.Rx k ->
    infix_cf (infix_cf "\\node[draw,rectangle,fill=white]  at (0, 0){$\\textit{Rx}_{"
              (i_to_s k))
    "}$};\n"
  | Wired_circuits__Circuit_c.Ry k ->
    infix_cf (infix_cf "\\node[draw,rectangle,fill=white]  at (0, 0){$\\textit{Ry}_{"
              (i_to_s k))
    "}$};\n"
  | Wired_circuits__Circuit_c.Rz k ->
    infix_cf (infix_cf "\\node[draw,rectangle,fill=white]  at (0, 0){$\\textit{Rz}_{"
              (i_to_s k))
    "}$};\n"
  | Wired_circuits__Circuit_c.Rzp k ->
    infix_cf (infix_cf "\\node[draw,rectangle,fill=white]  at (0, 0){$\\textit{Rzp}_{"
              (i_to_s k))
    "}$};\n"
  | Wired_circuits__Circuit_c.Hadamard ->
    "\\node[draw,rectangle,fill=white] at (0, 0) {$\\textit{H}$};\n"
  | Wired_circuits__Circuit_c.S ->
    "\\node[draw,rectangle,fill=white]  at (0, 0){$\\textit{S}$};\n"
  | Wired_circuits__Circuit_c.T ->
    "\\node[draw,rectangle,fill=white]  at (0, 0){$\\textit{T}$};\n"
  | Wired_circuits__Circuit_c.X ->
    "\\node[draw,rectangle,fill=white]  at (0, 0){$\\textit{X}$};\n"
  | Wired_circuits__Circuit_c.Y ->
    "\\node[draw,rectangle,fill=white]  at (0, 0){$\\textit{Y}$};\n"
  | Wired_circuits__Circuit_c.Z ->
    "\\node[draw,rectangle,fill=white]  at (0, 0){$\\textit{Z}$};\n"
  | Wired_circuits__Circuit_c.Bricks_Cnot ->
    "\\node(c) at (0, 0){$\\bullet$};\n\\node(t) at (0, -1){$\\oplus$};\n\\draw (c)to (t);\n"
  | Wired_circuits__Circuit_c.Bricks_Toffoli ->
    "\\node(c1) at (0, 0){$\\bullet$};\n\\node(c2) at (0, -1){$\\bullet$};\n\\node(t) at (0, -2){$\\oplus$};\n\\draw (c1)to (t);\n"
  | Wired_circuits__Circuit_c.Bricks_Fredkin ->
    "\\node(c) at (0, 0){$\\bullet$};\n\\node(t1) at (0, -1){$\\times$};\n\\node(t2) at (0, -2){$\\times$};\n\\draw (c)to (t2);\n"
  | Wired_circuits__Circuit_c.Bricks_Swap ->
    "\\node(t1) at (0, 0){$\\times$};\n\\node(t2) at (0, -1){$\\times$};\n\\draw (t1) to (t2);\n"
  | Wired_circuits__Circuit_c.Cnot (c1,
    t,
    _) ->
    infix_cf (infix_cf (infix_cf (infix_cf "\\node(c) at (0, -" (i_to_s c1))
                        "){$\\bullet$};\n\\node(t) at (0, -")
              (i_to_s t))
    "){$\\oplus$};\n\\draw (c)to (t);\n"
  | Wired_circuits__Circuit_c.Toffoli (c1,
    c2,
    t,
    _) ->
    infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf "\\node(c1) at (0, -"
                                                      (i_to_s c1))
                                            "){$\\bullet$};\n\\node(c2) at (0, -")
                                  (i_to_s c2))
                        "){$\\bullet$};\n\\node(t) at (0, -")
              (i_to_s t))
    "){$\\oplus$};\n\\draw (c1)to (t);\n"
  | Wired_circuits__Circuit_c.Fredkin (c1,
    t1,
    t2,
    _) ->
    infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf "\\node(c) at (0, -"
                                                      (i_to_s c1))
                                            "){$\\bullet$};\n\\node(t1) at (0, -")
                                  (i_to_s t1))
                        "){$\\times$};\n\\node(t2) at (0, -")
              (i_to_s t2))
    "){$\\times$};\n\\draw (c)to (t2);\n"
  | Wired_circuits__Circuit_c.Swap (t1,
    t2,
    _) ->
    infix_cf (infix_cf (infix_cf (infix_cf "\\node(t1) at (0, -" (i_to_s t1))
                        "){$\\times$};\n\\node(t2) at (0, -")
              (i_to_s t2))
    "){$\\times$};\n\\draw (t1.center) to (t2.center);\n"
  | Wired_circuits__Circuit_c.Place (c1,
    p,
    _) ->
    infix_cf (infix_cf (infix_cf (infix_cf (infix_cf "\\begin{scope}[yshift= -"
                                            (i_to_s p))
                                  " cm]\n")
                        (circ_to_tikz_pre c1))
              "\\end{scope}")
    (if not (Wired_circuits__Circuit_c.atomic c1)
     then
       infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf 
                                                                   (infix_cf "\n\\node(rect)[draw, minimum width ="
                                                                    (i_to_s 
                                                                    (Wired_circuits__Circuit_c.depth_pre c1)))
                                                                   "cm, minimum height =")
                                                         (i_to_s (Wired_circuits__Circuit_c.width_pre c1)))
                                               " cm ]at(0,-")
                                     (i_to_s (Wired_circuits__Circuit_c.width_pre c1)))
                           "/2+1/2-")
                 (i_to_s p))
       "){};\n"
     else "\n")
  | Wired_circuits__Circuit_c.Cont (c1,
    co,
    t,
    _) ->
    if Wired_circuits__Circuit_c.atomic c1
    then
      infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf 
                                                                  (infix_cf 
                                                                   (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf "\\node(rect)[ minimum width ="
                                                                    (i_to_s 
                                                                    (Wired_circuits__Circuit_c.depth_pre c1)))
                                                                    "cm, minimum height =")
                                                                    (i_to_s 
                                                                    (Wired_circuits__Circuit_c.width_pre c1)))
                                                                    "cm  ]at(0,-")
                                                                    (i_to_s 
                                                                    (Wired_circuits__Circuit_c.width_pre c1)))
                                                                    "/2 +1/2 -")
                                                                   (i_to_s t))
                                                                  "){};\n\\node(c) at (0, -")
                                                        (i_to_s co))
                                              "){$\\bullet$};\n\\draw (rect.center) to (c.center);\n\\begin{scope}[yshift= -")
                                    (i_to_s t))
                          "cm]\n")
                (circ_to_tikz_pre c1))
      "\\end{scope}\n"
    else
      infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf 
                                                                  (infix_cf 
                                                                   (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf "\\node(rect)[draw, minimum width ="
                                                                    (i_to_s 
                                                                    (Wired_circuits__Circuit_c.depth_pre c1)))
                                                                    "cm, minimum height =")
                                                                    (i_to_s 
                                                                    (Wired_circuits__Circuit_c.width_pre c1)))
                                                                    "cm  ]at(0,-")
                                                                    (i_to_s 
                                                                    (Wired_circuits__Circuit_c.width_pre c1)))
                                                                    "/2 +1/2 -")
                                                                   (i_to_s t))
                                                                  "){};\n\\node(c) at (0, -")
                                                        (i_to_s co))
                                              "){$\\bullet$};\n\\draw (rect) to (c.center);\n\\begin{scope}[yshift= -")
                                    (i_to_s t))
                          "cm]\n")
                (circ_to_tikz_pre c1))
      "\\end{scope}\n"
  | Wired_circuits__Circuit_c.Sequence (d,
    e) ->
    infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf 
                                                                (infix_cf 
                                                                 (circ_to_tikz_pre d)
                                                                 "\\hspace{")
                                                                (i_to_s 
                                                                 (Wired_circuits__Circuit_c.depth_pre d)))
                                                      "cm}\n")
                                            (circ_to_tikz_pre e))
                                  "\n")
                        "\\hspace{-")
              (i_to_s (Wired_circuits__Circuit_c.depth_pre d)))
    "cm}\n"
  | Wired_circuits__Circuit_c.Parallel (d,
    e) ->
    infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (circ_to_tikz_pre d)
                                            "\\begin{scope}[yshift= -")
                                  (i_to_s (Wired_circuits__Circuit_c.width_pre d)))
                        "cm]\n")
              (circ_to_tikz_pre e))
    "\\end{scope}\n"
  | Wired_circuits__Circuit_c.Ancillas (d,
    l) ->
    infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf 
                                                                (infix_cf 
                                                                 (infix_cf 
                                                                  (infix_cf 
                                                                   (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf 
                                                                    (infix_cf "\\foreach  \\i in {1,...,"
                                                                    (i_to_s l))
                                                                    "}){\n\\draw[ultra thick](-0.5,")
                                                                    (i_to_s 
                                                                    (Wired_circuits__Circuit_c.width_pre d)))
                                                                    "-\\i-.3) to (-0.5,")
                                                                    (i_to_s 
                                                                    (Wired_circuits__Circuit_c.width_pre d)))
                                                                    "-\\i+.3);\n\\draw[ultra thick](")
                                                                    (i_to_s 
                                                                    (Wired_circuits__Circuit_c.depth_pre d)))
                                                                    "-0.5,")
                                                                    (i_to_s 
                                                                    (Wired_circuits__Circuit_c.width_pre d)))
                                                                    "-\\i-.3) to (")
                                                                   (i_to_s 
                                                                    (Wired_circuits__Circuit_c.depth_pre d)))
                                                                  "-0.5,")
                                                                 (i_to_s 
                                                                  (Wired_circuits__Circuit_c.width_pre d)))
                                                                "-\\i+.3);\n\\draw(-0.5,")
                                                      (i_to_s (Wired_circuits__Circuit_c.width_pre d)))
                                            "-\\i) to(")
                                  (i_to_s (Wired_circuits__Circuit_c.depth_pre d)))
                        "-0.5,-\\i);n}")
              (circ_to_tikz_pre d))
    "\n"

let tikz_start : string =
  "\\documentclass[tikz, border=1mm]{standalone}\n\\begin{document}\n\\begin{figure}[\\width = \\textwidth]\n\\begin{tikzpicture}\n"

let tikz_end : string =
  "\\end{tikzpicture}\n\\end{figure}\n\\end{document}\n"

let circ_to_tikz_ (c: Wired_circuits__Circuit_c.wired_circuit) : string =
  infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf (infix_cf tikz_start
                                                              "\\foreach  \\i in {-")
                                                    (i_to_s (Z.sub (Wired_circuits__Circuit_c.width_pre c)
                                                             Z.one)))
                                          ",...,0}{\n\\draw(-.5,\\i)to(")
                                (i_to_s (Wired_circuits__Circuit_c.depth_pre c)))
                      "-.5,\\i);\n}\n")
            (circ_to_tikz_pre c))
  tikz_end

let circ_to_tikz (c: Wired_circuits__Circuit_c.circuit) : string =
  circ_to_tikz_ c

