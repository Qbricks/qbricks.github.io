DIRS?= --library=../math_libs --library=../Qbricks --library=../Case_studies --library=../extracted


ide_circuits_equiv:
	why3 ide $(DIRS) circuits_equiv.mlw

ide_cont_c:
	why3 ide $(DIRS) cont_c.mlw

ide_wired_circuits:
	why3 ide --library=../math_libs --library=../Qbricks wired_circuits.mlw

ide_qbricks_c:
	why3 ide $(DIRS) qbricks_c.mlw

ide_qbricks:
	why3 ide $(DIRS) qbricks.mlw

ide_derived_circuits_c:
	why3 ide $(DIRS) derived_circuits_c.mlw


ide_pps:
	why3 ide $(DIRS) pps.mlw

ide_qdata:
	why3 ide $(DIRS) ../math_libs/qdata.mlw

ide_binary:
	why3 ide $(DIRS) ../math_libs/binary.mlw

ide_hybrid_circuits:
	why3 ide $(DIRS) hybrid_circuits.mlw

ide_hpps:
	why3 ide $(DIRS) hpps.mlw

ide_reversion:
	why3 ide $(DIRS) reversion.mlw


reformat_qbricks:
	why3 pp --output mlw qbricks.mlw >> qbricks_f.mlw

reformat_circuits_equiv:
	why3 pp --output mlw circuits_equiv.mlw >> circuits_equiv_f.mlw


prove_circuits_equiv:
	why3 prove $(DIRS) circuits_equiv.mlw


prove_hybrid_circuits:
	why3 prove $(DIRS) hybrid_circuits.mlw
prove_hybrid_semantics:
	why3 prove $(DIRS) hybrid_semantics.mlw

# Print dependencies tree of `qbricks.mlw`
dep_qbricks:
	why3 pp --output dep qbricks.mlw >> qbricks_dep.mlw
	dot -Tps qbricks_dep.mlw -o qbricks_dep.ps
	gmt psconvert qbricks_dep.ps  -A -P -Tg
	xviewer qbricks_dep.png