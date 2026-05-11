# This file is part of SQbricks.
#
# Copyright (C) 2022-2025
# CEA (Commissariat à l'énergie atomique et aux énergies alternatives)
# Université Paris-Saclay
#
# you can redistribute it and/or modify it under the terms of the GNU
# Lesser General Public License as published by the Free Software
# Foundation, version 2.1.
#
# It is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# See the GNU Lesser General Public License version 2.1
# for more details (enclosed in the file licenses/LGPLv2.1).

.PHONY: all benchmark sanity sanity-unit sanity-hybrid sanity-partial benchmarks \
        owm tele unit-vs-hybrid qiskit-hybrid owm-vs-qiskit owm-vs-tele veriqc \
        tests tests_prim tests_qiskit tests_mbqc tests_unit \
        build container start fig6 fig7 examples \
				doc clean_doc

DATE := $(shell date +%Y-%m)
DATE_FILE := $(shell date +%Y-%m-%d)
RESULT_FOLDER := benchmarks/result/$(DATE)
LOG_FOLDER := test/logs/$(DATE)
MAKEFLAGS += --no-print-directory

# Documentation generation
DOC_DIR := $(shell pwd)/doc/doc-$(DATE_FILE)

doc:
	@echo "Generating documentation..."
	@dune build @doc
	@rm -rf $(DOC_DIR)  
	@mkdir -p $(DOC_DIR)
	@cp -r _build/default/_doc/_html/* $(DOC_DIR)/
	@echo "Documentation generated in $(DOC_DIR)"
	@if command -v open > /dev/null; then open $(DOC_DIR)/index.html; fi 2>/dev/null || true

clean_doc:
	dune clean

# Tests

tests: tests_prim tests_qiskit tests_mbqc tests_unit tests_verif

tests_qiskit:
	@rm -rf $(shell pwd)/_build/qiskit
	@mkdir -p $(shell pwd)/_build
	@mkdir -p $(LOG_FOLDER)
	dune build @qiskit --build-dir $(shell pwd)/_build/qiskit > $(LOG_FOLDER)/qiskit_$(DATE_FILE).log 2>&1

tests_unit:
	@rm -rf $(shell pwd)/_build/unitary
	@mkdir -p $(shell pwd)/_build
	@mkdir -p $(LOG_FOLDER)
	dune build @unitary --build-dir $(shell pwd)/_build/unitary > $(LOG_FOLDER)/unitary_$(DATE_FILE).log 2>&1

tests_prim:
	@rm -rf $(shell pwd)/_build/primitives
	@mkdir -p $(shell pwd)/_build
	@mkdir -p $(LOG_FOLDER)
	dune build @primitives --build-dir $(shell pwd)/_build/primitives > $(LOG_FOLDER)/primitives_$(DATE_FILE).log 2>&1
	
tests_mbqc:
	@rm -rf $(shell pwd)/_build/mbqc
	@mkdir -p $(shell pwd)/_build
	@mkdir -p $(LOG_FOLDER)
	dune build @mbqc --build-dir $(shell pwd)/_build/mbqc > $(LOG_FOLDER)/mbqc_$(DATE_FILE).log 2>&1

tests_verif:
	@rm -rf $(shell pwd)/_build/verif
	@mkdir -p $(shell pwd)/_build
	@mkdir -p $(LOG_FOLDER)
	dune build @verif --build-dir $(shell pwd)/_build/verif > $(LOG_FOLDER)/verif_$(DATE_FILE).log 2>&1


# Benchmark & Sanity check

benchmark:
	@mkdir -p $(RESULT_FOLDER)
	@./scripts/benchmarks.sh $(TYPE) >> $(RESULT_FOLDER)/benchmarks_$(TYPE)_$(DATE_FILE).csv 2>/dev/null || true


sanity: sanity-unit sanity-hybrid sanity-partial

sanity-unit:
	@echo "sanity-unit" 
	@rm -rf $(shell pwd)/_build/sanity-unit 2>/dev/null || true
	@mkdir -p $(shell pwd)/_build
	@$(MAKE) TYPE=sanity-unit benchmark 

sanity-hybrid:
	@echo "sanity-hybrid"
	@rm -rf $(shell pwd)/_build/sanity-hybrid 2>/dev/null || true
	@mkdir -p $(shell pwd)/_build
	@$(MAKE) TYPE=sanity-hybrid benchmark 

sanity-partial:
	@echo "sanity-partial"
	@rm -rf $(shell pwd)/_build/sanity-partial 2>/dev/null || true
	@mkdir -p $(shell pwd)/_build
	@$(MAKE) TYPE=sanity-partial benchmark


benchmarks: tele owm  owm-vs-qiskit owm-vs-tele qiskit-hybrid veriqc unit-vs-hybrid
#      

owm: 
	@echo "owm"
	@rm -rf $(shell pwd)/_build/owm 2>/dev/null || true
	@mkdir -p $(shell pwd)/_build
	@dune build --build-dir $(shell pwd)/_build/owm 
	@$(MAKE) TYPE=owm benchmark

tele: 
	@echo "tele"
	@rm -rf $(shell pwd)/_build/tele 2>/dev/null || true
	@mkdir -p $(shell pwd)/_build
	@dune build --build-dir $(shell pwd)/_build/tele 
	@$(MAKE) TYPE=tele benchmark

unit-vs-hybrid: 
	@echo "unit-vs-hybrid"
	@rm -rf $(shell pwd)/_build/unit-vs-hybrid 2>/dev/null || true
	@mkdir -p $(shell pwd)/_build
	@dune build --build-dir $(shell pwd)/_build/unit-vs-hybrid 
	@$(MAKE) TYPE=unit-vs-hybrid benchmark

qiskit-hybrid: 
	@echo "qiskit-hybrid"
	@rm -rf $(shell pwd)/_build/qiskit-hybrid 2>/dev/null || true
	@mkdir -p $(shell pwd)/_build
	@dune build --build-dir $(shell pwd)/_build/qiskit-hybrid
	@$(MAKE) TYPE=qiskit-hybrid benchmark

owm-vs-qiskit: 
	@echo "owm-vs-qiskit"
	@rm -rf $(shell pwd)/_build/owm-vs-qiskit 2>/dev/null || true
	@mkdir -p $(shell pwd)/_build
	@dune build --build-dir $(shell pwd)/_build/owm-vs-qiskit
	@$(MAKE) TYPE=owm-vs-qiskit benchmark

owm-vs-tele: 
	@echo "owm-vs-tele"
	@rm -rf $(shell pwd)/_build/owm-vs-tele 2>/dev/null || true
	@mkdir -p $(shell pwd)/_build
	@dune build --build-dir $(shell pwd)/_build/owm-vs-tele
	@$(MAKE) TYPE=owm-vs-tele benchmark

veriqc: 
	@echo "veriqc"
	@rm -rf $(shell pwd)/_build/veriqc 2>/dev/null || true
	@mkdir -p $(shell pwd)/_build
	@dune build --build-dir $(shell pwd)/_build/veriqc
	@$(MAKE) TYPE=veriqc benchmark


all: benchmarks sanity

# Paper Examples

examples: ex3 ex4

ex3:
	python3 scripts/Example-3.py

ex4:
	python3 scripts/Example-4.py

# Docker Build

build:
	docker build -t sqbricks .

container:
	@docker rm -f sqbricks 2>/dev/null >/dev/null || true
	bash container.sh


## Docker Pull (Alternative to Build)

pull:
	docker pull jricc/sqbricks:latest

container-pull:
	@docker rm -f sqbricks 2>/dev/null >/dev/null || true
	bash container.sh --custom-image

# Container Start

start:
	docker start -ai sqbricks

