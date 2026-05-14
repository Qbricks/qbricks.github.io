#!/bin/bash

#  This file is part of SQbricks.
#
#  Copyright (C) 2022-2026
#  CEA (Commissariat à l'énergie atomique et aux énergies alternatives)
#  Université Paris-Saclay
#
#  you can redistribute it and/or modify it under the terms of the GNU
#  Lesser General Public License as published by the Free Software
#  Foundation, version 2.1.
#
#  It is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Lesser General Public License for more details.
#
#  See the GNU Lesser General Public License version 2.1
#  for more details (enclosed in the file licenses/LGPLv2.1).

debug="false"
version="$1"
sqbricks_only="false"

if [[ "$debug" == "true" ]]; then
	echo "-> version = $version"
fi

export DUNE_BUILD_DIR="$(pwd)/_build/$version"

# Memory limit 7go
ulimit -v 7340032

# Timeout 10min
ulimit -t 600

mkdir -p _tmp
mkdir -p "_tmp/$version"

if [ -z "$1" ]; then
	echo "Error: Please specify the function to be used."
	exit 1
fi

load_paths_and_print_header() {
	local path_file="$1"
	local header="$2"

	if [ -f "$path_file" ]; then
		mapfile -t path_originals < <(grep -v '^[[:space:]]*$' "$path_file")
		echo "$header"
		if [[ "$debug" == "true" ]]; then
			echo "-> path_originals = $path_originals"
		fi
	else
		echo "The script is running in the directory: $(pwd)" >&2
		echo "Error: the file $(basename "$path_file") is not found." >&2
		exit 1
	fi

}

case "$version" in
"qiskit-hybrid" | "tele" | "owm" | "qiskit-unit" | "owm-vs-tele" | "owm-vs-qiskit")
	load_paths_and_print_header "scripts/paths/paths_${version}.txt" \
		"Program;Tool;Version;Lift;Opt;CH;CS;CZ;CCZ;CCX;CU1;Gates;Time"
	;;
"sanity-unit" | "sanity-hybrid" | "sanity-partial" | "unit-vs-hybrid" | "veriqc")
	load_paths_and_print_header "scripts/paths/paths_${version}.txt" \
		"Program1;Program2;Tool;Version;Lift;Opt;CH;CS;CZ;CCZ;CCX;CU1;Gates;Time"
	;;
*)
	echo "Error paths : Unknown version : '$version'."
	exit 1
	;;
esac

# Boucle principale sur chaque fichier QASM
for path_original in "${path_originals[@]}"; do
	filename=$(basename -- "$path_original")
	filename_no_ext="${filename%.qasm}"

	# Fonction pour préparer les chemins de sortie
	prepare_paths() {
		case "$version" in
		"qiskit-hybrid" | "qiskit-unit")
			path_optimize="_tmp/$version/${filename_no_ext}_optimize.qasm"
			path_unitary="_tmp/$version/${filename_no_ext}_ium.qasm"
			path_optimize_unitary="_tmp/$version/${filename_no_ext}_optimize_ium.qasm"
			path_pyzx="_tmp/$version/${filename_no_ext}_pyzx.qasm"
			path_optimize_pyzx="_tmp/$version/${filename_no_ext}_optimize_pyzx.qasm"
			path_autoq="_tmp/$version/${filename_no_ext}_autoq.qasm"
			path_optimize_autoq="_tmp/$version/${filename_no_ext}_optimize_autoq.qasm"
			path_feynman="_tmp/$version/${filename_no_ext}_feynman.qc"
			path_optimize_feynman="_tmp/$version/${filename_no_ext}_optimize_feynman.qc"
			;;
		"sanity-hybrid" | "sanity-unit" | "sanity-partial" | "unit-vs-hybrid" | "veriqc")
			IFS=';' read -r path1 path2 <<<"$path_original"
			filename1=$(basename -- "$path1")
			filename2=$(basename -- "$path2")
			filename1_no_ext="${filename1%.qasm}"
			filename2_no_ext="${filename2%.qasm}"
			path1_unitary="_tmp/$version/${filename1_no_ext}_unitary.qasm"
			path2_unitary="_tmp/$version/${filename2_no_ext}_unitary.qasm"
			path1_ium="_tmp/$version/${filename1_no_ext}_ium.qasm"
			path2_ium="_tmp/$version/${filename2_no_ext}_ium.qasm"
			path1_pyzx="_tmp/$version/${filename1_no_ext}_pyzx.qasm"
			path2_pyzx="_tmp/$version/${filename2_no_ext}_pyzx.qasm"
			path1_autoq="_tmp/$version/${filename1_no_ext}_autoq.qasm"
			path2_autoq="_tmp/$version/${filename2_no_ext}_autoq.qasm"
			path1_feynman="_tmp/$version/${filename1_no_ext}_feynman.qc"
			path2_feynman="_tmp/$version/${filename2_no_ext}_feynman.qc"
			if [[ "$debug" == "true" ]]; then
				echo "-> path_original = <$path_original>"
				echo "-> path1 = <$path1>, path2 = <$path2>"
			fi
			;;
		"owm" | "tele")
			path_original_unitary="_tmp/$version/${filename_no_ext}_${version}_original_unitary.qasm"
			path_by_gates="_tmp/$version/${filename_no_ext}_${version}_by_gates.qasm"
			path_by_meas="_tmp/$version/${filename_no_ext}_${version}_by_meas.qasm"
			path_by_gates_ium="_tmp/$version/${filename_no_ext}_${version}_by_gates_ium.qasm"
			path_by_meas_ium="_tmp/$version/${filename_no_ext}_${version}_by_meas_ium.qasm"
			;;
		"owm-vs-tele")
			path_original_unitary="_tmp/$version/${filename_no_ext}_original_unitary.qasm"
			path_owm="_tmp/$version/${filename_no_ext}_${version}_owm.qasm"
			path_owm_ium="_tmp/$version/${filename_no_ext}_${version}_owm_ium.qasm"
			path_tele="_tmp/$version/${filename_no_ext}_${version}_tele.qasm"
			path_tele_ium="_tmp/$version/${filename_no_ext}_${version}_tele_ium.qasm"
			;;
		"owm-vs-qiskit")
			path_original_unitary="_tmp/$version/${filename_no_ext}_original_unitary.qasm"
			path_optimize="_tmp/$version/${filename_no_ext}_optimize.qasm"
			path_optimize_ium="_tmp/$version/${filename_no_ext}_optimize_ium.qasm"
			path_owm="_tmp/$version/${filename_no_ext}_${version}_owm.qasm"
			path_owm_ium="_tmp/$version/${filename_no_ext}_${version}_owm_ium.qasm"
			;;

		esac

	}

	test_equiv_feynman() {
		local nb_gate="$1"
		local filename="$2"
		local path1="$3"
		local path2="$4"
		local type="$5" # lift
		local version="$6"

		if result=$(tools/Feynman_"$version"/feynver "$path1" "$path2"); then
			result_sed=$(echo "$result" | sed -n 's/Equal (took \([^s]*\)s)/\1/p' | sed 's/\./,/')
			if [[ -z "$result_sed" ]]; then
				result_sed=$(echo "$result" | sed -n 's/Not equal (took \([^s]*\)s)/NE/p' | sed 's/\./,/')
				if [[ -z "$result_sed" ]]; then
					echo "$filename;Feynman;$version;${type};None;$nb_gate;NC"
				else
					echo "$filename;Feynman;$version;${type};None;$nb_gate;$result_sed"
				fi
			else
				echo "$filename;Feynman;$version;${type};None;$nb_gate;$result_sed"
			fi
		else
			echo "$filename;Feynman;$version;${type};None;$nb_gate;Err$?"
		fi
	}

	test_equiv_qcec() {
		local nb_gate="$1"
		local filename="$2"
		local path1="$3"
		local path2="$4"
		local type="$5"
		local dynamic="$6"
		local partial="$7"

		if [[ "$dynamic" == "" ]]; then
			if [[ "$partial" == "" ]]; then
				qcec_options="None"
			else
				qcec_options="$partial"
			fi
		else
			if [[ "$partial" == "" ]]; then
				qcec_options="$dynamic"
			else
				qcec_options="$dynamic,$partial"
			fi
		fi

		time=-1
		verification_type=""

		# Function to extract time and type of output
		extract_time_and_type() {
			local input_string="$1"

			# Use a regular expression to extract the number
			if [[ $input_string =~ ^[[:space:]]*([-+]?[0-9]+(\.[0-9]+)?([eE][-+]?[0-9]+)?) ]]; then
				time=$(echo "${BASH_REMATCH[1]}" | sed 's/\./,/')       # Extract number
				verification_type="${input_string:${#BASH_REMATCH[0]}}" # Remaining part of the chain
			else
				echo "test_qcec error"
			fi
		}

		# Execute command and capture output
		if
			if [[ "$debug" == "true" ]]; then
				echo "-> python3 scripts/mqt-qcec-qiskit.py $path1 $path2 $dynamic $partial"
			fi
			result=$(python3 scripts/mqt-qcec-qiskit.py "$path1" "$path2" "$dynamic" "$partial")
		then
			# If the command succeeds, extract time and type
			extract_time_and_type "$result"
			if [[ "${verification_type}" == "NE" || "${verification_type}" == "NC" ]]; then
				echo "$filename;QCEC;1.8.1;${type};$qcec_options;$nb_gate;${verification_type}"
			else
				if [[ ${verification_type} == "" ]]; then
					echo "$filename;QCEC;1.8.1;${type};$qcec_options;$nb_gate;$time"
				else
					echo "$filename;QCEC;1.8.1;${type};${verification_type},$qcec_options;$nb_gate;$time"
				fi
			fi
		else
			echo "$filename;QCEC;1.8.1;${type};$qcec_options;$nb_gate;Err$?"
		fi

	}

	test_equiv_pyzx() {
		local filename="$2"
		local nb_gate="$1"
		local path1="$3"
		local path2="$4"
		local type="$5"

		if result=$(python3 scripts/pyzx_verify.py "$path1" "$path2"); then
			result=$(echo "$result" | sed 's/\./,/g')
			echo "$filename;PyZX;0.9.0;${type};None;$nb_gate;$result"
		else
			echo "$filename;PyZX;0.9.0;${type};None;$nb_gate;Err$?"
		fi
	}

	test_equiv_autoq() {
		local filename="$2"
		local nb_gate="$1"
		local path1="$3"
		local path2="$4"
		local type="$5"
		local version="$6" # POPL25 | 2.0

		if result=$(./tools/AutoQ-"$version"/autoq eq "$path1" "$path2"); then
			extracted=$(echo "$result" | awk -F '[][]' '{print ($2=="equal"?$4:$2)}' | sed 's/s$//')
			if [[ "$extracted" == "unequal" ]]; then
				echo "$filename;AutoQ;$version;${type};None;$nb_gate;NE"
			else
				# Checks if argument is in correct format
				if [[ $extracted =~ ^[0-9]+m[0-9]+$ ]]; then
					# Extrait les minutes et les secondes
					minutes=${extracted%m*}
					seconds=${extracted#*m}
					# Converts minutes to seconds and adds seconds
					total_seconds=$((minutes * 60 + seconds))
					total_seconds=$(
						echo "$total_seconds" | sed 's/\./,/g'
					)
					echo "$filename;AutoQ;$version;${type};None;$nb_gate;$total_seconds"
				else
					if [[ $extracted = "ERROR" ]]; then
						echo "$filename;AutoQ;$version;${type};None;$nb_gate;Err"
					else
						extracted=$(
							echo "$extracted" | sed 's/\./,/g'
						)
						echo "$filename;AutoQ;$version;${type};None;$nb_gate;$extracted"
					fi
				fi
			fi
		else
			echo "$filename;AutoQ;$version;${type};None;$nb_gate;Err$?"
		fi
	}

	# SQbricksVerif (Partial-Unitary-Equivalence)
	test_equiv_sqbricks() {
		local nb_gate="$1"
		local filename="$2"
		local path1="$3"
		local path2="$4"
		local lift="$5"
		local inputs1="${6:-}"
		local inputs2="${7:-}"
		local outputs1="${8:-}"
		local outputs2="${9:-}"
		local meas1="${10:-}"
		local meas2="${11:-}"

		# Helper function to run the equivalence check and print results
		run_equiv() {
			local algo="$1"  # Algorithm: s (sequence) or p (parallel)
			local equiv="$2" # Equivalence type: s (sub-circuit) | g (global-phase)
			local label="$3" # Label for output (Sequence, Parallel)

			if [[ "$debug" == "true" ]]; then
				echo "dune exec -- ./bin/main.exe -sqv $algo $equiv $path1 $path2 $inputs1 $inputs2 $outputs1 $outputs2 $meas1 $meas2 "
			fi

			# Run the command, capture output, replace '.' with ',' for CSV compatibility
			local stdout
			local stderr
			stdout=$(dune exec -- ./bin/main.exe -sqv "$algo" "$equiv" \
				"$path1" "$path2" \
				"$inputs1" "$inputs2" "$outputs1" "$outputs2" \
				"$meas1" "$meas2" 2> >(
					stderr=$(cat)
					typeset -p stderr >&2
				))

			local status=$?

			if [[ $status -eq 0 ]]; then
				# CSV cleaning
				stdout=$(echo "$stdout" | sed 's/\./,/')
				echo "$filename;SQbricks;2025;$lift;$label;$nb_gate;$stdout"
			else
				# Check if stderr contents OCaml message
				if echo "$stderr" | grep -q "allocation failure during minor GC"; then
					echo "$filename;SQbricks;2025;$lift;$label;$nb_gate;OutOfMemory"
				else
					echo "$filename;SQbricks;2025;$lift;$label;$nb_gate;Err$status"
				fi
			fi
		}

		# Run Sequence-Equivalence (Mix, or DisFree)
		if [[ "$version" != "owm-vs-tele" && "$version" != "owm-vs-owm-qiskit" ]]; then
			run_equiv seq s "Sequence"
		fi

		# Run Parallel-Equivalence
		run_equiv par s "Parallel"
	}

	# Function: test_unit
	# Purpose:
	#   Run multiple equivalence verification tools (SQbricks, QCEC, Feynman, PyZX, AutoQ)
	#   on two given QASM circuits. Each backend is tested independently, and results
	#   are printed in CSV format. Conversion errors are reported as "ErrConv".
	#
	# Arguments:
	#   1  - path to first QASM file
	#   2  - path to second QASM file
	#   3  - path to first Feynman output file
	#   4  - path to second Feynman output file
	#   5  - path to first PyZX output file
	#   6  - path to second PyZX output file
	#   7  - path to first AutoQ output file
	#   8  - path to second AutoQ output file
	#   9  - number of gates
	#   10 - circuit name (identifier for reporting)
	test_unit() {
		local path1="$1"
		local path2="$2"
		local path1_feynman="$3"
		local path2_feynman="$4"
		local path1_pyzx="$5"
		local path2_pyzx="$6"
		local path1_autoq="$7"
		local path2_autoq="$8"
		local nb_gate="$9"
		local name="${10}"

		# If only SQbricks should be tested
		if [[ "$sqbricks_only" == "true" ]]; then
			test_equiv_sqbricks "$nb_gate" "$name" "$path1" "$path2" "standalone"
		else
			# Run QCEC equivalence check (standalone, No Deferred Measurement, No Partial Equivalence)
			test_equiv_qcec "$nb_gate" "$name" "$path1" "$path2" "standalone" "NoDM" "NoPartial"

			# Run SQbricks equivalence check
			test_equiv_sqbricks "$nb_gate" "$name" "$path1" "$path2" "standalone"

			# Convert to Feynman format and run equivalence checks with two different versions
			if dune exec -- ./bin/main.exe -qasm_to_feynman "$path1" "$path1_feynman" &&
				dune exec -- ./bin/main.exe -qasm_to_feynman "$path2" "$path2_feynman"; then
				test_equiv_feynman "$nb_gate" "$name" "$path1_feynman" "$path2_feynman" "standalone" "28-11-2024"
				test_equiv_feynman "$nb_gate" "$name" "$path1_feynman" "$path2_feynman" "standalone" "13-10-2022"
			else
				echo "$name;Feynman;lifting;;;;;;;;ErrConv"
			fi

			# Convert to PyZX format and run equivalence check
			if dune exec -- ./bin/main.exe -qasm_to_pyzx "$path1" "$path1_pyzx" &&
				dune exec -- ./bin/main.exe -qasm_to_pyzx "$path2" "$path2_pyzx"; then
				test_equiv_pyzx "$nb_gate" "$name" "$path1_pyzx" "$path2_pyzx" "standalone"
			else
				echo "$name;PyZX;standalone;;;;;;;;ErrConv"
			fi

			# Convert to AutoQ format and run equivalence check (POPL25 version)
			if dune exec -- ./bin/main.exe -qasm_to_autoq "$path1" "$path1_autoq" &&
				dune exec -- ./bin/main.exe -qasm_to_autoq "$path2" "$path2_autoq"; then
				test_equiv_autoq "$nb_gate" "$name" "$path1_autoq" "$path2_autoq" "standalone" "POPL25"
			else
				echo "$name;AutoQ;lifting;;;;;;;;ErrConv"
			fi

			# Convert to AutoQ format and run equivalence check (2.0 version)
			if dune exec -- ./bin/main.exe -qasm_to_autoq "$path1" "$path1_autoq" &&
				dune exec -- ./bin/main.exe -qasm_to_autoq "$path2" "$path2_autoq"; then
				test_equiv_autoq "$nb_gate" "$name" "$path1_autoq" "$path2_autoq" "standalone" "2.0"
			else
				echo "$name;AutoQ;standalone;;;;;;;;ErrConv"
			fi
		fi
	}

	# Function: test_hybrid
	# Purpose:
	#   Run hybrid equivalence verification on two QASM circuits using multiple backends
	#   (QCEC, SQbricks, Feynman, PyZX, AutoQ). Supports both standalone and lifting modes.
	#   Conversion errors are reported as "ErrConv".
	#
	# Arguments:
	#   1  - path to first QASM file
	#   2  - path to second QASM file
	#   3  - path to first IUM (Intermediate Unitary Model) file
	#   4  - path to second IUM file
	#   5  - path to first Feynman output file
	#   6  - path to second Feynman output file
	#   7  - path to first PyZX output file
	#   8  - path to second PyZX output file
	#   9  - path to first AutoQ output file
	#   10 - path to second AutoQ output file
	#   11 - number of gates
	#   12 - circuit name (identifier for reporting)
	test_hybrid() {
		local path1="$1"
		local path2="$2"
		local path1_ium="$3"
		local path2_ium="$4"
		local path1_feynman="$5"
		local path2_feynman="$6"
		local path1_pyzx="$7"
		local path2_pyzx="$8"
		local path1_autoq="$9"
		local path2_autoq="${10}"
		local nb_gate="${11}"
		local name="${12}"

		# Run SQbricks equivalence check (only if not restricted to sqbricks-only mode)
		if [[ "$sqbricks_only" == "true" ]]; then
			test_equiv_sqbricks "$nb_gate" "$name" "$path1_ium" "$path2_ium" "lifting"
		else
			(

				# Determine QCEC option (Partial Equivalence: OE or No Partial Equivalence: NoOE) depending on version
				if [[ "$version" == "sanity-hybrid" || "$version" == "veriqc" ]]; then
					oe="OE"
				else
					oe="NoOE"
				fi

				# Debug output for QCEC command
				if [[ "$debug" == "true" ]]; then
					echo "-> test_equiv_qcec $nb_gate $name $path1 $path2 standalone DM $oe"
				fi

				# Run QCEC equivalence checks (standalone mode, Deferred Measurement enabled, with/without Partial Eqiuvalence)
				test_equiv_qcec "$nb_gate" "$name" "$path1" "$path2" "standalone" "DM" "OE"
				test_equiv_qcec "$nb_gate" "$name" "$path1" "$path2" "standalone" "DM" "NoOE"

				# Run QCEC equivalence check in lifting mode (using IUM representation)
				test_equiv_qcec "$nb_gate" "$name" "$path1_ium" "$path2_ium" "lifting" "$dynamic" "$oe"

				# Run SQbricks equivalence check
				test_equiv_sqbricks "$nb_gate" "$name" "$path1_ium" "$path2_ium" "lifting"

				# Convert to Feynman format and run equivalence checks (two versions)
				if dune exec -- ./bin/main.exe -qasm_to_feynman "$path1_ium" "$path1_feynman" &&
					dune exec -- ./bin/main.exe -qasm_to_feynman "$path2_ium" "$path2_feynman"; then
					test_equiv_feynman "$nb_gate" "$name" "$path1_feynman" "$path2_feynman" "lifting" "28-11-2024"
					test_equiv_feynman "$nb_gate" "$name" "$path1_feynman" "$path2_feynman" "lifting" "13-10-2022"
				else
					echo "$name;Feynman;,lifting;;;;;;;;ErrConv"
				fi

				# Convert to PyZX format and run equivalence check
				if dune exec -- ./bin/main.exe -qasm_to_pyzx "$path1_ium" "$path1_pyzx" &&
					dune exec -- ./bin/main.exe -qasm_to_pyzx "$path2_ium" "$path2_pyzx"; then
					test_equiv_pyzx "$nb_gate" "$name" "$path1_pyzx" "$path2_pyzx" "lifting"
				else
					echo "$name;PyZX;lifting;;;;;;;;ErrConv"
				fi

				# Convert to AutoQ format and run equivalence checks (two versions: 2.0 and POPL25)
				if dune exec -- ./bin/main.exe -qasm_to_autoq "$path1_ium" "$path1_autoq" &&
					dune exec -- ./bin/main.exe -qasm_to_autoq "$path2_ium" "$path2_autoq"; then
					test_equiv_autoq "$nb_gate" "$name" "$path1_autoq" "$path2_autoq" "lifting" "2.0"
					test_equiv_autoq "$nb_gate" "$name" "$path1_autoq" "$path2_autoq" "lifting" "POPL25"
				else
					echo "$name;AutoQ;lifting;;;;;;;;ErrConv"
				fi
			)
		fi
	}

	# Function: test_partial
	# Purpose:
	#   Run partial equivalence verification using SQbricks on two QASM circuits
	#   represented in IUM (Initialisations Unitary Measurements) form. This mode allows
	#   checking equivalence only on specified subsets of inputs, outputs, and
	#   measurement qubits.
	#
	# Arguments:
	#   1  - path to first IUM file
	#   2  - path to second IUM file
	#   3  - list of input qubits for circuit 1
	#   4  - list of input qubits for circuit 2
	#   5  - list of output qubits for circuit 1
	#   6  - list of output qubits for circuit 2
	#   7  - list of measurement qubits for circuit 1
	#   8  - list of measurement qubits for circuit 2
	#   9  - number of gates
	#   10 - circuit name (identifier for reporting)
	test_partial() {
		local path1_ium="$1"
		local path2_ium="$2"
		local inputs1="$3"
		local inputs2="$4"
		local outputs1="$5"
		local outputs2="$6"
		local meas1="$7"
		local meas2="$8"
		local nb_gate="$9"
		local name="${10}"

		# Debug output: show the exact SQbricks command that will be executed
		if [[ "$debug" == "true" ]]; then
			echo "test_equiv_sqbricks $nb_gate $name $path1_ium $path2_ium lifting $inputs1 $inputs2 $outputs1 $outputs2 $meas1 $meas2"
		fi

		# Run SQbricks partial equivalence check in lifting mode
		test_equiv_sqbricks "$nb_gate" "$name" \
			"$path1_ium" "$path2_ium" "lifting" \
			"$inputs1" "$inputs2" "$outputs1" "$outputs2" "$meas1" "$meas2"
	}

	tests_equiv() {
		local path1="$1"
		local path2="$2"
		local path1_ium="$3"
		local path2_ium="$4"
		local path1_feynman="$5"
		local path2_feynman="$6"
		local path1_pyzx="$7"
		local path2_pyzx="$8"
		local path1_autoq="$9"
		local path2_autoq="${10}"
		local name1="${11:-"${filename_no_ext}"}"
		local name2="${12:-""}"
		local inputs1="${13}"
		local inputs2="${14}"
		local outputs1="${15}"
		local outputs2="${16}"
		local meas1="${17}"
		local meas2="${18}"

		if [[ "$name2" == "" ]]; then
			name="$name1"
		else
			name="$name1;$name2"
		fi

		if [[ "$version" == "qiskit-unit" || "$version" == "sanity-unit" ]]; then
			nb_gate=$(dune exec -- ./bin/main.exe -nb_gates_csv "$path1" "$path2")
			test_unit "$path1" "$path2" "$path1_feynman" "$path2_feynman" "$path1_pyzx" "$path2_pyzx" "$path1_autoq" "$path2_autoq" "$nb_gate" "$name"
		else
			if [[ "$version" == "qiskit-hybrid" || "$version" == "sanity-hybrid" || "$version" == "unit-vs-hybrid" || "$version" == "veriqc" ]]; then
				nb_gate=$(dune exec -- ./bin/main.exe -nb_gates_csv "$path1_ium" "$path2_ium")
				if [[ "$debug" == "true" ]]; then
					echo "-> test_hybrid $path1 $path2 $path1_ium $path2_ium $path1_feynman $path2_feynman $path1_pyzx $path2_pyzx $path1_autoq $path2_autoq $nb_gate $name"
				fi
				test_hybrid "$path1" "$path2" "$path1_ium" "$path2_ium" "$path1_feynman" "$path2_feynman" "$path1_pyzx" "$path2_pyzx" "$path1_autoq" "$path2_autoq" "$nb_gate" "$name"
			else
				if [[ "$version" == "tele" || "$version" == "owm" || "$version" == "sanity-partial" || "$version" == "owm-vs-tele" || "$version" == "owm-vs-qiskit" || "$version" == "owm-vs-owm-qiskit" ]]; then
					nb_gate=$(dune exec -- ./bin/main.exe -nb_gates_csv "$path1_ium" "$path2_ium")
					if [[ "$debug" == "true" ]]; then
						echo "-> test_partial $path1_ium $path2_ium $inputs1 $inputs2 $outputs1 $outputs2 $meas1 $meas2 $nb_gate $name"
					fi
					test_partial "$path1_ium" "$path2_ium" "$inputs1" "$inputs2" "$outputs1" "$outputs2" "$meas1" "$meas2" "$nb_gate" "$name"
				else
					echo "version $version unknown"
				fi
			fi
		fi
	}

	prepare_paths "$version"

	if [ -f "sqbricks-py-env/bin/activate" ]; then
		source sqbricks-py-env/bin/activate
	fi

	case "$version" in
	"qiskit-hybrid")
		if python3 scripts/qiskit-tr.py "$path_original" "$path_optimize"; then
			if (
				_=$(dune exec -- ./bin/main.exe -sql u "$path_original" "$path_unitary") &&
					_=$(dune exec -- ./bin/main.exe -sql u "$path_optimize" "$path_optimize_unitary")
			); then
				tests_equiv "$path_original" "$path_optimize" "$path_unitary" "$path_optimize_unitary" "$path_feynman" "$path_optimize_feynman" "$path_pyzx" "$path_optimize_pyzx" "$path_autoq" "$path_optimize_autoq"
			else
				echo "$filename_no_ext;SQbricks;;;;;;;;;ErrConv"
			fi
		else
			echo "$filename_no_ext;Qiskit;;;;;;;;;ErrOpt"
		fi
		echo ""
		;;
	"qiskit-unit")
		if python3 scripts/qiskit-tr.py "$path_original" "$path_optimize"; then
			tests_equiv "$path_original" "$path_optimize" "" "" "$path_feynman" "$path_optimize_feynman" "$path_pyzx" "$path_optimize_pyzx" "$path_autoq" "$path_optimize_autoq"
		else
			echo "$filename_no_ext;Qiskit;;;;;;;;;ErrOpt"
		fi
		echo ""
		;;

	"sanity-unit")
		if (
			_=$(dune exec -- ./bin/main.exe -sql ium "$path1" "$path1_ium") &&
				_=$(dune exec -- ./bin/main.exe -sql ium "$path2" "$path2_ium")
		); then
			tests_equiv "$path1" "$path2" "$path1_ium" "$path2_ium" "$path1_feynman" "$path2_feynman" "$path1_pyzx" "$path2_pyzx" "$path1_autoq" "$path2_autoq" "${filename1_no_ext}" "${filename2_no_ext}"
		else
			echo "$filename_no_ext;SQbricks;;;;;;;;;;ErrConv"
		fi
		echo ""
		;;

	"sanity-hybrid" | "sanity-partial" | "unit-vs-hybrid" | "veriqc")
		if (
			_=$(dune exec -- ./bin/main.exe -sql u "$path1" "$path1_unitary") &&
				_=$(dune exec -- ./bin/main.exe -sql u "$path2" "$path2_unitary")
		); then
			if [[ "$debug" == "true" ]]; then
				echo "-> tests_equiv $path1 $path2 $path1_unitary $path2_unitary $path1_feynman $path2_feynman $path1_pyzx $path2_pyzx $path1_autoq $path2_autoq ${filename1_no_ext} ${filename2_no_ext}"
			fi
			tests_equiv "$path1" "$path2" "$path1_unitary" "$path2_unitary" "$path1_feynman" "$path2_feynman" "$path1_pyzx" "$path2_pyzx" "$path1_autoq" "$path2_autoq" "${filename1_no_ext}" "${filename2_no_ext}"
		else
			echo "$filename_no_ext;SQbricks;;;;;;;;;;ErrConv"
		fi
		echo ""
		;;

	"owm" | "tele")
		if
			if [[ "$debug" == "true" ]]; then
				echo "dune exec -- ./bin/main.exe -sql u $path_original $path_original_unitary"
			fi &&
				_=$(dune exec -- ./bin/main.exe -sql u "$path_original" "$path_original_unitary") &&
				if [[ "$debug" == "true" ]]; then
					echo "dune exec -- ./bin/main.exe -qasm_to_${version} $path_original_unitary $path_by_meas false"
				fi &&
				# OWM or Tele transformation and retrieval of input and output lists
				result=$(dune exec -- ./bin/main.exe -qasm_to_${version} "$path_original_unitary" "$path_by_meas" "false") &&
				if [[ "$debug" == "true" ]]; then
					echo "dune exec -- ./bin/main.exe -sql u $path_by_meas $path_by_meas_ium"
				fi &&
				# DM returns a list of measurement
				meas1=$(dune exec -- ./bin/main.exe -sql u "$path_by_meas" "$path_by_meas_ium")
		then
			inputs=$(echo "$result" | sed -E 's/,.*//')
			outputs=$(echo "$result" | sed -E 's/.*,//')
			tests_equiv "" "" "$path_by_meas_ium" "$path_original_unitary" "" "" "" "" "" "" "${filename_no_ext}" "" "$inputs" "[]" "$outputs" "[]" "$meas1" "[]"
		else
			echo "$filename_no_ext;SQbricks;;;;;;;;;ErrConv"
		fi
		echo ""

		;;

	"owm-vs-tele")
		if
			_=$(dune exec -- ./bin/main.exe -sql u "$path_original" "$path_original_unitary") &&
				result_owm=$(dune exec -- ./bin/main.exe -qasm_to_owm "$path_original_unitary" "$path_owm" "false") &&
				result_tele=$(dune exec -- ./bin/main.exe -qasm_to_tele "$path_original_unitary" "$path_tele" "false") &&
				meas1=$(dune exec -- ./bin/main.exe -sql u "$path_owm" "$path_owm_ium") &&
				meas2=$(dune exec -- ./bin/main.exe -sql u "$path_tele" "$path_tele_ium")
		then
			inputs1=$(echo "$result_owm" | sed -E 's/,.*//')
			inputs2=$(echo "$result_tele" | sed -E 's/,.*//')
			outputs1=$(echo "$result_owm" | sed -E 's/.*,//')
			outputs2=$(echo "$result_tele" | sed -E 's/.*,//')
			if ("$debug" == "true"); then
				echo "tests_equiv $path_owm_ium $path_tele_ium ${filename_no_ext} $inputs1 $inputs2 $outputs1 $outputs2"
			fi
			tests_equiv "" "" "$path_owm_ium" "$path_tele_ium" "" "" "" "" "" "" "${filename_no_ext}" "" "$inputs1" "$inputs2" "$outputs1" "$outputs2" "$meas1" "$meas2"
		else
			echo "$filename_no_ext;SQbricks;;;;;;;;;ErrConv"
		fi
		echo ""

		;;

	"owm-vs-owm-qiskit")
		if
			python3 scripts/qiskit-tr.py "$path_original" "$path_optimize" &&
				# Unitarization
				result_owm=$(dune exec -- ./bin/main.exe -qasm_to_owm "$path_original" "$path_owm" "false") &&
				result_opt_owm=$(dune exec -- ./bin/main.exe -qasm_to_owm "$path_optimize" "$path_opt_owm" "false") &&
				meas1=$(dune exec -- ./bin/main.exe -sql u "$path_owm" "$path_owm_ium") &&
				meas2=$(dune exec -- ./bin/main.exe -sql u "$path_opt_owm" "$path_opt_owm_ium")
		then
			inputs1=$(echo "$result_owm" | sed -E 's/,.*//')
			inputs2=$(echo "$result_opt_owm" | sed -E 's/,.*//')
			outputs1=$(echo "$result_owm" | sed -E 's/.*,//')
			outputs2=$(echo "$result_opt_owm" | sed -E 's/.*,//')
			if [[ "$debug" == "true" ]]; then
				echo "tests_equiv $path_owm_ium $path_opt_owm_ium ${filename_no_ext} $inputs1 $inputs2 $outputs1 $outputs2"
			fi
			tests_equiv "" "" "$path_owm_ium" "$path_opt_owm_ium" "" "" "" "" "" "" "${filename_no_ext}" "" "$inputs1" "$inputs2" "$outputs1" "$outputs2" "$meas1" "$meas2"
		else
			echo "$filename_no_ext;SQbricks;;;;;;;;;ErrConv"
		fi
		echo ""

		;;

	"owm-vs-qiskit")
		if
			python3 scripts/qiskit-tr.py "$path_original" "$path_optimize" &&
				_=$(dune exec -- ./bin/main.exe -sql u "$path_original" "$path_original_unitary") &&
				result_owm=$(dune exec -- ./bin/main.exe -qasm_to_owm "$path_original_unitary" "$path_owm" "false") &&
				_=$(dune exec -- ./bin/main.exe -sql u "$path_optimize" "$path_optimize_ium") &&
				meas1=$(dune exec -- ./bin/main.exe -sql u "$path_owm" "$path_owm_ium")
		then
			inputs1=$(echo "$result_owm" | sed -E 's/,.*//')
			outputs1=$(echo "$result_owm" | sed -E 's/.*,//')
			tests_equiv "" "" "$path_owm_ium" "$path_optimize_ium" "" "" "" "" "" "" "${filename_no_ext}" "" "$inputs1" "" "$outputs1" "" "$meas1" ""
		else
			echo "$filename_no_ext;SQbricks;;;;;;;;;ErrConv"
		fi
		echo ""

		;;

	*)
		echo "Error : unknown version '$version'."
		exit 1
		;;
	esac

done
