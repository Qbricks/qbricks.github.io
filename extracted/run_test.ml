      let () =
        let oc = open_out "qft.txt" in 
        Printf.fprintf oc "%s\n" (Test__Test.test_qft_string ());
        close_out oc;
        
        let os = open_out "shor.oqasm" in 
        Printf.fprintf os "%s\n" (Test__Test.test_shor_oqasm() );
        close_out os;
        
        let ocd = open_out "exe.tex" in 
        Printf.fprintf ocd "%s\n" (Test__Test.test_qft_draw ()); 
        close_out ocd;

