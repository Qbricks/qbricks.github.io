let () =
  let oq =
    open_out "To_openqasm_examples.qasm" in 
      Printf.fprintf oq "%s" (To_openqasm_examples__Test_oq2.run ());
    close_out oq;
