DIRS?= --library=../math_libs --library=../Qbricks --library=../Case_studies

.PHONY: run ide

ide_jerome:
	why3 ide $(DIRS) jerome_toffoli.mlw

ide_qft_test:
	why3 ide $(DIRS) qft_test.mlw

ide_translation:
	why3 ide $(DIRS) translation.mlw

ide_translation_grover:
	why3 ide $(DIRS) translation_grover.mlw

ide_translation_grovercz:
	why3 ide $(DIRS) translation_grovercz.mlw

ide_test:
	why3 ide $(DIRS) test.mlw

prove_test:
	why3 prove $(DIRS) test.mlw

prove_no_anc_shor_circ:
	why3 prove $(DIRS) Shor/no_anc_shor_circ.mlw
