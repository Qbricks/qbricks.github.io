DIRS?= --library=./ --library=./../math_libs --library=../Qbricks


type_check:
	why3 prove $(DIRS) tutorial.mlw

ide:
	why3 ide $(DIRS) tutorial.mlw

tool_type_check:
	why3 prove $(DIRS) tool_box.mlw

tool_ide:
	why3 ide $(DIRS) tool_box.mlw

sol_type_check:
	why3 prove $(DIRS) tutorial_solution.mlw

sol_ide:
	why3 ide $(DIRS) tutorial_solution.mlw

