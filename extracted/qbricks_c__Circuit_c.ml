type circuit_pre =
  | Phase of (Z.t)
  | Rz of (Z.t)
  | Hadamard
  | Cnot
  | Swap
  | Id
  | Sequence of circuit_pre * circuit_pre
  | Parallel of circuit_pre * circuit_pre
  | Ancillas of circuit_pre * (Z.t)

let rec width_pre (c: circuit_pre) : Z.t =
  match c with
  | Cnot -> Z.of_string "2"
  | Swap -> Z.of_string "2"
  | Sequence (d, _) -> width_pre d
  | Parallel (d, e) -> Z.add (width_pre d) (width_pre e)
  | Ancillas (d, i) -> Z.sub (width_pre d) i
  | _ -> Z.one

let rec build_correct (c: circuit_pre) : bool =
  match c with
  | Sequence (d,
    e) ->
    Z.equal (width_pre d) (width_pre e) && build_correct d && build_correct e
  | Parallel (d, e) -> build_correct d && build_correct e
  | Ancillas (d,
    i) ->
    Z.leq Z.one i && Z.leq (Z.add i Z.one) (width_pre d) && build_correct d
  | _ -> true

type circuit = circuit_pre

let to_qc (c: circuit_pre) : circuit = c

let infix_cf (a: string) (b: string) : string = a ^ b

let rec circ_to_string_ (c: circuit) : string =
  match c with
  | Sequence (d,
    e) ->
    infix_cf (infix_cf (circ_to_string_ (to_qc d)) ";")
    (circ_to_string_ (to_qc e))
  | Parallel (d,
    e) ->
    infix_cf (infix_cf (infix_cf (infix_cf "PAR("
                                  (circ_to_string_ (to_qc d)))
                        ",")
              (circ_to_string_ (to_qc e)))
    ")"
  | Ancillas (d,
    _) ->
    infix_cf (infix_cf "ANC(" (circ_to_string_ (to_qc d))) ")"
  | Phase k -> infix_cf (infix_cf "(Ph_" (Z.to_string k)) ")"
  | Rz k -> infix_cf (infix_cf "(Rz_" (Z.to_string k)) ")"
  | Hadamard -> "HAD"
  | Cnot -> "CNOT"
  | Id -> "ID"
  | Swap -> "SWAP"

let circ_to_string (c: circuit) : string = infix_cf (circ_to_string_ c) "\n"

let width (c: circuit) : Z.t = width_pre c

let rec size (c: circuit) : Z.t =
  match c with
  | Sequence (d, e) -> Z.add (size (to_qc d)) (size (to_qc e))
  | Parallel (d, e) -> Z.add (size (to_qc d)) (size (to_qc e))
  | Ancillas (d, _) -> size (to_qc d)
  | Id -> Z.zero
  | Swap -> Z.zero
  | _ -> Z.one

let rec ancillas (c: circuit) : Z.t =
  match c with
  | Sequence (d, e) -> Z.max (ancillas (to_qc d)) (ancillas (to_qc e))
  | Parallel (d, e) -> Z.add (ancillas (to_qc d)) (ancillas (to_qc e))
  | Ancillas (d, i) -> Z.add (ancillas (to_qc d)) i
  | _ -> Z.zero

let phase (k: Z.t) : circuit = Phase k

let rz (k: Z.t) : circuit = Rz k

let hadamard : circuit = Hadamard

let cnot : circuit = Cnot

let id : circuit = Id

let swap : circuit = to_qc Swap

let sequence (d: circuit) (e: circuit) : circuit = Sequence (d, e)

let ancilla (d: circuit) (i: Z.t) : circuit = Ancillas (d, i)

let parallel (d: circuit) (e: circuit) : circuit = Parallel (d, e)

let ancilla_g (c: circuit) (i: Z.t) : circuit = ancilla c i

let ancilla_spec (c: circuit) (i: Z.t) : circuit = ancilla_g c i

