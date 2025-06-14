DIRS?= --library=./ --library=./../math_libs --library=../Qbricks


tutorial_type_check:
	why3 prove $(DIRS) tutorial.mlw

tutorial_ide:
	why3 ide $(DIRS) tutorial.mlw

tool_box_type_check:
	why3 prove $(DIRS) tool_box.mlw

tool_box_ide:
	why3 ide $(DIRS) tool_box.mlw

tutorial_solution_type_check:
	why3 prove $(DIRS) tutorial_solution.mlw

tutorial_solution_ide:
	why3 ide $(DIRS) tutorial_solution.mlw

