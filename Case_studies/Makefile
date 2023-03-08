DIRS?= --library=../math_libs --library=../Qbricks --library=../Case_studies

.PHONY: run ide

ide_qft_test:
	why3 ide $(DIRS) qft_test.mlw

ide_shor:
	why3 ide $(DIRS) shor.mlw

prove_no_anc_shor_circ:
	why3 prove $(DIRS) Shor/no_anc_shor_circ.mlw
